#!/bin/bash
# PROJECT_NAME SessionStart hook: Detect documentation gaps
# Cross-platform: Windows Git Bash compatible

set +e

source .claude/hooks/resolve-identity.sh

IDENTITY=$(resolve_identity)

echo "=== Checking for Documentation Gaps ==="

# UE source directory for this project (project uses client/Source/ instead of src/)
UE_SOURCE_DIR="client/Source"

# --- Check 0: Fresh project detection (suggests /start) ---
FRESH_PROJECT=true

# Check if engine is configured
if [ -f ".claude/docs/technical-preferences.md" ]; then
  ENGINE_LINE=$(grep -E "^\- \*\*Engine\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
  if [ -n "$ENGINE_LINE" ] && ! echo "$ENGINE_LINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
    FRESH_PROJECT=false
  fi
fi

# Check if game concept exists
if [ -f "design/gdd/game-concept.md" ]; then
  FRESH_PROJECT=false
fi

# Check if UE source code exists (non-trivial: more than the default module skeleton)
if [ -d "$UE_SOURCE_DIR" ]; then
  SRC_CHECK=$(find "$UE_SOURCE_DIR" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) 2>/dev/null | head -1)
  if [ -n "$SRC_CHECK" ]; then
    FRESH_PROJECT=false
  fi
fi

if [ "$FRESH_PROJECT" = true ]; then
  echo ""
  echo "新项目：引擎未配置，无游戏概念，无源码。"
  echo "  运行 /start 查看项目状态并选择工作方向。"
  echo "  运行 /project-stage-detect 获取完整项目分析。"
  echo "==================================="
  exit 0
fi

# --- Check 1: Substantial codebase but sparse design docs ---
if [ -d "$UE_SOURCE_DIR" ]; then
  SRC_FILES=$(find "$UE_SOURCE_DIR" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) 2>/dev/null | wc -l)
else
  SRC_FILES=0
fi

if [ -d "design/gdd" ]; then
  DESIGN_FILES=$(find design/gdd -type f -name "*.md" 2>/dev/null | wc -l)
else
  DESIGN_FILES=0
fi

SRC_FILES=$(echo "$SRC_FILES" | tr -d ' ')
DESIGN_FILES=$(echo "$DESIGN_FILES" | tr -d ' ')

if [ "$SRC_FILES" -gt 50 ] && [ "$DESIGN_FILES" -lt 5 ]; then
  echo "GAP: Substantial codebase ($SRC_FILES source files in $UE_SOURCE_DIR) but sparse design docs ($DESIGN_FILES files)"
  echo "  Suggested action: /reverse-document design $UE_SOURCE_DIR/[system]"
  echo "  Or run: /project-stage-detect to get full analysis"
fi

# --- Check 2: Pending "TBD ADR" placeholders awaiting backfill ---
# Counts unresolved placeholders that should be replaced once the corresponding
# ADR is written. Match on full-width punctuation (：（) which is unique to the
# placeholder syntax — avoids self-matching this hook's own ASCII strings.
# See docs/architecture/README.md for the index.
TBD_ADR_PATTERN='TBD ADR[：（]'
TBD_ADR_COUNT=$(grep -rnE "$TBD_ADR_PATTERN" design/ 2>/dev/null | wc -l)
TBD_ADR_COUNT=$(echo "$TBD_ADR_COUNT" | tr -d ' ')

if [ "$TBD_ADR_COUNT" -gt 0 ]; then
  echo ""
  echo "GAP: $TBD_ADR_COUNT 处 \"TBD ADR\" 占位待回填"
  TBD_FILES=$(grep -rlE "$TBD_ADR_PATTERN" design/ 2>/dev/null | tr '\n' ' ')
  echo "  涉及文件: $TBD_FILES"
  echo "  追踪清单: docs/architecture/README.md"
  echo "  Suggested: 写完对应 ADR 后按清单替换 TBD 占位"
fi

# --- Summary ---
echo ""
echo "To get a comprehensive project analysis, run: /project-stage-detect"
echo "==================================="

exit 0

