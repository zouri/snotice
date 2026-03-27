# Codex -> SNotice

This setup uses Codex `notify` to forward completion/error events into SNotice.

## Prerequisites

1. Start SNotice and confirm it responds:

   ```bash
   curl http://127.0.0.1:8642/api/status
   ```

2. Verify the adapter script:

   ```bash
   python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py \
     --agent codex \
     --dry-run \
     --input-json '{"event":"task_completed","message":"Build finished"}'
   ```

## One-command install

```bash
python3 /Users/sun/Src/snotice_new/scripts/install_agent_hooks.py install --agent codex
```

## Suggested Codex config

Add this to `~/.codex/config.toml`:

```toml
notify = ["python3", "/Users/sun/Src/snotice_new/scripts/agent_notify.py", "--agent", "codex"]
```

## How it works

- Codex invokes the `notify` command and passes a JSON payload on stdin.
- The adapter normalizes the event and forwards it to `POST /api/notify`.
- Error-like payloads become red edge alerts.
- Completion-like payloads become normal desktop notifications.

## Notes

- If you keep multiple Codex workspaces, point the command at a stable absolute
  script path.
- The adapter keeps the original Codex payload under SNotice `payload.raw` so
  later filtering/debugging stays possible even if Codex evolves its schema.
- If `~/.codex/config.toml` already has a different `notify` command, the
  installer will stop instead of overwriting it. Re-run with `--force` only if
  you want SNotice to take over that slot.
