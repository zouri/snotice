#!/usr/bin/env python3
"""Adapt agent hook payloads into SNotice notifications."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from typing import Any


ERROR_KEYWORDS = ("error", "failed", "failure", "exception", "crash")
PERMISSION_KEYWORDS = ("permission", "approval", "confirm", "prompt")
COMPLETION_KEYWORDS = (
    "complete",
    "completed",
    "done",
    "finished",
    "idle",
    "stop",
)


def parse_json(text: str) -> Any:
    if not text.strip():
        return None
    return json.loads(text)


def compact_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def call_api(
    base_url: str,
    timeout: float,
    payload: dict[str, Any],
) -> tuple[int, Any, str]:
    url = f"{base_url.rstrip('/')}/api/notify"
    data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    request = urllib.request.Request(
        url=url,
        data=data,
        method="POST",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read().decode("utf-8", errors="replace")
            return response.status, safe_parse_json(raw), raw
    except urllib.error.HTTPError as err:
        raw = err.read().decode("utf-8", errors="replace")
        return err.code, safe_parse_json(raw), raw


def safe_parse_json(text: str) -> Any:
    if not text.strip():
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return text


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Convert Claude Code / Codex / OpenCode events into SNotice notifications.",
    )
    parser.add_argument(
        "--agent",
        default="auto",
        choices=["auto", "claude", "codex", "opencode", "generic"],
        help="Source agent type (default: auto)",
    )
    parser.add_argument("--event", default="", help="Optional event name override")
    parser.add_argument("--title", default="", help="Optional notification title override")
    parser.add_argument("--message", default="", help="Optional notification message override")
    parser.add_argument("--body", default="", help=argparse.SUPPRESS)
    parser.add_argument("--priority", default="", help="Optional priority override")
    parser.add_argument("--category", default="", help="Optional category override")
    parser.add_argument("--host", default="127.0.0.1", help="SNotice host")
    parser.add_argument("--port", type=int, default=8642, help="SNotice port")
    parser.add_argument("--timeout", type=float, default=5.0, help="Request timeout")
    parser.add_argument(
        "--input-json",
        default="",
        help="Read raw event payload from this JSON string instead of stdin",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the final SNotice payload without sending it",
    )
    return parser


def read_input_payload(args: argparse.Namespace) -> dict[str, Any]:
    raw_text = args.input_json.strip()
    if not raw_text and not sys.stdin.isatty():
        raw_text = sys.stdin.read().strip()

    if not raw_text:
        return {}

    parsed = parse_json(raw_text)
    if not isinstance(parsed, dict):
        raise ValueError("Hook input must be a JSON object.")
    return parsed


def first_string(*values: Any) -> str:
    for value in values:
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


def stringify(value: Any) -> str:
    if isinstance(value, str):
        return value.strip()
    if value is None:
        return ""
    if isinstance(value, (dict, list)):
        return compact_json(value)
    return str(value).strip()


def humanize_event(value: str) -> str:
    normalized = value.replace(".", " ").replace("_", " ").replace("-", " ").strip()
    if not normalized:
        return "Notification"
    return " ".join(part.capitalize() for part in normalized.split())


def detect_agent(source_hint: str, raw_payload: dict[str, Any]) -> str:
    if source_hint != "auto":
        return source_hint

    if "hook_event_name" in raw_payload or "transcript_path" in raw_payload:
        return "claude"

    event_value = raw_payload.get("event")
    if isinstance(event_value, dict):
        return "opencode"

    if isinstance(event_value, str) and "." in event_value:
        return "opencode"

    return "codex"


def classify_event(event_name: str, message_text: str) -> str:
    combined = f"{event_name} {message_text}".lower()
    if any(keyword in combined for keyword in ERROR_KEYWORDS):
        return "error"
    if any(keyword in combined for keyword in PERMISSION_KEYWORDS):
        return "permission"
    if any(keyword in combined for keyword in COMPLETION_KEYWORDS):
        return "completion"
    return "info"


def normalize_claude_event(raw_payload: dict[str, Any], event_override: str) -> dict[str, Any]:
    event_name = first_string(event_override, raw_payload.get("hook_event_name"), raw_payload.get("event"))
    message = first_string(
        raw_payload.get("message"),
        raw_payload.get("summary"),
        raw_payload.get("reason"),
        raw_payload.get("tool_name"),
    )
    matcher = first_string(raw_payload.get("matcher"))
    if matcher:
        message = first_string(message, f"Matcher: {matcher}")

    return {
        "agent": "claude",
        "event": event_name or "notification",
        "message": message,
        "cwd": first_string(raw_payload.get("cwd")),
        "sessionId": first_string(raw_payload.get("session_id"), raw_payload.get("sessionId")),
        "transcriptPath": first_string(raw_payload.get("transcript_path")),
        "raw": raw_payload,
    }


def normalize_codex_event(raw_payload: dict[str, Any], event_override: str) -> dict[str, Any]:
    event_name = first_string(
        event_override,
        raw_payload.get("event"),
        raw_payload.get("type"),
        raw_payload.get("status"),
    )
    message = first_string(
        raw_payload.get("message"),
        raw_payload.get("body"),
        raw_payload.get("summary"),
        raw_payload.get("title"),
    )

    return {
        "agent": "codex",
        "event": event_name or "notify",
        "message": message,
        "cwd": first_string(raw_payload.get("cwd"), raw_payload.get("workdir")),
        "sessionId": first_string(raw_payload.get("session_id"), raw_payload.get("sessionId")),
        "transcriptPath": first_string(raw_payload.get("transcript_path"), raw_payload.get("transcriptPath")),
        "raw": raw_payload,
    }


def normalize_opencode_event(raw_payload: dict[str, Any], event_override: str) -> dict[str, Any]:
    raw_event = raw_payload.get("event")
    event_payload = raw_event if isinstance(raw_event, dict) else {}
    event_name = first_string(
        event_override,
        event_payload.get("type"),
        raw_payload.get("event"),
    )
    message = first_string(
        event_payload.get("body"),
        event_payload.get("message"),
        raw_payload.get("message"),
        raw_payload.get("body"),
        raw_payload.get("title"),
    )

    return {
        "agent": "opencode",
        "event": event_name or "notification",
        "message": message,
        "cwd": first_string(raw_payload.get("cwd"), raw_payload.get("projectPath")),
        "sessionId": first_string(raw_payload.get("sessionId"), raw_payload.get("session_id")),
        "transcriptPath": first_string(raw_payload.get("transcriptPath")),
        "raw": raw_payload,
    }


def normalize_generic_event(raw_payload: dict[str, Any], event_override: str) -> dict[str, Any]:
    event_name = first_string(
        event_override,
        raw_payload.get("event"),
        raw_payload.get("type"),
    )
    message = first_string(
        raw_payload.get("message"),
        raw_payload.get("body"),
        raw_payload.get("summary"),
        raw_payload.get("title"),
    )
    return {
        "agent": "generic",
        "event": event_name or "notification",
        "message": message,
        "cwd": first_string(raw_payload.get("cwd")),
        "sessionId": first_string(raw_payload.get("sessionId"), raw_payload.get("session_id")),
        "transcriptPath": first_string(raw_payload.get("transcriptPath"), raw_payload.get("transcript_path")),
        "raw": raw_payload,
    }


def normalize_event(source_agent: str, raw_payload: dict[str, Any], event_override: str) -> dict[str, Any]:
    if source_agent == "claude":
        return normalize_claude_event(raw_payload, event_override)
    if source_agent == "opencode":
        return normalize_opencode_event(raw_payload, event_override)
    if source_agent == "generic":
        return normalize_generic_event(raw_payload, event_override)
    return normalize_codex_event(raw_payload, event_override)


def map_event_to_notification(
    normalized: dict[str, Any],
    title_override: str,
    message_override: str,
    priority_override: str,
    category_override: str,
) -> dict[str, Any]:
    agent = normalized["agent"]
    event_name = stringify(normalized["event"])
    message = stringify(normalized["message"])
    severity = classify_event(event_name, message)

    title = title_override.strip()
    message_override = message_override.strip()
    final_message = message_override
    priority_override = priority_override.strip()
    priority = priority_override or "normal"
    category = category_override.strip()

    if not title:
        if severity == "error":
            title = f"[{agent.capitalize()}] Attention needed"
        elif severity == "permission":
            title = f"[{agent.capitalize()}] Approval required"
        elif severity == "completion":
            title = f"[{agent.capitalize()}] Task finished"
        else:
            title = f"[{agent.capitalize()}] {humanize_event(event_name)}"

    if not final_message:
        if message:
            final_message = message
        elif severity == "error":
            final_message = f"{agent.capitalize()} reported an error."
        elif severity == "permission":
            final_message = f"{agent.capitalize()} is waiting for your confirmation."
        elif severity == "completion":
            final_message = f"{agent.capitalize()} completed the current task."
        else:
            final_message = f"{agent.capitalize()} sent a notification event."

    payload: dict[str, Any] = {
        "title": title,
        "message": final_message,
        "priority": priority,
        "payload": {
            "source": "agent-hook",
            "agent": agent,
            "event": event_name,
            "cwd": normalized.get("cwd"),
            "sessionId": normalized.get("sessionId"),
            "transcriptPath": normalized.get("transcriptPath"),
            "raw": normalized.get("raw"),
        },
    }

    if category:
        payload["category"] = category
        return payload

    if severity == "error":
        payload.update(
            {
                "category": "flash_edge",
                "flashColor": "#EF4444",
                "flashDuration": 900,
                "edgeWidth": 14,
                "edgeOpacity": 0.92,
                "edgeRepeat": 2,
                "priority": priority_override or "high",
            }
        )
    elif severity == "permission":
        payload.update(
            {
                "category": "flash_edge",
                "flashColor": "#F59E0B",
                "flashDuration": 800,
                "edgeWidth": 12,
                "edgeOpacity": 0.9,
                "edgeRepeat": 1,
                "priority": priority_override or "high",
            }
        )

    return payload


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        raw_payload = read_input_payload(args)
        source_agent = detect_agent(args.agent, raw_payload)
        normalized = normalize_event(source_agent, raw_payload, args.event)
        notify_payload = map_event_to_notification(
            normalized,
            args.title,
            first_string(args.message, args.body),
            args.priority,
            args.category,
        )
    except (ValueError, json.JSONDecodeError) as err:
        print(f"Input error: {err}", file=sys.stderr)
        return 2

    if args.dry_run:
        print(json.dumps(notify_payload, ensure_ascii=False, indent=2))
        return 0

    base_url = f"http://{args.host}:{args.port}"
    try:
        status, body, raw = call_api(base_url, args.timeout, notify_payload)
    except urllib.error.URLError as err:
        print(f"Request failed: {err.reason}", file=sys.stderr)
        return 1

    print(f"HTTP {status}")
    if isinstance(body, (dict, list)):
        print(json.dumps(body, ensure_ascii=False, indent=2))
    elif body is None:
        print("<empty>")
    else:
        print(raw)
    return 0 if 200 <= status < 300 else 1


if __name__ == "__main__":
    raise SystemExit(main())
