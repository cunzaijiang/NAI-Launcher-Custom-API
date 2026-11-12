# Custom API 验证记录 / 驗證記錄 / Verification record

## Preview6 大图解析修复 / 大圖解析修復 / Large-image parsing fix

- 发布 / Published: `custom-api-v4.3.1-preview.6`, app `4.3.1+47`; source `2a4dda661d55da72bfb443ecef7b1ad6410e5d03`.
- [CI 43133676596](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/43133676596): all six jobs succeeded, 39 regression files, 710 tests passed. This is the scoped release gate, not a claim of a green full repository suite.
- Android APK, Windows Setup/Portable, macOS Portable rebuilt from the same source. Exactly seven published assets; CI downloads every asset and compares size/SHA-256 before publication. Manifest and checksum entries independently match GitHub API asset digests.
- Offline noisy-PNG regressions cover 1472×1472, 1088×1092 and 1092×1088, each with >4 MiB Base64, plus malformed/duplicate responses. No paid generation for this fix. Real-device installation/generation acceptance remains pending.
- Manual update only. Android ephemeral debug signing, Windows unsigned, macOS ad-hoc without notarization. [Release notes](releases/custom_api_preview.md).

## Preview5 historical evidence / 历史证据 / 歷史證據


> **Preview5 已公开发布并完成附件回验 / 已公開發佈並完成附件回驗 / Publicly released with assets verified.** CI run `41297577735`: six jobs `success`。Preview3／Preview4 历史证据独立保留 / 歷史證據獨立保留 / Historical evidence is preserved separately.

## Preview5 本地证据与未完成验收 / 本機證據與未完成驗收 / Local evidence and open acceptance

Tag: `custom-api-v4.3.1-preview.5` · Filename version: `4.3.1-custom-api-preview.5`。已公开发布 / 已公開發佈 / Publicly released. P3/P4 历史证据不继承 / 歷史證據不繼承 / Historical evidence is not inherited.

### 简体中文

- **最终定向回归：42 文件、740 tests 全部通过，`00:30`、exit `0`**；本地日志 `tool/.tmp/button-fix/preview5-verified-regressions.log`。完整桌面 shell 点击测试 4/4；mobile 单文件 17 passed，含实际触发 fake callback（不是设备或真实服务验收）。
- 此前全仓批次 **10634 passed / 3 skipped / 5 failed**，不是全仓 green。其后 4 项已修复或复测通过（i18n、导航 fixture、浅色对比、mobile 布局）；installer 的 `hiddenPowerShell` marker 仍失败。该 installer 生产代码与测试 baseline 未改，child probe 单独成功，环境原因未知，未为此改源码。
- desktop/mobile 恢复 Preview3 主按钮核心布局；金额为纯文字，价格 spinner 仅用于刷新；`isSaving` 显式反馈保存状态，准备错误可见。Chat 后台解析保留 PNG 校验；新增阶段日志用于后续实际设备定位，不确认 Windows 根因或承诺消除全部一分钟等待。
- **直接 API 探测：8 请求、7 成功、1 失败，`stream=false`、无重试。** 四模型 single/multi 共 8 个案例（含 initial V5 Full single）：其余 7 个 HTTP 200 且取得有效 PNG；V4.5 Curated single 在 **152.177 秒** `RemoteDisconnected`，未重试，扣费未知。不是应用端到端验收，也不是 8/8 全通过。证据：`tool/.tmp/button-fix/live-test-summary.json`。
- 成功请求从开始至 headers 为 **3.075–10.754 秒**，至 body complete 为 **19.828–85.959 秒**；不是额外相加的两个时段。离线 Dart 样本解析 **84 ms**、metadata **30 ms**，不能据此把实际等待全部归因本地或外推所有响应性能。
- **实际 UI 均 blocked**：Android 无 SDK／emulator／device；Windows debug 原生构建下载固定 NVIDIA DLSS 头文件时 TLS 错误 `35`。未完成真实设备 UI、安装或应用端到端验收；Preview5 CI 与附件回验通过不替代这些验收。

### 繁體中文

