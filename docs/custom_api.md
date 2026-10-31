# 自定义图像 API / 自訂影像 API / Custom image APIs

## 简体中文

### 登录入口

- **NovelAI 官方**：继续使用官方 Token 或账号密码登录，原有流程不变。
- **自定义接口**：第三方入口固定使用下述原生 JSON `/v1` 接口，不再提供协议开关。这不是任意 OpenAI 图片生成服务的通用适配器，也不使用 `/v1/images/generations` 来替代 NAI 原生参数。

填写主 API 的根地址或以 `/v1` 结尾的地址；例如 `https://provider.example` 与 `https://provider.example/v1/` 都规范为 `https://provider.example/v1`。反向代理路径前缀会保留。图像 API 与主 API 固定使用同一地址，不需要单独填写。昵称与 Token 均必填，Token 使用 Bearer 方式发送给所填站点；请确认地址可信。

### 验证与支持边界

登录仅 GET `/v1/models`，要求成功响应中的 `data` 为非空列表，且至少包含下表中一个精确模型 ID。网页、空列表、未知模型以及 HTTP 错误均不通过，也不会转为试画或读取占位 `/user/subscription`。

| 支持的模型 ID | 模型 |
| --- | --- |
| `nai-diffusion-4-full` | V4 Full |
| `nai-diffusion-4-5-full` | V4.5 Full |
| `nai-diffusion-4-5-curated` | V4.5 Curated |
| `nai-diffusion-5-full` | V5 Full |
| `nai-diffusion-5-curated` | V5 Curated |

生成使用原生 JSON `/v1/ai/generate-image`，Vibe 编码使用 `/v1/ai/encode-vibe`，而非官方 multipart/cache 协议。模型、参考图与参数仍受服务商能力约束；登录成功不代表每项生成能力都受支持。V5 medium effort 不属于上述五模型支持范围。

### 费用与隐私

- 固定订阅数值只是服务端占位，客户端将余额与费用视为未知，不伪造 Opus 免费资格。Agent/MCP 收费操作即使旧预估为 0 也要求确认未知费用。余额不可用不等于免费。
- **每次生成都有基础费用，即使客户端预估为 0 Anlas。** 原生请求没有服务端预算上限，请直接向服务商确认计价、余额和限额。
- 非流式请求接收 ZIP；开启“流式预览”时使用 `/v1/ai/generate-image-stream`，也只接收最终图像，没有中间预览。
- Token 仍保存在当前设备的安全存储，不进入云备份。验证向所填主地址发送 Token，生成向所填图像地址发送 Token、提示词、参数和所需图像；仅使用可信服务。
- 协议选择随账号端点保存；旧账号或未知协议值不会自动迁移。需要时通过“自定义接口”重新添加账号。

## 繁體中文

### 登入入口

- **NovelAI 官方**：繼續使用官方 Token 或帳號密碼登入，原有流程不變。
- **自訂介面**：第三方入口固定使用下述原生 JSON `/v1` 介面，不再提供協定開關。這不是任意 OpenAI 影像生成服務的通用介接，也不使用 `/v1/images/generations` 取代 NAI 原生參數。

填寫主 API 的根位址或以 `/v1` 結尾的位址；例如 `https://provider.example` 與 `https://provider.example/v1/` 都會正規化為 `https://provider.example/v1`。反向代理路徑前綴會保留。影像 API 與主 API 固定使用同一位址，不需要單獨填寫。暱稱與 Token 均必填，Token 使用 Bearer 方式傳送給所填站點；請確認位址可信。

### 驗證與支援邊界

登入僅 GET `/v1/models`，要求成功回應中的 `data` 為非空清單，且至少包含上表中一個精確模型 ID（V4 Full、V4.5 Full/Curated、V5 Full/Curated）。網頁、空清單、未知模型以及 HTTP 錯誤均不通過，也不會轉為試畫或讀取佔位 `/user/subscription`。

生成使用原生 JSON `/v1/ai/generate-image`，Vibe 編碼使用 `/v1/ai/encode-vibe`，而非官方 multipart/cache 協定。模型、參考圖與參數仍受服務商能力限制；登入成功不代表每項生成能力均受支援。V5 medium effort 不屬於上述五模型支援範圍。

### 費用與隱私

- 固定訂閱數值只是伺服器佔位，用戶端將餘額與費用視為未知，不偽造 Opus 免費資格。Agent/MCP 收費操作即使舊預估為 0 也要求確認未知費用。餘額不可用不等於免費。
- **每次生成都有基本費用，即使用戶端預估為 0 Anlas。** 原生請求沒有伺服器端預算上限，請直接向服務商確認計價、餘額與限額。
- 非串流請求接收 ZIP；開啟「串流預覽」時使用 `/v1/ai/generate-image-stream`，也只接收最終影像，沒有中間預覽。
- Token 仍儲存在目前裝置的安全儲存空間，不進入雲端備份。驗證向所填主位址傳送 Token，生成向所填影像位址傳送 Token、提示詞、參數與所需影像；僅使用可信服務。
- 協定選擇隨帳號端點儲存；舊帳號或未知協定值不會自動遷移。需要時透過「自訂介面」重新新增帳號。

## English

### Sign-in entry

- **Official NovelAI**: keep using official token or credential login; the existing flow is unchanged.
- **Custom API**: the third-party entry always uses the native JSON `/v1` API described here, without a protocol switch. This is not a generic adapter for arbitrary OpenAI image providers and does not substitute `/v1/images/generations` for native NAI parameters.

Enter the main API root or a URL ending in `/v1`. Both `https://provider.example` and `https://provider.example/v1/` normalize to `https://provider.example/v1`, preserving reverse-proxy path prefixes. The main and image API always use the same URL; no separate image URL is requested. Nickname and token are required. The token is sent to the entered site as a Bearer token, so verify that the URL is trustworthy.

### Validation and supported scope

Login only performs GET `/v1/models`. A successful response must contain a nonempty `data` list with at least one exact model ID from the table above: V4 Full, V4.5 Full/Curated, or V5 Full/Curated. HTML, empty lists, unknown models, and HTTP errors fail validation. There is no test generation or fallback to placeholder `/user/subscription` data.

Generation uses native JSON `/v1/ai/generate-image`, and Vibe encoding uses `/v1/ai/encode-vibe`, not the official multipart/cache protocol. Models, references, and parameters remain subject to provider capabilities; successful login does not guarantee every generation feature. V5 medium effort is outside the five-model supported set.

### Billing and privacy

- Fixed subscription values are server placeholders, not your actual balance. Balance and costs are unknown, with no fabricated Opus free entitlement. Agent/MCP billing calls require unknown-cost confirmation even for a stale zero estimate. An unavailable balance does not mean free service.
- **Every generation has a base fee, even when the client estimates 0 Anlas.** Native requests have no server-side budget limit. Confirm pricing, balance, and limits directly with your provider.
- Non-streaming requests receive ZIP responses. Enabling Streaming preview uses `/v1/ai/generate-image-stream`, which also returns final images only, without intermediate previews.
- Tokens remain in device secure storage and are excluded from cloud backups. Validation sends your token to the main URL; generation sends the token, prompts, parameters, and required images to the image URL. Use trusted services only.
- The protocol choice is persisted with the account endpoint. Legacy accounts and unknown protocol values are not migrated automatically. Re-add an account through Custom API when needed.
