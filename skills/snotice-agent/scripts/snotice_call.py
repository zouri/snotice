#!/usr/bin/env python3
"""Minimal SNotice API helper for skill workflows."""

from __future__ import annotations

import argparse
import json
import urllib.error
import urllib.request
from typing import Any


def parse_json(text: str) -> Any:
    if not text.strip():
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return text


def call_api(
    base_url: str,
    timeout: float,
    method: str,
    path: str,
    payload: dict[str, Any] | None = None,
) -> tuple[int, Any, str]:
    url = f"{base_url.rstrip('/')}{path}"
    data = None
    headers = {"Accept": "application/json"}

    if payload is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")

    req = urllib.request.Request(url=url, data=data, method=method, headers=headers)

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            return resp.status, parse_json(raw), raw
    except urllib.error.HTTPError as err:
        raw = err.read().decode("utf-8", errors="replace")
        return err.code, parse_json(raw), raw


def print_result(status: int, body: Any, raw: str) -> None:
    print(f"HTTP {status}")
    if isinstance(body, (dict, list)):
        print(json.dumps(body, ensure_ascii=False, indent=2))
    elif body is None:
        print("<empty>")
    else:
        print(raw)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Call local SNotice API")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8642)
    parser.add_argument("--timeout", type=float, default=5.0)

    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("status")
    sub.add_parser("config-get")

    notify = sub.add_parser("notify")
    notify.add_argument("--title", required=True)
    notify.add_argument("--message", default="")
    notify.add_argument("--body", default="", help=argparse.SUPPRESS)
    notify.add_argument("--priority", default="normal")
    notify.add_argument("--category", default="")
    notify.add_argument("--flash-color", default="")
    notify.add_argument("--flash-duration", type=int, default=0)
    notify.add_argument("--edge-width", type=float, default=0)
    notify.add_argument("--edge-opacity", type=float, default=-1)
    notify.add_argument("--edge-repeat", type=int, default=0)
    notify.add_argument("--barrage-color", default="")
    notify.add_argument("--barrage-duration", type=int, default=0)
    notify.add_argument("--barrage-speed", type=float, default=0)
    notify.add_argument("--barrage-font-size", type=float, default=0)
    notify.add_argument("--barrage-lane", default="")
    notify.add_argument("--barrage-repeat", type=int, default=0)

    return parser


def main() -> int:
    args = build_parser().parse_args()
    base_url = f"http://{args.host}:{args.port}"

    if args.command == "status":
        status, body, raw = call_api(base_url, args.timeout, "GET", "/api/status")
        print_result(status, body, raw)
        return 0 if 200 <= status < 300 else 1

    if args.command == "config-get":
        request_payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {"name": "snotice_get_config", "arguments": {}},
        }
        status, body, raw = call_api(
            base_url,
            args.timeout,
            "POST",
            "/api/mcp",
            request_payload,
        )
        if isinstance(body, dict):
            result = body.get("result")
            if isinstance(result, dict):
                structured = result.get("structuredContent")
                if isinstance(structured, dict):
                    maybe_body = structured.get("body")
                    if isinstance(maybe_body, dict):
                        body = maybe_body
        print_result(status, body, raw)
        return 0 if 200 <= status < 300 else 1

    payload: dict[str, Any] = {
        "title": args.title,
        "message": args.message or args.body,
        "priority": args.priority,
    }

    if args.category:
        payload["category"] = args.category
    if args.flash_color:
        payload["flashColor"] = args.flash_color
    if args.flash_duration > 0:
        payload["flashDuration"] = args.flash_duration
    if args.edge_width > 0:
        payload["edgeWidth"] = args.edge_width
    if args.edge_opacity >= 0:
        payload["edgeOpacity"] = args.edge_opacity
    if args.edge_repeat > 0:
        payload["edgeRepeat"] = args.edge_repeat
    if args.barrage_color:
        payload["barrageColor"] = args.barrage_color
    if args.barrage_duration > 0:
        payload["barrageDuration"] = args.barrage_duration
    if args.barrage_speed > 0:
        payload["barrageSpeed"] = args.barrage_speed
    if args.barrage_font_size > 0:
        payload["barrageFontSize"] = args.barrage_font_size
    if args.barrage_lane:
        payload["barrageLane"] = args.barrage_lane
    if args.barrage_repeat > 0:
        payload["barrageRepeat"] = args.barrage_repeat

    status, body, raw = call_api(base_url, args.timeout, "POST", "/api/notify", payload)
    print_result(status, body, raw)
    return 0 if 200 <= status < 300 else 1


if __name__ == "__main__":
    raise SystemExit(main())
