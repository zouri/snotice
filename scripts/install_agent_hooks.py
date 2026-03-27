#!/usr/bin/env python3
"""Install SNotice agent integrations for Claude Code, Codex, and OpenCode."""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


OPENCODE_PLUGIN_NAME = "snotice-notify.js"
MANAGED_MARKER = "Managed by SNotice install_agent_hooks.py"
LAUNCHER_MARKER = "Managed by SNotice launcher install_agent_hooks.py"
DEFAULT_AGENT_SET = ("claude", "codex", "opencode")


@dataclass
class ActionResult:
    agent: str
    path: Path
    status: str
    detail: str


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def default_adapter_script() -> Path:
    return repo_root() / "scripts" / "agent_notify.py"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Install or remove SNotice hook/notify integrations for local AI agents.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    for name in ("install", "status", "uninstall"):
        cmd = sub.add_parser(name)
        cmd.add_argument(
            "--agent",
            choices=["all", "claude", "codex", "opencode"],
            nargs="+",
            default=["all"],
            help="Target agent(s). Default: all",
        )
        cmd.add_argument(
            "--home",
            default="",
            help="Override home directory for testing or custom installs.",
        )
        cmd.add_argument(
            "--script-path",
            default=str(default_adapter_script()),
            help="Absolute path to scripts/agent_notify.py",
        )
        cmd.add_argument(
            "--bin-dir",
            default="",
            help="Directory where the snotice launcher command should be created.",
        )
        cmd.add_argument(
            "--command-name",
            default="snotice",
            help="Launcher command name referenced by hooks.",
        )
        cmd.add_argument(
            "--python",
            default=sys.executable,
            help="Python executable path used in generated hook commands.",
        )
        cmd.add_argument("--host", default="127.0.0.1", help="SNotice host")
        cmd.add_argument("--port", type=int, default=8642, help="SNotice port")
        if name == "install":
            cmd.add_argument(
                "--force",
                action="store_true",
                help="Allow replacing conflicting existing Codex/OpenCode config.",
            )
    return parser


def resolve_home(args: argparse.Namespace) -> Path:
    if args.home:
        return Path(args.home).expanduser().resolve()
    return Path.home()


def selected_agents(raw_agents: list[str]) -> list[str]:
    if "all" in raw_agents:
        return list(DEFAULT_AGENT_SET)
    seen: list[str] = []
    for agent in raw_agents:
        if agent not in seen:
            seen.append(agent)
    return seen


def default_bin_dir(home: Path) -> Path:
    if os.name == "nt":
        return home / "bin"
    return home / ".local" / "bin"


def resolve_bin_dir(args: argparse.Namespace, home: Path) -> Path:
    if args.bin_dir:
        return Path(args.bin_dir).expanduser().resolve()
    return default_bin_dir(home)


def launcher_path(bin_dir: Path, command_name: str) -> Path:
    return bin_dir / command_name


def launcher_marker_present(path: Path) -> bool:
    if not path.exists():
        return False
    return LAUNCHER_MARKER in path.read_text(encoding="utf-8", errors="replace")


def launcher_source(script_path: Path, python_executable: str) -> str:
    quoted_python = shlex.quote(python_executable)
    quoted_script = shlex.quote(str(script_path))
    return (
        "#!/usr/bin/env sh\n"
        f"# {LAUNCHER_MARKER}\n"
        f"exec {quoted_python} {quoted_script} \"$@\"\n"
    )


def install_launcher(
    bin_dir: Path,
    command_name: str,
    script_path: Path,
    python_executable: str,
) -> ActionResult:
    path = launcher_path(bin_dir, command_name)
    expected = launcher_source(script_path, python_executable)
    if path.exists():
        current = path.read_text(encoding="utf-8", errors="replace")
        if current == expected:
            return ActionResult("command", path, "unchanged", "Launcher command already installed.")
        if LAUNCHER_MARKER not in current:
            return ActionResult(
                "command",
                path,
                "conflict",
                "Existing launcher command is not managed by SNotice.",
            )

    backup = backup_file(path)
    write_text(path, expected)
    path.chmod(0o755)
    detail = f"Installed launcher command '{command_name}'."
    if backup is not None:
        detail += f" Backup: {backup}"
    path_env = os.environ.get("PATH", "")
    if str(bin_dir) not in path_env.split(os.pathsep):
        detail += f" Add {bin_dir} to PATH if command is not found."
    return ActionResult("command", path, "installed", detail)


