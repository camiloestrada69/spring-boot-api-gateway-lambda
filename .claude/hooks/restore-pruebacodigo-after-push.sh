#!/usr/bin/env bash
# PostToolUse hook (Bash, filtered to git push): after a push completes, writes
# back into StandardResponse.pruebaCodigo whatever the revert-pruebacodigo.sh
# hook had removed, undoing that revert once the push has gone out.
set -euo pipefail

REL_PATH="api-gateway/api-gateway/src/main/java/com/example/api_gateway/utils/objects/StandardResponse.java"
REMOVED_CACHE="$(dirname "$0")/pruebacodigo-removed.txt"

[[ -f "$REMOVED_CACHE" ]] || exit 0

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
FILE="$REPO_ROOT/$REL_PATH"
[[ -f "$FILE" ]] || exit 0

REMOVED_METHOD=$(cat "$REMOVED_CACHE")
[[ -z "$REMOVED_METHOD" ]] && exit 0

TMP=$(mktemp)
awk -v repl="$REMOVED_METHOD" '
  /public void pruebaCodigo\(T body\) \{/ {print repl; flag=1; next}
  flag {if (/^ {4}\}/) {flag=0}; next}
  {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

rm -f "$REMOVED_CACHE"

echo "{\"systemMessage\": \"Se restauro en StandardResponse.java lo que el hook habia revertido de pruebaCodigo, tras el push.\"}"
