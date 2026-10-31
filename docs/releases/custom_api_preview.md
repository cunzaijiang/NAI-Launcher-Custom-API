# NAI Launcher Custom API 4.3.1 Preview 2

> **Preview 2 已公开发布 / 已公開發佈 / Publicly released.** Release ID: `430016699` · [CI 与发布验证 / CI 與發佈驗證 / CI and publication verification](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/actions/runs/41213027696)
>
> Source SHA: `2d812ac3d8e3307af8e3f2a0beca121f3adf784d`

Tag: `custom-api-v4.3.1-preview.2` · Asset version: `4.3.1-custom-api-preview.2`

[Release / 下载 / 下載](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2)

## 简体中文

这是 `cunzaijiang/NAI-Launcher-Custom-API` 的独立修改版预览，**不是上游官方发行版**。可能存在尚未发现的问题，请先备份。如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈，分享前删除 Token 等敏感信息。

### Preview 2 的变化

- 官方 NovelAI 登录与生成路线保持不变。自定义入口改为 **OpenAI Chat `/v1/chat/completions`**：外层 `model` / `messages`，消息内容携带 JSON 绘图 payload，结果仅接受 Markdown 内联 PNG data URI，不支持 HTTPS/HTTP 远程图片 URL。不是普通聊天，也不是任意 `/v1/images/generations` 服务通用适配器。
- 登录只验证 `/v1/models`，不试画、不查询占位订阅。五模型精确白名单：V4 Full、V4.5 Full/Curated、V5 Full/Curated；不支持 V5 Medium 与 V5 Vibe / Precise Reference。服务商仍决定实际生成与编辑能力。
- 自定义绘图不调用原生 `/v1/ai` 生成、流式生成或编码端点；仅最终图像，没有中间流式预览，不自动重试或协议回退。
- Chat Vibe 发送原始参考图，由服务端编码与缓存，其预算字段被忽略。当前客户端不持久保存或复用返回的 `vibe_cache_ids`，不保证跨请求缓存复用。独立原生 Encode 工具不属于绘图链路，不能用其结果推导 Chat Vibe 能力。
- 余额、订阅资格、实际费用仍为未知；**每次生成都有基础费用，即使本地预估为 0 Anlas**。本地预估不是服务商报价，Vibe 预算不是硬上限；Agent/MCP 需确认未知费用。Token、提示词、参数与所需图像会发送给所填服务商，请仅使用可信站点。
- 应用内 GitHub 入口改为本分支。**独立预览版禁用自动检查更新与应用内下载安装**，“检查更新”仅提供本分支 Releases 手动下载入口；不读取或解析上游签名更新清单，也不将本分支下载清单伪装为受信任更新。请选择最新预发布版本，核对校验值并手动安装。旧 Preview 1 包不变，需手动升级。

