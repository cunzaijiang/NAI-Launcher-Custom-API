# 自定义接口交付与验证 / 自訂介面交付與驗證 / Custom API verification

> **Preview 2 已公开发布 / 已公開發佈 / Publicly released.** [Release / 下载 / 下載](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2) · Release ID: `430016699`

## 简体中文

本文区分 Preview 2 的发布 CI、本地历史定向检查与未验证范围，不把测试数量或既有构建目录当作发布证明。协议见 [custom_api.md](custom_api.md)，安装与签名边界见 [发布说明](releases/custom_api_preview.md)。上游 MIT 与第三方许可保留。

### 已完成的 CI 与发布验证

- [GitHub Actions run 41213027696](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696) 的全部 jobs 成功，包括完整 **19-suite 测试 gate**、平台构建和发布。19 是 suite 数，不是测试用例总数；本文不推算最终用例总数。
- 已公开发布 `custom-api-v4.3.1-preview.2`，Release ID 为 `430016699`。Tag 与四个平台安装包使用同一不可变源码 SHA：`2d812ac3d8e3307af8e3f2a0beca121f3adf784d`。
- publish 步骤已下载全部 **7 个已发布附件**并完成 SHA-256 回验：Windows Setup、Windows Portable、Android APK、macOS Portable，以及 `checksums.txt`、`release_manifest.json`、`release_notes_custom_api.md`。这不等于发布者数字签名或应用运行验收。
- 三语 README 保留四个 Preview 2 精确安装包链接。`release_manifest.json` 用于独立下载溯源，不是上游受信任签名自动更新格式；请按发布说明备份并手动安装。
- 已上传的 `release_notes_custom_api.md` 含构建时的旧状态文字。该附件按原样保留以维持现有校验关系；当前发布状态以公开 Release 和上述 CI 记录为准。此后的文档状态更正不改变安装包、tag 或附件的源码 SHA。

### 当前实现说明

- 自定义入口使用 OpenAI Chat `/v1/chat/completions`：外层 `model` / `messages`，消息内容为 JSON 绘图 payload，仅接受 Markdown 内联 PNG data URI，不支持 HTTPS/HTTP 远程图片 URL。官方登录与生成路线不变。
- 登录仅 `/v1/models` 验证，不试画、不读取占位订阅。自定义绘图不调用原生 `/v1/ai` 生成或编码端点；无自动重试或协议回退。
- Chat Vibe 交付原始图片，由服务端编码与缓存，Vibe 预算字段被忽略。当前客户端只解析 `vibe_cache_ids` 并记录计数，不持久保存或在后续请求复用 `cache_id`，不保证跨请求缓存复用。独立原生 Encode 不属于绘图路径。余额与实际费用未知，0 Anlas 本地预估不代表免费，仍有基础费用。
- 本分支 GitHub/手动更新入口指向 `cunzaijiang/NAI-Launcher-Custom-API`。发行版常量禁用周期、启动及手动服务更新请求；更新弹窗只提供固定 Releases 手动下载入口，不读取上游签名清单、不解析独立预览清单、不提供应用内安装。

参考字段契约为 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 与 `character_references` 数组（不是 `precise_reference`）；详见协议说明。离线 CI gate 通过不等于真实服务支持这些字段。

### 2026-10-31 本地定向检查记录

