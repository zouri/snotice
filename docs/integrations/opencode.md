# OpenCode -> SNotice

This setup uses an OpenCode plugin to forward selected session events into
SNotice.

## Prerequisites

1. Start SNotice and confirm it responds:

   ```bash
   curl http://127.0.0.1:8642/api/status
   ```

2. Verify the adapter script:

   ```bash
   python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py \
     --agent opencode \
     --dry-run \
     --input-json '{"event":{"type":"session.idle","message":"Task finished"}}'
   ```

## One-command install

```bash
python3 /Users/sun/Src/snotice_new/scripts/install_agent_hooks.py install --agent opencode
```

## Suggested plugin

Create `~/.config/opencode/plugins/snotice-notify.js`:

```js
export default async function snoticeNotify({ $ }) {
  const script = "/Users/sun/Src/snotice_new/scripts/agent_notify.py";

  return {
    event: async ({ event }) => {
      if (!["session.idle", "session.error", "permission.asked"].includes(event.type)) {
        return;
      }

      const payload = {
        event: {
          type: event.type,
          message:
            event.type === "session.idle"
              ? "OpenCode completed the current task."
              : event.type === "permission.asked"
                ? "OpenCode is waiting for your confirmation."
                : "OpenCode reported a session error."
        }
      };

      await $`python3 ${script} --agent opencode --input-json ${JSON.stringify(payload)}`;
    }
  };
}
```

## Recommended event policy

- `session.idle`: notify when a response finishes.
- `session.error`: escalate as a red edge alert.
- `permission.asked`: escalate as an amber edge alert.

## Notes

- OpenCode Desktop already has its own system notifications. This plugin is
  most useful when you want all agent notifications routed through SNotice and
  benefit from flash/barrage options plus a unified local log.
- If `~/.config/opencode/plugins/snotice-notify.js` already exists and is not
  managed by SNotice, the installer will stop unless you pass `--force`.
