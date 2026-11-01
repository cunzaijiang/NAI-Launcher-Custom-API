# NAI Launcher Custom API 4.3.1 Preview3

Tag: `custom-api-v4.3.1-preview.3` · Filename version: `4.3.1-custom-api-preview.3`

这是独立修改版预览，不是上游官方发行版或 NovelAI 官方产品。 / 這是獨立修改預覽，不是上游官方發行版或 NovelAI 官方產品。 / An independent modified preview, not an official upstream release or NovelAI product.

## 下载 / 下載 / Downloads

**附件以本发布实际资产为准 / 附件以本發佈實際資產為準 / The actual assets attached to this release are authoritative.** Preview3 已公开发布，以下四包已下载回验 / Preview3 已公開發佈，以下四包已下載回驗 / Preview3 is publicly released; all four packages below were downloaded and verified.

| 平台 / Platform | 包 / Package |
| --- | --- |
| Windows 安装版 / 安裝版 / Setup | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe) |
| Windows 便携版 / 可攜版 / Portable | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip) |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk) |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip) |

[旧 Preview2 回退（无动态定价）/ 舊 Preview2 回退（無動態定價）/ Old Preview2 fallback (no dynamic pricing)](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)

## 简体中文

Preview3 为自定义 Chat 绘图增加服务商动态定价、独立 extra-Anlas 估算和原始 usage 计算值展示。官方 NovelAI 登录、生成协议、整数 Anlas 计算、统计与授权门槛保持不变。原作者与 MIT 归属不变；上游仓库是致谢来源，不是本分支下载入口。

### 动态定价与费用边界

- **来源隔离**：仅主／图像地址均为精确 origin `https://api.cunzaijiang.cn`、路径为根或 `/v1` 时启用；不适用于其他 origin、子域、非默认端口或代理路径前缀。独立客户端公开 GET `https://api.cunzaijiang.cn/api/pricing`，不带 API Key、Authorization、Cookie，不跟随重定向；5 秒时限、1 MiB 响应上限，不触发登录或试画。
- **四模型、受限解析**：仅 NAI4.5 Full/Curated、NAI5 Full/Curated 的精确模型 ID，使用受限两分支 `tiered_expr` 白名单，不执行 `eval`。未知站点、模型、模式或表达式显示未知，不借用其他站点规则；V4 Full 可登录但没有此报价。
- **缓存与刷新**：保存 `pricing_version` 和获取时间，设备持久缓存 TTL 1 小时、不进入云备份；每小时自动刷新，首次获取失败后每小时重试。点击／触屏／键盘激活价格徽标仅刷新价格。失败保留最近成功目录并提示离线／过期，无估价显示 `--`；合法新目录中的未知表达式使对应模型变为未知，不沿用旧规则。
- **无单位数字**：报价和 usage 计算值只显示原始数字，不添加 USD、CNY、货币符号或推断币种。同步规则中的 NAI4.5 标准基础值为 `0`（仍可能有附加费）、NAI5 为 `0.05`；基础值、系数、偏移与分组倍率随同步规则变化，不是稳定价格承诺。
- **extra-Anlas 独立估算**：有效面积 `≤1048576` 且实际步数 `≤28` 时基础部分为 `0`；超出使用现有单图面积／步数、SMEA、模型及强度公式，不给予第三方订阅折扣。可用 Precise Reference 每张加 `5`；超过四张的 Vibe 每张加 `2`，另对每张启用 Vibe 每次独立请求计 `0..2` 编码区间，因为服务端缓存未知。批量逐次报价后对全部 `nSamples * imagesPerRequest` 独立请求求和，不能整批只收一次基础值或编码费。无效参数、超出现有单图上限 `140`、几何未就绪或超分流程不报价；完整公式及能力边界见协议说明。
- **预估不等于 usage，更不等于钱包实扣**：只有预估使用 `p=1`，零 extra-Anlas 时 `c=2`，否则 `c=extraAnlas*10000`。响应计算使用实际原始 `prompt_tokens` / `completion_tokens` 和同步表达式，响应模型必须明确匹配请求模型；缺字段或模型不匹配则未知。真实 `p=100000` 不能改成 `p=1`，即使 c 是 10000 的倍数也走实际后备分支并保留编码不一致警告。余额、订阅资格与钱包实扣仍未知；服务商报价不替换官方整数 Anlas，Agent/MCP 仍须确认未知费用，零预估不能自动免费放行。

