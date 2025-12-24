#!/usr/bin/env bash
set -euo pipefail

# 只捕获 pane 输出并显示，不调用 AI
# 用法: capture_only.sh [pane_id]

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

# 获取 pane 信息
pane_path=$(tmux display-message -t "$pane_id" -p '#{pane_current_path}')
pane_cmd=$(tmux display-message -t "$pane_id" -p '#{pane_current_command}')

# 检测问题类型
detect_error_type() {
  local file="$1"
  if grep -qi "error:" "$file"; then
    echo "error"
  elif grep -qi "failed\|failure\|exception\|traceback" "$file"; then
    echo "exception"
  elif grep -qi "typeerror\|syntaxerror\|referenceerror\|valueerror" "$file"; then
    echo "type_error"
  elif grep -qi "warning:" "$file"; then
    echo "warning"
  elif grep -qi "cannot find\|not found\|no such file" "$file"; then
    echo "missing_file"
  else
    echo "output"
  fi
}

ERROR_TYPE=$(detect_error_type "$OUTPUT_FILE")

# 在新 pane 中显示捕获的内容
tmux split-window -h -c "$pane_path" -p 40 "
  echo '🔍 已捕获 Pane $pane_id 的输出'
  echo ''
  echo '📍 工作目录: $pane_path'
  echo '📍 当前命令: $pane_cmd'
  echo '📍 错误类型: $ERROR_TYPE'
  echo '📍 输出文件: $OUTPUT_FILE'
  echo ''
  echo '=================================='
  echo ''
  cat \"$OUTPUT_FILE\"
  echo ''
  echo '=================================='
  echo ''
  echo '💡 使用以下命令发送给 AI:'
  echo \"   cat \\\"$OUTPUT_FILE\\\" | opencode\"
  echo \"   cat \\\"$OUTPUT_FILE\\\" | claude\"
  exec bash
"
