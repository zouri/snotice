# API Contract

## Base URL

- Default: `http://127.0.0.1:8642`

## Endpoints

### `GET /api/status`

Success body fields:

- `running` (bool)
- `port` (int)
- `uptime` (seconds)

### `GET /api/config`

Success body fields:

- `port` (int)
- `allowedIPs` (array<string>)
- `autoStart` (bool)
- `showNotifications` (bool)

### `POST /api/config`

Request body is a JSON object with config fields.

Important: server model performs full parse, so omitted fields can fall back to defaults. Prefer read-then-merge updates.

### `POST /api/notify`

Request body key fields:

- Required: `title`
- Required for non-flash: `body`
- Optional: `priority` (`low|normal|high`)
- Optional flash mode: `category=flash_full` or `category=flash_edge`
- Flash fields:
  - `flashColor` (string)
  - `flashDuration` (>0)
  - `edgeWidth` (>0, only when `category=flash_edge`)
  - `edgeOpacity` (0~1, only when `category=flash_edge`)
  - `edgeRepeat` (>0, only when `category=flash_edge`)

Compatibility aliases are not supported. Use canonical field names only.

## Common Error Cases

- 400 invalid JSON or validation failure
- 401 caller IP not in whitelist
- 404 endpoint path mismatch
- 500 internal runtime error
