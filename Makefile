# タスクの契約。スキルと CI はこの 6 ターゲットしか呼ばない。
# 言語が決まるまでは全部 "not configured"。/init-stack が中身を埋める。
.DEFAULT_GOAL := help
.PHONY: help setup check fmt test e2e build

help: ## ターゲット一覧
	@grep -E '^[a-z0-9]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{ printf "  %-8s %s\n", $$1, $$2 }'

setup: ## 依存関係の導入。SessionStart hook がクラウドでだけ呼ぶ
	@echo "setup: not configured"

check: ## lint / format 確認 / 型チェック / テスト。push 前と CI はこれだけ
	@echo "check: not configured"

fmt: ## 自動整形。push 前に必ず通す
	@echo "fmt: not configured"

test: ## テストだけ。triage が再現テストの失敗を確かめるときに使う
	@echo "test: not configured"

e2e: ## 画面やサービスの結合確認。無いプロジェクトでは空のまま
	@echo "e2e: not configured"

build: ## 成果物の生成
	@echo "build: not configured"