- **最終定向回歸：42 檔案、740 tests 全部通過，`00:30`、exit `0`**；日誌同上。完整桌面 shell 點擊測試 4/4；mobile 單檔 17 passed，含實際觸發 fake callback，不是裝置或真實服務驗收。
- 先前全倉批次 **10634 passed / 3 skipped / 5 failed**，不是全倉 green。其後 4 項已修復或複測通過（i18n、導覽 fixture、淺色對比、mobile 版面）；installer 的 `hiddenPowerShell` marker 仍失敗。該 installer 生產程式碼與測試 baseline 未改，child probe 單獨成功，環境原因未知，未為此改原始碼。
- desktop/mobile 恢復 Preview3 主按鈕核心版面；金額為純文字，價格 spinner 僅用於重新整理；`isSaving` 明確回饋儲存狀態，準備錯誤可見。Chat 背景解析保留 PNG 校驗；新階段日誌供後續實際裝置定位，不確認 Windows 根因或承諾消除全部一分鐘等待。
- **直接 API 探測：8 請求、7 成功、1 失敗，`stream=false`、無重試。** 四模型 single/multi 共 8 案例（含 initial V5 Full single）：其餘 7 個 HTTP 200 並取得有效 PNG；V4.5 Curated single 在 **152.177 秒** `RemoteDisconnected`，未重試，扣費未知。不是應用程式端對端驗收，也不是 8/8 通過；證據為上述 summary。
- 成功請求從開始至 headers **3.075–10.754 秒**、至 body complete **19.828–85.959 秒**，不是兩段相加。離線 Dart 樣本解析 **84 ms**、metadata **30 ms**，不代表全部等待皆由本機造成，也不外推所有回應效能。
- **實際 UI 皆 blocked**：Android 無 SDK／emulator／device；Windows debug 原生建置下載固定 NVIDIA DLSS 標頭時 TLS 錯誤 `35`。未完成真實裝置 UI、安裝或應用程式端對端驗收；Preview5 CI 與附件回驗通過不替代這些驗收。

### English

- **Final targeted regressions: all 740 tests in 42 files passed, `00:30`, exit `0`**, in the log above. Complete desktop-shell click tests: 4/4. Mobile file: 17 passed, including invocation of a fake callback, not device or real-service acceptance.
- The earlier full-repository run recorded **10634 passed / 3 skipped / 5 failed**, not a green full suite. Four items were subsequently fixed or retested successfully (i18n, navigation fixture, light-theme contrast, mobile layout). The installer `hiddenPowerShell` marker still fails. Its production code and test baseline are unchanged; an isolated child probe succeeds, the environmental cause remains unknown, and no production fix was made for it.
- Desktop/mobile restore the Preview3 main-button core layout. Amounts are plain text; the pricing spinner is refresh-only. `isSaving` explicitly reports saving, and preparation errors are visible. Background Chat parsing retains PNG validation. New phase logs support later device diagnosis, not a confirmed Windows root cause or a promise to eliminate all minute-long waits.
- **Direct API probes: 8 requests, 7 successes, 1 failure, `stream=false`, no retries.** The four-model single/multi matrix includes the initial V5 Full single probe. Seven returned HTTP 200 and valid PNGs. V4.5 Curated single raised `RemoteDisconnected` after **152.177 seconds**, without retry; billing is unknown. This is not app E2E acceptance or an 8/8 pass. Evidence: the summary above.
- Successful requests reached headers **3.075–10.754 seconds** after start and body completion **19.828–85.959 seconds** after start; these are not additive intervals. One offline Dart sample took **84 ms** to parse and **30 ms** for metadata. This neither attributes the whole wait to local processing nor establishes performance for all responses.
- **Actual UI acceptance is blocked on both platforms**: Android has no SDK/emulator/device; the Windows native debug build hit TLS error `35` downloading pinned NVIDIA DLSS headers. Real-device UI, installation and app E2E acceptance remain incomplete. Successful Preview5 CI and asset verification do not replace that acceptance.

### CI 配置 / 設定 / Configuration

39-file gate: existing 34 suites, followed by desktop shell click, submit guard, i18n, main navigation and light-theme readability. Existing Chat codec/compatible transport suites remain included. [Preview5 CI run 41297577735](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41297577735) completed with all six jobs successful; this does not establish a green full-repository test suite or real UI acceptance. 原 34 门禁及 macOS 15、immutable source、no-clobber 保留 / 原 34 閘門及 macOS 15、immutable source、no-clobber 保留 / The original 34 suites and macOS 15, immutable-source and no-clobber safeguards are retained. The disabled updater's separate installer suite is not added to this gate.

### Preview5 发布资产 / 發佈資產 / Published assets

[Preview5 Release](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5) · source SHA: `772fc8f2ee80e024d6bbbfe86a2106c31a66606a` · [CI run 41297577735](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41297577735): six jobs `success` · App version: `4.3.1+46` · Release ID: `430519156`

