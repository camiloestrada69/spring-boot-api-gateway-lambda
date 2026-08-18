#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): reverts the body of StandardResponse.pruebaCodigo
# to its baseline version, undoing any edit made to that method.
# Baseline resolution order: origin/main -> local HEAD -> cached first-seen snapshot.
set -euo pipefail

REL_PATH="api-gateway/api-gateway/src/main/java/com/example/api_gateway/utils/objects/StandardResponse.java"
BASELINE_CACHE="$(dirname "$0")/pruebacodigo-baseline.txt"
REMOVED_CACHE="$(dirname "$0")/pruebacodigo-removed.txt"

INPUT=$(cat)
FILE=$(node -e '
  let d="";
  process.stdin.on("data", c => d += c);
  process.stdin.on("end", () => {
    try {
      const j = JSON.parse(d);
      process.stdout.write(j.tool_response?.filePath || j.tool_input?.file_path || "");
    } catch (e) {}
  });
' <<< "$INPUT")

[[ -z "$FILE" ]] && exit 0
[[ "$FILE" == *StandardResponse.java ]] || exit 0

extract_method() {
  awk '
    /public void pruebaCodigo\(T body\) \{/ {flag=1}
    flag {print; if (/^ {4}\}/) exit}
  ' <<< "$1"
}

CURR_METHOD=$(extract_method "$(cat "$FILE")")
[[ -z "$CURR_METHOD" ]] && exit 0

ORIG_METHOD=""
MAIN_CONTENT=$(git show "origin/main:$REL_PATH" 2>/dev/null || true)
[[ -n "$MAIN_CONTENT" ]] && ORIG_METHOD=$(extract_method "$MAIN_CONTENT")

if [[ -z "$ORIG_METHOD" ]]; then
  HEAD_CONTENT=$(git show "HEAD:$REL_PATH" 2>/dev/null || true)
  [[ -n "$HEAD_CONTENT" ]] && ORIG_METHOD=$(extract_method "$HEAD_CONTENT")
fi

if [[ -z "$ORIG_METHOD" && -f "$BASELINE_CACHE" ]]; then
  ORIG_METHOD=$(cat "$BASELINE_CACHE")
fi

if [[ -z "$ORIG_METHOD" ]]; then
  # First time seeing pruebaCodigo anywhere: adopt current content as baseline, no revert.
  printf '%s' "$CURR_METHOD" > "$BASELINE_CACHE"
  exit 0
fi

[[ "$ORIG_METHOD" == "$CURR_METHOD" ]] && exit 0

# Remember what the edit removed, so a later git push can restore it.
printf '%s' "$CURR_METHOD" > "$REMOVED_CACHE"

TMP=$(mktemp)
awk -v repl="$ORIG_METHOD" '
  /public void pruebaCodigo\(T body\) \{/ {print repl; flag=1; next}
  flag {if (/^ {4}\}/) {flag=0}; next}
  {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "{\"systemMessage\": \"Se revirtio el metodo pruebaCodigo en StandardResponse.java a su version base.\"}"
