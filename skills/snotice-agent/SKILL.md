---
name: snotice-agent
description: Operate SNotice as an AI-callable notification gateway through its local HTTP API and built-in MCP endpoint. Use when tasks need to send desktop notifications (normal/flash/barrage), check service health, or inspect runtime config from an agent workflow.
---

# SNotice Agent

Use this skill to control a running SNotice instance at `http://127.0.0.1:8642`.

## Quick Workflow

1. Confirm SNotice app is running and HTTP server is enabled.
2. Read status with `python3 skills/snotice-agent/scripts/snotice_call.py status`.
3. Send notification with `python3 skills/snotice-agent/scripts/snotice_call.py notify --title "..." --message "..."`.
4. For barrage overlay, use `--category barrage` plus optional `--barrage-*` fields.
5. For MCP clients, call `POST /api/mcp` on the SNotice server.

## MCP Mode

Call these tools via `POST /api/mcp`:

- `snotice_send_notification`
- `snotice_get_status`
- `snotice_get_config`

Recommended call order for safety:

1. `snotice_get_status`
2. `snotice_get_config`
3. `snotice_send_notification`

## HTTP/CLI Mode

Use the bundled helper script for deterministic calls:

```bash
python3 skills/snotice-agent/scripts/snotice_call.py status
python3 skills/snotice-agent/scripts/snotice_call.py config-get
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Build Done" --message "macOS package finished"
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Barrage" --category barrage --message "Build done"
```

## Read References Only When Needed

- API fields and validation limits: `references/api_contract.md`
- Example payloads for normal/flash/edge/barrage: `references/examples.md`

## Failure Handling

1. On connection errors, check SNotice server status in app UI and verify host/port.
2. On HTTP 401, update `allowedIPs` to include the caller IP.
3. On HTTP 403 for barrage, check `showBarrage` in config.
4. On HTTP 400 validation errors, correct fields before retry.
5. For config reads, prefer `snotice_get_config` over scraping UI text.