七附件已下载，tag／manifest／source SHA、六项校验、四包大小与 SHA-256、ZIP CRC、APK／EXE 检查通过。 / 七附件已下載，tag／manifest／source SHA、六項校驗、四包大小與 SHA-256、ZIP CRC、APK／EXE 檢查通過。 / All seven assets downloaded; tag/manifest/source SHA, six checksum entries, four package sizes/SHA-256 values, ZIP CRCs and APK/EXE checks passed.

证据 / 證據 / Evidence: `tool/.tmp/button-fix/preview5-verified.json` and `dist/custom-api-v4.3.1-preview.5/release_manifest.json`。Seven assets: four packages, `checksums.txt`, `release_manifest.json`, `release_notes_custom_api.md`; checksums do not include themselves.

| 文件 / File | 字节 / Bytes | SHA-256 |
| --- | ---: | --- |
| `NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.5.apk` | 277827360 | `f06982d73855f1d953cb1da87a45fd13734d7943fa02cc1cc810fbe66a2fe139` |
| `NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.5_Portable.zip` | 137622629 | `e0973d58c8abbb06d4f6a25df90c5e20d04adb8c90b2ea7706ba5801e2878e57` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Portable.zip` | 105086244 | `61b08a9a121ff205602f6a234cca290c27f4112d5e263aea75072835479b41e5` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Setup.exe` | 77986377 | `fbace2baf651af0d95fbcc679520996077637611dadb277213c366bc19116b49` |

Signing: Windows `unsigned`; macOS `ad-hoc-no-developer-id-not-notarized`; Android `ephemeral-debug-key-not-upstream`. 完整性校验不等于发布者签名、真实安装或 UI 验收 / 完整性校驗不等於發布者簽章、真實安裝或 UI 驗收 / Integrity verification is not publisher-signature, real-installation or UI acceptance. Code fixes do not establish that issues on users’ machines are resolved.

## Preview4 实际证据与验证边界 / 實際證據與驗證邊界 / Actual evidence and verification limits

2026-11-01 最终本地验证 / 最終本機驗證 / Final local validation:

| 检查 / 檢查 / Check | Preview4 实际证据 / 實際證據 / Actual evidence |
| --- | --- |
| 本地回归 / 本機回歸 / Local regressions | **38 files, 677 tests passed** · `00:35` · exit `0`；含新增 2 个 metadata 一致性用例 / 含新增 2 個 metadata 一致性案例 / Includes 2 added metadata-consistency cases。本地日志 / 本機日誌 / Local log: `tool/.tmp/provider-position/preview4-regressions.log`。 |
| 定向静态分析 / 定向靜態分析 / Scoped analysis | **24 Dart files** · `No issues found!`；后续 3 个改动文件单独分析亦无问题 / 後續 3 個改動檔案個別分析亦無問題 / The 3 subsequently changed files also passed separate analysis。本地日志 / 本機日誌 / Local log: `tool/.tmp/provider-position/final-analyze.log`。 |
| 源码审阅 / 原始碼審閱 / Source review | **31 reviewed paths**。 |
| CI / CI / CI | [run 41291110464](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41291110464) · `completed / success`；workflow 门禁 34 文件 / workflow 閘門 34 檔案 / 34-file workflow gate. |

- 本次范围为自定义 Chat 多角色定位（移除 AI 选择、5×5 网格、旧配置强制 `use_coords: true`）、official 原有定位行为，以及自定义预计费用移入生成按钮、移除独立价格框；费用数值逻辑与官方 Anlas 不变。
- 本次範圍為自訂 Chat 多角色定位（移除 AI 選擇、5×5 網格、舊設定強制 `use_coords: true`）、official 原有定位行為，以及自訂預估費用移入生成按鈕、移除獨立價格框；費用數值邏輯與官方 Anlas 不變。
- Scope: custom Chat multi-character positioning (no AI selection, a 5×5 grid, enforced `use_coords: true` for old configurations), existing official positioning, and moving the custom cost estimate into Generate without a separate price box; custom calculations and official Anlas remain unchanged.

未做真实 UI、安装或付费生成；Windows／Android 热重载会话未启动。附件回验不等于真实安装或 UI 验收，不沿用下列 Preview3 结果。 / 未做真實 UI、安裝或付費生成；Windows／Android 熱重載工作階段未啟動。附件回驗不等於真實安裝或 UI 驗收，不沿用下列 Preview3 結果。 / No real UI, installation, or paid-generation testing was performed; Windows/Android hot-reload sessions were not started. Asset verification does not establish real installation or UI acceptance; no Preview3 results are inherited.

