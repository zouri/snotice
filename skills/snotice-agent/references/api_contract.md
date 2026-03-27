# API Contract

## Base URL

- Default: `http://127.0.0.1:8642`

## Endpoints

### `GET /api/status`

Success body fields:

- `running` (bool)
- `port` (int)
- `uptimeSeconds` (seconds)
- `startedAt` (ISO timestamp, only when server is running)

### `POST /api/notify`

Request body key fields:

- Required: `title`
- Required for non-overlay notifications: `message`
- Optional: `priority` (`low|normal|high`)
- Optional overlay category:
  `category=flash_full` or `category=flash_edge` or `category=barrage`
- Flash fields (`flash_full`/`flash_edge`):
  - `flashColor` (string)
  - `flashDuration` (>0)
  - `edgeWidth` (>0, only when `category=flash_edge`)
  - `edgeOpacity` (0~1, only when `category=flash_edge`)
  - `edgeRepeat` (>0, only when `category=flash_edge`)
- Barrage fields (only when `category=barrage`):
  - `barrageColor` (string)
  - `barrageDuration` (>0)
  - `barrageSpeed` (>0)
  - `barrageFontSize` (>0)
  - `barrageLane` (`top|middle|bottom`)
  - `barrageRepeat` (1~8)

Server-side defaults:

- When `category=barrage`, omitted barrage fields are auto-filled from current
  config (`defaultBarrageColor/defaultBarrageDuration/defaultBarrageSpeed/defaultBarrageFontSize/defaultBarrageLane`).

Compatibility aliases are not supported. Use canonical field names only.

Compatibility note:

- Legacy field `body` is still accepted as an input alias, but new callers
  should send `message`.

### `POST /api/mcp`

MCP JSON-RPC endpoint that exposes:

- `snotice_send_notification`
- `snotice_get_status`
- `snotice_get_config`

## Common Error Cases

- 400 invalid JSON or validation failure
- 401 caller IP not in whitelist
- 403 barrage disabled (`showBarrage=false`)
- 404 endpoint path mismatch
- 500 internal runtime error
