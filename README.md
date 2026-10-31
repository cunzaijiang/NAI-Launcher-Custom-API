# NAI Launcher Custom API

<p align="center">
  简体中文 · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.en-US.md">English</a>
</p>

<p align="center">
  <img src="assets/icons/Icon.png" alt="NAI Launcher 图标" width="112">
</p>

<p align="center">
  <strong>自定义图像 API 优先的独立预览分支，保留可选的 NovelAI 官方入口。</strong>
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2"><img src="https://img.shields.io/badge/Custom_API-custom--api--preview-blue" alt="Custom API preview"></a>
  <img src="https://img.shields.io/badge/Windows%20%7C%20macOS%20%7C%20Android-可用-6f7785" alt="支持平台">
  <img src="https://img.shields.io/badge/license-MIT-5b8c5a" alt="MIT License">
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2">下载 Custom API 预览版</a> ·
  <a href="docs/releases/custom_api_preview.md">本分支更新说明</a> ·
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues">反馈本分支问题</a>
</p>

**NAI Launcher Custom API** 是由 **cunzaijiang** 独立维护、基于 NAI Launcher 上游的 Custom API 二次开发分支，**不是上游官方发行版，也不是 NovelAI 官方产品**。原作者与 MIT 归属见文末致谢。使用自定义图像服务无需 NovelAI 账号；官方登录保留为可选路线。请遵守所用服务的条款、内容规则与当地法律。

本分支以登录页的“自定义接口”为主要入口：只需 **一个 API URL、昵称和 API Key / Token**，支持站点根地址或 `/v1` 地址。Windows、macOS 与 Android 保留上游的本地工具和创作界面，不登录也能先使用本地工具。

## 下载 Custom API Preview 2

**4.3.1 Custom API Preview 2 已公开发布。** [发布页面与校验文件](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2) · [阅读本分支更新说明](docs/releases/custom_api_preview.md)。请使用以下四个实际安装包，不要下载源码归档来安装：

| 平台 | 直接下载安装包 |
| --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Setup.exe) |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Portable.zip) |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.2.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.2.apk) |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.2_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.2_Portable.zip) |

> **预览版与安装风险**：请先备份。Windows 安装版与便携版均未做 Authenticode 签名；macOS 仅 ad-hoc 签名，无 Apple Developer ID 且未公证；Android 为 release 模式、临时 debug key 签名，应用 ID 沿用上游，不能覆盖不同签名的上游安装，也不保证不同预览构建间直接覆盖安装。Windows 安装目录可能与上游重叠；卸载可能删除本地数据。请核对来源与 SHA-256，不要全局关闭系统安全保护。本预览未做真实服务端到端测试，不保证任意第三方站点可用。

> **Preview 2 更新方式**：应用内 GitHub 入口指向本分支；自动检查更新与应用内下载安装已禁用，“检查更新”只提供本分支 [Releases 页面](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases)的手动下载入口。独立预览清单不兼容上游签名更新格式，不会作为可信自动更新解析。旧 Preview 1 包不会因此改变，请从本页手动升级。

## 自定义 API 支持边界

- 使用 **OpenAI Chat `/v1/chat/completions`**：外层 `model` 与 `messages`，消息内容是 JSON 绘图参数，响应仅接受 Markdown 内联 PNG data URI，不支持 HTTPS/HTTP 远程图片 URL；不是 `/v1/images/generations` 通用图片 API。主 API 与图像 API 共用一个 URL，没有协议切换。
- 登录仅读取 `/v1/models` 验证，不触发试画。仅接受五个精确模型 ID：`nai-diffusion-4-full`、`nai-diffusion-4-5-full`、`nai-diffusion-4-5-curated`、`nai-diffusion-5-full`、`nai-diffusion-5-curated`。
- **不支持 V5 Medium（节约档）；V5 的 Vibe／Precise Reference 参考功能不可用。** 其他模型的参考图、生成和编辑能力仍取决于服务商；登录成功不等于所有功能可用。仅返回最终图像，没有中间流式预览，失败不自动重试。
- **Chat Vibe 将原始参考图交给服务端编码与缓存；其预算字段会被忽略。** 当前客户端不持久保存或复用返回的 `vibe_cache_ids`，不保证跨请求缓存复用。 自定义绘图不调用原生 `/v1/ai` 生成或编码端点；独立 Encode 操作不属于绘图链路，不能据此推断 Chat Vibe 能力。
- 第三方余额、订阅资格和费用均视为**未知**；**每次生成都有基础费用，即使本地预估为 0 Anlas**。本地预估不是服务商报价，Vibe 预算不是硬上限；Agent/MCP 收费操作需确认未知费用，不能以 0 Anlas 自动按免费放行。请向服务商确认价格和限额。
- API Key / Token、Prompt、参数及所需图像会发送至你填写的站点，请仅使用可信服务。详见[自定义 API 说明](docs/custom_api.md)。

