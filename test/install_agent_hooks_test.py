from __future__ import annotations

import importlib.util
import json
import pathlib
import sys
import tempfile
import unittest


def load_module():
    root = pathlib.Path(__file__).resolve().parent.parent
    module_path = root / "scripts" / "install_agent_hooks.py"
    spec = importlib.util.spec_from_file_location("install_agent_hooks", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Failed to load scripts/install_agent_hooks.py")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


installer = load_module()


class InstallAgentHooksTest(unittest.TestCase):
    def test_claude_install_and_uninstall(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = pathlib.Path(tmp)
            script = home / "agent_notify.py"
            script.write_text("#!/usr/bin/env python3\n", encoding="utf-8")

            install_result = installer.install_claude(home, script, "127.0.0.1", 8642, False)
            self.assertEqual(install_result.status, "installed")

            settings_path = installer.claude_path(home)
            data = json.loads(settings_path.read_text(encoding="utf-8"))
            self.assertIn("hooks", data)
            self.assertIn("Notification", data["hooks"])
            self.assertIn("Stop", data["hooks"])

            status_result = installer.claude_status(home, script, "127.0.0.1", 8642)
            self.assertEqual(status_result.status, "installed")

            uninstall_result = installer.uninstall_claude(home, script, "127.0.0.1", 8642)
            self.assertEqual(uninstall_result.status, "removed")

            cleaned = json.loads(settings_path.read_text(encoding="utf-8"))
            self.assertNotIn("hooks", cleaned)

    def test_codex_conflict_requires_force(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = pathlib.Path(tmp)
            script = home / "agent_notify.py"
            script.write_text("#!/usr/bin/env python3\n", encoding="utf-8")

            config_path = installer.codex_path(home)
            config_path.parent.mkdir(parents=True, exist_ok=True)
            config_path.write_text('notify = ["python3", "/tmp/other.py"]\n', encoding="utf-8")

            result = installer.install_codex(home, script, "127.0.0.1", 8642, False)
            self.assertEqual(result.status, "conflict")

            forced = installer.install_codex(home, script, "127.0.0.1", 8642, True)
            self.assertEqual(forced.status, "installed")
            self.assertIn(str(script), config_path.read_text(encoding="utf-8"))

    def test_opencode_install_and_uninstall(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = pathlib.Path(tmp)
            script = home / "agent_notify.py"
            script.write_text("#!/usr/bin/env python3\n", encoding="utf-8")

            install_result = installer.install_opencode(home, script, "127.0.0.1", 8642, False)
            self.assertEqual(install_result.status, "installed")

            plugin_path = installer.opencode_plugin_path(home)
            self.assertTrue(plugin_path.exists())
            self.assertIn(installer.MANAGED_MARKER, plugin_path.read_text(encoding="utf-8"))

            status_result = installer.opencode_status(home, script, "127.0.0.1", 8642)
            self.assertEqual(status_result.status, "installed")

            uninstall_result = installer.uninstall_opencode(home, script, "127.0.0.1", 8642)
            self.assertEqual(uninstall_result.status, "removed")
            self.assertFalse(plugin_path.exists())


if __name__ == "__main__":
    unittest.main()