def uninstall_launcher(bin_dir: Path, command_name: str) -> ActionResult:
    path = launcher_path(bin_dir, command_name)
    if not path.exists():
        return ActionResult("command", path, "absent", "Launcher command not found.")
    if not launcher_marker_present(path):
        return ActionResult(
            "command",
            path,
            "absent",
            "Launcher exists but is not managed by SNotice.",
        )
    backup = backup_file(path)
    path.unlink()
    detail = f"Removed launcher command '{command_name}'."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("command", path, "removed", detail)


def launcher_status(bin_dir: Path, command_name: str) -> ActionResult:
    path = launcher_path(bin_dir, command_name)
    if not path.exists():
        return ActionResult("command", path, "absent", "Launcher command not found.")
    if not launcher_marker_present(path):
        return ActionResult(
            "command",
            path,
            "conflict",
            "Launcher command exists but is not managed by SNotice.",
        )
    if not os.access(path, os.X_OK):
        return ActionResult("command", path, "partial", "Launcher exists but is not executable.")
    return ActionResult("command", path, "installed", "Launcher command is installed.")


def backup_file(path: Path) -> Path | None:
    if not path.exists():
        return None
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(f"{path.name}.bak.{timestamp}")
    shutil.copy2(path, backup)
    return backup


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def json_command(
    command_name: str,
    script_path: Path,
    agent: str,
    host: str,
    port: int,
    python_executable: str,
) -> str:
    del script_path, python_executable
    command = [
        command_name,
        "--agent",
        agent,
        "--host",
        host,
        "--port",
        str(port),
    ]
    if os.name == "nt":
        return subprocess.list2cmdline(command)
    return shlex.join(command)


