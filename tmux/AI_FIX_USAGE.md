# Tmux AI 修复工具使用说明

## 快捷键

- **Alt + G**: 捕获并在新 pane 显示
- **Alt + Shift + G**: 智能捕获并自动打开 AI 分析
- **Alt + Shift + K**: 捕获并复制到剪贴板（推荐）

## 脚本说明

### capture_show.sh
捕获 pane 输出，在新 pane 中显示内容。

### smart_fix.sh
捕获输出、检测错误类型，并自动在新 pane 中调用 AI 工具进行分析。

### capture_and_send.sh
捕获输出并复制到系统剪贴板，用户手动粘贴到 AI agent（最稳定）。

## 使用流程

### 推荐：Alt+Shift+K（最稳定）

```bash
# 1. 在一个 pane 中运行命令（有错误）
npm run dev

# 2. 按 Alt+Shift+K
# -> 内容自动复制到剪贴板

# 3. 切换到 AI agent pane（opencode/claude）

# 4. 按 Cmd+V 粘贴并回车
```

### 方案二：Alt+G（查看内容）

```bash
# 1. 按 Alt+G
# -> 新 pane 显示捕获内容

# 2. 复制显示的命令

# 3. 在 AI agent 中粘贴运行
```

### 方案三：Alt+Shift+G（自动调用 AI）

```bash
# 1. 按 Alt+Shift+G
# -> 自动在新 pane 调用 AI 工具分析
```

## 输出文件位置

所有捕获保存在 `~/.cache/tmux-fix/` 目录：
- `{TIMESTAMP}.txt`: 原始输出
- `{TIMESTAMP}_prompt.txt`: AI 提示词

## 配置生效

重新加载 tmux 配置：

```bash
tmux source-file ~/.tmux.conf
```

或在 tmux 中按 `Ctrl+s` 然后 `r`。

## 支持的 AI 工具

自动检测（按优先级）：
1. opencode
2. claude
3. aider

## 手动运行示例

```bash
# 捕获并复制到剪贴板
~/.config/tmux/scripts/capture_and_send.sh

# 捕获并显示
~/.config/tmux/scripts/capture_show.sh

# 智能捕获
~/.config/tmux/scripts/smart_fix.sh

# 指定 pane
~/.config/tmux/scripts/capture_and_send.sh %2
```

## 修复历史

### 修复 v2（最新）
**问题**: Alt+Shift+K 自动粘贴时内容重复、截断
**原因**: `tmux paste-buffer` 在快捷键上下文中不可靠
**解决**: 改为复制到剪贴板，用户手动粘贴

### 修复 v1
**问题**: 原脚本在 tmux 快捷键模式下卡死
**原因**: `read` 命令等待用户输入时阻塞
**解决**: 移除交互式确认，直接在新 pane 中显示或运行 AI 工具