### 使用与协议

1. 先备份，选择本发布实际附件并核对来源和 SHA-256；不要把源码归档当作安装包。
2. 登录页选择“自定义接口”，填写一个站点根地址或 `/v1` URL、昵称和 API Key / Token。主／图像 API 共用地址；登录仅 GET `/v1/models`，不试画、不查询占位订阅。
3. 服务商必须实现 OpenAI Chat `/v1/chat/completions` 契约：外层 `model` / `messages`，消息内为序列化 JSON 绘图 payload。仅接受恰好一个 Markdown 内联 PNG data URI，不支持 HTTP/HTTPS 远程图片 URL；不是通用 `/v1/images/generations` 适配器。
4. 登录白名单为 V4 Full、V4.5 Full/Curated、V5 Full/Curated；V5 Medium、V5 Vibe／Precise Reference 不可用。其他生成、参考和编辑能力由服务商决定；登录成功不保证全部能力。
5. 自定义绘图无原生 `/v1/ai` 生成／流式／编码调用，无中间预览、自动重试或协议回退。参考字段是 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 和 `character_references`，不是 `precise_reference`。Chat Vibe 发送原始参考图由服务端编码／缓存；客户端不持久保存或复用 `vibe_cache_ids`，不能证明缓存命中。Vibe 预算被忽略，不是硬上限；独立原生 Encode 不是 Chat 绘图能力证明。

Token 保存在设备安全存储，不进入云备份；登录发送 Token，绘图发送 Token、提示词、参数和所需图像至所填站点。仅使用可信服务。更新仅从本分支 Releases 手动下载安装；自动检查与应用内下载安装禁用，独立下载清单不作为上游可信签名自动更新元数据。

### 验证与安装安全

2026-11-01 本地验证：**最终 32 文件 615 tests 全通过**，包含 timer provider 15 tests 与新增 core 9 cases；另有 **3 文件 Agent 文案 17 tests 全通过**；**30 文件 scoped analyze：`No issues`**，审阅 41 文件。245 个 hosted 依赖使用官方 `pub.dev` 的来源检查通过。真实无认证公开定价请求返回 HTTP `200`，并用生产规则验证四模型；CI run 41264301138 全部 job 成功，云端 gate 32 文件通过；七附件下载、六项校验及四包哈希、ZIP CRC、APK／EXE 检查通过。这不代表真实安装验收或钱包扣费证明。未做真实 UI、真实安装、付费生成端到端或钱包实扣验证，不保证任意服务商兼容。

以本发布实际 `checksums.txt`、`release_manifest.json` 及 CI 记录核对文件与来源；缺失的大小、SHA-256、源码标识或签名结果不推测、不补造。哈希和独立清单只用于完整性／下载溯源，不是发布者数字签名。本次 Preview3 manifest 声明 Windows 无 Authenticode（`unsigned`）、macOS 仅 ad-hoc 且无 Developer ID／公证、Android 使用非上游临时 debug key。请核对实际包签名，不假定正式签名或跨版本覆盖安装兼容。应用 ID／安装位置可能与上游重叠，不同签名不能覆盖，卸载可能删除本地数据；先备份，不要全局关闭系统安全保护。源码归档不是安装包，缺少完整 Git LFS 数据库，也不包含上游云盘 OAuth 凭据。

如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈，分享前删除 Token 等敏感信息。

## 繁體中文

Preview3 為自訂 Chat 繪圖新增服務商動態定價、獨立 extra-Anlas 估算與原始 usage 計算值顯示。官方 NovelAI 登入、生成協定、整數 Anlas 計算、統計及授權門檻不變。原作者與 MIT 歸屬不變；上游倉庫僅供致謝，不是本分支下載入口。

### 動態定價與費用邊界