### Preview4 发布资产 / 發佈資產 / Published assets

[Preview4 Release](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.4) · Tag: `custom-api-v4.3.1-preview.4` · source SHA: `8c974628b2f4f8e368502726632decefcc0c6023` · Release ID: `430476364` · App version: `4.3.1+46`

七附件已下载，六项校验通过，四包大小与 SHA-256 与 manifest 一致，归档 CRC 通过；tag／manifest／source SHA 一致。 / 七附件已下載，六項校驗通過，四包大小與 SHA-256 與 manifest 一致，封存 CRC 通過；tag／manifest／source SHA 一致。 / Seven assets downloaded; six checksum entries, four package sizes/SHA-256 values against the manifest, and archive CRCs verified; tag/manifest/source SHA matched.

Seven assets: four packages, `checksums.txt`, `release_manifest.json`, `release_notes_custom_api.md`. The checksum file does not checksum itself.

| 文件 / File | 字节 / Bytes | SHA-256 |
| --- | ---: | --- |
| `NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.4.apk` | 277827360 | `e3673f3f0fb1408f7ec3a7b954ef5dc2add5974723e487f540afab1f1052a1ff` |
| `NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.4_Portable.zip` | 137600309 | `1c3c7618a3c1e80477bddc3a19ac7ede6d10da95008fbf2bf887a35ca55d4c1c` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.4_Portable.zip` | 105070978 | `857053a585bf7779a7ee24b8c113d17d3f8ce965965cf6132ce7210916d009a0` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.4_Setup.exe` | 77975667 | `c54cd97654da815009f8db05e714af0a944c24da57168d5cf6b2b97c2db45b91` |

签名依实际 manifest / 簽章依實際 manifest / Signing per actual manifest: Windows `unsigned`; macOS `ad-hoc-no-developer-id-not-notarized`; Android `ephemeral-debug-key-not-upstream`. 完整性校验不是发布者签名或真实安装验收 / 完整性校驗不是發布者簽章或真實安裝驗收 / Integrity verification is not a publisher signature or real-installation acceptance.

## Preview3 历史证据 / 歷史證據 / Historical evidence

> **2026-11-01：Preview3 已公开发布、CI 构建成功、附件已回验 / 已公開發佈、CI 建置成功、附件已回驗 / Publicly released, CI builds succeeded, assets verified.**

## 简体中文

### 已有实际证据（2026-11-01）

| 检查 | 实际结果与边界 |
| --- | --- |
| 环境 | Flutter `3.47.5` / Dart `3.13.4`。 |
| 完整测试批次 | 最终 32 个文件，615 tests 全部通过。原 28 文件 604 tests（`00:19`，exit `0`）为较早批次。 |
| 定向回归 | timer provider 的 15 tests 已通过；新增 core 9 cases（空定价快照 1、异步准备后 epoch／endpoint 变化中止 8）均在完整批次通过；Agent 文案既有 3 个文件的 17 tests 全部通过。 |
| 静态分析 | 29 个 Dart 文件加登录测试，共 30 个文件；scoped analyze：`No issues`。 |
| 源码审阅 | 共 41 个 reviewed files。 |
| 公开定价请求 | 真实无认证 GET `https://api.cunzaijiang.cn/api/pricing`：HTTP `200`，响应 `14029 bytes`，`pricing_version=a42d372ccf0b5dd13ecf71203521f9d2`。仅公开读取，不是登录或生成。 |
| 生产定价解析 | 用实际响应经生产 `PricingRule` 验证四模型：V4.5 Full/Curated 的基础值 `0`、`+1 extra-Anlas` 为 `0.01`；V5 Full/Curated 的基础值 `0.05`、`+1 extra-Anlas` 为 `0.06`。均为无单位数字，只代表该版本规则。 |
| 原始 usage 分支 | 原始 `p=100000, c=10000` 按实际表达式走后备分支：V4.5 为 `0`，V5 为 `0.05`；不伪改成 `p=1`，保留编码不一致警告。这不是钱包实扣证明。 |
| 依赖来源 | `verify_flutter_sources` 通过：245 个 hosted 依赖均使用官方 `pub.dev`。 |

### 已补实现与尚未验证

