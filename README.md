# vibe-template

Claude Code のリモート Routine だけで開発を完結させるためのテンプレートリポジトリ。

このテンプレートから作ったリポジトリでは、**人間はコードを読まない**。
人間がやるのは「依頼を書く」「不具合を報告する」「成果物を見る」の 3 つだけで、
Issue の整形・実装・テスト・レビュー・マージはすべて AI エージェントが行う。

## 使い方

1. GitHub で **Use this template** から新しいリポジトリを作る
2. [docs/setup.md](docs/setup.md) の手順で初期設定と Routine の登録をする (人間がやるのはここだけ)
3. あとは Issue を書く。依頼は「依頼」テンプレート、不具合は「不具合報告」テンプレートで

## 中身

| パス | 役割 |
| --- | --- |
| `AGENTS.md` | 運用ルール。Claude 以外のエージェント (ChatGPT など) もこれを読む |
| `CLAUDE.md` | Claude 固有の設定。`AGENTS.md` を取り込み、スキルと Routine の対応を書く |
| `Makefile` | タスクの契約。`setup / check / fmt / test / e2e / build` の 6 つだけ |
| `.claude/skills/` | ワーカー、起案、トリアージ、庭師、言語決定のスキル |
| `.claude/hooks/` | セッション開始時の `make setup` と、push 前の `make check` 強制 |
| `.github/` | Issue と PR のテンプレート、CI |
| `docs/routines.md` | 人間が登録する Routine の一覧 |
| `scripts/repo-setup.sh` | ラベル、auto-merge、ブランチ保護の初期設定 |

開発言語とフレームワークはテンプレートでは決めない。最初の Issue で `/init-stack` が決めて埋める。
