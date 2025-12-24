#!/usr/bin/env bash
set -euo pipefail

# 捕获 tmux pane 输出并发送给 AI 修复（tmux 快捷键优化版）
# 用法: capture_and_fix.sh [pane_id]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.cache/tmux-fix"
mkdir -p "$CACHE_DIR"

pane_id="${1:-}"

# 如果没有指定 pane_id，使用当前 pane
if [[ -z "$pane_id" ]]; then
  pane_id=$(tmux display-message -p '#P')
fi

# 捕获 pane 内容
CAPTURE_LINES=50
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$CACHE_DIR/${TIMESTAMP}.txt"

tmux capture-pane -t "$pane_id" -p -S -"$CAPTURE_LINES" > "$OUTPUT_FILE"

# 获取 pane 的当前路径
pane_path=$(tmux display-message -t "$pane_id" -p '#{pane_current_path}')

# 生成提示词
PROMPT_FILE="$CACHE_DIR/${TIMESTAMP}_prompt.txt"
cat > "$PROMPT_FILE" <<EOF
请分析以下终端输出，识别错误或问题，并提供修复方案。

工作目录: $pane_path

终端输出:
\`\`\`
$(cat "$OUTPUT_FILE")
\`\`\`

请提供：
1. 问题分析
2. 修复方案（如果需要运行命令，请明确列出命令）
3. 相关文件和行号（如果有）
EOF

# 调用 AI 工具（在新 pane 中运行）
AI_CMD=""
if command -v opencode >/dev/null 2>&1; then
  AI_CMD="cat \"$PROMPT_FILE\" | opencode"
elif command -v claude >/dev/null 2>&1; then
  AI_CMD="cat \"$PROMPT_FILE\" | claude"
elif command -v aider >/dev/null 2>&1; then
  AI_CMD="cd \"$pane_path\" && aider --message \"$(cat "$PROMPT_FILE" | tr '\n' ' ')\""
fi

if [[ -z "$AI_CMD" ]]; then
  # 没有找到 AI 工具，在新 pane 中显示内容
  tmux split-window -h -c "$pane_path" -p 30 "
    echo '🔍 已捕获输出'
    echo ''
    echo '📍 输出文件: $OUTPUT_FILE'
    echo '📍 提示词文件: $PROMPT_FILE'
    echo ''
    cat \"$OUTPUT_FILE\"
    exec bash
  "
else
  # 在新 pane 中运行 AI 工具
  tmux split-window -h -c "$pane_path" -p 60 "eval $AI_CMD || (echo 'AI 工具执行失败'; exec bash)"
fi
