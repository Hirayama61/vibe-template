#!/bin/bash
# Bash ツールで git push が実行される前に 2 つを確かめる。
#   1. push 先が main でないこと (AGENTS.md「main への直 push は禁止」)。
#      GitHub のブランチ保護は無料プランの非公開リポジトリでは効かないので、ここで止める。
#   2. make check が通ること (AGENTS.md「push 前に make check を必ず通す」)。
# どちらかに引っかかったら exit 2 で push を止め、理由を stderr に出す。
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# 1. main への push を拒否する。
#    - 今いるブランチが main なら、引数に関係なく拒否 (git push / git push origin HEAD など)。
#    - 引数に main が単独のトークンとして現れたら拒否 (origin main / HEAD:main / main:main)。
#      issue/12-main-page や origin/main のような一部分としての main は対象外。
branch=$(git branch --show-current 2>/dev/null || true)
if [ "$branch" = "main" ] || printf '%s' "$cmd" | grep -Eq '(^|[^A-Za-z0-9_/.-])main([^A-Za-z0-9_/.-]|$)'; then
  cat >&2 <<'MSG'
main への直 push は禁止です (AGENTS.md)。
作業ブランチを切ってから別のコマンドで push し、PR を作ってください。
  git checkout -b issue/<番号>-<slug>
  git push -u origin HEAD
MSG
  exit 2
fi

# 2. make check を通す。
if ! out=$(make check 2>&1); then
  printf 'make check が失敗したため push を止めました。直してから push してください。\n\n%s\n' "$out" >&2
  exit 2
fi
exit 0
