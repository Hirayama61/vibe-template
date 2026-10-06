---
name: work-issue
description: ワーカー。bug のトリアージ、request の整形、ready な Issue の実装のうち 1 つを行い、PR を作ってマージまで面倒を見る。Routine と対話セッションの両方がこの手順で動く。
argument-hint: "[Issue 番号 (省略時は自動で選ぶ)]"
---

# work-issue

1 回の実行で扱う Issue は 1 件。終わったら次を拾わずに報告して終える (Routine は次の起動で次を拾う)。
GitHub の操作は `gh api` (REST) で行う。`gh issue` / `gh pr` は GraphQL のため使えない。

```sh
R="repos/$(git remote get-url origin | sed -E 's#.*github.com[:/]##; s#\.git$##')"
```

## 1. 最新化

```sh
git checkout main && git pull --rebase origin main
make setup
```

## 2. 何をやるか決める

番号が指定されていればその Issue を使う (状態に応じて 3 / 4 / 5 のどれかへ)。指定が無ければ、上から順に最初に見つかったものを 1 件だけやる。

```sh
# a. 未トリアージの不具合報告 (bug で、ready / needs-input / blocked のどれも付いていない)
gh api "$R/issues?state=open&labels=bug&per_page=100" --jq '.[] | select([.labels[].name] | any(. == "ready" or . == "needs-input" or . == "blocked") | not) | "#\(.number) \(.title)"'
# b. 未整形の依頼 (request で、needs-input が付いていない)
gh api "$R/issues?state=open&labels=request&per_page=100" --jq '.[] | select([.labels[].name] | any(. == "needs-input") | not) | "#\(.number) \(.title)"'
# c. 着手可能な Issue
gh api "$R/issues?state=open&labels=ready&per_page=100" --jq '.[] | "#\(.number) \(.title) \(.created_at)"'
gh api "$R/issues?state=open&labels=in-progress&per_page=100" --jq '.[] | "#\(.number) \(.title) \(.updated_at)"'
```

- a があれば → 3 へ。b があれば → 4 へ。c があれば → 5 へ。
- c で `in-progress` が既に 2 件あるなら着手しない (並列上限)。`in-progress` のまま 6 時間以上更新が無い Issue は放置とみなし、その旨をコメントして `in-progress` を外してよい (選ぶのは次回)。
- `needs-input` / `blocked` は選ばない。候補が無ければ「着手できる Issue はありません」と報告して終える。
- c の候補が複数あれば古いものを優先する。

## 3. 不具合のトリアージ

`/triage <番号>` の手順で行う。結果は `ready` (再現テストあり) か `needs-input` のどちらか。ここで終える。

## 4. 依頼の整形

`/create-issue` の DISCOVER → FRAME → DRAFT と同じ基準で、依頼を「完了条件」を持つ `ready` な Issue に変換する。人間はいないので GRILL (質問) はしない。

- 独立した目的が複数混ざっていれば、Issue を複数に分ける。
- 回答によって目的・スコープ・完了条件が変わる曖昧さがあるなら、質問を箇条書きで依頼にコメントして `needs-input` を付け、整形しない。実装方法 (How) しか変わらない曖昧さは自分で決める。
- 作った Issue の本文の「参考情報」に元の依頼 `#<番号>` を書き、依頼側には作った Issue の番号をコメントして閉じる (`state_reason=completed`)。

ここで終える。

## 5. 実装

```sh
N=<番号>
gh api -X POST "$R/issues/$N/labels" -f 'labels[]=in-progress' >/dev/null
gh api -X DELETE "$R/issues/$N/labels/ready" >/dev/null
gh api -X POST "$R/issues/$N/comments" -f body="着手します ($(date -u +%Y-%m-%dT%H:%MZ))" >/dev/null
git checkout -b "issue/$N-<短い英語スラッグ>" main
```

- Issue 本文の「達成したい状態」「スコープ」「制約」「完了条件」に従う。本文に無いことはやらない。
- `AGENTS.md` と `CLAUDE.md` の約束事を守る。機能にはテストを、バグ修正には回帰テストを必ず足す。
- 本文の前提が間違っている、判断が要る、完了条件を満たせないと分かったら、理由をコメントして `needs-input` を付け、`in-progress` を外し、ブランチは push せずに終える。

## 6. 検証とセルフレビュー

```sh
make fmt && make check
make e2e   # 画面やサービスの結合に触ったとき
```

通るまで push しない。通ったら自分の差分を `/code-review` で見直し、見つかった問題を直してもう一度 `make check`。

## 7. PR

コミットメッセージの本文に `Closes #<番号>` を入れる。push したら `.github/pull_request_template.md` の構成で本文を書き、PR を作る。

```sh
git push -u origin HEAD
gh api -X POST "$R/pulls" -f title="<Issue のタイトル>" -f head="$(git branch --show-current)" -f base=main -F body=@<本文ファイル>
```

- GitHub の MCP ツール `enable_pr_auto_merge` (squash) が使えれば有効にする。使えなければ 8 で自分でマージする。
- `subscribe_pr_activity` で PR を購読する。以降、CI の結果とレビューはイベントとして届く。

## 8. マージまで

PR を作ったセッションがマージまで責任を持つ。イベントが届くたびに次を見る。

- **CI が赤** → 原因を直して push。「flake」で片付けない。
- **レビュー指摘** → 直して push し、スレッドに 1 行で返す。指摘が妥当でなければ理由を返して閉じる。修正ラウンドは 3 回まで。超えたら `needs-input` を付けて人間に戻し、PR はそのまま残す。
- **コンフリクト** → `git merge origin/main` で解消して検証し直し、push。
- **CI 緑、未解決のスレッド無し、auto-merge が無効** → `gh api -X PUT "$R/pulls/<PR 番号>/merge" -f merge_method=squash`。
- 同じ指摘が過去の PR でも出ていたと気づいたら、lint ルール・フォーマッタ設定・テストへ昇格させる Issue を `/create-issue` の基準で起案する (承認は不要)。

## 9. 完了

- Issue に 5 行以内で「何をどう変えたか」「検証したこと」「残したこと」をコメントする。
- `in-progress` を外す。マージで閉じなかった場合は `gh api -X PATCH "$R/issues/$N" -f state=closed -f state_reason=completed`。
- 扱った Issue 番号、結果 (完了 / needs-input / 候補なし)、PR 番号を 1〜3 行で報告して終える。
