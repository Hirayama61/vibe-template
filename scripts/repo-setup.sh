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

# マージの設定とブランチ保護は、Claude のセッションからは書き込めない (GitHub 連携のプロキシが
# リポジトリ設定の変更を拒否する)。人間が GitHub の Settings でやる。docs/setup.md の 3 を参照。
cat <<'MSG'

以下は GitHub の Settings で人間が設定してください (Claude からは変更できません):
  General → Pull Requests: Allow squash merging だけ ON、Allow auto-merge ON、
                           Automatically delete head branches ON
  General → Template repository: テンプレートとして使うリポジトリだけ ON
  Branches → Add rule (main): Require a pull request、Require status checks (check)、
                              Do not allow bypassing the above settings
完了
MSG
