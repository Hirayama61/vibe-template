#!/bin/bash
# Bash ツールで git push が実行される前に make check を通す。失敗したら push を止める。
# AGENTS.md の「push 前に make check を必ず通す」を hook で強制するもの。
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

if ! out=$(make check 2>&1); then
  printf 'make check が失敗したため push を止めました。直してから push してください。\n\n%s\n' "$out" >&2
  exit 2
fi
exit 0