- 使用 `N:/tool/.tmp/sdk/flutter-3.47.5/bin/flutter.bat --version` 确认 Flutter **3.47.5**、Dart **3.13.4**；PowerShell **7.6.9** 位于 `N:/tool/.tmp/sdk/powershell-7.6.9/pwsh.exe`。`N:/` 是本机工作目录映射，不是用户运行应用的必要路径。
- 实际执行 `flutter gen-l10n`，从简中、繁中、英文、日文 ARB 生成本地化 Dart；实际执行 Dart formatter。
- 对 `community_links.dart`、`update_check_service.dart`、`update_check_dialog.dart` 及四个受影响测试文件执行定向 `dart analyze`，结果 **No issues found**。
- 用 `scripts/test_affected.ps1` 的 120 秒 watchdog 运行 **7 个测试文件，65 个测试全部通过**（约 6 秒）。这只是更新/关于页/弹窗相关批次，不是全仓库或生成协议测试总数。
- 检查确认：默认自定义发行版在启动、周期、手动及忽略跳过版本时均不访问 GitHub API 或解析清单；手动更新界面无需读取更新 provider，不显示“已是最新版本”；320/600/840/1180/1600 宽度、3 倍文本、短屏/IME 下两个操作均可滚动触达。保留并显式测试既有非自定义发行路径。
- 初次相关批次发现一个旧弹窗集成断言仍期待“检查中”，已按新的手动更新语义修正并重跑上述完整批次通过。
- 此前本地 **458 项通过对应旧的 18-suite 批次**，另有 **324 项通过的独立定向批次**；这些历史批次与上述 65 项均按各自范围记录，不相加，也不作为最终 19-suite CI gate 的用例总数。

### 未验证范围

- 上述本地更新界面检查未执行全量 Flutter 测试、完整 Flutter analyze、真实 UI 手工验收或二进制构建；最终 CI 与发布结果单独列于上文，不以本地定向结果替代。
- 未配置真实 API 地址或密钥，没有真实模型发现、付费出图、Vibe 编码或真实服务端到端测试，也未完成各平台应用的人工端到端验收；不承诺任意第三方服务可用。CI、构建、附件下载与 SHA-256 回验不能替代这些验证。

## 繁體中文

### 已完成的 CI 與發佈驗證

[GitHub Actions run 41213027696](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696) 的全部 jobs 成功，包括完整 **19-suite 測試 gate**、平台建置與發佈。19 是 suite 數，不是測試案例總數；不推算最終案例總數。

`custom-api-v4.3.1-preview.2` 已公開發佈，Release ID 為 `430016699`，tag 與四個平台安裝包使用同一不可變來源 SHA `2d812ac3d8e3307af8e3f2a0beca121f3adf784d`。publish 步驟已下載全部 **7 個附件**並完成 SHA-256 回驗：四個安裝包及 `checksums.txt`、`release_manifest.json`、`release_notes_custom_api.md`。三語 README 的四個精確安裝包連結保持不變；獨立清單不是上游可信任簽章更新格式。

已上傳的 `release_notes_custom_api.md` 含建置時的待發狀態文字；保留原附件以維持現有校驗關係，當前狀態以公開 Release 與 CI 記錄為準。後續文件更正不改變安裝包、tag 或附件的來源 SHA。雜湊回驗不等於數位簽章或應用程式執行驗收。

### 實作與本機檢查範圍

自訂繪圖使用 OpenAI Chat、訊息內 JSON payload 與 Markdown 行內 PNG data URI，不支援 HTTPS/HTTP 遠端圖片 URL；官方路線不變。Chat Vibe 傳送原始圖，由伺服器編碼／快取，預算被忽略；用戶端不持久儲存或重用 `vibe_cache_ids`，不保證跨請求快取重用；獨立原生 Encode 不是繪圖路徑。實際費用未知，0 Anlas 本機預估不代表免費。登入不試畫，自訂繪圖不呼叫原生生成／編碼端點、不自動重試。自動更新與應用程式內安裝停用，GitHub 與固定手動 Releases 入口指向本分支，不解析上游簽章清單或獨立預覽清單為可信任更新。

參考欄位為 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 與 `character_references` 陣列，不是 `precise_reference`；離線 CI 通過不等於真實服務支援這些欄位。

2026-10-31 使用本機 `N:/` 映射下 Flutter 3.47.5／Dart 3.13.4／PowerShell 7.6.9，實際執行四語 `flutter gen-l10n`、formatter，以及更新常數／服務／彈窗與四個測試檔的定向分析（No issues found）。`test_affected.ps1` 以 120 秒 watchdog 執行 7 個相關測試檔，**65 個測試全數通過**，不是全倉庫或繪圖協定測試總數。覆蓋不存取 GitHub／不解析清單、無 provider 的手動更新介面，以及五個寬度、3 倍文字、短屏與 IME 的操作可達性。初次發現舊介面斷言失效，修正後重跑通過。

