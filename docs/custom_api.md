# 自定义图像 API / 自訂影像 API / Custom image APIs

> **Preview 2 已公开发布 / 已公開發佈 / Publicly released.** [Release / 下载 / 下載](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2) · [CI 与发布验证 / CI 與發佈驗證 / CI and publication verification](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)

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

- 余额、订阅资格、实际费用均为**未知**；固定订阅数字不是实际余额，不伪造 Opus 免费资格。**每次生成都有基础费用，即使本地预估为 0 Anlas。** 本地预估不是服务商报价；请确认服务商价格、额度与限额，尤其不要把被忽略的 Vibe 预算当作硬上限。Agent/MCP 收费操作仍需确认未知费用。
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

- 餘額、訂閱資格及實際費用**未知**；固定數字不是實際餘額，不偽造 Opus 免費資格。**每次生成都有基本費用，即使本機預估為 0 Anlas。** 本機預估不是服務商報價；請確認價格、額度與限額，不要將被忽略的 Vibe 預算當作硬上限。Agent/MCP 收費操作仍須確認未知費用。
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

- Balance, subscription eligibility and actual costs are **unknown**. Fixed numbers are not balances and do not grant fabricated Opus free entitlement. **Every generation has a base fee, even if the local estimate is 0 Anlas.** Local estimates are not provider quotes; verify pricing, allowances and limits, and do not treat ignored Vibe budgets as hard caps. Agent/MCP billing calls still require unknown-cost confirmation.
- Tokens remain in device secure storage, outside cloud backups. Validation sends the token; drawing sends the token, prompts, parameters and required images to your provider, with results read only from inline PNG data URIs, never remote-image downloads. Use trusted services only and remove sensitive data before sharing logs.
- Automatic checks and in-app download/installation are disabled for this independent preview. GitHub and manual update entries point to [this fork](https://github.com/cunzaijiang/NAI-Launcher-Custom-API) and its [Releases](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases). Select the latest prerelease, verify checksums and install manually. Independent download manifests are not upstream trusted signed update metadata and are never parsed as automatic updates. This distribution boundary also applies when using an official account.