- 已补 1 小时自动刷新 timer；离线时保留最近成功的持久缓存，首次获取失败后每小时重试。timer provider 的 15 tests 已通过，已纳入完整批次结果。
- Windows／Android 热重载会话均未启动；未做真实 UI 验收。
- 未配置真实 API Key，未做真实安装、付费生成、真实生成端到端或钱包实扣验证；公开定价及离线规则计算不能证明余额、订阅资格、真实扣款或任意第三方兼容性。
- Preview3 已公开发布，CI 全部 job 成功，云端 gate 32 文件通过。七附件均已下载，tag／manifest／source SHA 一致，六项校验通过，四包 SHA-256、ZIP CRC、APK／EXE 检查通过；三平台 QQ 图标资源与源码一致，编译载荷均含群地址 `qm.qq.com/q/jY8Pshi5os`。这些不代替真实安装或 UI 验收。

[协议与费用边界](custom_api.md) · [发行说明](releases/custom_api_preview.md)。[旧 Preview2（无动态定价）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)与[历史 CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)仅供旧版追溯，不证明 Preview3 已通过、已构建或已发布；旧附件与校验关系不变。Preview3 主下载已切换至本次已回验附件。

## 繁體中文

### 已有實際證據（2026-11-01）

| 檢查 | 實際結果與邊界 |
| --- | --- |
| 環境 | Flutter `3.47.5` / Dart `3.13.4`。 |
| 完整測試批次 | 最終 32 個檔案，615 tests 全部通過。原 28 檔案 604 tests（`00:19`，exit `0`）為較早批次。 |
| 定向回歸 | timer provider 的 15 tests 已通過；新增 core 9 cases（空定價快照 1、非同步準備後 epoch／endpoint 變更中止 8）皆在完整批次通過；Agent 文案既有 3 個檔案的 17 tests 全部通過。 |
| 靜態分析 | 29 個 Dart 檔案加登入測試，共 30 個檔案；scoped analyze：`No issues`。 |
| 原始碼審閱 | 共 41 個 reviewed files。 |
| 公開定價請求 | 真實無認證 GET `https://api.cunzaijiang.cn/api/pricing`：HTTP `200`，回應 `14029 bytes`，`pricing_version=a42d372ccf0b5dd13ecf71203521f9d2`。僅公開讀取，不是登入或生成。 |
| 生產定價解析 | 以實際回應經生產 `PricingRule` 驗證四模型：V4.5 Full/Curated 基本值 `0`、`+1 extra-Anlas` 為 `0.01`；V5 Full/Curated 基本值 `0.05`、`+1 extra-Anlas` 為 `0.06`。皆為無單位數字，僅代表該版本規則。 |
| 原始 usage 分支 | 原始 `p=100000, c=10000` 按實際運算式走後備分支：V4.5 為 `0`，V5 為 `0.05`；不偽改為 `p=1`，保留編碼不一致警告，不是錢包實扣證明。 |
| 依賴來源 | `verify_flutter_sources` 通過：245 個 hosted 依賴均使用官方 `pub.dev`。 |

### 已補實作與尚未驗證

- 已補 1 小時自動重新整理 timer；離線時保留最近成功的持久快取，首次擷取失敗後每小時重試。timer provider 的 15 tests 已通過，已納入完整批次結果。
- Windows／Android 熱重載工作階段皆未啟動；未做真實 UI 驗收。
- 未設定真實 API Key，未做真實安裝、付費生成、真實生成端對端或錢包實扣驗證；公開價格與離線規則計算不證明餘額、訂閱、真實扣款或任意服務相容性。
- Preview3 已公開發佈，CI 全部 job 成功，雲端 gate 32 檔案通過。七附件均已下載，tag／manifest／source SHA 一致，六項校驗通過，四包 SHA-256、ZIP CRC、APK／EXE 檢查通過；三平台 QQ 圖示資源與來源一致，編譯載荷均含群位址 `qm.qq.com/q/jY8Pshi5os`。不代替真實安裝或 UI 驗收。

[協定與費用邊界](custom_api.md) · [發行說明](releases/custom_api_preview.md)。[舊 Preview2（無動態定價）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)與[歷史 CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)僅供舊版追溯，不證明 Preview3 已通過、已建置或已發佈；舊附件／校驗關係不變。Preview3 主下載已切換至本次已回驗附件。

## English

### Actual evidence available (2026-11-01)

