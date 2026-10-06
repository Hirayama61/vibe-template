---
name: init-stack
description: 開発言語とフレームワークを決めた最初の Issue で 1 回だけ使う。ツールチェーン・lint・フォーマッタ・テストランナーを入れ、Makefile の 6 ターゲットを埋め、CLAUDE.md にプロジェクト固有の章を足す。
argument-hint: "<言語やフレームワーク (例: TypeScript + Vite + React)>"
---

# init-stack

テンプレートは言語を決めていない。この手順で決めて埋める。通常の Issue と同じく、ブランチを切って PR で入れる (`/work-issue` の 5 以降に従う)。

## 制約

- クラウドコンテナに最初から入っているものだけで動くこと: node 22 / bun / python3 + uv / go / rust。
- 依存の取得は npm / PyPI / crates.io / Go proxy から。それ以外の配布元 (独自インストーラ、GitHub Releases 直リンク) に頼らない。
- lint とフォーマッタは必ず入れる。レビュー指摘を設定へ昇格させる先が無いと `gardening` のループが回らない。
- テストランナーも必ず入れ、動作確認用のテストを 1 つ置く。`make test` が 1 件以上実行して成功する状態にする。

## 手順

1. Issue に書かれた言語・フレームワークで、その言語で標準的な lint / フォーマッタ / テストランナーを選ぶ。選択肢が複数あるなら、設定が少なく済むものを選ぶ (How はこの手順の裁量)。
2. 設定ファイルと `.gitignore` を置く。
3. `Makefile` の 6 ターゲットを埋める。`check` は lint → format 確認 → 型チェック → `test` の順で全部を呼ぶ。`e2e` が無いプロジェクトは `@echo "e2e: none"` のままにする。
4. `make setup && make fmt && make check && make build` が通ることを確認する。
5. `CLAUDE.md` の「プロジェクト固有の章」に「構成」「コマンド」「テストの置き方」を足す。新しいセッションがこれだけ読めば開発を始められる粒度にする。
6. `AGENTS.md` の「環境」に、選んだツールチェーンを 1 行追記する。
7. `.github/workflows/ci.yml` は `make` を呼ぶだけなので原則変更しない。ブラウザなど追加のセットアップが要るときだけ step を足す。
