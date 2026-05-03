MCfun

Minecraft 指令编辑器 —— 让每条指令都有趣

<div align="center">

https://img.shields.io/badge/Godot-4.6.1-478CBF?logo=godot-engine&logoColor=white
https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/Status-Stable-brightgreen
https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Web-lightgrey

一个功能完整的 Minecraft 指令编辑器，支持语法高亮、智能补全和实时错误检测

</div>

---

📖 项目简介

MCfun 是一个为 Minecraft 玩家设计的智能指令编辑工具。它不仅是一个编辑器，更是一个完整的语法解析引擎——能够理解 Minecraft 指令的语法结构，实时提供补全建议，并高亮显示每条指令的各个部分。

为什么叫 MCfun？

Minecraft 是有趣的，指令也是有趣的。让编辑指令的过程也变得有趣。

---

✨ 核心功能

🎨 语法高亮

· 指令名、参数、坐标、选择器分色显示
· 支持 Minecraft 颜色码（§ 格式）
· 实时高亮更新

🔍 智能补全

· 上下文感知的指令补全
· 1500+ 物品名、100+ 实体名自动补全
· 目标选择器参数补全（@p[name=...]）
· 支持命名空间格式（minecraft:diamond）

⚠️ 错误检测

· 实时语法检查
· 参数类型验证
· 括号匹配与嵌套检查

⌨️ 编辑器特性

· 多光标支持
· 智能缩进
· 双击符号映射（如 .. → ~）
· 补全项权重排序

---

🎮 支持的指令

指令 参数 说明
execute 30+ 条件执行，支持子命令递归
scoreboard 20+ 计分板管理
tp 10+ 传送（支持 facing 等参数）
summon 12+ 召唤实体
give / clear 5+ 物品管理
effect 6+ 状态效果
gamerule 3+ 游戏规则（动态补全）
tellraw 2+ JSON 文本显示
... ... 共 25+ 条指令

补全数据规模

· 🧱 物品：1500+ 种（minecraft 命名空间）
· 👾 实体：100+ 种
· ✨ 状态效果：40+ 种
· 🏷️ 标签：动态积累

---

🏗️ 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                    表现层 (Editor)                       │
│          FunctionEdit (继承 Godot CodeEdit)              │
│              语法高亮 + 补全显示 + 光标管理               │
└─────────────────────────────────────────────────────────┘
							  ↓
┌─────────────────────────────────────────────────────────┐
│                   解析层 (Element)                       │
│   22种元素类型 | 递归下降解析 | 括号匹配 | 错误收集       │
└─────────────────────────────────────────────────────────┘
							  ↓
┌─────────────────────────────────────────────────────────┐
│                   规则层 (Grammar)                       │
│   指令结构定义 | 嵌套规则 | 补全数据 | 内嵌命令           │
└─────────────────────────────────────────────────────────┘
							  ↓