- **來源隔離**：主／影像位址均須為精確 origin `https://api.cunzaijiang.cn`，路徑為根或 `/v1`；其他 origin、子網域、非預設埠或代理前綴不適用。獨立公開 GET `https://api.cunzaijiang.cn/api/pricing`，不帶 API Key／Authorization／Cookie、不跟隨重新導向；5 秒時限、1 MiB 上限，不登入或試畫。
- **四模型、受限解析**：僅 NAI4.5／5 Full/Curated 精確 ID，採兩分支 `tiered_expr` 白名單，不用 `eval`。未知來源、模型、模式或運算式維持未知，不跨站套用規則；V4 Full 可登入但沒有此報價。
- **快取與重新整理**：保存 `pricing_version`、擷取時間與 1 小時 TTL 裝置持久快取，不進雲端備份；每小時自動重新整理，首次失敗後每小時重試。點擊／觸控／鍵盤啟動徽章只更新價格。失敗保留最近成功目錄並提示離線／過期，無估價顯示 `--`；合法新目錄內未知運算式使模型轉為未知，不沿用舊規則。
- **無單位數字**：報價與 usage 計算值僅顯示原始數字，無 USD、CNY、貨幣符號或推斷幣別。同步規則的 NAI4.5 標準基本值 `0` 仍可有附加費，NAI5 基本值 `0.05`；基本值、係數、偏移與群組倍率隨規則變化，不是穩定價格承諾。
- **獨立 extra-Anlas**：有效面積 `≤1048576` 且實際步數 `≤28` 時基本部分 `0`，超出採既有單圖面積／步數、SMEA、模型及強度公式，無第三方訂閱折扣。可用 Precise 每張加 `5`；Vibe 超過四張每張加 `2`，另因伺服器快取未知，每張啟用 Vibe 每次獨立請求計 `0..2` 編碼區間。逐次報價後加總全部 `nSamples * imagesPerRequest` 請求，不是整批只收一次基本值／編碼費。無效參數、超過既有單圖上限 `140`、幾何未就緒或超分流程不報價；完整公式及能力見協定說明。
- **估算、usage 與錢包分離**：僅估算用 `p=1`，零 extra-Anlas 時 `c=2`，否則 `c=extraAnlas*10000`。回應用實際原始 `prompt_tokens`／`completion_tokens` 與同步運算式，回應模型須明確匹配；缺欄位／模型不符則未知。真實 `p=100000` 不得改成 `p=1`，即使 c 為 10000 倍數仍走實際後備分支並保留編碼不一致警告。餘額、訂閱與錢包實扣未知；報價不替換官方整數 Anlas。Agent/MCP 仍須確認未知費用，零估算不能自動免費放行。

### 使用與協定

1. 先備份，下載本發佈實際附件，核對來源與 SHA-256；來源封存檔不是安裝包。
2. 登入頁選「自訂介面」，填一個根位址或 `/v1` URL、暱稱與 API Key／Token；主／影像 API 共用位址。登入僅 GET `/v1/models`，不試畫或查佔位訂閱。
3. 服務商須實作 OpenAI Chat `/v1/chat/completions`：外層 `model`／`messages`，內容為序列化 JSON 繪圖 payload；僅接受恰好一個 Markdown 行內 PNG data URI，不支援遠端圖片 URL，不是通用 `/v1/images/generations` 介接。
4. 登入支援 V4 Full、V4.5／5 Full/Curated；V5 Medium、V5 Vibe／Precise 不可用。其他生成、參考與編輯能力由服務商決定，登入成功不保證全部能力。
5. 無原生 `/v1/ai` 繪圖／串流／編碼、中間預覽、自動重試或協定回退。參考用 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 與 `character_references`，不是 `precise_reference`。Chat Vibe 送原始圖由伺服器編碼／快取，客戶端不持久儲存／重用 `vibe_cache_ids`，不能證明命中；預算被忽略，不是硬上限。獨立原生 Encode 不證明 Chat 繪圖能力。

Token 在裝置安全儲存、不進雲端備份；登入傳送 Token，繪圖傳送 Token、提示詞、參數與所需影像至所填站點。僅使用可信服務。更新僅從本分支 Releases 手動下載安裝；自動檢查與應用程式內下載安裝停用，獨立清單不是上游可信任簽章自動更新中繼資料。

### 驗證與安裝安全

2026-11-01 本機驗證：**最終 32 檔案 615 tests 全通過**，含 timer provider 15 tests 與新增 core 9 cases；另有 **3 檔案 Agent 文案 17 tests 全通過**；**30 檔案 scoped analyze：`No issues`**，審閱 41 檔案。245 個 hosted 依賴均用官方 `pub.dev` 的來源檢查通過。真實無認證公開定價 HTTP `200`，經生產規則驗證四模型；CI run 41264301138 全部 job 成功，雲端 gate 32 檔案通過；七附件下載、六項校驗及四包雜湊、ZIP CRC、APK／EXE 檢查通過。不代表真實安裝驗收或錢包扣費。未做真實 UI、安裝、付費生成端對端或錢包實扣驗證，不保證任意服務相容。

