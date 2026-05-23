#!/bin/bash
# PROJECT_NAME Stop hook: Log session summary when Claude finishes
# Identity-aware: archives to per-developer session logs

source .claude/hooks/resolve-identity.sh

IDENTITY=$(resolve_identity)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Per-developer log directory
SESSION_LOG_DIR=$(get_session_logs_dir "$IDENTITY")
mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

# Log recent git activity from this session (check up to 8 hours for long sessions)
RECENT_COMMITS=$(git log --oneline --since="8 hours ago" 2>/dev/null)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null)

# --- Archive active session state on normal shutdown ---
STATE_FILE=$(get_session_state_file "$IDENTITY")
if [ -f "$STATE_FILE" ]; then
    # Archive to per-developer session log before session ends
    {
        echo "## Archived Session State: $TIMESTAMP"
        cat "$STATE_FILE"
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
    # active.md persists as living checkpoint (see .claude/docs/context-management.md)
fi

if [ -n "$RECENT_COMMITS" ] || [ -n "$MODIFIED_FILES" ]; then
    {
        echo "## Session End: $TIMESTAMP"
        if [ -n "$RECENT_COMMITS" ]; then
            echo "### Commits"
            echo "$RECENT_COMMITS"
        fi
        if [ -n "$MODIFIED_FILES" ]; then
            echo "### Uncommitted Changes"
            echo "$MODIFIED_FILES"
        fi
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
fi

exit 0

