# Preview3 验证记录 / 驗證記錄 / Verification record

> **2026-11-01：已完成本地验证，正在准备 Preview3 发布，尚未发布 / 已完成本機驗證，正在準備 Preview3 發佈，尚未發佈 / Local validation complete; Preview3 release preparation underway, not released.**
>
> GitHub 上传发布已获授权；本记录仅确认下列本地及公开定价证据，Preview3 CI、构建与发布附件仍待实际结果核对 / GitHub 上傳發佈已獲授權；本記錄僅確認下列本機與公開定價證據，Preview3 CI、建置與發佈附件仍待實際結果核對 / GitHub upload and publication are authorized. This record confirms only the local and public-pricing evidence below; Preview3 CI, builds, and release assets await actual-result verification.

## 简体中文

### 已有实际证据（2026-11-01）

| 检查 | 实际结果与边界 |
| --- | --- |
| 环境 | Flutter `3.47.5` / Dart `3.13.4`。 |
| 完整测试批次 | 28 个文件，604 tests 全部通过；用时 `00:19`，exit `0`。 |
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
- 本地 source-only patch／zip 交付位置为 `dist/custom-api-v4.3.1-preview.3-source/`，不是安装包，也不是构建或发布证明。GitHub 上传发布认证已验证，正在准备 Preview3 发布；本记录尚无 Preview3 CI、二进制构建、公开附件回验、产物大小、SHA-256 或已发布源码标识的确认结果，以上仍待实际结果核对，不填写推测值。目标 tag 为 `custom-api-v4.3.1-preview.3`，不是已发布证明。

[协议与费用边界](custom_api.md) · [待发布说明](releases/custom_api_preview.md)。[旧 Preview2（无动态定价）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)与[历史 CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)仅供旧版追溯，不证明 Preview3 已通过、已构建或已发布；旧附件与校验关系不变。只有实际发布并回验后才启用 Preview3 下载。

## 繁體中文

### 已有實際證據（2026-11-01）

| 檢查 | 實際結果與邊界 |
| --- | --- |
| 環境 | Flutter `3.47.5` / Dart `3.13.4`。 |
| 完整測試批次 | 28 個檔案，604 tests 全部通過；用時 `00:19`，exit `0`。 |
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
- 本機 source-only patch／zip 交付位置為 `dist/custom-api-v4.3.1-preview.3-source/`，不是安裝包，也不是建置或發佈證明。GitHub 上傳發佈認證已驗證，正在準備 Preview3 發佈；本記錄尚無 Preview3 CI、二進位建置、公開附件回驗、產物大小、SHA-256 或已發佈來源識別的確認結果，仍待實際結果核對，不填推測值。目標 tag `custom-api-v4.3.1-preview.3` 不是已發佈證明。

[協定與費用邊界](custom_api.md) · [待發佈說明](releases/custom_api_preview.md)。[舊 Preview2（無動態定價）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)與[歷史 CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)僅供舊版追溯，不證明 Preview3 已通過、已建置或已發佈；舊附件／校驗關係不變。實際發佈並回驗後才啟用 Preview3 下載。

## English

### Actual evidence available (2026-11-01)

| Check | Observed result and limits |
| --- | --- |
| Environment | Flutter `3.47.5` / Dart `3.13.4`. |
| Full test batch | All 604 tests in 28 files passed; duration `00:19`, exit `0`. |
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
- Local source-only patch/zip delivery location: `dist/custom-api-v4.3.1-preview.3-source/`, not installers or evidence of a build or release. GitHub upload/publication authentication has been verified and Preview3 release preparation is underway. This record has no confirmed Preview3 CI, binary-build, public-asset verification, artifact-size, SHA-256, or published-source-identifier results yet; these await actual-result verification, and none are invented. Target tag `custom-api-v4.3.1-preview.3` does not establish publication.

[Protocol and billing limits](custom_api.md) · [Unreleased notes](releases/custom_api_preview.md). [Old Preview2 (no dynamic pricing)](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2) and [historical CI](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696) are old-version provenance only, not proof that Preview3 has passed, been built, or been released. Old assets/checksum relationships remain unchanged. Enable Preview3 downloads only after actual publication and asset verification.
