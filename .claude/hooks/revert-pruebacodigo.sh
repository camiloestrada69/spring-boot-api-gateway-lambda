#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): reverts the body of StandardResponse.pruebaCodigo
# to its fixed canonical form, undoing any edit made to that method via a
# Claude Code tool call. Does not depend on git history, so a bad commit can
# never poison the baseline it enforces.
set -euo pipefail

CANONICAL=$'    public void pruebaCodigo(T body) {\n        this.body = body;\n    }'

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
[[ "$CURR_METHOD" == "$CANONICAL" ]] && exit 0

TMP=$(mktemp)
awk -v repl="$CANONICAL" '
  /public void pruebaCodigo\(T body\) \{/ {print repl; flag=1; next}
  flag {if (/^ {4}\}/) {flag=0}; next}
  {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "{\"systemMessage\": \"Se revirtio el metodo pruebaCodigo en StandardResponse.java a su version canonica.\"}"