> **下方继承的完整功能介绍以 NovelAI 官方路线为基准，不是自定义接口全部支持的承诺。** 本地图库和词库等工具仍可使用；在线生成、模型、参考图、余额、免费额度和费用行为请以所选路线及上述限制为准。

## ✨ 一套完整的创作流程

| 你要做什么 | NAI Launcher 可以怎么帮你 |
| --- | --- |
| **开始创作** | 写 Prompt、选模型和参数，加入角色、Vibe、Precise Reference 或源图。 |
| **反复调整** | 图生图、局部重绘、扩图、变体、增强，随时从历史图片取回部分参数。 |
| **批量处理** | 把多组任务交给队列，暂停、继续、排序、重试，并查看真实进度与 Anlas 消耗。 |
| **沉淀素材** | 将作品放进本地图库，把标签、Vibe 和精准参考整理成可搜索、可分类的个人资源库。 |
| **寻找灵感** | 搜索多个在线画廊，查看原始 Prompt 与生成信息，再送回生成页继续创作。 |
| **跨工具与设备** | 连接 Krita、ComfyUI 和云备份，让桌面创作流程延续到 Android。 |

## 🚀 功能全览

### 🎨 NovelAI 生成与编辑（官方路线）

- 支持文生图、图生图、普通 Inpaint、Focused Inpaint、Outpaint、变体和增强。
- 支持 NovelAI V5 Curated / Full、V4.5、V4 与 V3 系列常用工作流；切换模型时，可用参数、默认值、Token 上限与参考功能会跟随模型能力变化。
- V5 Full 可切换「节约 / 标准」生成档位：节约档消耗更少 Anlas 与 Opus 免费额度，并与官网一样固定步数、采样器和负面预设；V4 及之后的模型可切换动漫 / 兽人模式，兽人模式会在提示词开头加入 fur dataset 数据集标签，导入图片时自动识别。
- 可设置尺寸、采样器、Steps、CFG、Seed、噪声计划等生成参数，并在不符合 NovelAI 请求限制时给出可用尺寸建议。
- 生成前显示预计 Anlas 消耗；可能产生费用的关键操作会单独确认，完成后自动更新余额和统计。
- 内置生成历史与预览，可以复用 Prompt、Seed、模型和部分参数，不会覆盖仍在编辑的内容。
- 预览图和历史记录支持「另存为」：单张可从右键、更多菜单或全屏详情页顶栏自选位置和文件名，多选后可一次存入同一文件夹。另存为只导出保留完整生成参数的副本，不写入应用图库；开启保护模式及“导出时避免覆盖已有文件”后，重名文件自动编号。

### ✍️ Prompt、固定词与角色

- 正向 Prompt、负向 Prompt、正负面固定词和角色内容分区编辑，复杂工作流也能看清每一部分来自哪里。
- 多角色可以分别设置正负面 Prompt、参考图与画面位置，并根据当前模型处理角色数量和定位能力。
- 内置 Danbooru / e621 基础标签与别名，可离线显示补全、类型、热度和翻译；也可安装中文词库与相关标签数据包。
- 相关标签补全能继续寻找构图、服装、动作和画面元素；Danbooru 在线结果可补充较新的标签。
- 自定义标签词库、固定词和随机词库都支持分类、搜索、批量编辑与快速插入。
- 输入框右下角可切换文本／标签模式，直接编辑原文、调整权重、多选后长按标签拖动排序及撤销；简中与繁中界面在标签下显示同一份本地中文译文，其他语言只显示原文。文本模式选中完整标签时也可查看译文。
- 主提示词输入框底部可拖动调整高度，双击拖动条恢复自动增高；文本与标签模式共用高度。
- 标签可禁用后恢复，原文中的 `/*disabled:原片段*/` 会随提示词保存和云同步，但禁用内容不参与生成、有效预览和 Token 计数。这是 Launcher 编辑语法，旧版客户端及外部工具不保证识别；外部使用请在菜单选择「复制有效提示词」。
- 本地译文未命中的内容可以交给你配置的 AI 翻译服务。
- 提示词助手的反推、优化、翻译等任务支持统一设置响应等待超时，可选 1、2、5、10、15 或 30 分钟，默认 5 分钟。
- 提示词助手的提供商可独立保存自动或手动并发模式，默认自动从 5 个请求开始调整；独立标签批次并行翻译。各任务可选择模型支持的思考等级。服务商、API Key 与模型在「设置 → 集成 → 模型服务」管理，任务路由与思考等级位于「设置 → 集成 → 提示词助手」，均保存在本机。