先前本機 **458 項通過屬於舊的 18-suite 批次**；另有 **324 項通過的獨立定向批次**。這些批次與上述 65 項均分別記錄，不相加，也不當作最終 19-suite CI gate 的案例總數。

本機更新介面檢查沒有執行全量測試、完整分析、人工 UI 驗收或二進位建置；最終 CI 結果另列於上文。未設定真實 API 位址或密鑰，沒有真實模型探索、付費出圖、Vibe 編碼或真實服務端對端測試，也未完成人工跨平台端對端驗收。CI 與附件回驗不能替代這些驗證，不保證任意服務商可用。詳見 [協定](custom_api.md) 與 [發佈說明](releases/custom_api_preview.md)，保留上游 MIT 與第三方授權。

## English

### Completed CI and publication verification

All jobs in [GitHub Actions run 41213027696](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696) succeeded, including the complete **19-suite test gate**, platform builds and publication. Nineteen is the suite count, not the test-case total; no final case total is inferred.

`custom-api-v4.3.1-preview.2` is publicly released as Release ID `430016699`. The tag and all four platform packages share immutable source SHA `2d812ac3d8e3307af8e3f2a0beca121f3adf784d`. The publish step downloaded all **7 published assets** and completed SHA-256 verification: the four packages plus `checksums.txt`, `release_manifest.json` and `release_notes_custom_api.md`. The three READMEs retain the four exact package links. The independent manifest is not upstream trusted signed update metadata.

The uploaded `release_notes_custom_api.md` contains build-time prepublication wording. The original asset is retained to preserve existing checksum relationships; the public Release and CI record establish the current publication state. Later documentation corrections do not change the source SHA of the packages, tag or assets. Hash verification is not a publisher signature or application runtime acceptance.

### Implementation and local-check scope

Custom drawing uses OpenAI Chat, JSON payloads inside messages and only inline Markdown PNG data URI results, not HTTPS/HTTP remote image URLs; the official route is unchanged. Chat Vibe sends raw images for server-side encoding/cache and ignores its budget field; the client does not persist or reuse returned `vibe_cache_ids` and does not guarantee cross-request cache reuse. Independent native Encode is outside drawing. Actual costs are unknown: a local 0-Anlas estimate does not waive the base fee. Login never generates, and custom drawing has no native generation/encoding calls or automatic retries. Automatic updates and in-app installation are disabled; GitHub and fixed manual Releases links point to this fork, and neither upstream signed metadata nor independent preview metadata is parsed as trusted updates.

The reference contract is `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` and a `character_references` array, not `precise_reference`. Passing offline CI does not establish real-provider support for these fields.

On 2026-10-31, the local `N:/` workspace mapping provided Flutter 3.47.5 / Dart 3.13.4 / PowerShell 7.6.9. Four-locale `flutter gen-l10n` and formatting were actually run. Targeted analysis of updater constants/service/dialog and four test files reported **No issues found**. `test_affected.ps1` ran 7 related files with a 120-second watchdog: **65 tests passed**, not a repository-wide or drawing-protocol total. Coverage includes zero GitHub/manifest access, manual-update UI without provider reads, and action reachability at five widths with 3x text, short screens and IME. An initial stale checking-state integration assertion was corrected, then the entire batch passed.

The earlier local **458 passing tests belong to the old 18-suite batch**; **324 passing tests belong to a separate targeted batch**. These batches and the 65-test batch above are separate scope records, not additive counts or the final 19-suite CI gate's case total.

The local updater-UI check did not run repository-wide tests, full analysis, manual UI acceptance or binary builds; final CI results are recorded separately above. No real API endpoint or key was configured, and no live model discovery, paid generation, Vibe encoding or real-service end-to-end test was performed. Manual cross-platform end-to-end acceptance has not been completed either. CI and asset verification do not replace those checks or establish arbitrary provider compatibility. See the [protocol](custom_api.md) and [release notes](releases/custom_api_preview.md); upstream MIT and third-party notices remain intact.
