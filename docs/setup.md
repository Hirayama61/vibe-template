# 新しいリポジトリの立ち上げ

人間がやるのはこのページの手順だけ。全部で 10 分くらい。

## 1. リポジトリを作る

GitHub でこのテンプレートの **Use this template** → **Create a new repository**。
名前を決めて作る。公開・非公開はどちらでもよいが、非公開でブランチ保護を使うには GitHub Pro が要る (無くても運用ルールで直 push しないので動く)。

## 2. Claude がそのリポジトリを触れるようにする

Claude アプリ → 設定 → GitHub 連携で、作ったリポジトリを Claude GitHub App の対象に加える。
https://claude.ai/connect-github から辿れる。

## 3. 初期設定をさせる

作ったリポジトリを選んで Claude Code のセッションを開き、「初期設定をして」と送る。
Claude が `scripts/repo-setup.sh` を実行して、ラベル・auto-merge・ブランチ保護を入れる。

## 4. 自動レビューを入れる

PR のレビューは GitHub 側のイベントで動く bot に任せる。Anthropic の Claude Code Review (GitHub App) をこのリポジトリに入れる。
入れられない場合でも、ワーカーは PR を作る前に自分の差分を `/code-review` で見直すので、レビュー無しにはならない。

## 5. Routine を登録する

[routines.md](routines.md) の 2 つを登録する。

## 6. 言語を決める

最初の Issue を「依頼」テンプレートで出す。例: 「TypeScript + Vite + React で作る。`/init-stack` を使って」。
ワーカーがこれを拾い、ツールチェーンを入れた PR を作る。マージされたら以降は普通に依頼を出すだけ。

## 日々やること

- やりたいことは「依頼」テンプレートで Issue にする。雑でよい。曖昧なら `needs-input` で質問が返ってくるので答える。
- おかしい動きは「不具合報告」テンプレートで Issue にする。再現と修正はエージェントがやる。
- `needs-input` の Issue が溜まっていたら答える。これだけが人間を待っているもの。