### 🧬 Vibe、精准参考与图像编辑

以下在线参考与编辑能力描述官方路线；自定义接口受服务商限制，V5 的 Vibe 与 Precise Reference 不可用。本地资源库管理不等于服务端支持相应生成能力。

- Vibe Transfer 支持图片、预编码 Vibe 与 Bundle，能够调整信息提取和参考强度，并按模型复用已有编码。
- Precise Reference 可用于角色或风格参考，支持多选、批量修改类型，以及带图片的配置包导入导出。
- Vibe 与 Precise Reference 都有独立资源库，可分类、搜索、预览、批量管理，并直接送到当前生成任务。
- 重绘编辑器提供画笔、蒙版、Focused Inpaint 区域和画布扩展；也可以先让智能代理准备蒙版或扩图草稿，再由你检查后提交。
- 支持从 NovelAI 图片元数据读取模型、尺寸、采样器、Steps、CFG、Seed、角色词等内容，并选择性恢复；下次导入会沿用上次勾选的项目。
- Android 可从 Discord 等应用将单张图片或图片直链分享到 NAI Launcher，读取图片后选择提取元数据、图生图或参考图等用途；图片直链需可访问，恢复参数需原图保留元数据。

### 🗂️ 本地图库与作品整理

- 扫描你指定的目录，按文件夹、相簿、收藏、Prompt 和生成信息查找作品；不会因为启动应用就盲目扫描所有图片。
- 图片详情会整理正负面 Prompt、固定词、角色词与完整生成参数，可以整组复制，也可以只取需要的部分。
- 支持批量分类、收藏、移动与删除，并提供图片对比、幻灯片、水印、打码副本和多种查看方式。
- 在“设置 → 安全与分享”中可独立开启“复制/拖拽时添加水印”，使用已保存的默认水印方案生成输出副本，不修改原图。添加水印不会清除元数据；如需清除，请同时开启保护模式及“复制/拖拽时移除全部元数据”，处理顺序为先清除、再加水印。
- 水印编辑器支持“自动选位”：以设定的锚点为首选位置，其他角明显更干净时，整套水印镜像过去；文字与 Logo 可分别开启“自动灰阶”，按水印下方的背景亮度取灰，并用“明暗差”控制与背景的反差。
- 桌面端提供右键、悬浮预览和拖拽，触屏端提供对应菜单；核心操作不会因为换到手机就消失。
- 本地图库、Vibe 库、精准参考库与词库的常驻侧栏支持拖动调宽，各页面宽度仅在本机保存，不参与云同步。
- 本地图库文件夹、相簿、Vibe 与词库类别支持原有顺序、名称及数量升降序，各分组仅在本机记忆排序。文件夹默认按名称降序，让统一格式的日期文件夹最新在前；拖动调序以当前显示顺序为基础，并自动切换为原有顺序。桌面直接拖动，触屏长按拖动；文件夹、相簿和词库类别还支持拖入子级，Vibe 保持平面类别。
- 词库条目在“自定义排序”下可拖动调序：桌面直接拖动卡片，触屏长按拖动，此时多选改从卡片的“更多”菜单进入。拖动选中项时整组移动，收藏条目始终在前；分组视图中拖到其他类别会移入该类别并放在落点处。
- 图片和资源卡片的右键、更多菜单与批量工具栏使用一致的操作；选中项打开批量菜单，未选中项仍只操作自身。桌面支持 Ctrl/Cmd 多选、Shift 范围选择及当前页全选，翻页保留选择。
- 从选中卡片拖出时会携带整组资源：图片使用实际图像，Vibe/Bundle 与精准参考使用各自的资源文件。应用内可拖到支持的生成参考、Agent、分类或相簿入口；单项入口会拒绝多项拖入。
- 本地图片可以直接发送到生成页、智能代理或 Krita，省去重复保存和选择文件。
- 在“设置 → 数据与存储 → 文件夹与文件名”中决定图库怎么存：子文件夹可按日期、按月份、按年/月两级或不建子文件夹，文件名可用“时间 + 种子”“日期时间 + 种子”或“提示词 + 种子”，也可以用与 NovelAI 官网相同的模板语法自定义（如 `{prompt} s-{seed}`、`{model}/{date}`），编辑时实时预览完整路径。默认仍按日期分文件夹、以时间和种子命名；修改只影响之后保存的图片，已有文件不会被重命名或移动。
- Android 保存图片时默认同步一份到系统相册；在“设置 → 数据与存储”关闭“同步到系统相册”后，生成和保存的图片只留在应用图库，需要时仍可单张“保存到系统相册”。

