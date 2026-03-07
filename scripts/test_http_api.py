#!/usr/bin/env python3
"""SNotice HTTP API tester (no third-party dependencies)."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any


@dataclass
class ApiResult:
    status: int
    body: Any
    raw: str


class SNoticeApiClient:
    def __init__(self, base_url: str, timeout: float) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def request(
        self, method: str, path: str, payload: dict[str, Any] | None = None
    ) -> ApiResult:
        url = f"{self.base_url}{path}"
        data: bytes | None = None
        headers = {"Accept": "application/json"}

        if payload is not None:
            headers["Content-Type"] = "application/json"
            data = json.dumps(payload, ensure_ascii=False).encode("utf-8")

        req = urllib.request.Request(url=url, data=data, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                raw = resp.read().decode("utf-8", errors="replace")
                return ApiResult(status=resp.status, body=self._parse_json(raw), raw=raw)
        except urllib.error.HTTPError as err:
            raw = err.read().decode("utf-8", errors="replace")
            return ApiResult(status=err.code, body=self._parse_json(raw), raw=raw)
        except urllib.error.URLError as err:
            raise RuntimeError(f"request failed: {err.reason}") from err

    @staticmethod
    def _parse_json(text: str) -> Any:
        if not text.strip():
            return None
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return text


def print_result(title: str, result: ApiResult) -> None:
    print(f"\n=== {title} ===")
    print(f"HTTP {result.status}")
    if isinstance(result.body, (dict, list)):
        print(json.dumps(result.body, ensure_ascii=False, indent=2))
    elif result.body is None:
        print("<empty>")
    else:
        print(result.raw)


def build_notify_payload(args: argparse.Namespace) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "title": args.title,
        "body": args.body,
        "priority": args.priority,
    }

    if args.mode == "flash_full":
        payload["category"] = "flash_full"
        payload["flashColor"] = args.flash_color
        payload["flashDuration"] = args.flash_duration
    elif args.mode == "flash_edge":
        payload["category"] = "flash_edge"
        payload["flashColor"] = args.flash_color
        payload["flashDuration"] = args.flash_duration
        payload["edgeWidth"] = args.edge_width
        payload["edgeOpacity"] = args.edge_opacity
        payload["edgeRepeat"] = args.edge_repeat

    if args.extra_json:
        try:
            extra = json.loads(args.extra_json)
        except json.JSONDecodeError as err:
            raise ValueError(f"--extra-json is not valid JSON: {err}") from err
        if not isinstance(extra, dict):
            raise ValueError("--extra-json must be a JSON object")
        payload.update(extra)

    return payload


def cmd_status(client: SNoticeApiClient, _args: argparse.Namespace) -> int:
    result = client.request("GET", "/api/status")
    print_result("GET /api/status", result)
    return 0 if 200 <= result.status < 300 else 1


def cmd_config_get(client: SNoticeApiClient, _args: argparse.Namespace) -> int:
    result = client.request("GET", "/api/config")
    print_result("GET /api/config", result)
    return 0 if 200 <= result.status < 300 else 1


def cmd_config_set(client: SNoticeApiClient, args: argparse.Namespace) -> int:
    try:
        payload = json.loads(args.json)
    except json.JSONDecodeError as err:
        print(f"invalid --json: {err}", file=sys.stderr)
        return 2

    if not isinstance(payload, dict):
        print("--json must be a JSON object", file=sys.stderr)
        return 2

    result = client.request("POST", "/api/config", payload)
    print_result("POST /api/config", result)
    return 0 if 200 <= result.status < 300 else 1


def cmd_notify(client: SNoticeApiClient, args: argparse.Namespace) -> int:
    try:
        payload = build_notify_payload(args)
    except ValueError as err:
        print(err, file=sys.stderr)
        return 2

    print("\nPayload:")
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    result = client.request("POST", "/api/notify", payload)
    print_result("POST /api/notify", result)
    return 0 if 200 <= result.status < 300 else 1


def cmd_smoke(client: SNoticeApiClient, args: argparse.Namespace) -> int:
    failures = 0

    status_result = client.request("GET", "/api/status")
    print_result("GET /api/status", status_result)
    if not (200 <= status_result.status < 300):
        failures += 1

    normal_payload = {
        "title": "Smoke Test - Notification",
        "body": "Normal notification from test_http_api.py",
        "priority": "normal",
    }
    normal_result = client.request("POST", "/api/notify", normal_payload)
    print_result("POST /api/notify (normal)", normal_result)
    if not (200 <= normal_result.status < 300):
        failures += 1

    if args.include_edge:
        edge_payload = {
            "title": "Smoke Test - Edge",
            "body": "Edge lighting from test_http_api.py",
            "category": "flash_edge",
            "flashColor": args.flash_color,
            "flashDuration": args.flash_duration,
            "edgeWidth": args.edge_width,
            "edgeOpacity": args.edge_opacity,
            "edgeRepeat": args.edge_repeat,
        }
        edge_result = client.request("POST", "/api/notify", edge_payload)
        print_result("POST /api/notify (edge)", edge_result)
        if not (200 <= edge_result.status < 300):
            failures += 1

    return 1 if failures else 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Test SNotice HTTP API endpoints.",
    )
    parser.add_argument("--host", default="127.0.0.1", help="Server host (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=8642, help="Server port (default: 8642)")
    parser.add_argument(
        "--timeout",
        type=float,
        default=5.0,
        help="Request timeout in seconds (default: 5)",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("status", help="Call GET /api/status")
    subparsers.add_parser("config-get", help="Call GET /api/config")

    config_set = subparsers.add_parser("config-set", help="Call POST /api/config")
    config_set.add_argument(
        "--json",
        required=True,
        help='JSON object string, e.g. \'{"port":8642,"allowedIPs":[],"autoStart":false}\'',
    )

    notify = subparsers.add_parser("notify", help="Call POST /api/notify")
    notify.add_argument(
        "--mode",
        choices=[
            "normal",
            "flash_full",
            "flash_edge",
        ],
        default="normal",
        help="Notification mode (default: normal)",
    )
    notify.add_argument("--title", default="Test Notification", help="Notification title")
    notify.add_argument("--body", default="Sent from test_http_api.py", help="Notification body")
    notify.add_argument(
        "--priority",
        default="normal",
        help="Priority field value (default: normal)",
    )
    notify.add_argument("--flash-color", default="#00D1FF", help="Flash/edge color")
    notify.add_argument("--flash-duration", type=int, default=700, help="Flash duration (ms)")
    notify.add_argument("--edge-width", type=float, default=14.0, help="Edge width")
    notify.add_argument("--edge-opacity", type=float, default=0.92, help="Edge opacity")
    notify.add_argument("--edge-repeat", type=int, default=2, help="Edge repeat count")
    notify.add_argument(
        "--extra-json",
        default="",
        help="Extra JSON object to merge into payload",
    )

    smoke = subparsers.add_parser(
        "smoke",
        help="Run quick checks: status + normal notify (+ optional edge notify)",
    )
    smoke.add_argument(
        "--include-edge",
        action="store_true",
        help="Also send one edge-lighting notify request",
    )
    smoke.add_argument("--flash-color", default="#00D1FF", help="Edge color for smoke test")
    smoke.add_argument("--flash-duration", type=int, default=700, help="Edge duration (ms)")
    smoke.add_argument("--edge-width", type=float, default=14.0, help="Edge width")
    smoke.add_argument("--edge-opacity", type=float, default=0.92, help="Edge opacity")
    smoke.add_argument("--edge-repeat", type=int, default=2, help="Edge repeat count")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    base_url = f"http://{args.host}:{args.port}"
    client = SNoticeApiClient(base_url=base_url, timeout=args.timeout)

    try:
        if args.command == "status":
            return cmd_status(client, args)
        if args.command == "config-get":
            return cmd_config_get(client, args)
        if args.command == "config-set":
            return cmd_config_set(client, args)
        if args.command == "notify":
            return cmd_notify(client, args)
        if args.command == "smoke":
            return cmd_smoke(client, args)
    except RuntimeError as err:
        print(f"error: {err}", file=sys.stderr)
        return 1

    parser.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
