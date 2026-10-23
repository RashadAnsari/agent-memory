# Agent Rules & Conventions

Rules for all agents and subagents working in this repository.

---

## Install Rule

This repository is a plugin marketplace for one plugin, `plugins/agent-memory`. Users install it through each platform's marketplace:

- Claude Code reads `.claude-plugin/marketplace.json`.
- Codex reads `.agents/plugins/marketplace.json`.
- Cursor reads `.cursor-plugin/marketplace.json` for team marketplaces. Without one, users copy `plugins/agent-memory` into `~/.cursor/plugins/local/agent-memory` with the commands in `README.md`; Cursor skips symlinks that point outside that folder, so it must be a copy.

Do not add an install or uninstall script, and do not write anything into a user's home folder outside what the plugin does at runtime. Everything the plugin needs at runtime must work from a marketplace install: do not rely on tools a marketplace install cannot guarantee. Hooks therefore use plain bash and build their JSON with `hooks/json.sh` instead of `jq`, and the MCP server starts through `scripts/run-with-uv.sh`, which installs `uv` when it is missing.

The memory database lives in `~/.agent-memory`, outside the plugin folder, so plugin updates and uninstalls keep it. Never move it into a platform's plugin data folder: the platforms delete those on uninstall, and all three platforms must share one database.

---

## Platform Parity Rule

The three plugin manifests in `plugins/agent-memory/` (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`) keep the same name, version, and author, the same description apart from the platform it names, and the same hook events wired to the same scripts, as far as each platform supports them. Cursor has no prompt-submit hook.

Do not add a root `plugin.json` or a root `mcp.json` to the plugin. A root `plugin.json` makes Codex load it through the Agent Plugins loader, which silently drops every hook (openai/codex#39895), and stops Codex reading `.mcp.json`.

`plugins/agent-memory/.mcp.json` is shared by all three platforms. The server sets `"cwd": "."`, which Codex resolves to the plugin root so the `$(pwd)` fallback finds the plugin; Claude Code and Cursor use `${CLAUDE_PLUGIN_ROOT}` and ignore `cwd`. The Codex manifest declares `"mcpServers": "./.mcp.json"` explicitly, which is what makes Codex read it.

The marketplace name and the plugin name are both `agent-memory`, so in Claude Code the server's tools are named `mcp__plugin_agent-memory_agent-memory__<tool>`. Skills and agents that list these tools in `allowed-tools` or `tools`, here or in other plugins, use that prefix.

---

## Reminder Sync Rule

The session-start text exists twice and the copies must stay identical:

- `plugins/agent-memory/hooks/session-start.sh`: the `SessionStart` hook for Claude Code and Codex, and for Cursor once Cursor fixes a bug that drops `additional_context`.
- `plugins/agent-memory/rules/agent-memory.mdc`: an `alwaysApply` rule that delivers the same text to Cursor today.

Edit both in the same change. The duplication is intentional; do not replace it with a generator.

---

## Skills Rule

Every workflow the user runs by name is a skill in `plugins/agent-memory/skills/<name>/SKILL.md`. A skill with side effects or a high cost (`forget`, `enrich`) sets `disable-model-invocation: true` and has an `agents/openai.yaml` with `policy: allow_implicit_invocation: false`, since Codex ignores the first.

Only Claude Code fills in `$ARGUMENTS`. A skill that uses it must say, right after its first use, to take the value from the user's message when the placeholder is not filled in.

---

## README Sync Rule

After any change that affects what users see (a skill, hook, MCP tool, install step, or storage behavior), update `README.md` in the same change.

---

## Version Rule

Every change bumps the version in the same change. Claude Code and Codex cache a plugin by the version in its manifest, so a change that keeps the old version never reaches users who update.

The version appears in five places, and all of them must hold the same value:

- `plugins/agent-memory/.claude-plugin/plugin.json`
- `plugins/agent-memory/.codex-plugin/plugin.json`
- `plugins/agent-memory/.cursor-plugin/plugin.json`
- `plugins/agent-memory/mcp-servers/agent-memory/pyproject.toml`
- `plugins/agent-memory/mcp-servers/agent-memory/uv.lock`: run `uv lock` in that folder after editing `pyproject.toml`

Follow semantic versioning: a patch bump for fixes and for changes that do not alter behavior, a minor bump for new features or changed behavior, and a major bump for breaking changes, such as a renamed MCP tool or a database older versions cannot read. Once the change is on `master`, tag that commit `v<version>` and push the tag.

---

## Verify After Changes Rule

After completing any change, run from the repository root:

```
make local
```

This validates the plugin and marketplace, formats, lints, and tests the MCP server. Fix every failure and rerun until it exits cleanly before reporting a task as done.

---

## General Rules

- Read this file before doing anything in this repository.
- When spawning subagents, instruct each one to read `AGENTS.md` itself before acting.
- Never write decorative section separator comments such as `# ── function_name ──`. Use plain comments or no comment at all.
- Never use the em dash character in any output, file, or generated content. Use a colon, comma, or period instead.
