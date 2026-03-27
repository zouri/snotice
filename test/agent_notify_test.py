from __future__ import annotations

import importlib.util
import pathlib
import unittest


def load_module():
    root = pathlib.Path(__file__).resolve().parent.parent
    module_path = root / "scripts" / "agent_notify.py"
    spec = importlib.util.spec_from_file_location("agent_notify", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Failed to load scripts/agent_notify.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


agent_notify = load_module()


class AgentNotifyTest(unittest.TestCase):
    def test_claude_permission_maps_to_edge_flash(self) -> None:
        normalized = agent_notify.normalize_event(
            "claude",
            {
                "hook_event_name": "Notification",
                "message": "Permission required to run command",
                "session_id": "claude-1",
            },
            "",
        )

        payload = agent_notify.map_event_to_notification(normalized, "", "", "", "")

        self.assertEqual(payload["category"], "flash_edge")
        self.assertEqual(payload["flashColor"], "#F59E0B")
        self.assertEqual(payload["priority"], "high")
        self.assertEqual(payload["payload"]["agent"], "claude")

    def test_codex_error_maps_to_edge_flash(self) -> None:
        normalized = agent_notify.normalize_event(
            "codex",
            {
                "event": "task_failed",
                "message": "Build failed after tests",
                "cwd": "/tmp/demo",
            },
            "",
        )

        payload = agent_notify.map_event_to_notification(normalized, "", "", "", "")

        self.assertEqual(payload["category"], "flash_edge")
        self.assertEqual(payload["flashColor"], "#EF4444")
        self.assertEqual(payload["payload"]["cwd"], "/tmp/demo")

    def test_opencode_idle_maps_to_normal_notification(self) -> None:
        normalized = agent_notify.normalize_event(
            "opencode",
            {
                "event": {
                    "type": "session.idle",
                    "message": "The agent finished the current task.",
                },
                "sessionId": "open-1",
            },
            "",
        )

        payload = agent_notify.map_event_to_notification(normalized, "", "", "", "")

        self.assertNotIn("category", payload)
        self.assertEqual(payload["title"], "[Opencode] Task finished")
        self.assertEqual(payload["payload"]["sessionId"], "open-1")


if __name__ == "__main__":
    unittest.main()
