# agent-memory

[![Build](https://github.com/RashadAnsari/agent-memory/actions/workflows/build.yml/badge.svg)](https://github.com/RashadAnsari/agent-memory/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platforms](https://img.shields.io/badge/works%20with-Claude%20Code%20%7C%20Cursor%20%7C%20Codex-555)

**Memory that persists across sessions for Claude Code, Cursor, and Codex.**

Agents look up project decisions and your preferences before they start, and save new ones when they finish, telling you each one in the chat. Memory follows the repository across clones and machines, and all three tools share the same database.

---

## Install

### Claude Code

```bash
claude plugin marketplace add RashadAnsari/agent-memory
claude plugin install agent-memory@agent-memory
```

Or run `/plugin marketplace add RashadAnsari/agent-memory` inside a session and install `agent-memory` from `/plugin`. Restart open sessions to load it. Update with `claude plugin marketplace update agent-memory`.

### Codex

```bash
codex plugin marketplace add RashadAnsari/agent-memory
codex plugin add agent-memory@agent-memory
```

Restart Codex, then run `/hooks` once to trust the plugin's hooks. Codex ships plugin hooks as untrusted, so they do not run until you review them.

### Cursor

Copy the plugin into Cursor's local plugins folder:

```bash
git clone --depth 1 https://github.com/RashadAnsari/agent-memory /tmp/agent-memory
mkdir -p ~/.cursor/plugins/local
rm -rf ~/.cursor/plugins/local/agent-memory
cp -R /tmp/agent-memory/plugins/agent-memory ~/.cursor/plugins/local/agent-memory
rm -rf /tmp/agent-memory
```

Run **Developer: Reload Window** to load it. Run the same commands again to update. On Enterprise plans, an admin must turn on **Allow Local Plugin Imports** first.

On a team plan, an admin can instead import `https://github.com/RashadAnsari/agent-memory` under **Plugins** > **Team Marketplaces** in the Cursor dashboard, and members install `agent-memory` from there.

### Requirements

The MCP server runs with [uv](https://docs.astral.sh/uv/). If `uv` is not on `PATH`, the plugin installs it on first start with the official installer. The embedding model (about 130 MB) downloads once on first use.

---

## What the plugin adds

### MCP server

`agent-memory` stores two kinds of memory with semantic search, and rejects vague, duplicate, and secret-containing entries:

- **Project memory** is tied to the repository's `origin` remote, so it follows the repo across clones and machines. Repositories without a remote fall back to their local path. `project_search` with `all_projects: true` searches every project at once, and each result says which repository it came from.
- **User memory** holds your preferences and applies to every project.

Tools: `project_remember`, `project_search`, `project_update`, `project_forget`, `project_purge`, and the same five for `user_`. See the [server README](plugins/agent-memory/mcp-servers/agent-memory/README.md) for details.

### Skills

| Skill | What it does |
|-------|--------------|
| `agent-memory` | Search memory before non-trivial work, and save durable learnings after it, telling you each one in the chat |
| `/remember <what>` | Saves something to project or user memory, or this session's learnings when given nothing |
| `/forget <what>` | Finds and removes matching entries from project and user memory |
| `/enrich` | Mines the 100 most recently merged pull requests for decisions, conventions, and gotchas, and saves them to project memory |

`/forget` and `/enrich` run only when you type them. In Codex, run skills with `$<name>`.

### Hooks

| Hook | Runs | What it does |
|------|------|--------------|
| `session-start` | Start of every session | Tells the agent to search memory and load the `agent-memory` skill before its first answer |
| `user-prompt-submit` | Every prompt | Repeats a one-line memory reminder, since session-start context fades in long conversations |
| `stop` | End of every turn | Asks the agent whether it learned anything durable and, if so, to save it and tell you what it saved and why |

Cursor drops the context a session-start hook returns and has no per-prompt hook, so the plugin also ships `rules/agent-memory.mdc`, an always-on rule with the same text.

---

## Storage

Memory lives in one SQLite database at `~/.agent-memory/memory.sqlite`, outside every repository and every plugin folder, so updating or uninstalling the plugin keeps it. Set `AGENT_MEMORY_DIR` to move it.

---

## Contributing

Repository rules for contributors and agents are in [`AGENTS.md`](AGENTS.md). Run `make local` before opening a pull request.

---

## License

[MIT](LICENSE) © Rashad Ansari
