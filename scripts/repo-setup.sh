#!/bin/bash
# テンプレートから作った直後のリポジトリに、ラベル・auto-merge・ブランチ保護を入れる。
# 何度実行しても同じ結果になる。GitHub の操作は gh api (REST) で行う。
set -euo pipefail

R="repos/$(git remote get-url origin | sed -E 's#.*github.com[:/]##; s#\.git$##')"
echo "対象: $R"

# ラベル。既にあれば色と説明を更新する。
label() { # name color description
  if gh api "$R/labels/$1" >/dev/null 2>&1; then
    gh api -X PATCH "$R/labels/$1" -f color="$2" -f description="$3" >/dev/null
  else
    gh api -X POST "$R/labels" -f name="$1" -f color="$2" -f description="$3" >/dev/null
  fi
  echo "label: $1"
}
label request      "c5def5" "人間からの依頼。エージェントが ready な Issue に整形する"
label bug          "d73a4a" "不具合報告。エージェントが再現テストを書いて ready にする"
label ready        "0e8a16" "着手可能。ワーカーが拾う"
label in-progress  "fbca04" "作業中"
label needs-input  "d876e3" "人間の判断待ち"
label blocked      "b60205" "先行 Issue 待ち"

# マージの設定。squash のみ、auto-merge 可、マージ後にブランチ削除。
gh api -X PATCH "$R" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F allow_auto_merge=true -F delete_branch_on_merge=true >/dev/null
echo "merge: squash のみ / auto-merge 有効 / マージ後ブランチ削除"

# ブランチ保護。CI (check) を必須にし、直 push を禁止する。人間の承認は要求しない。
# 非公開リポジトリでは GitHub Pro が無いと 403 になる。その場合は運用ルール (AGENTS.md) だけで守る。
if gh api -X PUT "$R/branches/main/protection" --input - >/dev/null 2>&1 <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["check"] },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
then
  echo "protection: main は PR 必須 / CI 必須 / force push 禁止"
else
  echo "protection: 設定できませんでした (非公開リポジトリで GitHub Pro が無い場合は仕様)。AGENTS.md のルールで直 push を避けます" >&2
fi

echo "完了"
