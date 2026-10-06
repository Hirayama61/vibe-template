---
name: gardening
description: 庭師。週 1 回、放置された Issue・PR・ブランチを片付け、レビュー指摘の再発をルールへ昇格させ、Routine の失敗パターンからスキルや運用ルールの改善 Issue を起案する。
---

# gardening

リポジトリを人間が見なくても荒れないようにする。コードは直さない。直すべきことは Issue にしてワーカーに渡す。
1 回の実行で起案する Issue は 3 件まで。それ以上は次回に回す (ワーカーの処理能力を超えない)。

```sh
R="repos/$(git remote get-url origin | sed -E 's#.*github.com[:/]##; s#\.git$##')"
SINCE=$(date -u -d '8 days ago' +%Y-%m-%dT%H:%MZ)
```

## 1. 片付け

```sh
gh api "$R/issues?state=open&labels=in-progress&per_page=100" --jq '.[] | "#\(.number) \(.updated_at)"'
gh api "$R/pulls?state=open&per_page=100" --jq '.[] | "#\(.number) \(.head.ref) \(.updated_at) draft=\(.draft)"'
gh api "$R/branches?per_page=100" --jq '.[].name'
```

- `in-progress` のまま 6 時間以上更新が無い Issue: 「放置されたため ready に戻します」とコメントし、`in-progress` を外して `ready` を付ける。
- 開いている PR: CI が緑で未解決スレッドが無ければ squash でマージする。CI が赤で 24 時間以上動きが無ければ、Issue に `needs-input` を付けて PR にその旨をコメントする。
- ブランチの削除はセッションからはできない (API も `git push --delete` もプロキシが 403 を返す)。マージ済みブランチは GitHub の「Automatically delete head branches」に任せる。PR の無いまま 7 日以上更新の無いブランチは、報告に名前を挙げるだけにする。
- `needs-input` が 14 日以上放置: 何を聞いているかを 3 行に要約してコメントし直す (人間がスマホで見て答えられるように)。

## 2. レビュー指摘の昇格

```sh
gh api "$R/pulls?state=closed&sort=updated&direction=desc&per_page=30" --jq '.[] | select(.merged_at != null and .merged_at > "'"$SINCE"'") | .number'
gh api "$R/pulls/<番号>/comments" --jq '.[].body'
gh api "$R/pulls/<番号>/reviews" --jq '.[].body'
```

この 1 週間にマージされた PR のレビューコメントを読み、同じ種類の指摘が 2 回以上出ていたら、再発させない仕組みへ昇格させる Issue を 1 件起案する。昇格先は次の優先順で選ぶ。

1. lint ルールかフォーマッタ設定 (機械的に検出できるもの)
2. テスト (振る舞いとして検証できるもの)
3. `AGENTS.md` か `CLAUDE.md` の 1 行 (上の 2 つで表現できない約束事)

Issue の完了条件は「この指摘を含むコードで `make check` が失敗する」のように検証可能にする。

## 3. Routine の健康診断

```sh
gh api "$R/issues?state=all&since=$SINCE&per_page=100" --jq '.[] | "#\(.number) [\([.labels[].name]|join(","))] \(.title)"'
```

この 1 週間の Issue の動きから、ワーカーがつまずいたパターンを探す。

- `needs-input` に落ちた Issue が多い → 起案 (`create-issue` / `request` の整形) の基準が甘い。質問の内容を読み、整形時に自分で決められたはずのものがあればスキルの直し方を Issue にする。
- 「着手します」のコメントの後に完了コメントが無い Issue → ワーカーがセッション途中で止まっている。原因が手順にあれば `work-issue` の直し方を Issue にする。
- レビュー修正が 3 ラウンドに達した PR → 実装前の確認が足りない。`work-issue` の 6 (セルフレビュー) に足すべき観点を Issue にする。

スキルや運用ルールの改善も通常の Issue と同じで、ワーカーが PR で直す。

## 4. 報告

片付けたもの、起案した Issue、見送ったことを 5 行以内で報告して終える。起案も片付けも無ければ「異常なし」の 1 行でよい。
