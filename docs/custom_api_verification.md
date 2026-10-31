# 自定义接口交付与验证 / 自訂介面交付與驗證 / Custom API verification

> **Preview 2 尚未发布 / 尚未發佈 / Not yet published.** 等待主发布流程上传附件并完成验证。 / Upload and verification by the main release process are pending.

## 简体中文

本文记录 Preview 2 文档、本地化与更新边界的实际验证，不把历史测试数量、构建目录或新测试源码当作当前发布成功的证明。协议见 [custom_api.md](custom_api.md)，安装与签名边界见 [发布说明](releases/custom_api_preview.md)。上游 MIT 与第三方许可保留。

### 当前实现说明

- 自定义入口使用 OpenAI Chat `/v1/chat/completions`：外层 `model` / `messages`，消息内容为 JSON 绘图 payload，仅接受 Markdown 内联 PNG data URI，不支持 HTTPS/HTTP 远程图片 URL。官方登录与生成路线不变。
- 登录仅 `/v1/models` 验证，不试画、不读取占位订阅。自定义绘图不调用原生 `/v1/ai` 生成或编码端点；无自动重试或协议回退。
- Chat Vibe 交付原始图片，由服务端编码与缓存，Vibe 预算字段被忽略。当前客户端只解析 `vibe_cache_ids` 并记录计数，不持久保存或在后续请求复用 `cache_id`，不保证跨请求缓存复用。独立原生 Encode 不属于绘图路径。余额与实际费用未知，0 Anlas 本地预估不代表免费，仍有基础费用。
- 本分支 GitHub/手动更新入口指向 `cunzaijiang/NAI-Launcher-Custom-API`。发行版常量禁用周期、启动及手动服务更新请求；更新弹窗只提供固定 Releases 手动下载入口，不读取上游签名清单、不解析独立预览清单、不提供应用内安装。

参考字段契约为 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 与 `character_references` 数组（不是 `precise_reference`）；详见协议说明。该契约说明不等于当前 codec 已通过这些字段的验证，代码变更与定向测试由负责绘图实现的任务完成。

### 2026-10-31 实际完成的本次检查

- 使用 `N:/tool/.tmp/sdk/flutter-3.47.5/bin/flutter.bat --version` 确认 Flutter **3.47.5**、Dart **3.13.4**；PowerShell **7.6.9** 位于 `N:/tool/.tmp/sdk/powershell-7.6.9/pwsh.exe`。`N:/` 是本机工作目录映射，不是用户运行应用的必要路径。
- 实际执行 `flutter gen-l10n`，从简中、繁中、英文、日文 ARB 生成本地化 Dart；实际执行 Dart formatter。
- 对 `community_links.dart`、`update_check_service.dart`、`update_check_dialog.dart` 及四个受影响测试文件执行定向 `dart analyze`，结果 **No issues found**。
- 用 `scripts/test_affected.ps1` 的 120 秒 watchdog 运行 **7 个测试文件，65 个测试全部通过**（本次约 6 秒）。这只是本次更新/关于页/弹窗相关批次，不是全仓库或生成协议测试总数。
- 新增检查确认：默认自定义发行版在启动、周期、手动及忽略跳过版本时均不访问 GitHub API 或解析清单；手动更新界面无需读取更新 provider，不显示“已是最新版本”；320/600/840/1180/1600 宽度、3 倍文本、短屏/IME 下两个操作均可滚动触达。保留并显式测试既有非自定义发行路径。
- 初次相关批次发现一个旧弹窗集成断言仍期待“检查中”，已按新的手动更新语义修正并重跑上述完整批次通过。

### 未验证范围与发布门槛

- 本次没有执行全量 Flutter 测试、完整 Flutter analyze、真实 UI 手工验收或二进制构建；不能从本批次推断其他协议测试或各平台打包成功。
- 未配置真实 API 地址或密钥，没有真实模型发现、付费出图、Vibe 编码或真实服务端到端测试；不承诺任意第三方服务可用。
- README 已为 `custom-api-v4.3.1-preview.2` 与 `4.3.1-custom-api-preview.2` 准备精确附件链接。发布方仍须确认四个附件实际上传、下载成功，大小与 SHA-256 匹配同一不可变源码 SHA 后再作为可下载版本发布。本文不声称远端 Release 已存在。
- `release_manifest.json` 仅用于独立下载溯源，不是上游受信任签名自动更新格式。安装前核对来源及校验值，按发布说明备份并手动安装。

