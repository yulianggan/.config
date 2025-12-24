# Tmux AI 修复工具

通过快捷键捕获 tmux pane 的输出内容，并联动 AI 工具进行分析和修复。

## 功能

- **capture_and_fix.sh**: 捕获 pane 输出并发送给 AI 分析
- **smart_fix.sh**: 智能捕获 pane 输出，自动检测错误类型并提供修复建议

## 使用方法

### 快捷键

- `Alt + F` (`M-F`): 捕获当前 pane 输出并询问是否发送给 AI
- `Alt + Shift + F` (`M-S-F`): 智能捕获并自动检测错误类型

### 手动运行

```bash
# 捕获当前 pane
~/.config/tmux/scripts/capture_and_fix.sh

# 捕获指定 pane
~/.config/tmux/scripts/capture_and_fix.sh %1

# 智能修复（自动模式）
~/.config/tmux/scripts/smart_fix.sh %1 --auto
```

## 支持的 AI 工具

脚本会自动检测以下 AI 工具（按优先级）：
1. **opencode**: Claude Code CLI 工具
2. **claude**: Anthropic Claude CLI
3. **aider**: AI pair programming tool

## 工作流程

1. 按下快捷键或运行脚本
2. 脚本捕获当前 pane 的最近 50-100 行输出
3. 显示捕获的内容并询问是否继续
4. 生成结构化的 AI 提示词
5. 调用 AI 工具进行分析
6. AI 提供问题和修复建议
7. 根据建议手动执行修复

## 历史记录

所有捕获的输出和提示词会保存在 `~/.cache/tmux-fix-history/` 目录中，文件名格式：
- `{TIMESTAMP}.txt`: 原始输出
- `{TIMESTAMP}_prompt.txt`: AI 提示词

## 配置

### 修改捕获行数

编辑脚本中的 `CAPTURE_LINES` 变量：

```bash
# capture_and_fix.sh
CAPTURE_LINES=100  # 默认 50

# smart_fix.sh  
CAPTURE_LINES=200  # 默认 100
```

### 自定义快捷键

在 `~/.config/tmux/.tmux.conf` 中修改绑定：

```tmux
bind -n YOUR_KEY run-shell "~/.config/tmux/scripts/smart_fix.sh"
```

## 示例场景

### 1. TypeScript 编译错误

```bash
npm run dev
# 显示编译错误...

# 按 Alt+Shift+F 捕获并修复
```

### 2. Python 异常

```bash
python main.py
# 显示 Traceback...

# 按 Alt+Shift+F 捕获并修复
```

### 3. Git 冲突

```bash
git pull
# 显示冲突信息...

# 按 Alt+F 捕获并咨询 AI
```

## 提示词结构

AI 提示词包含：
- 工作目录路径
- 当前运行的命令
- 检测到的错误类型（error/exception/warning/missing_file）
- 完整的终端输出
- 明确的修复要求

## 故障排除

### AI 工具未找到

确保已安装至少一个 AI 工具：

```bash
# 安装 opencode
npm install -g @anthropic-ai/opencode

# 安装 claude
npm install -g @anthropic-ai/claude

# 安装 aider
pip install aider-chat
```

### 权限问题

确保脚本有执行权限：

```bash
chmod +x ~/.config/tmux/scripts/*.sh
```

### 快捷键不生效

重新加载 tmux 配置：

```bash
tmux source-file ~/.tmux.conf
```

或在 tmux 中按 `Ctrl+s` 然后 `r`。

## 高级用法

### 结合 tmux hooks

在 `.tmux.conf` 中添加自动修复触发：

```tmux
# 当 pane 输出包含错误时自动提示
set-hook -ag after-new-pane 'run-shell "~/.config/tmux/scripts/smart_fix.sh"'
```

### 批量修复多个 pane

```bash
for pane in $(tmux list-panes -s -F '#{pane_id}'); do
  ~/.config/tmux/scripts/smart_fix.sh "$pane"
done
```

## 贡献

欢迎提交问题和改进建议！
