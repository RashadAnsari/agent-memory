#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=json.sh
source "$(dirname "$0")/json.sh"

# Claude Code and Codex, which share this output schema. SessionStart context
# decays as the conversation grows and can be lost in compaction, so this
# re-injects a one-line reminder each turn. Cursor has no equivalent
# (beforeSubmitPrompt can only block, not inject); there the alwaysApply
# rules/agent-memory.mdc is re-sent every request instead.
REMINDER="Per-turn reminder: search agent memory (project_search / user_search) for context relevant to this prompt before acting, and store durable learnings with project_remember / user_remember before finishing. Never save silently: for every memory you store, update, or archive, tell the user in your reply what you learned, why it matters, and whether it went to project or user memory."

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":%s}}\n' "$(json_string "$REMINDER")"