依本發佈實際 `checksums.txt`、`release_manifest.json` 與 CI 記錄核對檔案／來源，不推測缺失的大小、SHA-256、來源識別或簽章結果。雜湊與獨立清單是完整性／下載溯源，不是發布者數位簽章。本次 Preview3 manifest 聲明 Windows 無 Authenticode（`unsigned`）、macOS 僅 ad-hoc 且無 Developer ID／公證、Android 使用非上游臨時 debug key。核對實際套件簽章，不假定正式簽章或跨版覆蓋相容。ID／安裝位置可能與上游重疊，不同簽章不能覆蓋，解除安裝可能刪資料；先備份，不要全域停用安全保護。來源封存不是安裝包，缺完整 Git LFS 資料庫，不含上游雲端 OAuth 憑證。

如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報，分享前移除 Token 等敏感資訊。

## English

Preview3 adds provider dynamic pricing, separate extra-Anlas estimates, and raw-usage-derived values to custom Chat drawing. Official NovelAI login, generation protocol, integer Anlas calculations, statistics, and authorization gates remain unchanged. Original-author and MIT attribution remain intact; upstream is an acknowledgment source, not this fork's download destination.

### Dynamic pricing and billing boundaries

- **Origin isolation**: Both main/image URLs must use exact origin `https://api.cunzaijiang.cn` at root or `/v1`; other origins, subdomains, nondefault ports, and proxy prefixes are excluded. An isolated public GET to `https://api.cunzaijiang.cn/api/pricing` sends no API key, Authorization, or Cookie and follows no redirects; 5-second deadline, 1-MiB response limit. It performs neither login nor test generation.
- **Four models, bounded parsing**: Only exact NAI4.5/5 Full/Curated IDs, using a bounded two-branch `tiered_expr` whitelist, never `eval`. Unknown origins/models/modes/expressions remain unknown, without cross-site rules. V4 Full supports login but has no quote here.
- **Cache and refresh**: `pricing_version`, fetch time, and a durable device cache with a 1-hour TTL stay outside cloud backups. Hourly refresh includes retries after an initial failure. Clicking/touching/keyboard-activating the badge only refreshes pricing. Failures retain the last successful catalog with offline/stale warnings; unavailable quotes show `--`. Unknown expressions in a valid new catalog make that model unknown rather than preserving old rules.
- **Unitless numbers**: Quotes and usage-derived values show raw numbers only, without USD, CNY, currency symbols, or inferred currency. Synchronized rules describe a NAI4.5 standard baseline of `0` with possible extras and a NAI5 base of `0.05`. Base/coefficient/offset/group factor follow synchronized rules, not stable price promises.
- **Separate extra-Anlas**: Zero base component at effective area `≤1048576` and actual steps `≤28`; otherwise the existing single-image area/step, SMEA, model, and strength formula applies without third-party subscription discounts. Supported Precise References add `5` each; Vibes beyond four add `2` each, plus a `0..2` encoding range per enabled Vibe per independent request because server cache state is unknown. Quote each request, then sum all `nSamples * imagesPerRequest` requests, not one base/encoding fee for the whole batch. Invalid inputs, values above the existing per-image limit `140`, unresolved geometry, and upscale workflows have no quote. See the protocol guide for full formulas and capability limits.
- **Estimates, usage, and wallets are distinct**: Only estimates use `p=1`, with `c=2` at zero extra-Anlas, otherwise `c=extraAnlas*10000`. Responses use actual raw `prompt_tokens` / `completion_tokens` with synchronized expressions and require an explicitly matching response model; missing fields/model mismatches remain unknown. Never rewrite real `p=100000` to `p=1`: even if c is divisible by 10000, evaluate the actual fallback and retain the encoding-mismatch warning. Balances, eligibility, and wallet debits remain unknown. Quotes do not replace official integer Anlas; Agent/MCP still requires unknown-cost confirmation even for a zero estimate.

### Usage and protocol