### 🔎 在线画廊与灵感收集

- 聚合 Danbooru、Safebooru、Gelbooru、AI TAG 与法典图鉴（NovelAI QuickTagCloud）。
- 根据来源提供搜索、热门、随机、排行榜、日期、内容分级、黑名单与输出过滤，不把不支持的筛选硬套到所有站点。
- 支持本地收藏；登录 Danbooru 或配置 Gelbooru API 后，还可以使用对应的账号能力。
- 可查看多图作品、原始 Prompt 和结构化生成信息，整组下载，或把可识别的参数送回生成页。
- 法典图鉴支持公开法典、分类、版本、多图与纯文本词条、贡献者信息和最近浏览。

### 🤖 智能代理

- 在桌面侧栏或移动端抽屉中对话，让代理查询标签、整理 Prompt、查看生成历史、操作资源库并准备生成任务。
- 图片、Vibe 和 Precise Reference 可以直接作为上下文加入会话；图片也能在输入框按 Ctrl/Cmd+V 粘贴，或从文件管理器、浏览器拖到面板，Android 可从输入法插入。代理也能准备重绘蒙版、扩展画布与重绘草稿，或直接放大、增强图片。
- **以下费用与全自动行为仅描述官方路线；自定义接口仍须确认未知费用。** “准备任务”和“真正生成”严格分开：准备阶段核实费用；完全访问模式下，已核实为零 Anlas 的生成直接执行，删除已保存的数据与付费操作仍需确认。需要无人值守批量出图时可切换到“全自动”：付费操作直接执行，只有单次消耗达到保护模式的高消耗阈值时才确认，删除已保存的数据仍需确认。
- 默认角色调查流程会结合联网身份核实、标准标签检索和画廊特征；联网关闭或证据不足时会说明限制。
- 系统提示词可直接用自然语言补充要求或替换内置正文，无需占位符。工作目录、联网状态、Skills 和应用执行规则自动补充，并可预览最终内容；自定义不会绕过应用权限确认。
- 支持逐题回答的结构化提问：每题三个可行方向、一个“推荐”标记和一个自定义入口，最后统一检查并提交。默认两分钟未提交会自动采用全部推荐选项；提问时显示 Toast、入口问号和 Android 系统通知。
- Windows 与 macOS 可在“设置 → 集成 → MCP”开启本地 MCP 服务，让 Claude Code、Codex CLI、Cursor、Cherry Studio、Pi、Claude Desktop 等外部智能体通过同一套工具操作 Launcher；服务默认关闭，授权确认与 Anlas 消耗确认仍在 Launcher 内完成。详见 [MCP 服务说明](docs/mcp_server.md)。
- MCP 生成与取图默认返回原分辨率图片；客户端可能在折叠的工具详情中显示。正文展示支持供 Cherry Studio 等同机客户端使用的短期本机 HTTP 图片地址，以及供 Codex 使用的可选显示缓存，无需另存图库副本。HTTP 地址最长有效 1 小时，服务关闭或缓存淘汰后失效。开启保护模式及“复制/拖拽时移除全部元数据”后，MCP 图片、HTTP 展示、显示缓存、另存导出和剪贴板输出同样清除元数据与 NAI 隐写水印，且不返回原图路径；本地原图不受影响。净化另存使用 PNG，仍保留目标路径权限与禁止覆盖检查。
- 支持 OpenAI 兼容接口、Google Gemini 原生接口、第三方 Gemini 兼容中转与 OpenRouter；每个服务商可从接口列表挑选模型或手动添加模型 ID，并按模型能力启用思考等级和工具调用。
- 模型服务、API Key、可用地区和费用由你选择的提供方负责；联网搜索等额外工具默认关闭。

### 📋 队列、历史与统计

- 生成任务可以批量加入队列，支持暂停、继续、调整顺序、取消和重试失败任务。
- 运行中可以查看单项状态、整体进度和失败原因，不需要守着每一次请求。
- 统计页面按时间、尺寸、采样器、模型与 Anlas 消耗回顾创作记录，帮助了解自己的常用设置。

