# API Contract

## Base URL

- Default: `http://127.0.0.1:8642`

## Endpoints

### `GET /api/status`

Success body fields:

- `running` (bool)
- `port` (int)
- `uptime` (seconds)

### `POST /api/notify`

Request body key fields:

- Required: `title`
- Required for non-overlay notifications: `body`
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

Server-side defaults:

- When `category=barrage`, omitted barrage fields are auto-filled from current
  config (`defaultBarrageColor/defaultBarrageDuration/defaultBarrageSpeed/defaultBarrageFontSize/defaultBarrageLane`).

Compatibility aliases are not supported. Use canonical field names only.

## Common Error Cases

- 400 invalid JSON or validation failure
- 401 caller IP not in whitelist
- 403 barrage disabled (`showBarrage=false`)
- 404 endpoint path mismatch
- 500 internal runtime error
