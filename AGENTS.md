# 運用ルール

このリポジトリの作業はすべて AI エージェントが行う。人間は Issue で依頼と不具合報告を出し、成果物だけを見る。
人間はコードを読まない前提で動くこと。正しさの根拠は常にテストと CI に置く。

## 流れ

```
依頼 (request) ─┐
不具合 (bug) ───┼→ ready な Issue → ブランチ → PR → 自動レビュー → CI 緑 → マージ → Issue が閉じる
```

main への直 push は禁止。すべて PR を経由する。Claude のセッションからの main への push は hook が止める (無料プランの非公開リポジトリでは GitHub 側のブランチ保護が効かないため)。

## Issue

- 入口は 2 つ。人間が書く `request` (依頼) と `bug` (不具合報告)。どちらもそのままでは着手しない。
  - `request` はエージェントが「完了条件」を持つ 1 つ以上の `ready` な Issue に整形する。
  - `bug` はエージェントが再現テストを書いて失敗を確認してから `ready` にする。再現できなければ `needs-input`。
- 状態ラベル: `ready` (着手可) → `in-progress` (作業中) → 閉じて完了。人の判断待ちは `needs-input`、先行 Issue 待ちは `blocked`。
- 1 Issue = 1 PR = 1 セッション。大きければ分割して起案する。
- 本文の「完了条件」が受け入れ基準。無い Issue には着手せず `needs-input` を付ける。
- 同時に `in-progress` にできる Issue は 2 件まで。
- Issue 本文に無いことはやらない。気づいた課題は別 Issue にする。

## PR

- タスクの契約は `make` の 6 ターゲット (`setup` / `check` / `fmt` / `test` / `e2e` / `build`)。CI も同じものを呼ぶ。
- push 前に `make fmt && make check` を必ず通す。通らないものは push しない。
- バグ修正 PR には回帰テストを必ず含める。機能追加 PR にはその機能のテストを含める。
- PR を作ったエージェントがマージまで責任を持つ。CI の失敗とレビュー指摘は同じセッションで直す。
- レビュー指摘への修正は 3 ラウンドまで。超えたら `needs-input` を付けて人間に戻す。
- 同じレビュー指摘が 2 回出たら、lint ルール・フォーマッタ設定・テストのどれかに昇格させる Issue を起案する。
- マージは squash。ブランチはマージ後に削除する。

## 環境

- すべての作業は Claude のクラウドコンテナで行う。使えるツールチェーンは node 22 / bun / python3 + uv / go / rust。
- 外部ネットワークは制限される。依存の取得は npm / PyPI / crates.io / Go proxy から。それ以外の配布元に頼らない。
- GitHub の操作は `gh api` (REST) か GitHub の MCP ツールで行う。`gh issue` / `gh pr` のサブコマンドは GraphQL を使うため失敗する。
- 秘密情報をコード・コミット・Issue に入れない。

## やってはいけないこと

- テストをスキップ・無効化・削除して CI を通す。
- 人間の判断が要ることを推測で進める。`needs-input` で止める。
- Issue 本文に無いことをやる。
- 他人のブランチの履歴を書き換える (rebase / amend / force push)。