参考字段契约：`controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 与 `character_references` 数组；不是 `precise_reference`。

### 下载、签名与来源边界

四个包名与 [三语 README](../../README.md) 一致：

| 平台 | 文件 |
| --- | --- |
| Windows | `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Setup.exe` |
| Windows | `NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.2_Portable.zip` |
| Android | `NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.2.apk` |
| macOS | `NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.2_Portable.zip` |

- 四个二进制包已从同一不可变源码 SHA `2d812ac3d8e3307af8e3f2a0beca121f3adf784d` 构建，不复制上游应用成品。内部基础版本仍为 `4.3.1+46`，独立预览身份由 tag、文件名及清单标识。上述 CI run 全部 jobs 成功，包括完整 19-suite 测试 gate；publish 步骤已下载全部 7 个附件并完成 SHA-256 回验。实际大小、来源 SHA 与 SHA-256 见 Release 附件；不推算测试用例总数。
- Windows x64 Portable / NSIS Setup 无 Authenticode 签名，可能触发 SmartScreen；安装目录可能与上游重叠。macOS 仅 ad-hoc 签名，无 Apple Developer ID 且未公证，Gatekeeper 可能阻止打开。核对来源与哈希，不要全局关闭系统安全保护。
- Android 是 release 模式、runner 临时 debug key 签名，不是上游官方签名。应用 ID 仍为 `com.aaalice.nai_launcher`；不能覆盖不同签名的上游安装，也不保证不同预览构建间直接覆盖。安装、卸载前备份，卸载可能删除本地数据。
- 附带 `checksums.txt`、`release_manifest.json`、`release_notes_custom_api.md`。校验文件覆盖四个二进制包、清单与说明；清单记录真实 SHA-256、大小与源码 SHA。校验值不等于发布者数字签名，清单仅用于独立下载溯源，不是上游受信任签名更新格式。
- GitHub 自动提供同 tag 的 Source code ZIP/TAR.GZ，源码归档不是安装包，也不包含完整 Git LFS 数据库。需要自有注册的云盘 OAuth 等功能不含上游凭据。
- 没有真实服务地址、密钥或付费 API / 真实服务端到端验证，也未完成人工跨平台端到端验收；离线测试通过不保证任意第三方服务可用。具体协议与验证范围见 [custom_api.md](../custom_api.md) 和 [custom_api_verification.md](../custom_api_verification.md)。

## 繁體中文

這是 `cunzaijiang/NAI-Launcher-Custom-API` 的獨立 Preview 2，**不是上游官方發行版**。請先備份；如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報，並移除 Token 等敏感資訊。

- 官方登入與生成不變。自訂繪圖使用 **OpenAI Chat `/v1/chat/completions`**，外層 `model` / `messages`，訊息內容為 JSON 繪圖 payload，僅接受 Markdown 行內 PNG data URI，不支援 HTTPS/HTTP 遠端圖片 URL；不是一般聊天或通用 `/v1/images/generations` 介接。
- 登入只驗證 `/v1/models`，不試畫或查詢佔位訂閱。精確支援 V4 Full、V4.5 Full/Curated、V5 Full/Curated，不支援 V5 Medium 或 V5 Vibe / Precise Reference。實際能力由服務商決定。
- 繪圖不呼叫原生 `/v1/ai` 生成、串流或編碼端點；僅最終影像，沒有中間預覽、自動重試或協定回退。Chat Vibe 傳送原始參考圖，由伺服器編碼與快取，預算欄位被忽略；目前用戶端不持久儲存或重用 `vibe_cache_ids`，不保證跨請求快取重用；獨立原生 Encode 不屬於繪圖鏈路。
- 餘額及實際費用未知，**即使本機預估 0 Anlas，生成仍有基本費用**。本機預估不是報價，Vibe 預算不是硬上限，Agent/MCP 須確認未知費用。Token、提示詞與圖片傳送至所填服務商，請僅使用可信站點。
- GitHub 及手動更新入口改為本分支。自動檢查與應用程式內下載安裝停用，不解析上游簽章清單或將獨立清單當作可信任更新。請從 Releases 最新預發佈版本手動下載、核對檢查碼後安裝；舊 Preview 1 套件不變。

參考欄位為 `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` 與 `character_references` 陣列，不是 `precise_reference`。

四個套件名稱見上表，已由同一不可變來源 SHA `2d812ac3d8e3307af8e3f2a0beca121f3adf784d` 建置；上述 CI run 全部 jobs 成功，包括完整 19-suite 測試 gate，publish 步驟已下載全部 7 個附件並完成 SHA-256 回驗，不推算測試案例總數。內部版本仍為 `4.3.1+46`。Windows 無 Authenticode、macOS 僅 ad-hoc 且未公證、Android release 模式使用 runner 臨時 debug key；應用程式 ID 與安裝位置沿用上游，不能覆蓋不同簽章安裝，不保證預覽間可直接升級。安裝／解除安裝前備份，不要全域停用安全保護。

實際附件、大小與雜湊以 Release 為準。`checksums.txt`、獨立清單與說明記錄來源，不是數位簽章或可信任自動更新中繼資料。來源封存檔不是安裝包且缺少完整 LFS 資料庫；不含上游雲端 OAuth 憑證。未進行真實服務或付費 API / 端對端測試，也未完成人工跨平台端對端驗收。詳見 [使用說明](../custom_api.md) 與 [驗證範圍](../custom_api_verification.md)。

## English

This is independent Preview 2 from `cunzaijiang/NAI-Launcher-Custom-API`, **not an official upstream release**. Back up first. Report issues through Settings → About → Export diagnostic logs, removing tokens and other sensitive data before sharing.

- Official login and generation remain unchanged. Custom drawing now uses **OpenAI Chat `/v1/chat/completions`**, with outer `model` / `messages`, a JSON drawing payload inside message content, and only inline Markdown PNG data URI results; HTTPS/HTTP remote image URLs are unsupported. This is not ordinary chat or a generic `/v1/images/generations` adapter.
- Login only validates `/v1/models`, without test drawing or placeholder subscription queries. The exact allowlist is V4 Full, V4.5 Full/Curated, and V5 Full/Curated; no V5 Medium or V5 Vibe / Precise Reference. Actual capabilities depend on the provider.
- Drawing never calls native `/v1/ai` generation, streaming or encoding endpoints. Final images only; no intermediate previews, automatic retries or protocol fallback. Chat Vibe sends raw reference images for server-side encoding/cache; its budget field is ignored. The client does not persist or reuse returned `vibe_cache_ids`; cross-request cache reuse is not guaranteed. Independent native Encode is not part of drawing.
- Balance and actual costs are unknown. **Every generation has a base fee, even if the local estimate is 0 Anlas.** Local estimates are not provider quotes; Vibe budgets are not hard caps, and Agent/MCP requires unknown-cost confirmation. Tokens, prompts and images go to your configured provider; use trusted sites only.
- In-app GitHub and manual update entries now point to this fork. Automatic checks and in-app download/installation are disabled. Neither upstream signed metadata nor this fork's independent manifest is parsed as a trusted update. Choose the latest prerelease on Releases, verify checksums and install manually. Existing Preview 1 packages remain unchanged.

Reference fields are `controlnet: {strength: 1, images: [{image, info_extracted, strength}]}` and a `character_references` array, not `precise_reference`.

The four filenames are listed above and were built from immutable source SHA `2d812ac3d8e3307af8e3f2a0beca121f3adf784d`, without copying upstream binaries. All jobs in the linked CI run succeeded, including the complete 19-suite test gate; the publish step downloaded all 7 assets and completed SHA-256 verification. No test-case total is inferred. The internal version remains `4.3.1+46`. Windows lacks Authenticode; macOS has ad-hoc signing only, no Developer ID or notarization; Android is release-mode with an ephemeral runner debug key. Application IDs and installation locations are inherited, preventing differently signed replacements and potentially overlapping upstream installations. Upgrades between previews are not guaranteed. Back up before installation/uninstallation, which may erase local data; do not globally disable security protections.

Publication, sizes, source SHA and hashes are established by actual Release attachments, not by these notes. `checksums.txt`, `release_manifest.json` and `release_notes_custom_api.md` document provenance, not publisher signatures or trusted automatic-update metadata. GitHub source archives are not installers and omit full LFS databases. Upstream cloud OAuth credentials are not included. No real-service or paid API / end-to-end tests have been performed, and manual cross-platform end-to-end acceptance has not been completed; offline passing tests cannot establish arbitrary provider compatibility. See the [API guide](../custom_api.md) and [verification scope](../custom_api_verification.md).
