# Custom API 验证记录 / 驗證記錄 / Verification record

> **Preview4 已公开发布并完成附件回验 / 已公開發佈並完成附件回驗 / Publicly released with assets verified.** CI run `41291110464`: `completed / success`。Preview3 历史证据独立保留 / 歷史證據獨立保留 / Historical evidence is preserved separately.

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
