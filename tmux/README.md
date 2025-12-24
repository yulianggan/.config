# Tmux Configuration Guide (Colemak Optimized)

这份 Tmux 配置专为 **Colemak 键盘布局** 深度定制，集成了高级的自动排序会话管理系统、基于脚本的窗口/面板操作以及 Agent Tracker 集成。

## 核心基础 (Core)

- **前缀键 (Prefix):** `Ctrl + s` (取代了默认的 `Ctrl+b`)
- **方向键映射 (Colemak):** 遵循 Vim 的 Colemak 键位风格：
    - `n` : 左 (Left)
    - `e` : 下 (Down)
    - `u` : 上 (Up)
    - `i` : 右 (Right)

## 1. 会话管理 (Session Management)

本配置使用 `session_manager.py` 驱动独特的会话管理系统，自动保持会话以 `1-Name`, `2-Name` 格式编号和排序，便于通过数字键快速切换。

| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
|他第308 `Alt + S` | **新建会话** | 创建一个新会话并自动编号 |
| `Prefix + .` | **重命名会话** | 弹出提示框重命名当前会话 |
| `Prefix + l` | **左移会话** | 将当前会话在列表中的顺序向前移 (交换序号) |
| `Prefix + y` | **右移会话** | 将当前会话在列表中的顺序向后移 |
| `Ctrl + 1` ~ `9` | **切换会话** | 快速切换到第 1 到 9 号会话 |
| `F1` ~ `F5` | **切换会话** | 备用的切换快捷键 |

## 2. 窗口管理 (Window Management)

| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| `Alt + o` | **新建窗口** | 在当前目录新建窗口 |
| `Prefix + ,` | **重命名窗口** | 重命名当前窗口 |
| `Alt + 1` ~ `9` | **切换窗口** | 直接跳转到对应编号的窗口 |
| `Ctrl + p` | **上一窗口** | Previous window |
| `Ctrl + n` | **下一窗口** | Next window |
| `Prefix + 1` ~ `0` | **移动窗口** | **特色功能**：将当前窗口移动到第 N 个会话中 |
| `Alt + l` | **左移窗口** | 交换当前窗口与左侧窗口的位置 |
| `Alt + y` | **右移窗口** | 交换当前窗口与右侧窗口的位置 |
| `Alt + s` | **Scratchpad** | 切换暂存窗口 |

## 3. 面板管理 (Pane Management)

面板操作完全适配 **Colemak (n/e/u/i)** 键位。

### 创建与关闭
| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| `Prefix + n` | **左分屏** | 在左侧创建新面板 (`split-window -hb`) |
| `Prefix + e` | **下分屏** | 在下方创建新面板 (`split-window -v`) |
| `Prefix + u` | **上分屏** | 在上方创建新面板 (`split-window -vb`) |
| `Prefix + i` | **右分屏** | 在右侧创建新面板 (`split-window -h`) |
| `Alt + Q` | **关闭面板** | Kill 当前面板 |
| `Alt + O` | **拆分面板** | 将当前面板拆分出去成为一个独立的新窗口 (Break pane) |

### 导航与调整
| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| `Alt + n` | **焦点向左** | 移动光标到左侧面板 |
| `Alt + e` | **焦点向下** | 移动光标到下方面板 |
| `Alt + u` | **焦点向上** | 移动光标到上方面板 |
| `Alt + i` | **焦点向右** | 移动光标到右侧面板 |
| `Alt + N/E/U/I` | **调整大小** | 向 左/下/上/右 调整面板大小 (步长 3) |
| `Alt + f` | **最大化** | 切换当前面板的全屏缩放 (Zoom) |

### 移动与布局
| 快捷键 | 功能 | 说明 |
| :--- | :--- | :--- |
| `Prefix + >` | **向下换** | 与下一个面板交换位置 |
| `Prefix + <` | **向上换** | 与上一个面板交换位置 |
| `Prefix + Space` | **切换布局** | 在水平/垂直平铺布局间切换 (仅限2个面板时) |
| `Alt + Shift + 1-9` | **加入窗口** | 将当前面板加入到第 1-9 号窗口 (Join pane) |

### 高级布局构建 (Layout Builder)
使用 `Prefix + 方向` 快速构建复杂布局 (基于 `layout_builder.sh`)：
- `Prefix + I` (Right): 当前面板保留，右侧构建分割。
- `Prefix + N` (Left): 向左构建。
- `Prefix + U` (Up): 向上构建。
- `Prefix + E` (Down): 向下构建。

## 4. 复制与粘贴 (Copy Mode)

- **进入模式:** `Alt + v`
- **操作 (Vi 风格):**
    - `v`: 开始选择字符
    - `Ctrl + v`: 块选择模式 (Rectangle toggle)
    - `y`: 复制选区到系统剪贴板
    - `n/e/u/i`: 光标移动 (Colemak)
    - `h`: 下一个单词结尾
- **粘贴:**
    - `Ctrl + Shift + v` 或 `Alt + Shift + v`: 从系统剪贴板粘贴到 Tmux

## 5. 其他特色功能 (Special Features)

- **Agent Tracker 集成:**
    - `Alt + t`: 切换 Agent Tracker 状态。
    - `Alt + m`: 聚焦到最新通知的任务。
    - `Alt + Shift + m`: 聚焦到最后的任务来源。
    - 自动钩子：自动记录 Pane 焦点、销毁等事件。
- **项目自动激活 (Project Hooks):**
    - 切换窗口时，会自动检查并执行当前路径下的 `on-tmux-window-activate.sh`。
