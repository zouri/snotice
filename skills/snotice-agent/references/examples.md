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
  "category": "flash",
  "flashEffect": "full",
  "flashColor": "#FF0000",
  "flashDuration": 800
}
```

## Edge Flash

```json
{
  "title": "Edge Alert",
  "body": "Peripheral indicator",
  "category": "flash",
  "flashEffect": "edge",
  "flashColor": "#00D1FF",
  "flashDuration": 700,
  "edgeWidth": 12,
  "edgeOpacity": 0.92,
  "edgeRepeat": 2
}
```

## Config Patch Flow

1. GET `/api/config`
2. Merge changed fields only
3. POST merged object to `/api/config`
