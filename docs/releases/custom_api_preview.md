# NAI Launcher Custom API 4.3.1 Preview 1

## 简体中文

这是 `cunzaijiang/NAI-Launcher-Custom-API` 的独立修改版预览发布，来自 `custom-api` 分支，**不是上游官方发行版**。预览版可能存在尚未发现的问题；请先备份数据。如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈，并在反馈中删除 Token 等敏感信息。

### 自定义接口

- 官方 NovelAI 登录入口保留；自定义接口使用原生 JSON `/v1` 协议，不是任意 OpenAI 图片 API 的通用适配器。
- 登录仅验证 `/v1/models`，不触发试画。支持精确模型 ID：`nai-diffusion-4-full`、`nai-diffusion-4-5-full`、`nai-diffusion-4-5-curated`、`nai-diffusion-5-full`、`nai-diffusion-5-curated`。
- 生成使用 `/v1/ai/generate-image`，Vibe 编码使用 `/v1/ai/encode-vibe`；服务商决定实际能力。流式端点仅返回最终图像，不提供中间预览。
- 第三方余额、订阅资格与费用视为未知；**每次生成都有基础费用，即使客户端显示 0 Anlas**。请向服务商确认计价与限额。Token、提示词与参考图会发送至您配置的服务商，请仅使用可信地址。

### 下载、签名与更新边界

- **Android APK**：重新构建的 release 模式 APK，使用本次托管 runner 临时生成的 Android debug key 签名，可安装但不是上游官方签名。应用 ID 仍为 `com.aaalice.nai_launcher`；不能覆盖不同签名的上游安装，也不保证不同预览构建之间直接覆盖安装。卸载前请备份，卸载可能删除本地数据。
- **macOS Portable.zip**：重新构建的应用包，无 Apple Developer ID 签名且未公证；仅有 Apple silicon 运行所需的 ad-hoc 签名。Gatekeeper 可能阻止打开。只在确认来源与 SHA-256 后通过系统允许的方式打开，不要全局关闭系统安全保护。
- **Windows Portable.zip / Setup.exe**：重新构建的 x64 应用与随包 MCP CLI，沿用仓库 NSIS 安装器配方，不使用上游证书；未做 Authenticode 签名，可能出现 SmartScreen 提示。便携版解压使用，安装版可能与已有上游应用使用相同安装目录，安装前请备份并关闭运行中的应用。
- 四个二进制包由同一不可变源码 SHA 构建，不复制上游应用成品。应用内部基础版本仍为 `4.3.1+46`；独立预览身份由文件名、发布 tag 与清单标识。
- 附带 `checksums.txt`、`release_manifest.json`、`release_notes_custom_api.md`。校验文件覆盖四个二进制包、清单与说明，清单记录真实 SHA-256、大小及源码 SHA。校验值不等于发布者数字签名。
- 清单仅用于此独立预览的下载溯源，**不是上游受信任自动更新清单**。请手动安装并核对来源；本次发布不修改应用现有更新逻辑，不承诺应用内更新能获取或保留此修改版。云盘 OAuth 等需要项目自身注册的功能不随包提供上游凭据。
- GitHub 自动提供 Source code ZIP/TAR.GZ，指向同一发布 tag；源码归档不是可直接运行的安装包，也不包含由 Git LFS 管理的完整数据库内容。

## 繁體中文

這是 `cunzaijiang/NAI-Launcher-Custom-API` 的獨立修改版預覽，**不是上游官方發行版**。請先備份資料；如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報，並移除 Token 等敏感資訊。

自訂介面採用原生 JSON `/v1` 協定，登入僅驗證 `/v1/models`，不試畫；支援 V4 Full、V4.5 Full/Curated、V5 Full/Curated。生成及 Vibe 能力由服務商決定，串流僅提供最終影像。第三方餘額與費用未知；**每次生成都有基本費用，即使用戶端顯示 0 Anlas**。Token、提示詞及參考圖會傳送至所填服務商，請僅使用可信位址。

四個二進位套件由同一不可變 SHA 重建：Android release 模式 APK 使用本次 runner 臨時 debug key，不能覆蓋不同簽章的上游安裝，也不保證不同預覽可直接覆蓋；macOS 僅 ad-hoc 簽章，無 Developer ID 且未公證；Windows x64 Portable 與 NSIS Setup 均未做 Authenticode 簽章。應用程式 ID、基礎版本及安裝位置沿用原專案，安裝／解除安裝前請備份。系統可能提示安全警告，請核對來源與雜湊，不要全域停用安全保護。

附帶真實檔案大小、SHA-256、來源 SHA 的獨立清單、檢查碼與說明；GitHub 自動提供來源 ZIP/TAR.GZ（不含完整 LFS 資料庫）。清單不是上游可信任自動更新中繼資料；本次不修改應用程式原有更新邏輯，請手動安裝，不保證應用程式內更新保留修改版。雲端硬碟 OAuth 等功能不含上游憑證。詳情見上方簡體中文與 `docs/custom_api.md`。

## English

This is an independently modified preview from `cunzaijiang/NAI-Launcher-Custom-API`, branch `custom-api`, **not an official upstream release**. Back up your data first. Report problems using Settings → About → Export diagnostic logs, removing tokens and other sensitive data before sharing.

The custom entry uses native JSON `/v1`, not a generic OpenAI image API adapter. Login validates `/v1/models` without generating an image. Supported exact models are V4 Full, V4.5 Full/Curated, and V5 Full/Curated as listed above. Generation and Vibe capabilities depend on your provider; streaming returns final images only. Third-party balances and costs are unknown. **Every generation has a base fee, even if the client shows 0 Anlas.** Tokens, prompts, and reference images go to your configured provider; use trusted endpoints only.

All four binary packages are rebuilt from one immutable source SHA; no upstream application binaries are republished. Android is a release-mode APK signed with an ephemeral runner debug key, not the upstream key. Its unchanged application ID prevents replacing a differently signed installation; upgrades between preview builds are not guaranteed. Back up before uninstalling, which can erase local data. macOS has only an ad-hoc signature, no Developer ID and no notarization. Windows x64 Portable and the existing NSIS Setup recipe have no Authenticode signature; installation locations can overlap upstream installations. Operating systems may warn or block launch. Check provenance and hashes; do not globally disable security protections.

The internal base version remains `4.3.1+46`; filenames, tag, and manifest identify this preview. `checksums.txt` covers the four packages, `release_manifest.json`, and `release_notes_custom_api.md`. The independent manifest records actual hashes, sizes, and source SHA; checksums are not publisher signatures. It is **not trusted upstream automatic-update metadata**. Install manually: this release does not change the app's existing updater and does not promise in-app updates will retain the modifications. Upstream credentials are not included for features such as cloud-drive OAuth. GitHub's automatic source ZIP/TAR.GZ archives reference the same tag but are not installable packages and omit full Git LFS database content. See `docs/custom_api.md` for API details.