### 🧩 Krita 与 ComfyUI

- **Krita Bridge**：把 Krita 画布送到 Launcher 生成或重绘，并将结果送回 Krita。
- **ComfyUI**：连接本地服务器，执行常规超分或 SeedVR2 工作流；服务器模型与自定义节点仍由你的 ComfyUI 环境负责。
- **DLSSNR 图像增强（Windows）**：在“设置 → 集成 → DLSSNR”按需安装公开运行库并检测 NVIDIA GPU；支持生成后自动增强（默认关闭）、图片卡片手动增强与拖动分割线对比；共用对比组件支持“跟随鼠标”开关，便于放大后比较局部，开关偏好在本机保存。SR 放大倍率默认 2 倍，可手动输入；SR 放大后执行单次 NR，再完成增强与颜色混合。提供 7 套内置风格预设，默认使用“质感光影”，另有“保色增强”“浓郁”等风格可选；可另存、重命名和删除自定义预设；当前选择和调整自动保存。参数附带说明和数值输入。图像在本机处理，手动保存创建新文件并作为最新结果加入历史记录，不覆盖原图。
- 从图库、预览和编辑流程都能进入这些工具，不必每次手动导出再重新选文件。

### ☁️ 同步与备份

- 支持 OneDrive、GitHub 与 WebDAV；Google Drive 因授权审核尚未通过，暂时禁用新增连接入口。连接账号不会自动上传、下载或覆盖内容。
- 推送、拉取和恢复都由你主动开始，并可预览差异与处理冲突。
- 可分别选择设置、Prompt 与词库、词库预览图、在线画廊设置与收藏、本地相簿、固定词使用记录、智能代理 Prompt 与 Skill，以及可选的 Vibe、Precise Reference。
- 本地图库原图、远程图库原图、账号凭据、缓存和日志不会进入备份。
- 备份使用便于查看和迁移的明文数据，不需要额外恢复密钥；请自行确认目标空间的访问权限。

## 🖼️ 界面预览

以下截图沿用上游，仅作界面示意，不代表本分支 Preview 2 的自定义接口外观、支持范围或真实服务测试结果。

### 🖥️ 桌面端

<table>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-generation-desktop.png" alt="生成工作台与智能代理" width="100%"><br>
      <sub>生成工作台：Prompt、参数、预览与智能代理同屏协作</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-local-gallery-desktop.png" alt="本地图库" width="100%"><br>
      <sub>本地图库：搜索、相簿、文件夹与批量整理</sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-online-gallery-desktop.png" alt="在线画廊" width="100%"><br>
      <sub>在线画廊：多个来源、筛选与瀑布流浏览</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-statistics-desktop.png" alt="统计仪表盘" width="100%"><br>
      <sub>统计仪表盘：作品、参数与 Anlas 使用情况</sub>
    </td>
  </tr>
</table>

## 💻 支持平台

| 平台 | 当前状态 | 说明 |
| --- | --- | --- |
| **Windows** | 主要开发与发布平台 | 提供安装版和便携版，适合长时间创作、批量任务、Krita / ComfyUI 联动以及 MCP 外部接入。 |
| **macOS** | 可用，持续完善中 | 需要 macOS 12 或更高版本。提供便携版；若系统阻止打开未公证应用，请按 macOS 安全提示手动允许。 |
| **Android** | Beta | 支持手机、横屏、平板和大屏；生成、图库、词库、队列、代理与设置均有触屏入口。 |
| **Linux** | 暂无正式发行包 | 当前不提供正式下载包。 |

## ⚡ 下载与开始使用

### 1. 手动下载并安装当前预览版

Preview 2 已公开发布；请查看[发布页面](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)，文件名如下（与上方直链一致）：

| 平台 | 文件 | 用法 |
| --- | --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Setup.exe) | 未签名安装版；先备份并检查安装目录。 |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Portable.zip) | 未签名便携版；解压后直接运行。 |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.2.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.2.apk) | 侧载 debug key 签名 APK；可能需要允许安装未知来源软件，不能覆盖不同签名的上游安装。 |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.2_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.2/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.2_Portable.zip) | 解压后打开 `Aaalice NAI Launcher.app`；仅 ad-hoc 签名且未公证。 |

本预览附带 `checksums.txt`、`release_manifest.json` 和 `release_notes_custom_api.md`，可核对 SHA-256、文件大小与来源；校验值不等于发布者数字签名。请同时阅读上方安装风险和应用内更新警告。