def codex_notify_list(
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> list[str]:
    del script_path, python_executable
    return [
        command_name,
        "--agent",
        "codex",
        "--host",
        host,
        "--port",
        str(port),
    ]


def toml_string(value: str) -> str:
    return json.dumps(value)


def codex_notify_assignment(
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> str:
    items = ", ".join(
        toml_string(item)
        for item in codex_notify_list(
            command_name,
            script_path,
            host,
            port,
            python_executable,
        )
    )
    return f'notify = [{items}]'


def find_notify_assignment_span(content: str) -> tuple[int, int] | None:
    match = re.search(r"(?m)^notify\s*=\s*\[", content)
    if match is None:
        return None

    start = match.start()
    index = content.find("[", match.start())
    in_string = False
    escaped = False
    depth = 0

    while index < len(content):
        char = content[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
            elif char == "[":
                depth += 1
            elif char == "]":
                depth -= 1
                if depth == 0:
                    end = index + 1
                    while end < len(content) and content[end] in "\r\n":
                        end += 1
                    return start, end
        index += 1

    raise ValueError(
        "Found notify assignment start but could not locate its closing bracket."
    )


def claude_path(home: Path) -> Path:
    return home / ".claude" / "settings.json"


def codex_path(home: Path) -> Path:
    return home / ".codex" / "config.toml"


def opencode_plugin_path(home: Path) -> Path:
    return home / ".config" / "opencode" / "plugins" / OPENCODE_PLUGIN_NAME


def load_json_object(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    content = path.read_text(encoding="utf-8").strip()
    if not content:
        return {}
    parsed = json.loads(content)
    if not isinstance(parsed, dict):
        raise ValueError(f"{path} must contain a JSON object.")
    return parsed


def save_json_object(path: Path, data: dict[str, Any]) -> None:
    write_text(path, json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def normalize_hook_entries(value: Any) -> list[dict[str, Any]]:
    if isinstance(value, list):
        return [entry for entry in value if isinstance(entry, dict)]
    return []


def managed_claude_entries(
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> dict[str, list[dict[str, Any]]]:
    command = json_command(
        command_name,
        script_path,
        "claude",
        host,
        port,
        python_executable,
    )
    return {
        "Notification": [
            {
                "matcher": "permission_prompt",
                "hooks": [{"type": "command", "command": command}],
            }
        ],
        "Stop": [
            {
                "hooks": [{"type": "command", "command": command}],
            }
        ],
    }


def entry_matches(entry: dict[str, Any], managed_entry: dict[str, Any]) -> bool:
    if entry.get("matcher") != managed_entry.get("matcher"):
        return False
    hooks = entry.get("hooks")
    managed_hooks = managed_entry.get("hooks")
    return hooks == managed_hooks


def claude_entry_command(entry: dict[str, Any]) -> str:
    hooks = entry.get("hooks")
    if not isinstance(hooks, list):
        return ""
    for hook in hooks:
        if not isinstance(hook, dict):
            continue
        if hook.get("type") != "command":
            continue
        command = hook.get("command")
        if isinstance(command, str):
            return command
    return ""


def is_managed_claude_entry(entry: dict[str, Any], command_name: str) -> bool:
    command = claude_entry_command(entry)
    if not command:
        return False
    if "--agent claude" not in command:
        return False
    if "agent_notify.py" in command:
        return True
    try:
        tokens = shlex.split(command)
    except ValueError:
        return False
    if not tokens:
        return False
    return tokens[0] == command_name


def install_claude(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
    force: bool,
) -> ActionResult:
    del force
    path = claude_path(home)
    data = load_json_object(path)
    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        hooks = {}
        data["hooks"] = hooks

    managed = managed_claude_entries(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    changed = False

    for event_name, entries in managed.items():
        current_entries = normalize_hook_entries(hooks.get(event_name))
        for managed_entry in entries:
            if any(entry_matches(entry, managed_entry) for entry in current_entries):
                continue
            matcher = managed_entry.get("matcher")
            replacement_index = next(
                (
                    index
                    for index, entry in enumerate(current_entries)
                    if entry.get("matcher") == matcher
                    and is_managed_claude_entry(entry, command_name)
                ),
                -1,
            )
            if replacement_index >= 0:
                current_entries[replacement_index] = managed_entry
            else:
                current_entries.append(managed_entry)
            changed = True
        hooks[event_name] = current_entries

    if not changed:
        return ActionResult(
            "claude",
            path,
            "unchanged",
            "Claude Code hooks already installed.",
        )

    backup = backup_file(path)
    save_json_object(path, data)
    detail = "Installed Claude Code hooks."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("claude", path, "installed", detail)


def uninstall_claude(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    path = claude_path(home)
    if not path.exists():
        return ActionResult(
            "claude",
            path,
            "absent",
            "Claude Code settings.json does not exist.",
        )

    data = load_json_object(path)
    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        return ActionResult(
            "claude",
            path,
            "absent",
            "No Claude Code hooks section found.",
        )

    managed = managed_claude_entries(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    changed = False

    for event_name, managed_entries in managed.items():
        current_entries = normalize_hook_entries(hooks.get(event_name))
        if not current_entries:
            continue
        managed_matchers = {entry.get("matcher") for entry in managed_entries}
        remaining_entries = [
            entry
            for entry in current_entries
            if not (
                is_managed_claude_entry(entry, command_name)
                and entry.get("matcher") in managed_matchers
            )
        ]
        if len(remaining_entries) != len(current_entries):
            changed = True
        if remaining_entries:
            hooks[event_name] = remaining_entries
        else:
            hooks.pop(event_name, None)

    if not changed:
        return ActionResult(
            "claude",
            path,
            "absent",
            "No managed Claude Code hooks found.",
        )

    if not hooks:
        data.pop("hooks", None)

    backup = backup_file(path)
    save_json_object(path, data)
    detail = "Removed managed Claude Code hooks."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("claude", path, "removed", detail)


def claude_status(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    path = claude_path(home)
    if not path.exists():
        return ActionResult(
            "claude",
            path,
            "absent",
            "Claude Code settings.json not found.",
        )

    try:
        data = load_json_object(path)
    except ValueError as err:
        return ActionResult("claude", path, "error", str(err))

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        return ActionResult(
            "claude",
            path,
            "absent",
            "No Claude Code hooks section found.",
        )

    managed = managed_claude_entries(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    missing: list[str] = []
    for event_name, managed_entries in managed.items():
        current_entries = normalize_hook_entries(hooks.get(event_name))
        for managed_entry in managed_entries:
            if not any(entry_matches(entry, managed_entry) for entry in current_entries):
                missing.append(event_name)
                break

    if missing:
        return ActionResult(
            "claude",
            path,
            "partial",
            f"Missing managed hooks for: {', '.join(missing)}",
        )
    return ActionResult("claude", path, "installed", "Claude Code hooks are installed.")


def install_codex(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
    force: bool,
) -> ActionResult:
    path = codex_path(home)
    assignment = codex_notify_assignment(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    managed_block = f"# {MANAGED_MARKER}\n{assignment}\n"
    current = path.read_text(encoding="utf-8") if path.exists() else ""
    span = find_notify_assignment_span(current) if current else None

    if span is None:
        backup = backup_file(path)
        prefix = "" if not current.strip() else current.rstrip() + "\n\n"
        write_text(path, prefix + managed_block)
        detail = "Installed Codex notify command."
        if backup is not None:
            detail += f" Backup: {backup}"
        return ActionResult("codex", path, "installed", detail)

    existing_assignment = current[span[0] : span[1]].strip()
    if existing_assignment == assignment:
        return ActionResult("codex", path, "unchanged", "Codex notify command already installed.")

    if not force:
        return ActionResult(
            "codex",
            path,
            "conflict",
            "Existing Codex notify configuration differs. Re-run with --force to replace it.",
        )

    backup = backup_file(path)
    start, end = span
    line_start = current.rfind("\n", 0, start)
    marker_start = line_start + 1 if line_start >= 0 else 0
    if current.startswith(f"# {MANAGED_MARKER}\n", marker_start):
        start = marker_start
    updated = current[:start] + managed_block + current[end:]
    write_text(path, updated)
    detail = "Replaced existing Codex notify command."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("codex", path, "installed", detail)


def uninstall_codex(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    path = codex_path(home)
    if not path.exists():
        return ActionResult("codex", path, "absent", "Codex config.toml not found.")

    current = path.read_text(encoding="utf-8")
    span = find_notify_assignment_span(current)
    if span is None:
        return ActionResult("codex", path, "absent", "No Codex notify assignment found.")

    assignment = codex_notify_assignment(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    existing_assignment = current[span[0] : span[1]].strip()
    if existing_assignment != assignment:
        return ActionResult(
            "codex",
            path,
            "absent",
            "Codex notify assignment exists but is not managed by SNotice.",
        )

    start, end = span
    line_start = current.rfind("\n", 0, start)
    marker_start = line_start + 1 if line_start >= 0 else 0
    if current.startswith(f"# {MANAGED_MARKER}\n", marker_start):
        start = marker_start
    updated = current[:start] + current[end:]
    updated = updated.lstrip("\n")

    backup = backup_file(path)
    write_text(path, updated)
    detail = "Removed managed Codex notify command."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("codex", path, "removed", detail)


def codex_status(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    path = codex_path(home)
    if not path.exists():
        return ActionResult("codex", path, "absent", "Codex config.toml not found.")

    current = path.read_text(encoding="utf-8")
    span = find_notify_assignment_span(current)
    if span is None:
        return ActionResult("codex", path, "absent", "No Codex notify assignment found.")

    assignment = codex_notify_assignment(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    existing_assignment = current[span[0] : span[1]].strip()
    if existing_assignment == assignment:
        return ActionResult("codex", path, "installed", "Codex notify command is installed.")
    return ActionResult("codex", path, "conflict", "Codex notify is configured, but not for SNotice.")


def opencode_plugin_source(
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> str:
    del script_path, python_executable
    return f"""// {MANAGED_MARKER}
export default async function snoticeNotify({{ $ }}) {{
  const command = {json.dumps(command_name)};
  const host = {json.dumps(host)};
  const port = {port};

  return {{
    event: async ({{ event }}) => {{
      if (!["session.idle", "session.error", "permission.asked"].includes(event.type)) {{
        return;
      }}

      const payload = {{
        event: {{
          type: event.type,
          message:
            event.type === "session.idle"
              ? "OpenCode completed the current task."
              : event.type === "permission.asked"
                ? "OpenCode is waiting for your confirmation."
                : "OpenCode reported a session error."
        }}
      }};

      await $`${{command}} --agent opencode --host ${{host}} --port ${{port}} --input-json ${{JSON.stringify(payload)}}`;
    }}
  }};
}}
"""


def install_opencode(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
    force: bool,
) -> ActionResult:
    path = opencode_plugin_path(home)
    expected = opencode_plugin_source(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )

    if path.exists():
        current = path.read_text(encoding="utf-8")
        if current == expected:
            return ActionResult(
                "opencode",
                path,
                "unchanged",
                "OpenCode plugin already installed.",
            )
        if MANAGED_MARKER not in current and not force:
            return ActionResult(
                "opencode",
                path,
                "conflict",
                "Existing OpenCode plugin file differs. Re-run with --force to replace it.",
            )

    backup = backup_file(path)
    write_text(path, expected)
    detail = "Installed OpenCode plugin."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("opencode", path, "installed", detail)


def uninstall_opencode(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    del command_name, script_path, host, port, python_executable
    path = opencode_plugin_path(home)
    if not path.exists():
        return ActionResult(
            "opencode",
            path,
            "absent",
            "OpenCode plugin file not found.",
        )

    current = path.read_text(encoding="utf-8")
    if MANAGED_MARKER not in current:
        return ActionResult(
            "opencode",
            path,
            "absent",
            "OpenCode plugin exists but is not managed by SNotice.",
        )

    backup = backup_file(path)
    path.unlink()
    detail = "Removed managed OpenCode plugin."
    if backup is not None:
        detail += f" Backup: {backup}"
    return ActionResult("opencode", path, "removed", detail)


def opencode_status(
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
) -> ActionResult:
    expected = opencode_plugin_source(
        command_name,
        script_path,
        host,
        port,
        python_executable,
    )
    path = opencode_plugin_path(home)
    if not path.exists():
        return ActionResult("opencode", path, "absent", "OpenCode plugin file not found.")

    current = path.read_text(encoding="utf-8")
    if current == expected:
        return ActionResult(
            "opencode",
            path,
            "installed",
            "OpenCode plugin is installed.",
        )
    if MANAGED_MARKER in current:
        return ActionResult(
            "opencode",
            path,
            "partial",
            "Managed OpenCode plugin exists with different settings.",
        )
    return ActionResult(
        "opencode",
        path,
        "conflict",
        "OpenCode plugin file exists but is not managed by SNotice.",
    )


def run_for_agent(
    command: str,
    agent: str,
    home: Path,
    command_name: str,
    script_path: Path,
    host: str,
    port: int,
    python_executable: str,
    force: bool,
) -> ActionResult:
    target_path = (
        claude_path(home)
        if agent == "claude"
        else codex_path(home)
        if agent == "codex"
        else opencode_plugin_path(home)
    )
    try:
        if command == "install":
            if agent == "claude":
                return install_claude(
                    home,
                    command_name,
                    script_path,
                    host,
                    port,
                    python_executable,
                    force,
                )
            if agent == "codex":
                return install_codex(
                    home,
                    command_name,
                    script_path,
                    host,
                    port,
                    python_executable,
                    force,
                )
            return install_opencode(
                home,
                command_name,
                script_path,
                host,
                port,
                python_executable,
                force,
            )
        if command == "uninstall":
            if agent == "claude":
                return uninstall_claude(
                    home,
                    command_name,
                    script_path,
                    host,
                    port,
                    python_executable,
                )
            if agent == "codex":
                return uninstall_codex(
                    home,
                    command_name,
                    script_path,
                    host,
                    port,
                    python_executable,
                )
            return uninstall_opencode(
                home,
                command_name,
                script_path,
                host,
                port,
                python_executable,
            )
        if agent == "claude":
            return claude_status(
                home,
                command_name,
                script_path,
                host,
                port,
                python_executable,
            )
        if agent == "codex":
            return codex_status(
                home,
                command_name,
                script_path,
                host,
                port,
                python_executable,
            )
        return opencode_status(
            home,
            command_name,
            script_path,
            host,
            port,
            python_executable,
        )
    except Exception as err:
        return ActionResult(
            agent,
            target_path,
            "error",
            f"{type(err).__name__}: {err}",
        )


def print_results(results: list[ActionResult]) -> int:
    exit_code = 0
    for result in results:
        print(f"[{result.agent}] {result.status}")
        print(f"  path: {result.path}")
        print(f"  detail: {result.detail}")
        if result.status in {"conflict", "error"}:
            exit_code = 1
    return exit_code


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    home = resolve_home(args)
    bin_dir = resolve_bin_dir(args, home)
    command_name = args.command_name.strip() or "snotice"
    script_path = Path(args.script_path).expanduser().resolve()
    python_executable = args.python.strip() or sys.executable

    if not script_path.exists():
        print(f"Adapter script not found: {script_path}")
        return 1

    launcher_result = (
        install_launcher(bin_dir, command_name, script_path, python_executable)
        if args.command == "install"
        else uninstall_launcher(bin_dir, command_name)
        if args.command == "uninstall"
        else launcher_status(bin_dir, command_name)
    )
    results = [launcher_result]
    results.extend(
        [
        run_for_agent(
            args.command,
            agent,
            home,
            command_name,
            script_path,
            args.host,
            args.port,
            python_executable,
            getattr(args, "force", False),
        )
        for agent in selected_agents(args.agent)
    ])
    return print_results(results)


if __name__ == "__main__":
    raise SystemExit(main())
