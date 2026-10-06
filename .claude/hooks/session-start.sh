#!/bin/bash
# Claude Code のクラウドセッション開始時に make setup を走らせ、テスト・lint が動く状態にする。
# 手元のセッションでは何もしない (手元の環境を勝手に変えない)。
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
make setup
