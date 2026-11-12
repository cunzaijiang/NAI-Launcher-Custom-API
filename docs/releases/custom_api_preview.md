# NAI Launcher Custom API 4.3.1 Preview6

Tag: `custom-api-v4.3.1-preview.6` · App version: `4.3.1+47`

准备发布 / 準備發佈 / Preparing release. 构建与验证结果以本版本 GitHub Actions 和 Release 附件为准，不继承 Preview5 测试结果。 / 建置與驗證結果以本版本 GitHub Actions 與 Release 附件為準，不繼承 Preview5 測試結果。 / Build and validation results come from this version's GitHub Actions and release assets, not earlier preview results.

## 简体中文

- 修复自定义 Chat 绘图收到大体积图片响应时可能出现的 Stack Overflow：改用逐字符扫描提取图片，避免正则匹配整段 Base64。
- 保留单张内嵌 PNG、Base64 与完整 PNG 校验，以及种子和元数据处理；Android、Windows 和 macOS 使用同一修复。
- 增加离线大图与异常响应回归；不额外发起付费生图。真实设备上所报三个尺寸的验收需与离线测试区分。

当前预览版从本仓库 Releases 手动下载安装；既有客户端不会自动下载安装更新。Windows 未做 Authenticode；macOS 仅 ad-hoc 签名且未公证；Android 沿用预览流程的临时 debug 签名，不保证覆盖旧版本。请先备份本地数据，勿为更新直接卸载。完整性校验不等于发布者签名。如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈。

## 繁體中文

- 修復自訂 Chat 繪圖收到大型圖片回應時可能出現的 Stack Overflow：改用逐字元掃描提取圖片，避免正則匹配整段 Base64。
- 保留單張內嵌 PNG、Base64 與完整 PNG 校驗，以及種子和中繼資料處理；Android、Windows 和 macOS 使用同一修復。
- 增加離線大圖與異常回應回歸；不額外發起付費生圖。真實裝置上所報三個尺寸的驗收須與離線測試區分。

目前預覽版從本倉庫 Releases 手動下載安裝；既有客戶端不會自動下載安裝更新。Windows 未做 Authenticode；macOS 僅 ad-hoc 簽章且未公證；Android 沿用預覽流程的臨時 debug 簽章，不保證覆蓋舊版本。請先備份本機資料，勿為更新直接解除安裝。完整性校驗不等於發佈者簽章。如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報。

## English

- Fix a possible Stack Overflow while decoding large custom Chat drawing responses by scanning inline image content instead of matching the entire Base64 payload with a regular expression.
- Retain exactly-one-inline-PNG, Base64 and complete PNG validation, seed handling and metadata processing. Android, Windows and macOS share the fix.
- Add offline large-image and invalid-response regressions without paid generation requests. Offline tests do not replace acceptance of the three reported sizes on real devices.

Download and install manually from this fork's Releases; existing clients do not automatically download or install this update. Windows packages have no Authenticode signature; macOS uses ad-hoc signing without notarization; Android retains the preview workflow's ephemeral debug signing and may not replace earlier builds. Back up local data first; do not uninstall just to update. Integrity checks are not publisher signatures. Report issues through Settings → About → Export diagnostic logs.
