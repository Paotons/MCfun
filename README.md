# MCfun

**适用于移动设备的 Minecraft 基岩版命令 IDE**  
一个功能完整、支持离线使用的 Minecraft 命令集成开发环境，完全基于 Godot 4 构建，专为移动设备（Android/iOS）设计。

MCfun 提供了从项目创建、代码编辑、实时解析与错误检测，到行为包导出的完整工作流——全程无需电脑。其底层的语法引擎由可热加载的 JSON 定义语法系统驱动，支持最新的 Minecraft 命令（beta 1.21），且无需修改核心代码即可扩展。

---

## 🔧 核心能力

- **移动端优先的 IDE**：针对触摸输入优化，无需电脑。
- **完整的命令覆盖**：支持所有 Minecraft 基岩版命令，包括 `execute`、`scoreboard`、`schedule`、`structure` 等。
- **可热加载的语法系统**：命令语法、括号规则、补全词典均在 JSON 中定义，并编译为二进制缓存。无需重新构建应用即可更新语法。
- **智能补全**：7 种插入模式（普通、单词、字符串、选择器、空间物品、引号、点分路径），配合加权排序算法（子串匹配、连续性加成、长度惩罚）。
- **实时语法高亮**：区分命令头、数字、布尔值、选项、选择器、坐标、富文本标记等。
- **实时错误检测**：行内错误下划线 + 专用错误面板，支持点击跳转。
- **项目系统**：多项目支持、文件树浏览、最近文件列表、自动保存。
- **内置辅助命令**：`&string`、`&tp`、`&scoreboard`、`&fill` 等，可编译为复杂的多命令序列（如基于记分板的精确传送、自动分块的大范围填充）。
- **注解指令**：`@list` 用于动态管理命令列表（跨行补全）。
- **行为包导出**：导出 `.mcfunction` 文件及 `manifest.json`，打包为 `.zip` 供 Minecraft 使用。

---

## 🏗️ 架构概览

MCfun 采用分层模块化设计。主要组件如下：


应用层（UI）
│
▼
全局单例（ProjectManager, FileSystem, EditManager）
│
▼
编辑器核心（CustomCodeEdit, FunctionEdit, FileListContainer）
│
▼
解析与补全引擎
├── CommandElementCreater（状态机解析器）
├── Element 继承树（25+ 个类）
└── FunctionCompletionData（加权排序）
│
▼
语法层（可热加载）
├── GrammarProcess（命令序列）
├── GrammarLaw（括号/选择器规则）
└── GrammarEntry（补全词库）
│
▼
项目与导出层
└── 行为包生成器（ZIP + manifest）


### 命令解析流程
1. 用户输入 → `CustomCodeEdit`（处理双击映射、退格、粘贴）
2. `FunctionSyntaxHighlight` 请求当前行的 `CommandElement`
3. `CommandElementCreater` 运行语法状态机（支持 `goto`、`extends`、试探性解析）
4. 解析出的 `CommandElement` 包含 `Element` 节点树（如 `IntElement`、`SelectorElement`）
5. 提取高亮和补全数据，回传给编辑器

### 语法热加载系统
- **定义**：`main.json`（格式版本 1）指向三个文件：`process.json`（命令序列）、`law.json`（括号规则）、`entry.json`（补全词库）
- **编译**：JSON 文件被编译为 Godot 序列化的二进制缓存（`.compiled`），存储在 `user://cache/grammar/`
- **运行时**：`Grammar` 类加载缓存；若缺失或过期，自动重新编译
- **可扩展性**：只需编辑 JSON 即可添加新的 Minecraft 命令——无需重新编译应用

### Element 继承树（部分）

Element（抽象）
└── BaseStringElement
├── BoolElement / IntElement / FloatElement / StringElement / WordElement
├── CoordElement / CoordsElement / ScopeElement
├── SelectorElement / SpaceItemElement / PointPathElement / FilePathElement
├── RichStringElement
├── HeadElement
├── OptionElement
└── BacketElement（及其子类：ParamBacket、EqualParamBacket、ColonParamBacket、ArrayBacket）


---

## 📖 使用说明

### 从源码构建
1. 克隆仓库
2. 在 Godot 4.x 中打开项目
3. 导出为 Android（`.apk`）或 iOS（需要 Xcode 和签名）  
   *注意：项目仅使用 GDScript，无需 C# 模块。*

### 首次运行
- 授予存储权限
- 应用会要求选择一个数据目录（选择可写文件夹，如 `Documents/MCfun`）
- 创建新项目或导入已有项目

### 编辑
- 在项目内创建 `.mcfun` 文件
- 使用编辑器编写命令（自动触发补全，或通过菜单手动触发）
- 错误会显示在行内和错误面板中；点击错误可跳转到对应位置

### 导出行为包
- 打开项目菜单 → **导出**
- 设置输出路径和包名
- 选择错误处理方式（忽略/直接导出）以及是否保留注释/空行
- 点击**导出**。生成的 `.zip` 包含 `manifest.json` 和 `functions/` 文件夹（内含编译后的 `.mcfunction` 文件）

---

## 🧪 技术亮点

- **行 ID 系统**：每行具有持久 ID，在插入/删除行后仍然保持不变，用于撤销/重做后的光标位置恢复
- **撤销/重做**：与 Godot 的 `UndoRedo` 集成，用于文件打开/关闭操作
- **多线程加载**：语法编译在后台线程运行，UI 保持响应
- **可配置 UI**：窗口缩放、编辑器颜色、双击映射、自动保存间隔等均存储在 `user://config.cfg`
- **移动端输入优化**：双击映射（如空格 → Tab，`.` → `~`，`s` → `§`），快速退格时抑制补全

---

## 📂 仓库结构（精简）


MCfun/
├── scene/                 # UI 场景（项目列表、编辑器、设置、帮助等）
├── script/
│   ├── command/           # 解析与元素定义
│   │   ├── creater/       # 命令解析的状态机
│   │   ├── element/       # 25+ 个 Element 类（Bool、Int、Selector、Backet...）
│   │   └── native/        # 内置辅助命令的实现
│   ├── completion/        # 补全数据结构与权重计算
│   ├── element/           # Element 基类与管理器
│   ├── exporter/          # 行为包导出器
│   ├── grammar/           # 语法加载、编译、缓存
│   ├── project/           # 项目管理与配置
│   ├── edit/              # 扩展的 CodeEdit（CustomCodeEdit、FunctionEdit）
│   ├── highlight/         # 语法高亮器
│   ├── global/            # 全局单例（FileSystem、ProjectManager、EditManager）
│   └── tool/              # 工具类（字符串、AABB、字典键值等）
├── resource/
│   ├── grammar/           # JSON 语法定义（main.json、process.json、law.json、entry.json）
│   │   └── default/       # 默认语法（Minecraft beta 1.21）
│   └── native/            # 内置辅助命令的 JSON 定义
└── test/                  # （可选）测试资源


---

## ⚖️ 许可证

**GNU General Public License v3.0**  
您可以根据 GPLv3 的条款复制、修改和分发本软件。详见 [LICENSE](LICENSE) 文件。

---

## 👤 作者

**泡桐树 (Paotons)** – 完全在手机上开发，没有使用电脑，历时数月，完成于高中时期。  
GitHub：[@Paotons](https://github.com/Paotons)

---

## 🙏 致谢

- **Mojang** – 创造了 Minecraft 及其命令系统
- **Godot 引擎** – 免费、开源的游戏引擎，使这一切成为可能
- **DeepSeek** – 协助代码生成与文档编写

---

*献给那些相信一部手机也足以打造专业工具的 Minecraft 命令创作者们。*
