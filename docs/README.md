# SNotice 文档导航

本目录用于沉淀 SNotice 的“当前可执行文档”和“历史提案文档”。

## 当前有效文档

- [architecture.md](./architecture.md)
  - 项目整体架构、启动链路、模块职责、REST/MCP 流程、平台差异与测试覆盖。
- [agent_integration.md](./agent_integration.md)
  - AI Agent 接入说明（MCP + Skill + Hook/Notify 适配脚本）。
- [integrations/claude_code.md](./integrations/claude_code.md)
  - Claude Code hooks 接到 SNotice 的示例配置。
- [integrations/codex.md](./integrations/codex.md)
  - Codex `notify` 接到 SNotice 的示例配置。
- [integrations/opencode.md](./integrations/opencode.md)
  - OpenCode plugin 事件接到 SNotice 的示例配置。
- `scripts/install_agent_hooks.py`
  - 一键安装、状态检查、卸载 Claude Code / Codex / OpenCode 的本地接入。

## 维护建议

- 功能或模块有结构调整时，优先更新 `architecture.md`。
- API/MCP 协议变更时，更新 `agent_integration.md`、`README.md` 与
  `docs/integrations/*.md` 示例。
