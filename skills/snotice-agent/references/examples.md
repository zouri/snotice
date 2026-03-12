# Examples

## Normal Notification

```json
{
  "title": "Build Finished",
  "body": "Desktop bundle completed",
  "priority": "normal"
}
```

## Full-Screen Flash

```json
{
  "title": "Alert",
  "body": "Immediate attention",
  "category": "flash_full",
  "flashColor": "#FF0000",
  "flashDuration": 800
}
```

## Edge Flash

```json
{
  "title": "Edge Alert",
  "body": "Peripheral indicator",
  "category": "flash_edge",
  "flashColor": "#00D1FF",
  "flashDuration": 700,
  "edgeWidth": 12,
  "edgeOpacity": 0.92,
  "edgeRepeat": 2
}
```

## Barrage Overlay

```json
{
  "title": "Barrage Alert",
  "body": "Build completed",
  "category": "barrage",
  "barrageColor": "#FFD84D",
  "barrageDuration": 6000,
  "barrageSpeed": 160,
  "barrageFontSize": 30,
  "barrageLane": "top",
  "barrageRepeat": 2
}
```

## MCP tools/call (Barrage)

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "snotice_send_notification",
    "arguments": {
      "title": "Barrage Alert",
      "body": "Build completed",
      "category": "barrage",
      "barrageColor": "#FFD84D",
      "barrageDuration": 6000,
      "barrageSpeed": 160,
      "barrageFontSize": 30,
      "barrageLane": "top"
    }
  }
}
```