| Check | Observed result and limits |
| --- | --- |
| Environment | Flutter `3.47.5` / Dart `3.13.4`. |
| Full test batch | Final batch: all 615 tests in 32 files passed. Earlier batch: 604 tests in 28 files, `00:19`, exit `0`. |
| Targeted regressions | The timer provider’s 15 tests pass. All 9 new core cases (1 null pricing snapshot, 8 epoch/endpoint changes after asynchronous preparation) passed in the full batch. All 17 tests in 3 existing Agent wording files pass. |
| Static analysis | 29 Dart files plus the login test, 30 files total; scoped analyze: `No issues`. |
| Source review | 41 reviewed files. |
| Public pricing request | Real unauthenticated GET `https://api.cunzaijiang.cn/api/pricing`: HTTP `200`, response `14029 bytes`, `pricing_version=a42d372ccf0b5dd13ecf71203521f9d2`. Public retrieval only, not login or generation. |
| Production pricing parser | The actual response was checked through production `PricingRule` for four models: V4.5 Full/Curated baseline `0`, `+1 extra-Anlas` gives `0.01`; V5 Full/Curated baseline `0.05`, `+1 extra-Anlas` gives `0.06`. Unitless numbers for this rule version only. |
| Raw usage branch | Raw `p=100000, c=10000` takes the actual expression fallback: `0` for V4.5 and `0.05` for V5. It is not rewritten to `p=1`; the encoding-mismatch warning remains. This is not evidence of a wallet debit. |
| Dependency sources | `verify_flutter_sources` passed: all 245 hosted dependencies use official `pub.dev`. |

### Implemented and still unverified

- A 1-hour automatic-refresh timer has been added. The last successful durable cache is retained offline; an initial fetch failure is retried hourly. The timer provider’s 15 tests pass and are included in the full-batch result.
- Neither Windows nor Android hot-reload sessions have been started; no real UI acceptance testing has been performed.
- No real API key has been configured. Real installation, paid generation, real generation end-to-end, and actual wallet debits have not been verified. Public rates and offline rule calculations do not establish balances, subscription eligibility, actual charges, or arbitrary-provider compatibility.
- Preview3 is publicly released. All CI jobs succeeded; the cloud gate passed 32 files. All seven assets were downloaded, tag/manifest/source SHA matched, six checksum entries verified, and four package SHA-256 values, ZIP CRCs, and APK/EXE checks passed. QQ icon resources match source on all three platforms, and compiled payloads contain `qm.qq.com/q/jY8Pshi5os`. This does not establish real installation or UI acceptance.

[Protocol and billing limits](custom_api.md) · [Release notes](releases/custom_api_preview.md). [Old Preview2 (no dynamic pricing)](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2) and [historical CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696) are old-version provenance only, not proof that Preview3 has passed, been built, or been released. Old assets/checksum relationships remain unchanged. Primary Preview3 downloads now point to the verified release assets.

## Preview3 发布资产（历史）/ 發佈資產（歷史）/ Published assets (historical)

[Preview3 Release](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3) · [CI run 41264301138](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41264301138)

Tag: `custom-api-v4.3.1-preview.3` · source SHA: `34924235cf21052eea9749800296939dfdce595d` · Release ID: `430321468`

七附件 / 七附件 / Seven assets: four packages, `checksums.txt`, `release_manifest.json`, `release_notes_custom_api.md`. Six checksum entries verified; the checksum file itself is not counted as its own entry.

| 文件 / File | 字节 / Bytes | SHA-256 |
| --- | ---: | --- |
| `NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk` | 277729032 | `3b155e7f6e311113520dbe4b5a8a337c49f21aa5402359c9a3599577e76b6d37` |
| `NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip` | 137608248 | `b24795caa063178bc6e4e6243f596bec1ce1fabe9bacd8072eb1d7b7384c9173` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip` | 105065468 | `813a15c5cedc1a26776c6104be93984c451f5690d7e09cca1a73ccb8250455b3` |
| `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe` | 77969376 | `1716d325ed2a1bae6a5137a1231237674bcf61ad7897ccdfc42ebbd9bc1b5db5` |

签名以本次 manifest 为准：Windows 两包 `unsigned`；macOS `ad-hoc-no-developer-id-not-notarized`；Android `ephemeral-debug-key-not-upstream`。完整性校验不等于发布者数字签名或真实安装验收。

簽章依本次 manifest：Windows 兩包 `unsigned`；macOS `ad-hoc-no-developer-id-not-notarized`；Android `ephemeral-debug-key-not-upstream`。完整性校驗不等於發布者數位簽章或真實安裝驗收。

Signing per this release manifest: both Windows packages `unsigned`; macOS `ad-hoc-no-developer-id-not-notarized`; Android `ephemeral-debug-key-not-upstream`. Integrity verification is not publisher-signature or real-installation acceptance.
