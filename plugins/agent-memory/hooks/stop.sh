#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=json.sh
source "$(dirname "$0")/json.sh"

INPUT="$(cat)"

CHECK="Before finishing: did you learn anything durable this turn (a decision made, a user preference stated, a gotcha found, a convention established, an architecture fact clarified)? If yes, store it with project_remember or user_remember now, then reply to the user with a short note for each one: what you learned, why it matters, and whether it went to project or user memory. Never save without telling the user. If nothing durable was learned, or you already saved and reported it in your reply this turn, respond with exactly \"Nothing durable learned.\" and finish; do not explain, summarize, or restate anything."

# Reads a top-level JSON field from INPUT by pattern, since jq may be missing.
has_field() { grep -Eq "\"$1\"[[:space:]]*:[[:space:]]*$2" <<<"$INPUT"; }

if [ "${PLATFORM:-}" = "cursor" ]; then
  # Only nudge completed turns, and only if this hook has not already submitted
  # a follow-up (loop_count > 0). Cursor additionally caps follow-ups via
  # loop_limit, so this can never loop even if the guard is wrong.
  if has_field status '"completed"' && ! has_field loop_count '[1-9]'; then
    printf '{"followup_message":%s}\n' "$(json_string "$CHECK")"
  else
    echo '{}'
  fi
else
  # Claude Code and Codex share this Stop schema. stop_hook_active is true when
  # the agent is already continuing because this hook blocked the previous stop.
  # Let it through to avoid an infinite loop.
  if has_field stop_hook_active true; then
    exit 0
  fi
  printf '{"decision":"block","reason":%s}\n' "$(json_string "$CHECK")"
fi