┌─────────────────────────────────────────────────────────┐
│                   数据层 (JSON)                          │
│     Grammer.json | GrammerLaw.json | GrammerEntry.json   │
└─────────────────────────────────────────────────────────┘
```

类型系统

支持 22 种 Minecraft 指令参数类型：

基础类型 复合类型 高级类型
bool, int, float, string dictionary, array, quotation selector, coords, spaceitem
word, option, scope point_path, rich_string command (递归)

补全模式

模式 说明
NORMAL 直接插入
WORLD 替换当前单词
SPACEITEM 智能处理 namespace:item
SELECTOR 目标选择器补全
QUOTATION 引号内补全
POINT_PATH 点号路径补全（如 slot.weapon.mainhand）

---

📁 项目结构

```
MCfun/
├── resource/                 # 数据资源
│   ├── grammer/             # 语法定义（编译后缓存）
│   ├── law/                 # 嵌套规则（编译后缓存）
│   └── entry/               # 补全条目（编译后缓存）
│
├── script/
│   ├── element/             # 解析元素
│   │   ├── child/          # 16种具体元素类型
│   │   └── *.gd            # 基类定义
│   ├── grammer/            # 规则编译系统
│   │   ├── Grammer.gd      # 指令语法编译
│   │   ├── GrammerLaw.gd   # 嵌套规则编译
│   │   └── GrammerEntry.gd # 补全数据编译
│   ├── manager/            # 工厂与管理
│   │   ├── ElementManager.gd
│   │   ├── ElementRule.gd
│   │   └── ElementRuleCMD.gd
│   ├── Edit.gd             # 编辑器核心
│   ├── Global.gd           # 全局单例
│   ├── StringTool.gd       # 字符串工具库
│   └── ...
│
├── main.tscn               # 主场景
│
├── Grammer.json            # 指令语法配置
├── GrammerLaw.json         # 嵌套规则配置
└── GrammerEntry.json       # 补全数据配置
```

---

🚀 开始使用

环境要求

· Godot 4.6.1 或更高版本
· 支持 Vulkan 的设备（Android / Windows / Web）

运行方式

方式一：Godot 编辑器运行

```bash
git clone https://github.com/Paotons/MCfun.git
cd MCfun
# 用 Godot 4.6.1 打开 project.godot
```

方式二：导出为应用程序

· Android：导出 APK，安装到手机
· Windows：导出可执行文件
· Web：导出 HTML5，部署到网页

方式三：已编译版本（如有）

前往 Releases 下载对应平台的预编译版本

基本操作

操作 说明
输入指令 自动触发补全和高亮
Tab 接受补全建议
Enter 换行
双击 符号映射（如 .. → ~）
多光标 Ctrl+左键 或 Alt+左键

---

📊 项目统计

维度 数据
GDScript 44 个文件 / ~5100 行
JSON 配置 3 个文件 / ~6500 行
总代码量 ~11600 行
开发周期 约 2 个月（2025.3.1 - 2025.4.25）
指令支持 25+ 条
物品数据 1500+ 种
实体数据 100+ 种

---

🛠️ 技术亮点

1. 完整的语法解析引擎

· 递归下降解析器，支持子命令嵌套
· 22 种类型系统，可扩展
· 括号匹配支持嵌套、转义、字符串保护

2. 可配置的规则系统

· 指令结构通过 JSON 定义，无需改代码
· 支持 goto 跳转（选项驱动的解析路径）
· 支持 extends 继承（条件参数）

3. 智能补全算法

· 模糊匹配 + 连续性加权排序
· 6 种插入模式，适配不同场景
· 动态补全（历史输入积累）

4. 高性能设计

· 正则表达式预编译
· 行 ID 系统（删除行后 ID 不复用）
· 字符串工具库（避免频繁创建临时字符串）

---

🙏 致谢

· Mojang Studios - 创造了一个值得为之写解析器的游戏
· Godot 社区 - 提供了优秀的开源引擎
· 每一位测试用户 - 你们的反馈让 MCfun 变得更好

---

📝 开发日志

v1.0.0 (2026.4.25)

· ✅ 完成 25+ 条指令的语法定义
· ✅ 实现 1500+ 物品/100+ 实体的补全数据
· ✅ 支持 execute、scoreboard 等复杂指令
· ✅ 完成语法高亮和错误检测

---

🔮 未来计划

· 添加更多指令（Minecraft 1.21+ 新指令）
· 指令可视化构建器（拖拽式）
· 指令模板库（一键生成常用指令）
· 云端同步（多设备共享补全数据）
· Godot 插件版本（直接拖入其他项目使用）

---

📄 许可证

MIT License © 2025 Paotons

---

📬 联系

· 作者：泡桐树 (Paotons)
· GitHub：github.com/Paotons

---

<div align="center">

用手机写代码的高二学生，做了一个需要编译原理知识的项目

这本身就是一个有趣的故事

</div>

---

附：作品集描述（精简版）

MCfun - Minecraft 智能指令编辑器

独立开发的一个完整语法解析引擎，支持 25+ 条 Minecraft 指令的实时高亮、补全和错误检测。实现了递归下降解析器、22 种类型系统、可配置规则引擎。代码量约 5100 行 GDScript + 6500 行 JSON 配置。

技术栈：Godot 4.6.1 + GDScript + 自定义语法解析引擎
