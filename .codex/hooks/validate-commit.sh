#!/bin/bash
# PROJECT_NAME PreToolUse hook: Validates git commit commands
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)

# Parse command
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only process git commit commands
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+commit'; then
    exit 0
fi

# Get staged files
STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
    exit 0
fi

WARNINGS=""

# Validate JSON data files -- block invalid JSON
DATA_FILES=$(echo "$STAGED" | grep -E '\.json$')
if [ -n "$DATA_FILES" ]; then
    PYTHON_CMD=""
    for cmd in python python3 py; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    done

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if [ -n "$PYTHON_CMD" ]; then
                if ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                    echo "BLOCKED: $file is not valid JSON" >&2
                    exit 2
                fi
            fi
        fi
    done <<< "$DATA_FILES"
fi

# Check for cross-identity session state edits
source .codex/hooks/resolve-identity.sh
IDENTITY=$(resolve_identity 2>/dev/null)
ROLE=$(get_identity_role "$IDENTITY" 2>/dev/null)
OTHER_STATE=$(echo "$STAGED" | grep "^team/session-state/" | grep -v "team/session-state/$IDENTITY/" 2>/dev/null)
if [ -n "$OTHER_STATE" ] && [ "$ROLE" != "admin" ]; then
    WARNINGS="$WARNINGS\nWARNING: You are modifying another developer's session state:"
    while IFS= read -r ofile; do
        WARNINGS="$WARNINGS\n  $ofile"
    done <<< "$OTHER_STATE"
fi

# Check for TODO/FIXME without assignee
SRC_FILES=$(echo "$STAGED" | grep -E '^client/Source/')
if [ -n "$SRC_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '(TODO|FIXME|HACK)[^(]' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\nSTYLE: $file has TODO/FIXME without owner tag. Use TODO(name) format."
            fi
        fi
    done <<< "$SRC_FILES"
fi

# Print warnings (non-blocking) and allow commit
if [ -n "$WARNINGS" ]; then
    echo -e "=== Commit Validation Warnings ===$WARNINGS\n================================" >&2
fi

exit 0

