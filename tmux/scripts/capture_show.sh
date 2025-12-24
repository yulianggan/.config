#!/usr/bin/env bash
set -euo pipefail

# 简化版：只捕获并显示快捷命令
# 用法: capture_show.sh [pane_id]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.cache/tmux-fix"
mkdir -p "$CACHE_DIR"

pane_id="${1:-}"

# 如果没有指定 pane_id，使用当前 pane
if [[ -z "$pane_id" ]]; then
  pane_id=$(tmux display-message -p '#P')
fi

# 捕获 pane 内容
CAPTURE_LINES=100
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$CACHE_DIR/${TIMESTAMP}.txt"

tmux capture-pane -t "$pane_id" -p -S -"$CAPTURE_LINES" > "$OUTPUT_FILE"

# 显示消息
tmux display-message "✅ 已捕获输出: $OUTPUT_FILE"

# 在新 pane 中显示内容
tmux split-window -h -p 40 "echo '🔍 已捕获输出'; echo ''; cat \"$OUTPUT_FILE\"; echo ''; echo '💡 复制命令:'; echo '   cat \"$OUTPUT_FILE\" | opencode'; exec bash"
