# 自定义图像 API / 自訂影像 API / Custom image APIs

> **Preview3 已公开发布并完成附件回验 / 已公開發佈並完成附件回驗 / Publicly released with assets verified.** [Preview3 Downloads](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3) · source SHA: `34924235cf21052eea9749800296939dfdce595d` · [验证 / 驗證 / Verification](custom_api_verification.md)。动态定价适用于 Preview3，旧 Preview2 不含此功能 / 動態定價適用於 Preview3，舊 Preview2 不含此功能 / Dynamic pricing applies to Preview3, not old Preview2.

最终本地验证 / 最終本機驗證 / Final local validation (2026-11-01): **32 files, 615 tests passed**；额外 Agent 文案 / 額外 Agent 文案 / Additional Agent wording: **3 files, 17 tests passed**；既有 scoped analyze / 既有靜態分析 / Earlier scoped analyze: **30 files, `No issues`**；源码审阅 / 原始碼審閱 / Source review: **41 files**。CI 全部 job 成功，云端 gate 32 文件通过；七附件下载、六项校验通过 / CI 全部 job 成功，雲端 gate 32 檔案通過；七附件下載、六項校驗通過 / All CI jobs succeeded; the cloud gate passed 32 files; seven assets downloaded and six checksum entries verified. 未做真实安装、UI、付费生成或钱包实扣验收 / 未做真實安裝、UI、付費生成或錢包實扣驗收 / Real installation, UI, paid generation, and wallet debits remain unverified.

## 简体中文

### 登录与协议

- **NovelAI 官方**：官方 Token、账号密码及原有生成协议不变。
- **自定义接口**：固定使用 **OpenAI Chat `/v1/chat/completions`**，没有协议开关；不是任意 OpenAI 图片服务的通用适配器，也不使用 `/v1/images/generations`。
- 填写一个 API URL、昵称与 API Key / Token。`https://provider.example` 与 `https://provider.example/v1/` 均规范为 `https://provider.example/v1`，保留反向代理路径前缀。主 API 与图像 API 共用地址。Token 以 Bearer 发送，请仅使用可信站点。
- 登录仅 GET `/v1/models`，要求成功响应中非空 `data` 列表至少包含以下一个精确模型 ID；HTML、空列表、未知模型和 HTTP 错误均不通过。不试画、不查询占位 `/user/subscription`。

| 模型 ID | 模型 |
| --- | --- |
| `nai-diffusion-4-full` | V4 Full |
| `nai-diffusion-4-5-full` | V4.5 Full |
| `nai-diffusion-4-5-curated` | V4.5 Curated |
| `nai-diffusion-5-full` | V5 Full |
| `nai-diffusion-5-curated` | V5 Curated |

### 绘图请求与响应

参考字段契约：`controlnet` 是对象 `{ "strength": 1, "images": [{ "image": "<BASE64_PNG>", "info_extracted": 1, "strength": 1 }] }`，不是图片数组本身，提取字段为 `info_extracted`。精准参考使用 `character_references` 数组，**不是 `precise_reference`**。数值仅示例，实际取对应参考参数。

POST `/v1/chat/completions` 的外层是 OpenAI Chat `model`、`messages` 等字段，`messages` 的消息内容携带序列化的 JSON 绘图 payload（模型、提示词、参数、源图或参考图），不是普通自然语言聊天，也不是把原生绘图参数直接作为外层请求。服务商必须支持这一约定。

响应仅接受 Chat 消息内容中**恰好一个 Markdown 内联 PNG data URI**：`![image](data:image/png;base64,<PNG_BASE64>)`，并验证 PNG 数据。**不支持 HTTPS/HTTP 远程图片 URL，也不会跟随远程链接下载图片。**仅返回最终图像；“流式预览”设置不会产生中间预览。失败不自动重试，也不回退到原生生成、原生流式端点或其他协议，避免重复收费。

