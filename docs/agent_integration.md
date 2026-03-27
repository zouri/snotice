# SNotice Agent Integration

This guide explains how to call SNotice from AI agents using MCP, Skill workflows,
or local hook/notify adapters.

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
      "arguments":{"title":"Hello","message":"From MCP"}
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
        "message":"Build passed",
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
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Deploy" --message "Service restarted"
python3 skills/snotice-agent/scripts/snotice_call.py notify \
  --title "Barrage" \
  --category barrage \
  --message "Build passed" \
  --barrage-color "#FFD84D" \
  --barrage-duration 6000 \
  --barrage-speed 160 \
  --barrage-font-size 30 \
  --barrage-lane top \
  --barrage-repeat 2
```

`config-get` is implemented through MCP (`/api/mcp`) and does not rely on a
standalone `/api/config` HTTP endpoint.

## Notes

- If you get `401 IP not allowed`, update SNotice `allowedIPs` config.
- `edgeWidth/edgeOpacity/edgeRepeat` only work with `category=flash_edge`.
- `barrageColor/barrageDuration/barrageSpeed/barrageFontSize/barrageLane`
  only work with `category=barrage`.
- `barrageRepeat` only works with `category=barrage` and must be in `1..8`.
- For `category=barrage`, if barrage fields are omitted, the server fills
  them from config defaults (`defaultBarrage*`).
- If `showBarrage=false`, barrage calls are rejected with HTTP `403`.
- MCP/skill callers should use the configured port directly; there is no
  automatic multi-port probing.

## Option C: Hook/Notify Adapter Script

Script path:

- `scripts/agent_notify.py`
- `scripts/install_agent_hooks.py`

What it does:

- reads JSON payloads from stdin or `--input-json`
- detects `claude`, `codex`, or `opencode` payload shapes
- maps the event into a SNotice request
- forwards to `POST /api/notify`
- stores the raw upstream payload in `payload.raw`

Quick examples:

```bash
python3 scripts/agent_notify.py \
  --agent claude \
  --dry-run \
  --input-json '{"hook_event_name":"Notification","message":"Permission required"}'
```

```bash
python3 scripts/agent_notify.py \
  --agent codex \
  --dry-run \
  --input-json '{"event":"task_completed","message":"Build finished"}'
```

Automatic install:

```bash
python3 scripts/install_agent_hooks.py install
```

Check current install status:

```bash
python3 scripts/install_agent_hooks.py status
```

Remove managed integrations:

```bash
python3 scripts/install_agent_hooks.py uninstall
```

Default mapping:

- completion/idle events -> normal notification
- permission/approval events -> `flash_edge` amber alert
- error/failure events -> `flash_edge` red alert
- outgoing SNotice payloads use canonical field `message`

Per-agent setup guides:

- `docs/integrations/claude_code.md`
- `docs/integrations/codex.md`
- `docs/integrations/opencode.md`
