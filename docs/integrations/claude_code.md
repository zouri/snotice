# Claude Code -> SNotice

This setup uses Claude Code hooks to forward local events into SNotice.

## Prerequisites

1. Start SNotice and confirm it responds:

   ```bash
   curl http://127.0.0.1:8642/api/status
   ```

2. Verify the adapter script:

   ```bash
   python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py \
     --agent claude \
     --dry-run \
     --input-json '{"hook_event_name":"Notification","message":"Permission required"}'
   ```

## One-command install

```bash
python3 /Users/sun/Src/snotice_new/scripts/install_agent_hooks.py install --agent claude
```

## Suggested hook config

Put this in `~/.claude/settings.json` or project-local `.claude/settings.json`.

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py --agent claude"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py --agent claude"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 /Users/sun/Src/snotice_new/scripts/agent_notify.py --agent claude"
          }
        ]
      }
    ]
  }
}
```

## Recommended event policy

- `Notification`: good for permission prompts and attention-needed moments.
- `Stop`: good for final task completion.
- `SubagentStop`: optional; turn it off if it feels noisy.

## Notes

- Claude Code sends hook payloads as JSON. The adapter reads stdin directly.
- The adapter stores Claude metadata under SNotice `payload`, including
  `sessionId`, `cwd`, and `transcriptPath` when present.
- Use `python3 /Users/sun/Src/snotice_new/scripts/install_agent_hooks.py status --agent claude`
  to verify the current install.
