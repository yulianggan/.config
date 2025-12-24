#!/usr/bin/env bash
set -euo pipefail

# 捕获当前 pane 输出并复制到剪贴板
# 用法: capture_and_send.sh [pane_id]

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

# 准备发送的提示词
PROMPT="请分析以下终端输出，识别问题并提供修复方案：

\`\`\`
$(cat "$OUTPUT_FILE")
\`\`\`

请提供：
1. 问题分析
2. 修复方案
3. 需要修改的文件和行号"

# 保存提示词到文件
PROMPT_FILE="$CACHE_DIR/${TIMESTAMP}_prompt.txt"
echo "$PROMPT" > "$PROMPT_FILE"

# 复制到系统剪贴板
if command -v pbcopy >/dev/null 2>&1; then
  cat "$PROMPT_FILE" | pbcopy
  tmux display-message "✅ 已复制到剪贴板，请按 Cmd+V 粘贴"
  tmux display-message "💾 文件: $PROMPT_FILE"
else
  tmux display-message "⚠️  pbcopy 不可用"
  tmux display-message "💾 文件: $PROMPT_FILE"
  tmux display-message "📝 运行: cat \"$PROMPT_FILE\" | opencode"
fi
