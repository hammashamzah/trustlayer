#!/bin/bash
# TrustLayer PostToolUse Hook: Auto-run scoped tests after edits
# Triggers on: Edit|Write
# Reads: .claude/current-task-scope.json
# Based on compiler-in-the-loop.sh pattern

# Read input once
INPUT=$(cat)

# Early exit if no scope file — no TrustLayer session active
SCOPE_FILE="$CLAUDE_PROJECT_DIR/.claude/current-task-scope.json"
if [ ! -f "$SCOPE_FILE" ]; then
  echo '{}'
  exit 0
fi

# Extract the edited file path (try both tool input formats)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null)
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  echo '{}'
  exit 0
fi

# Make path relative to project dir for matching
REL_PATH="${FILE_PATH#$CLAUDE_PROJECT_DIR/}"

# Read scope config
TEST_CMD=$(jq -r '.test_command // ""' "$SCOPE_FILE" 2>/dev/null)
if [ -z "$TEST_CMD" ] || [ "$TEST_CMD" = "null" ]; then
  echo '{}'
  exit 0
fi

# Check if edited file is within allowed scope
IN_SCOPE=false
while IFS= read -r pattern; do
  # Convert glob pattern to work with bash matching
  # Replace ** with any path and * with any segment
  if [[ "$REL_PATH" == $pattern ]]; then
    IN_SCOPE=true
    break
  fi
done < <(jq -r '.allowed_paths[]' "$SCOPE_FILE" 2>/dev/null)

if [ "$IN_SCOPE" = false ]; then
  # Check if it's a test file (always allow test edits to trigger)
  if [[ "$REL_PATH" == tests/* ]] || [[ "$REL_PATH" == *test* ]] || [[ "$REL_PATH" == *spec* ]]; then
    IN_SCOPE=true
  fi
fi

if [ "$IN_SCOPE" = false ]; then
  echo '{}'
  exit 0
fi

# Run scoped tests
TEST_OUTPUT=$(cd "$CLAUDE_PROJECT_DIR" && eval "$TEST_CMD" 2>&1 | tail -30)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  # Tests failed — provide feedback to Claude so it can fix
  # Using additionalContext instead of block so Claude sees the failure and self-corrects
  ESCAPED_OUTPUT=$(echo "$TEST_OUTPUT" | jq -Rs .)
  echo "{\"additionalContext\": \"TrustLayer: Scoped tests FAILED after edit to $REL_PATH. Fix before continuing:\\n\"$ESCAPED_OUTPUT\"\"}"
else
  echo "{\"additionalContext\": \"TrustLayer: Scoped tests passed after edit to $REL_PATH.\"}"
fi