**自定义绘图不调用原生 `/v1/ai/generate-image`、`/v1/ai/generate-image-stream` 或 `/v1/ai/encode-vibe`。** Chat Vibe 直接发送原始参考图，由服务端负责编码与缓存，不能依赖客户端已有编码缓存。当前客户端仅读取响应的 `vibe_cache_ids` 用于结果对象与诊断计数，不持久保存，也不在后续请求中复用 `cache_id`；不保证跨请求或跨会话缓存复用。Vibe 的预算字段会被忽略，不构成费用上限。独立 **Encode** 操作是单独的原生编码工具，不属于 Chat 绘图路径，其支持情况不能推导为绘图能力。

不支持 V5 Medium；V5 Vibe / Precise Reference 不可用。其他模型的参考图与编辑能力仍由服务商决定，登录通过并不表示所有功能可用。旧原生自定义账号不会静默迁移；如提示旧协议不受支持，请从“自定义接口”重新添加。

### 费用、隐私与更新

#### Preview3 动态定价（不是钱包账单）

- **来源边界**：仅当自定义 Chat 入口的主／图像地址均属于精确 origin `https://api.cunzaijiang.cn`，且路径为根或 `/v1`（可带结尾 `/`）时启用。HTTPS 默认端口 443、主机大小写按规范归一；其他 origin、子域、非默认端口、代理路径前缀均不适用。不把该来源的价格借给其他站点，也不以公开价格验证服务商可信度或生成能力。
- **公开读取**：独立、无认证客户端 GET `https://api.cunzaijiang.cn/api/pricing`，不携带 API Key、Authorization、Cookie 或应用认证拦截器，不跟随重定向；5 秒请求时限、1 MiB 响应上限。定价读取与带 Bearer 的 `/v1/models` 登录验证分开，不触发生成。
- **缓存与失败**：校验 `success`、`pricing_version`、`group_ratio` 中的 `NovelAI分组` 及其启用模型规则；保留版本和获取时间，SharedPreferences 设备本地持久缓存 TTL 1 小时，不进入云备份；已补每小时自动刷新，首次获取失败后每小时重试。点击／触屏或键盘激活徽标仅强制刷新价格；失败保留最近成功目录并提示离线／过期，无可用规则显示 `--`／未知。新目录合法但表达式不受支持时，该模型变为未知，不继续沿用旧表达式。
- **仅四模型与受限解析**：`nai-diffusion-4-5-full`、`nai-diffusion-4-5-curated`、`nai-diffusion-5-full`、`nai-diffusion-5-curated`。V4 Full 虽在登录白名单中，但没有本功能报价。只接受 `tiered_expr` 的固定两分支形状 `p==1 && c>=10000 && floor(c/10000)*10000==c ? tier("anlas", [offset +] c*coefficient) : tier("free"或"base", fixed(base))`，数值须有限且非负，表达式长度最多 4096 字符；**不是通用表达式执行器，不使用 `eval`**。缺失模型、未知模式／表达式或无效数据保持未知，绝不伪造为 0。
- **无币种**：按用户明确要求，报价及响应计算值仅显示无单位原始数字，忽略货币元数据，不添加 USD、CNY 或货币符号，不推断币种。同步规则所描述的 **NAI4.5 标准基础值为 0，仍可能有附加费用；NAI5 基础值为 0.05**。基础值、系数、偏移及分组倍率来自同步规则，可随 `pricing_version` 改变，不是硬编码的稳定价格承诺。2026-11-01 已公开读取并用生产规则验证四模型价格，见[实际验证记录](custom_api_verification.md)；未验证钱包实扣。
- **独立 extra-Anlas 估算**：有效计费面积 `A=width*height ≤1048576` 且实际步数 `S≤28` 时，基础部分 `B=0`，不依赖第三方订阅资格；任一超出则调用现有 `AnlasCalculator.calculateFromValues` 的单图、无订阅折扣公式。现代模型即 `B=max(ceil(ceil(2.951823174884865e-6*A + 5.753298233447344e-7*A*S*stepCostFactor)*smeaFactor*modelMultiplier*strength),2)`，SMEA 倍率为 1／1.2／1.4，模型与步数倍率按当前模型能力；超过现有单图上限 140 或参数无效则未知。使用实际生成／增强尺寸及 Focused Inpaint 请求裁剪尺寸；几何未就绪或超分流程不报价。
- **参考图与批量**：仅对模型／操作允许的参考功能计费，可用 Precise Reference 每张加 5；Vibe 超过四张的每张加 2，另因服务端编码缓存未知，所有启用 Vibe 每张每次独立请求加 `0..2` 的编码区间，即 `E低=B+5*R精+2*max(Rvibe-4,0)`，`E高=E低+2*Rvibe`（按能力互斥／禁用后计数）。客户端已有编码或返回的 `vibe_cache_ids` 不证明服务端缓存命中。每张样本都是独立 HTTP 请求；每次先把 E 代入价格规则，再对 `nSamples * imagesPerRequest` 的全部请求求和，不能把整批 E 合并后只收一次基础值，也不能只收一次 Vibe 编码费。
- **估算与真实 usage 分开**：仅估算使用规范输入 `p=1`，`E=0` 时 `c=2`，否则 `c=E*10000`。满足表达式条件的分支金额为 `(offset+c*coefficient)/1000000*groupFactor`，否则为 `base*groupFactor`。响应计算必须使用实际原始 `prompt_tokens` / `completion_tokens`（p/c），且响应模型须与实际请求模型明确一致；缺字段或模型不匹配则未知。**`p=100000` 不能改成 `p=1`**：即使 `c` 为 10000 的倍数，也走表达式实际的后备分支并保留编码不一致警告。计算值不是钱包实扣、发票或“实际 Anlas 消耗”，不要从 c 单独反推实际扣款。
- 余额、订阅资格与钱包实扣仍为**未知**；不伪造 Opus 免费资格。官方路线的整数 Anlas 计算、统计及授权门槛不变，服务商报价独立保存／展示，不替换官方整数 Anlas。Agent/MCP 收费操作仍需确认未知费用，不能因估算为 0 自动免费放行。Vibe 预算仍被忽略，不是硬上限；请向服务商确认价格、额度与限额。

