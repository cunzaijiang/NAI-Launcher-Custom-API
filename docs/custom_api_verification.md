# 自定义接口交付与验证 / 自訂介面交付與驗證 / Custom API delivery

## 简体中文

本目录为二次开发源码，不是已经编译完成的 Windows 安装包。原项目 MIT 许可证及第三方许可声明保持不变。

### 使用方式

在登录界面选择“自定义接口”，填写服务地址、昵称与 API Key。地址支持根地址或末尾 `/v1`，不需要选择协议或填写独立图像地址。具体接口及费用说明见 [custom_api.md](custom_api.md)。未内置任何服务地址或真实密钥。

### 已完成的检查

- 修改的 Dart 文件经过 Dart 3.13.7 格式化与语法解析检查。
- 独立的端点、兼容参数和权限策略纯 Dart 模块通过定向静态分析。
- 实际执行纯 Dart 检查，覆盖地址规范化、配置往返、模型/参数限制及未知费用确认策略。
- 四语 ARB 可解析，三语 README 已链接使用说明。
- 官方依赖源检查通过；锁文件保留 `https://pub.dev`。
- 内置标签数据库已按原项目 manifest 校验大小、SQLite 文件头与 SHA-256，SQLite quick_check 通过。

### 未执行的验证与构建条件

- 没有运行 Flutter 单元/Widget 测试、完整 Flutter analyze、gen-l10n 或 Windows 编译。新增 Flutter 测试不代表已经通过。
- 当前机器没有可用 Flutter SDK；尝试获取官方 Windows SDK manifest 与 3.47.5 归档均返回 404，未改用镜像或降低项目最低版本。
- 项目要求 Flutter >=3.47.0、Dart >=3.10.7，CI 固定 Flutter 3.47.5。Windows 构建还需 VS 2022 C++ 桌面开发组件及 NuGet CLI。本机现有 VS 2022 缺少 C++ 工作负载，NuGet CLI 未就绪。
- 没有服务地址或密钥，因此没有连接真实接口、验证实际出图，也没有发起付费生成或编码。
- 本地通过源码归档取得项目，没有 `.git`；未提交、推送或发布。

可用 Flutter 与构建依赖准备好后，按 `AGENTS.md` 的官方源检查、依赖安装、定向测试及 Windows release 构建步骤验证。Windows release 正常产物目录为 `build/windows/x64/runner/Release/`。

## 繁體中文

本目錄是二次開發原始碼，尚非編譯完成的 Windows 安裝包。MIT 與第三方授權聲明保留。登入時選擇「自訂介面」，填寫根位址或 `/v1` 位址、暱稱與 API Key，無須協定開關或獨立影像位址。詳見 [使用說明](custom_api.md)。未內建真實密鑰。

已實際執行 Dart 格式／語法檢查、獨立模組定向分析、純 Dart 端點／參數／未知費用確認檢查，並驗證四語 ARB、官方依賴源與標籤資料庫。尚未執行 Flutter 測試、完整分析、本地化生成或 Windows 編譯，也未連線真實服務或發起付費請求。

目前缺少可用 Flutter SDK；官方 Windows SDK manifest 與 3.47.5 歸檔下載返回 404，未使用鏡像或降低版本。另需補齊 VS 2022 C++ 工作負載與 NuGet CLI。建置步驟見 `AGENTS.md`，預期 Windows release 目錄為 `build/windows/x64/runner/Release/`。原始碼來自歸檔，沒有 `.git`，未提交或發布。

## English

This directory contains modified source, not a compiled Windows installer. Original MIT and third-party notices are preserved. Choose **Custom API**, enter your root or `/v1` URL, nickname and API key; there is no protocol switch or separate image URL. See [usage and billing](custom_api.md). No real key is embedded.

Executed checks include Dart formatting/syntax parsing, targeted analysis of standalone modules, pure Dart endpoint/parameter/unknown-cost permission checks, four-locale ARB validation, official dependency-source verification and bundled database integrity verification. Flutter tests, full analysis, localization regeneration and Windows compilation were not run. No live provider or paid request was used.

A usable Flutter SDK is unavailable: the official Windows manifest and 3.47.5 archive requests returned 404. No mirror or version downgrade was used. VS 2022 C++ workload and NuGet CLI also need preparation. Follow `AGENTS.md` once these prerequisites are available; the expected Windows release directory is `build/windows/x64/runner/Release/`. The source was downloaded as an archive without `.git`; nothing was committed, pushed or published.
