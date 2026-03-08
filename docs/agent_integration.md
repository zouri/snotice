# SNotice Agent Integration

This guide explains how to call SNotice from AI agents using either MCP or Skill workflows.

## Prerequisites

1. Start the SNotice desktop app.
2. Ensure its HTTP server is running (default `127.0.0.1:8642`).
3. Confirm with:

```bash
python3 scripts/test_http_api.py status
```

## Option A: MCP

MCP is built into the SNotice server at:

- `POST http://127.0.0.1:8642/api/mcp`

### Tool list

- `snotice_send_notification`
- `snotice_get_status`
- `snotice_get_config`
- `snotice_update_config`

### Example MCP JSON-RPC call

```bash
curl -X POST http://127.0.0.1:8642/api/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

```bash
curl -X POST http://127.0.0.1:8642/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "id":2,
    "method":"tools/call",
    "params":{
      "name":"snotice_send_notification",
      "arguments":{"title":"Hello","body":"From MCP"}
    }
  }'
```

### Example MCP `tools/call` for Barrage

```bash
curl -X POST http://127.0.0.1:8642/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "id":3,
    "method":"tools/call",
    "params":{
      "name":"snotice_send_notification",
      "arguments":{
        "title":"Barrage Alert",
        "body":"Build passed",
        "category":"barrage",
        "barrageColor":"#FFD84D",
        "barrageDuration":6000,
        "barrageSpeed":160,
        "barrageFontSize":30,
        "barrageLane":"top"
      }
    }
  }'
```

### Client config example (HTTP direct)

Use this when your MCP client supports HTTP/remote MCP directly:

```json
{
  "mcpServers": {
    "snotice": {
      "transport": "http",
      "url": "http://127.0.0.1:8642/api/mcp"
    }
  }
}
```

Notes:

- Some clients use different field names (for example `type`, `endpoint`, or `serverUrl`).
- Keep the URL pointing to `/api/mcp`.
- If your client supports only `stdio`, it cannot connect directly to this HTTP endpoint.

## Option B: Skills

Repo skill path:

- `skills/snotice-agent/SKILL.md`

This skill provides:

- helper script: `skills/snotice-agent/scripts/snotice_call.py`
- API references: `skills/snotice-agent/references/api_contract.md`
- payload examples: `skills/snotice-agent/references/examples.md`

Quick calls:

```bash
python3 skills/snotice-agent/scripts/snotice_call.py status
python3 skills/snotice-agent/scripts/snotice_call.py config-get
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Deploy" --body "Service restarted"
python3 skills/snotice-agent/scripts/snotice_call.py notify \
  --title "Barrage" \
  --category barrage \
  --body "Build passed" \
  --barrage-color "#FFD84D" \
  --barrage-duration 6000 \
  --barrage-speed 160 \
  --barrage-font-size 30 \
  --barrage-lane top
```

## Notes

- If you get `401 IP not allowed`, update SNotice `allowedIPs` config.
- For config updates, do read-then-merge to avoid resetting unspecified fields.
- `edgeWidth/edgeOpacity/edgeRepeat` only work with `category=flash_edge`.
- `barrageColor/barrageDuration/barrageSpeed/barrageFontSize/barrageLane`
  only work with `category=barrage`.
- For `category=barrage`, if barrage fields are omitted, the server fills
  them from config defaults (`defaultBarrage*`).
- If `showBarrage=false`, barrage calls are rejected with HTTP `403`.
- MCP/skill callers should use the configured port directly; there is no
  automatic multi-port probing.