1. Back up, download actual release assets, and verify provenance and SHA-256. Source archives are not installers.
2. Choose Custom API on the sign-in page and enter one root or `/v1` URL, nickname, and API key/token; main/image APIs share the URL. Login only GETs `/v1/models`, without test generation or placeholder subscription queries.
3. Providers must implement OpenAI Chat `/v1/chat/completions`: outer `model` / `messages`, serialized JSON drawing payload inside content, and exactly one inline Markdown PNG data URI in the response. Remote image URLs are unsupported; this is not a generic `/v1/images/generations` adapter.
4. Login allows V4 Full and V4.5/5 Full/Curated. V5 Medium and V5 Vibe/Precise Reference are unavailable. Other generation/reference/editing capabilities depend on the provider; successful login does not guarantee them all.
5. No native `/v1/ai` drawing/streaming/encoding calls, intermediate previews, automatic retries, or protocol fallback. References use `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` and `character_references`, not `precise_reference`. Chat Vibe sends raw references for server encoding/cache; the client neither persists nor reuses `vibe_cache_ids`, which do not establish cache hits. Vibe budgets are ignored, not hard caps. Independent native Encode does not establish Chat drawing support.

Tokens remain in device secure storage, excluded from cloud backups. Login sends the token; drawing sends the token, prompts, parameters, and required images to your configured site. Use trusted providers only. Updates are manual downloads/installations from this fork's Releases; automatic checks and in-app installation are disabled. Independent manifests are not upstream trusted signed automatic-update metadata.

### Validation and installation safety

Local evidence on 2026-11-01: **all 615 tests in the final 32-file batch passed**, including the timer provider's 15 tests and 9 new core cases; **all 17 tests in 3 additional Agent wording files passed**; **scoped analyze of 30 files: `No issues`**; 41 files reviewed. Dependency-source checks passed for all 245 hosted dependencies using official `pub.dev`. A real unauthenticated public-pricing request returned HTTP `200`, and production rules checked all four models. All jobs in CI run 41264301138 succeeded; the cloud gate passed 32 files. All seven assets were downloaded; six checksum entries, four package hashes, ZIP CRCs, and APK/EXE checks passed. This does not establish real installation acceptance or wallet debits. Real UI, installation, paid-generation end-to-end, and wallet-debit testing have not been performed; arbitrary-provider compatibility is not guaranteed.

Use this release's actual `checksums.txt`, `release_manifest.json`, and CI records to check files and provenance. Missing sizes, SHA-256 values, source identifiers, or signature results are not guessed. Hashes and independent manifests provide integrity/download provenance, not publisher digital signatures. This Preview3 manifest declares unsigned Windows packages, ad-hoc-only macOS signing without Developer ID/notarization, and Android signing with an ephemeral non-upstream debug key. Check actual package signatures; do not assume production signing or cross-version replacement compatibility. Application IDs/install locations may overlap upstream, differing signatures prevent replacement, and uninstalling can erase data. Back up and never globally disable security. Source archives are not installers, omit the full Git LFS database, and contain no upstream cloud OAuth credentials.

Report issues through Settings → About → Export diagnostic logs, removing tokens and other sensitive information before sharing.

完整协议与公式 / 完整協定與公式 / Full protocol and formulas: https://github.com/cunzaijiang/NAI-Launcher-Custom-API/blob/custom-api-v4.3.1-preview.3/docs/custom_api.md

实际验证记录 / 實際驗證記錄 / Actual verification record: https://github.com/cunzaijiang/NAI-Launcher-Custom-API/blob/custom-api-v4.3.1-preview.3/docs/custom_api_verification.md

## 发布回验 / 發佈回驗 / Release verification

Source SHA: `34924235cf21052eea9749800296939dfdce595d` · [CI run 41264301138](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41264301138) · [包大小、SHA-256 与验证边界 / 套件大小、SHA-256 與驗證邊界 / Package sizes, SHA-256, and verification limits](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/blob/custom-api/docs/custom_api_verification.md)

本版更新 [QQ 群入口](https://qm.qq.com/q/jY8Pshi5os)及标准 QQ 图标，其他功能不变。已确认三平台 QQ 图标资源与编译群地址包含，不代表真实点击或 UI 验收。

本版更新 [QQ 群入口](https://qm.qq.com/q/jY8Pshi5os)與標準 QQ 圖示，其他功能不變。已確認三平台 QQ 圖示資源與編譯群位址包含，不代表真實點擊或 UI 驗收。

This version updates the [QQ group entry](https://qm.qq.com/q/jY8Pshi5os) and standard QQ icon; other functionality is unchanged. QQ icon resources and the compiled group URL were confirmed on all three platforms; this is not real click or UI acceptance testing.
