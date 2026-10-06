# CLAUDE.md

@AGENTS.md

## スキルと Routine の対応

| 役 | スキル | 起動 |
| --- | --- | --- |
| ワーカー | `/work-issue` | Routine で 2 時間おき (`docs/routines.md`)。対話で番号を指定しても使える |
| 庭師 | `/gardening` | Routine で週 1 回 |
| 起案 | `/create-issue` | 対話セッションで人間と一緒に使う。承認してから作成する |
| トリアージ | `/triage` | `bug` Issue に対してワーカーが呼ぶ。対話でも使える |
| 言語決定 | `/init-stack` | 最初の Issue で 1 回だけ |

Routine の本文は `/work-issue` や `/gardening` の 1 行だけ。手順の本体はこのリポジトリのスキルにあり、PR で改善する。

## Hook

- SessionStart: クラウドセッションでだけ `make setup` を走らせる。
- PreToolUse (Bash): `git push` の前に `make check` を走らせ、失敗したら push を止める。

## 初期設定

テンプレートから作った直後のリポジトリで「初期設定をして」と言われたら `scripts/repo-setup.sh` を実行する。ラベル、auto-merge、ブランチ保護を入れる。

## プロジェクト固有の章

`/init-stack` が言語を決めたとき、ここから下に「構成」「コマンド」「テストの置き方」を足す。テンプレート時点では空。
