---
name: snotice-agent
description: Operate SNotice as an AI-callable notification gateway through its local HTTP API and built-in MCP endpoint. Use when tasks need to send desktop notifications, check service health, or update runtime config (port, whitelist, notification toggle) from an agent workflow.
---

# SNotice Agent

Use this skill to control a running SNotice instance at `http://127.0.0.1:8642`.

## Quick Workflow

1. Confirm SNotice app is running and HTTP server is enabled.
2. Read status with `python3 skills/snotice-agent/scripts/snotice_call.py status`.
3. Send notification with `python3 skills/snotice-agent/scripts/snotice_call.py notify --title "..." --body "..."`.
4. For MCP clients, call `POST /api/mcp` on the SNotice server.

## MCP Mode

Call these tools via `POST /api/mcp`:

- `snotice_send_notification`
- `snotice_get_status`
- `snotice_get_config`
- `snotice_update_config`

Recommended call order for safety:

1. `snotice_get_status`
2. `snotice_get_config` (before config changes)
3. `snotice_update_config` (only changed fields)
4. `snotice_send_notification`

## HTTP/CLI Mode

Use the bundled helper script for deterministic calls:

```bash
python3 skills/snotice-agent/scripts/snotice_call.py status
python3 skills/snotice-agent/scripts/snotice_call.py config-get
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Build Done" --body "macOS package finished"
```

## Read References Only When Needed

- API fields and validation limits: `references/api_contract.md`
- Example payloads for flash/edge: `references/examples.md`

## Failure Handling

1. On connection errors, check SNotice server status in app UI and verify host/port.
2. On HTTP 401, update `allowedIPs` to include the caller IP.
3. On HTTP 400 validation errors, correct fields before retry.
4. For config update, always read config first, then merge updates.