### 2. 优先使用“自定义接口”

1. 在登录页选择 **“自定义接口”**，不要将第三方 Key 填入官方登录。
2. 填写 **一个 API URL**：站点根地址或以 `/v1` 结尾的地址均可；例如 `https://provider.example` 或 `https://provider.example/v1/`。主 API 与图像 API 共用此地址，无需另填图像地址或选择协议。
3. 填写必需的 **昵称** 和 **API Key / Token**。Key 仅保存在当前设备安全存储中，不进入云备份，但验证时会发送至所填站点。
4. 登录仅请求 `/v1/models`，不会试画；通过验证后，先确认服务商计费与能力，再主动生成。五模型白名单、无 Medium、V5 参考不可用及未知费用限制见上方。

**可选：NovelAI 官方路线。** 如需官方服务，可使用 NovelAI 账号密码或 **Persistent API Token** 登录；网页安全验证导致密码登录失败时可改用 Persistent API Token。官方 Token 仅保存在当前设备安全存储中。官方模型与 Anlas 说明不适用于自定义服务的费用承诺。

### 3. 设置常用资源

- 在“设置”中选择本地作品目录，进入本地图库后开始扫描。
- 在“设置 → 数据源与缓存”中管理中文词库、相关标签数据包和在线缓存。
- 需要 Krita 联动时，先启用 Krita Bridge，再按照 [Krita 插件说明](krita_plugin/README.md) 安装插件。
- 需要 ComfyUI 时，在“设置 → ComfyUI”中填写本地地址并选择工作流。
- 需要跨设备使用时，在云同步页面连接一个备份目标，并认真确认要同步的内容。

## 🔒 数据与隐私

NAI Launcher 不在项目自有服务器上托管你的账号或作品。只有在你主动使用对应功能时，数据才会发送给相关服务：

| 使用的功能 | 数据会发送到哪里 |
| --- | --- |
| 生成、图生图、重绘、Vibe 编码 | NovelAI 或你显式配置的第三方图像 API 站点；包括本次请求所需的 Prompt、参数和源图或参考图。第三方 Token 会发送到所填地址，请仅使用可信服务。 |
| 在线画廊搜索与下载 | 你选择的第三方图库；可用性、限流和内容规则由各站点决定。 |
| AI 翻译或智能代理 | 你配置的模型服务；对话、附加图片和完成任务所需的工具结果可能产生服务费用。 |
| 同步与备份 | 你选择的 Google Drive、OneDrive、GitHub 或 WebDAV；只上传明确勾选的内容。 |

- NovelAI Token、OAuth access/refresh token、WebDAV 密码和 GitHub Token 使用设备安全存储，不会写入备份。
- 本地 Prompt、图库索引、标签、资源库和代理会话默认保存在本机。
- 云备份以明文保存所选数据；本地图库的图像本体不上传，相簿、分类、成员引用和固定词使用记录可作为轻量数据同步。
- 在线画廊可能包含第三方内容；分级筛选不能替代用户判断。
- WebDAV 的安全性取决于你配置的服务器与传输方式，请保留重要数据的本地副本。

## 🆘 支持与反馈

- 如遇异常，请通过“设置 → 关于 → 导出诊断日志”保存排查信息，并在反馈时一并提供。
- [提交本分支 Issue](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues)：报告可以复现的问题或提出功能建议；分享日志前请删除 Token 等敏感信息。
- [Preview 2 发布页](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)并核对校验文件；更新内容见[本分支更新说明](docs/releases/custom_api_preview.md)。请手动升级；Preview 2 不支持应用内安装更新。

## 🙏 致谢

感谢上游作者 **Aaalice233** 及 [NAI Launcher 上游项目](https://github.com/Aaalice233/Aaalice_NAI_Launcher) 提供原始代码、详细功能介绍与界面截图。本分支由 **cunzaijiang** 独立维护，保留上游 **MIT License**、原版权和许可声明；本分支的问题与下载请使用本页入口，不要作为上游官方发行版反馈。

感谢 [NovelAI](https://novelai.net/)、[法典图鉴](https://novelai.quicktagcloud.com/)、[AgIzT/NovelAI-Tag](https://github.com/AgIzT/NovelAI-Tag)、[Flutter](https://flutter.dev/)、[Riverpod](https://riverpod.dev/) 以及所有贡献者和测试用户。

## 📄 许可证

本分支继续基于 [MIT License](LICENSE) 开源，并保留上游版权与许可声明。