- Token 保存在当前设备安全存储，不进入云备份。验证发送 Token；绘图发送 Token、提示词、参数与所需图像到所填站点，结果仅从消息中的内联 PNG data URI 读取，不下载远程图片。请仅使用可信服务，反馈日志前删除敏感信息。
- 独立预览版的自动检查更新和应用内下载安装均禁用。应用内 GitHub 与手动更新入口指向 [本分支](https://github.com/cunzaijiang/NAI-Launcher-Custom-API)及其 [Releases](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases)，请选择最新预发布版本并核对校验值后手动安装。独立下载清单不是上游受信任签名更新清单，不解析为自动更新。官方账号路线也遵循此发行版更新边界。

## 繁體中文

### 登入與協定

- **NovelAI 官方**：官方 Token、帳號密碼與原有生成協定不變。
- **自訂介面**：固定使用 **OpenAI Chat `/v1/chat/completions`**，沒有協定開關；不是任意 OpenAI 影像服務的通用介接，也不使用 `/v1/images/generations`。
- 填寫一個 API URL、暱稱與 API Key / Token。根位址與 `/v1/` 位址均正規化為 `/v1`，保留反向代理路徑前綴；主 API 與影像 API 共用位址。Token 以 Bearer 傳送，請僅使用可信站點。
- 登入僅 GET `/v1/models`，要求成功回應中非空 `data` 清單包含上表至少一個精確模型 ID（V4 Full、V4.5 Full/Curated、V5 Full/Curated）。HTML、空清單、未知模型與 HTTP 錯誤均不通過；不試畫、不查詢佔位 `/user/subscription`。

### 繪圖請求與回應

參考欄位契約：`controlnet` 是物件 `{ "strength": 1, "images": [{ "image": "<BASE64_PNG>", "info_extracted": 1, "strength": 1 }] }`，不是圖片陣列本身，擷取欄位為 `info_extracted`。精準參考使用 `character_references` 陣列，**不是 `precise_reference`**。數值僅為範例，實際取對應參考參數。

POST `/v1/chat/completions` 外層使用 OpenAI Chat `model`、`messages` 等欄位，訊息內容放序列化 JSON 繪圖 payload（模型、提示詞、參數、來源圖或參考圖），不是一般自然語言聊天，也不把原生參數直接放在外層。服務商必須支援此約定。

回應僅接受 Chat 訊息內容中**恰好一個 Markdown 行內 PNG data URI**：`![image](data:image/png;base64,<PNG_BASE64>)`，並驗證 PNG 資料。**不支援 HTTPS/HTTP 遠端圖片 URL，也不會跟隨遠端連結下載圖片。**僅回傳最終影像，「串流預覽」不會產生中間預覽。失敗不自動重試，不回退到原生生成、原生串流或其他協定，以免重複收費。

**自訂繪圖不呼叫原生 `/v1/ai/generate-image`、`/v1/ai/generate-image-stream` 或 `/v1/ai/encode-vibe`。** Chat Vibe 直接傳送原始參考圖，由伺服器編碼與快取，不依賴用戶端已有編碼快取。目前用戶端僅讀取回應的 `vibe_cache_ids` 至結果物件與診斷計數，不持久儲存，也不在後續請求重用 `cache_id`；不保證跨請求或跨工作階段快取重用。其預算欄位被忽略，不是費用上限。獨立 **Encode** 是個別原生編碼工具，不屬於 Chat 繪圖路徑，不能據此推斷繪圖能力。

不支援 V5 Medium；V5 Vibe / Precise Reference 不可用。其他參考與編輯能力由服務商決定，登入成功不保證全部功能。舊原生自訂帳號不會靜默遷移；若提示舊協定不受支援，請重新新增帳號。

### 費用、隱私與更新

#### Preview3 動態定價（不是錢包帳單）

- **來源邊界**：自訂 Chat 的主／影像位址必須同屬精確 origin `https://api.cunzaijiang.cn`，路徑為根或 `/v1`（可帶結尾 `/`）。HTTPS 預設 443 與主機大小寫按規範正規化；其他 origin、子網域、非預設埠或代理路徑前綴均不適用。規則不借給其他站點，公開價格不證明服務可信或生成能力。
- **公開讀取**：獨立無認證用戶端 GET `https://api.cunzaijiang.cn/api/pricing`，不帶 API Key、Authorization、Cookie 或應用程式認證攔截器，不跟隨重新導向；時限 5 秒，回應上限 1 MiB。與帶 Bearer 的 `/v1/models` 登入驗證分開，不生成圖片。
- **快取與失敗**：驗證 `success`、`pricing_version`、`group_ratio` 的 `NovelAI分组` 及其啟用模型規則，儲存版本與擷取時間。SharedPreferences 裝置本機持久快取 TTL 1 小時，不進入雲端備份；已補每小時自動重新整理，首次擷取失敗後每小時重試。點擊／觸控或鍵盤啟動徽章只強制重新整理價格；失敗保留最近成功目錄並提示離線／過期，無規則顯示 `--`／未知。合法新目錄包含不支援運算式時，該模型轉為未知，不沿用舊運算式。
- **僅四模型、受限解析**：`nai-diffusion-4-5-full`、`nai-diffusion-4-5-curated`、`nai-diffusion-5-full`、`nai-diffusion-5-curated`；登入允許的 V4 Full 沒有本功能報價。僅接受 `tiered_expr` 固定兩分支形狀 `p==1 && c>=10000 && floor(c/10000)*10000==c ? tier("anlas", [offset +] c*coefficient) : tier("free"或"base", fixed(base))`，數值有限且非負，運算式最多 4096 字元。**不是通用執行器，不使用 `eval`**；缺失模型、未知模式／運算式或無效資料維持未知，不偽造為 0。
- **無幣別**：依使用者明確要求，報價與回應計算值僅顯示無單位原始數字，忽略貨幣中繼資料，不加 USD、CNY 或貨幣符號，不推斷幣別。同步規則所描述的 **NAI4.5 標準基本值為 0，仍可能有附加費用；NAI5 基本值為 0.05**。基本值、係數、偏移與群組倍率隨同步規則／`pricing_version` 變化，不是硬編碼的穩定價格承諾。2026-11-01 已公開讀取並用生產規則驗證四模型價格，見[實際驗證記錄](custom_api_verification.md)；未驗證錢包實扣。
- **獨立 extra-Anlas 估算**：有效計費面積 `A=width*height ≤1048576` 且實際步數 `S≤28` 時基本部分 `B=0`，不依賴第三方訂閱資格；超出任一條件使用現有 `AnlasCalculator.calculateFromValues` 單圖、無訂閱折扣公式。現代模型為 `B=max(ceil(ceil(2.951823174884865e-6*A + 5.753298233447344e-7*A*S*stepCostFactor)*smeaFactor*modelMultiplier*strength),2)`；SMEA 倍率 1／1.2／1.4，模型／步數倍率依目前模型能力。超過既有單圖上限 140 或參數無效則未知。採實際生成／增強尺寸與 Focused Inpaint 請求裁剪尺寸；幾何未就緒或超分流程不報價。
- **參考圖與批次**：僅計模型／操作允許的參考，可用 Precise Reference 每張加 5；超過四張的 Vibe 每張加 2，另因伺服器編碼快取未知，每張啟用 Vibe 每次請求增加 `0..2` 編碼區間。`E低=B+5*R精+2*max(Rvibe-4,0)`，`E高=E低+2*Rvibe`（計數遵循能力互斥／停用）。本機已有編碼或回傳 `vibe_cache_ids` 不證明伺服器快取命中。每張樣本是獨立 HTTP 請求，逐次將 E 代入價格規則，再對 `nSamples * imagesPerRequest` 全部請求加總；不能先合併整批 E 而只收一次基本值或 Vibe 編碼費。
- **估算與真實 usage 分開**：僅估算使用 `p=1`，`E=0` 時 `c=2`，否則 `c=E*10000`；符合條件時金額為 `(offset+c*coefficient)/1000000*groupFactor`，否則為 `base*groupFactor`。回應必須以實際原始 `prompt_tokens` / `completion_tokens`（p/c）計算，回應模型須明確等於實際請求模型；缺欄位／模型不符則未知。**不得把 `p=100000` 改成 `p=1`**；即使 c 是 10000 倍數仍走實際後備分支，保留編碼不一致警告。計算值不是錢包實扣、發票或「實際 Anlas 消耗」，不能只從 c 反推扣款。
- 餘額、訂閱資格與錢包實扣仍**未知**，不偽造 Opus 免費資格。官方整數 Anlas 計算、統計與授權門檻不變，服務商報價獨立儲存／顯示，不替換官方整數 Anlas。Agent/MCP 仍須確認未知費用，估算為 0 不能自動免費放行。Vibe 預算仍被忽略，不是硬上限；請向服務商確認價格、額度與限額。

- Token 儲存在裝置安全儲存空間，不進入雲端備份。驗證傳送 Token；繪圖傳送 Token、提示詞、參數與所需影像至所填站點，結果僅從訊息內的 PNG data URI 讀取，不下載遠端圖片。僅使用可信服務，分享日誌前移除敏感資訊。
- 獨立預覽版停用自動檢查更新與應用程式內下載安裝。GitHub 與手動更新入口指向 [本分支](https://github.com/cunzaijiang/NAI-Launcher-Custom-API)及 [Releases](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases)，請選擇最新預發佈版本，核對檢查碼後手動安裝。獨立下載清單不是上游受信任簽章更新格式，不作自動更新解析。官方帳號亦遵循此發行版更新邊界。

## English

### Sign-in and protocol

- **Official NovelAI**: official token/credential login and the existing generation protocol remain unchanged.
- **Custom API**: always uses **OpenAI Chat `/v1/chat/completions`**, with no protocol switch. This is not a generic adapter for arbitrary image providers and does not use `/v1/images/generations`.
- Enter one API URL, nickname and API key/token. Root and `/v1/` URLs normalize to `/v1`, preserving reverse-proxy prefixes. Main and image APIs share this URL. Tokens are sent as Bearer tokens; use trusted sites only.
- Login only GETs `/v1/models`; a successful nonempty `data` list must contain at least one exact ID in the table above (V4 Full, V4.5 Full/Curated, V5 Full/Curated). HTML, empty lists, unknown models and HTTP errors fail. No test generation or placeholder `/user/subscription` request is made.

### Drawing requests and responses

Reference-field contract: `controlnet` is an object `{ "strength": 1, "images": [{ "image": "<BASE64_PNG>", "info_extracted": 1, "strength": 1 }] }`, not the image array itself. The extraction key is `info_extracted`. Precise references use the `character_references` array, **not `precise_reference`**. Values here are illustrative; per-reference settings supply actual values.

POST `/v1/chat/completions` uses outer OpenAI Chat fields such as `model` and `messages`. Message content carries a serialized JSON drawing payload (model, prompts, parameters, source/reference images), not ordinary natural-language chat or native drawing fields placed directly at the outer level. The provider must implement this contract.

Responses must contain **exactly one inline Markdown PNG data URI** in Chat message content: `![image](data:image/png;base64,<PNG_BASE64>)`, with valid PNG data. **HTTPS/HTTP remote image URLs are unsupported and are never followed or downloaded.** Final images only: Streaming preview does not provide intermediate images. Failures are not automatically retried, and there is no native generation/streaming or alternate-protocol fallback that could cause duplicate billing.

**Custom drawing does not call native `/v1/ai/generate-image`, `/v1/ai/generate-image-stream`, or `/v1/ai/encode-vibe`.** Chat Vibe sends raw reference images for server-side encoding and caching, rather than relying on client encoding caches. The client currently only reads response `vibe_cache_ids` into the result object and diagnostic counts; it does not persist them or reuse `cache_id` in later requests. Cross-request or cross-session cache reuse is not guaranteed. Its budget field is ignored, not a spending cap. Independent **Encode** is a separate native encoding tool, not part of Chat drawing; its support does not establish drawing support.

V5 Medium is unsupported; V5 Vibe / Precise Reference are unavailable. Other reference and editing capabilities depend on the provider; validated login does not guarantee every feature. Legacy native custom accounts are not silently migrated; re-add through Custom API if an unsupported legacy-protocol message appears.

### Billing, privacy and updates

#### Preview3 dynamic pricing (not a wallet bill)

- **Origin boundary**: Both custom Chat main/image URLs must use the exact origin `https://api.cunzaijiang.cn`, with a root or `/v1` path (optional trailing `/`). Default HTTPS port 443 and host case normalize; other origins, subdomains, nondefault ports, and proxy path prefixes are unsupported. Rules are never borrowed for other sites; public pricing does not establish provider trust or generation capabilities.
- **Public retrieval**: An isolated unauthenticated client GETs `https://api.cunzaijiang.cn/api/pricing`, without an API key, Authorization, Cookie, app authentication interceptors, or redirects. Requests have a 5-second deadline and a 1-MiB response limit. This is separate from Bearer-authenticated `/v1/models` login validation and never generates images.
- **Cache and failures**: Validates `success`, `pricing_version`, the `NovelAI分组` entry in `group_ratio`, and enabled model rules. Version and fetch time persist in device-local SharedPreferences with a 1-hour TTL, excluded from cloud backups. Hourly automatic refresh has been added, including hourly retries after an initial fetch failure. Clicking, touching, or keyboard-activating the badge only forces a pricing refresh. Failures retain the last successful catalog with an offline/stale warning; missing rules show `--`/unknown. A valid new catalog with an unsupported expression makes that model unknown rather than reusing its old expression.
- **Four models, bounded parsing**: Only `nai-diffusion-4-5-full`, `nai-diffusion-4-5-curated`, `nai-diffusion-5-full`, and `nai-diffusion-5-curated`. V4 Full remains allowed for login but has no quote here. Only the fixed two-branch `tiered_expr` shape `p==1 && c>=10000 && floor(c/10000)*10000==c ? tier("anlas", [offset +] c*coefficient) : tier("free" or "base", fixed(base))` is recognized, with finite nonnegative numeric values and at most 4096 expression characters. **No general-purpose execution or `eval`**. Missing models, unknown modes/expressions, and invalid data stay unknown, never a fabricated zero.
- **No currency**: At the user's explicit request, quotes and usage-derived values display unitless raw numbers only, ignoring currency metadata and adding no USD, CNY, currency symbol, or inferred currency. The synchronized rules describe a **NAI4.5 standard baseline of 0 with possible extras, and a NAI5 base of 0.05**. Base, coefficient, offset, and group factor come from synchronized rules and may change with `pricing_version`; they are not hardcoded stable prices. Public rates were retrieved and checked through production rules for all four models on 2026-11-01; see the [actual verification record](custom_api_verification.md). Wallet debits were not verified.
- **Separate extra-Anlas estimate**: At effective billing area `A=width*height ≤1048576` and actual steps `S≤28`, the base component `B=0`, independently of third-party subscription eligibility. Above either limit, the existing single-image, undiscounted `AnlasCalculator.calculateFromValues` formula applies. For modern models: `B=max(ceil(ceil(2.951823174884865e-6*A + 5.753298233447344e-7*A*S*stepCostFactor)*smeaFactor*modelMultiplier*strength),2)`. SMEA factors are 1/1.2/1.4; model and step factors follow current model capabilities. Values above the existing per-image limit of 140 or invalid inputs remain unknown. Actual generation/enhancement dimensions and Focused Inpaint request crops are used; unresolved geometry and upscale workflows have no quote.
- **References and batches**: Only references permitted by the model/action count. Supported Precise References add 5 each; each Vibe beyond four adds 2. Unknown server encoding cache state adds a `0..2` encoding range per enabled Vibe per independent request: `E_low=B+5*R_precise+2*max(R_vibe-4,0)`, `E_high=E_low+2*R_vibe`, after capability exclusions/disabled references. Local encodings and returned `vibe_cache_ids` do not establish server cache hits. Each sample is an independent HTTP request: evaluate E through the pricing rule per request, then sum all `nSamples * imagesPerRequest` requests. Do not combine batch E before charging one base, or charge Vibe encoding only once for a batch.
- **Estimates versus real usage**: Only estimates use canonical `p=1`, with `c=2` for `E=0`, otherwise `c=E*10000`. The conditional branch gives `(offset+c*coefficient)/1000000*groupFactor`; the fallback gives `base*groupFactor`. Response calculations must use actual raw `prompt_tokens` / `completion_tokens` (p/c), with an explicit response model matching the model actually requested; missing fields/model mismatches remain unknown. **Never rewrite `p=100000` to `p=1`**. Even with c divisible by 10000, evaluate the actual fallback and retain the encoding-mismatch warning. A calculated value is not a wallet debit, invoice, or actual Anlas charge; c alone cannot prove a debit.
- Balance, subscription eligibility, and wallet debits remain **unknown**, without fabricated Opus entitlement. Official integer Anlas calculations, statistics, and authorization gates are unchanged; provider prices are stored/displayed separately, not substituted for official integer Anlas. Agent/MCP billing calls still require unknown-cost confirmation, even for a zero estimate. Ignored Vibe budgets are not hard caps; confirm prices, allowances, and limits with the provider.

- Tokens remain in device secure storage, outside cloud backups. Validation sends the token; drawing sends the token, prompts, parameters and required images to your provider, with results read only from inline PNG data URIs, never remote-image downloads. Use trusted services only and remove sensitive data before sharing logs.
- Automatic checks and in-app download/installation are disabled for this independent preview. GitHub and manual update entries point to [this fork](https://github.com/cunzaijiang/NAI-Launcher-Custom-API) and its [Releases](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases). Select the latest prerelease, verify checksums and install manually. Independent download manifests are not upstream trusted signed update metadata and are never parsed as automatic updates. This distribution boundary also applies when using an official account.