## 繁體中文

本文件只記錄 Preview 2 文件、本地化與更新邊界的實際檢查，不將舊測試數或既有建置目錄當作發佈證明。自訂繪圖使用 OpenAI Chat、訊息內 JSON payload 與 Markdown 行內 PNG data URI，不支援 HTTPS/HTTP 遠端圖片 URL；官方路線不變。Chat Vibe 傳送原始圖，由伺服器編碼／快取，預算被忽略；目前用戶端不持久儲存或重用 `vibe_cache_ids`，不保證跨請求快取重用；獨立原生 Encode 不是繪圖路徑。實際費用未知，0 Anlas 本機預估不代表免費。登入不試畫，自訂繪圖不呼叫原生生成／編碼端點、不自動重試。

參考欄位契約為 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 與 `character_references` 陣列（不是 `precise_reference`）。此說明不等於 codec 已通過相應欄位測試，實作與驗證由繪圖任務完成。

2026-10-31 使用本機 `N:/` 映射下 Flutter 3.47.5／Dart 3.13.4／PowerShell 7.6.9，實際執行四語 `flutter gen-l10n`、formatter，以及更新常數／服務／彈窗與四個測試檔的定向分析（No issues found）。`test_affected.ps1` 以 120 秒 watchdog 執行 7 個相關測試檔，**65 個測試全數通過**，不是全倉庫或繪圖協定測試總數。覆蓋不存取 GitHub／不解析清單、無 provider 的手動更新介面，以及五個寬度、3 倍文字、短屏與 IME 的操作可達性。初次發現舊介面斷言失效，修正後重跑通過。

自動檢查與應用程式內安裝已停用，GitHub 與固定手動 Releases 入口均指向本分支，獨立清單不當作上游可信任簽章更新解析。未進行本次全量測試、完整分析、手工 UI 驗收或二進位建置，也未使用真實服務、密鑰或付費請求。README 的 Preview 2 連結是待發佈準備；發佈方仍須驗證四個實際附件、下載、大小、同一來源 SHA 與 SHA-256，不代表遠端 Release 已存在。詳見 [協定](custom_api.md) 與 [發佈說明](releases/custom_api_preview.md)，保留上游 MIT 與第三方授權。

## English

This records actual Preview 2 documentation, localization and updater-boundary checks, not a promise derived from historical counts or existing build folders. Custom drawing uses OpenAI Chat, JSON payloads inside messages and only inline Markdown PNG data URI results, not HTTPS/HTTP remote image URLs; the official route is unchanged. Chat Vibe sends raw images for server-side encoding/cache and ignores its budget field; the client does not persist or reuse returned `vibe_cache_ids` and does not guarantee cross-request cache reuse; independent native Encode is outside drawing. Actual costs are unknown: a local 0-Anlas estimate does not waive the base fee. Login never generates, and custom drawing has no native generation/encoding calls or automatic retries.

The reference contract is `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` and a `character_references` array, not `precise_reference`. Documenting this contract does not certify current codec conformance; implementation and corresponding tests remain with the drawing task.

On 2026-10-31, the local `N:/` workspace mapping provided Flutter 3.47.5 / Dart 3.13.4 / PowerShell 7.6.9. Four-locale `flutter gen-l10n` and formatting were actually run. Targeted analysis of updater constants/service/dialog and four test files reported **No issues found**. `test_affected.ps1` ran 7 related files with a 120-second watchdog: **65 tests passed**, not a repository-wide or drawing-protocol total. Coverage includes zero GitHub/manifest access, manual-update UI without provider reads, and action reachability at five widths with 3x text, short screens and IME. An initial stale checking-state integration assertion was corrected, then the entire batch passed.

Automatic checks and in-app installation are disabled. GitHub and fixed manual Releases links point to this fork, and independent metadata is not parsed as upstream trusted signed updates. This scope did not run the full test suite, full analysis, manual UI acceptance or binary builds, and used no live provider, secret or paid request. Preview 2 README links are publication preparation: the publisher must still verify all four uploaded assets, downloads, sizes, a common source SHA and SHA-256 values. This document does not claim the remote Release already exists. See the [protocol](custom_api.md) and [release notes](releases/custom_api_preview.md); upstream MIT and third-party notices remain intact.
