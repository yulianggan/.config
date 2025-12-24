#!/usr/bin/env bash
set -euo pipefail

# 智能捕获脚本 - 优化 tmux 快捷键调用
# 用法: smart_fix.sh [pane_id]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.cache/tmux-fix"
mkdir -p "$CACHE_DIR"

pane_id="${1:-}"

# 如果没有指定 pane_id，使用当前 pane
if [[ -z "$pane_id" ]]; then
  pane_id=$(tmux display-message -p '#P')
fi

# 捕获 pane 内容
CAPTURE_LINES=1000
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

# 生成提示词
PROMPT_FILE="$CACHE_DIR/${TIMESTAMP}_prompt.txt"
cat > "$PROMPT_FILE" <<EOF
请分析以下终端输出，识别问题并提供修复方案。

## 上下文信息
- 工作目录: $pane_path
- 当前命令: $pane_cmd
- 检测到的错误类型: $ERROR_TYPE

## 终端输出
\`\`\`
$(cat "$OUTPUT_FILE")
\`\`\`

## 要求
1. 分析问题原因
2. 如果是代码错误，指出文件路径和行号
3. 提供具体的修复步骤
4. 如果需要运行命令，请用 \`\`\`bash 标记代码块
5. 如果需要修改文件，请明确说明修改内容

请简洁明了，直接给出解决方案。
EOF

# 在新 pane 中打开 AI 工具
AI_CMD=""
if command -v opencode >/dev/null 2>&1; then
  AI_CMD="cat \"$PROMPT_FILE\" | opencode"
elif command -v claude >/dev/null 2>&1; then
  AI_CMD="cat \"$PROMPT_FILE\" | claude"
elif command -v aider >/dev/null 2>&1; then
  AI_CMD="cd \"$pane_path\" && aider --message \"$(cat "$PROMPT_FILE" | tr '\n' ' ')\""
fi

if [[ -z "$AI_CMD" ]]; then
  # 没有找到 AI 工具，显示文件内容
  tmux split-window -h -c "$pane_path" -p 30 "
    echo '🔍 已捕获输出并生成提示词'
    echo ''
    echo '📍 输出文件: $OUTPUT_FILE'
    echo '📍 提示词文件: $PROMPT_FILE'
    echo ''
    echo '=== 检测到的错误类型: $ERROR_TYPE ==='
    echo ''
    head -30 \"$OUTPUT_FILE\"
    if [[ \$(wc -l < \"$OUTPUT_FILE\") -gt 30 ]]; then
      echo ''
      echo '... (共 \$(wc -l < \"$OUTPUT_FILE\") 行)'
    fi
    echo ''
    echo '提示词:'
    cat \"$PROMPT_FILE\"
    exec bash
  "
else
  # 在新 pane 中运行 AI 工具
  tmux split-window -h -c "$pane_path" -p 60 "eval $AI_CMD || (echo 'AI 工具执行失败'; exec bash)"
fi
