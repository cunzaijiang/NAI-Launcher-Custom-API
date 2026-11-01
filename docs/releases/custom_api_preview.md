# NAI Launcher Custom API 4.3.1 Preview4

Tag: `custom-api-v4.3.1-preview.4` · Filename version: `4.3.1-custom-api-preview.4`

发布状态与验证证据见 [分版本验证记录](../custom_api_verification.md)；以下说明不代表安装包已发布或验证已通过。 / 發佈狀態與驗證證據見 [分版本驗證記錄](../custom_api_verification.md)；以下說明不代表套件已發佈或驗證已通過。 / See the [version-separated verification record](../custom_api_verification.md) for publication status and evidence; these notes alone do not establish package availability or passing validation.

这是独立修改版预览，不是上游官方发行版或 NovelAI 官方产品。 / 這是獨立修改預覽，不是上游官方發行版或 NovelAI 官方產品。 / An independent modified preview, not an official upstream release or NovelAI product.

## 下载与旧版 / 下載與舊版 / Downloads and prior release

附件以实际发布资产为准，不以源码归档代替安装包。Preview4 使用独立 tag 和文件版本，不覆盖 Preview3 包、校验值或既有发行记录。 / 附件以實際發佈資產為準，來源封存檔不是安裝包。Preview4 使用獨立 tag 與檔案版本，不覆蓋 Preview3 套件、檢查碼或既有發行記錄。 / Actual published assets are authoritative; source archives are not installers. Preview4 uses a separate tag and filename version without overwriting Preview3 packages, checksums, or existing release records.

[Preview3 已发布版本 / 已發佈版本 / Published prior release](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3)

## 简体中文

### Preview4 修复范围

- 修复自定义 Chat 多角色定位：移除“AI 选择”位置选项，改用可点击的 **5×5 位置网格**。
- 自定义 Chat 绘图请求强制使用 `use_coords: true`，包括仍保存旧 AI 选择／自动定位设置的配置，避免角色位置被旧设置关闭。
- 将自定义接口的预计费用移入生成按钮，移除独立价格框；自定义费用数值逻辑与官方 Anlas 行为不变。
- **NovelAI official 模式保留原有 AI／手动定位行为**，不把自定义 Chat 的强制坐标规则套到官方路线。Preview3 动态定价、费用边界、登录与生成协议不在本次扩展范围内。

### 验证与安装边界

2026-11-01 最终本地验证：38 文件 677 tests 通过（`00:35`，exit `0`），包含新增 2 个 metadata 一致性用例；24 个 Dart 文件 scoped analyze：`No issues found!`，后续 3 个改动文件单独分析亦无问题；源码审阅 31 个路径。

Preview4 的本地回归、静态分析、CI 构建及三平台附件回验，仅以本版实际记录为证；不把 Preview3 的成功测试数、CI、源码 SHA 或包校验值当作本版证据。定位操作、旧配置与 official 模式均需单独回归；未做真实安装、UI 或付费生成，Windows／Android 热重载会话未启动；静态检查不能替代这些验收。

发布后以实际附件、`checksums.txt`、`release_manifest.json` 与源码身份为准。不要仅从发行说明推断包已存在、签名已验证或可以覆盖安装。独立预览的 Windows 包未做 Authenticode 签名，macOS 仅 ad-hoc、无 Developer ID／公证，Android 使用非上游临时 debug key；完整性校验不是发布者签名。应用 ID／安装位置可能与上游重叠，不同签名不能直接覆盖，卸载可能删除本地数据。先备份、核对来源和 SHA-256，不要全局关闭系统安全保护。更新仍从本分支 Releases 手动下载安装，自动检查与应用内下载安装禁用。

如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈，分享前删除 Token 等敏感信息。

## 繁體中文

### Preview4 修復範圍

- 修復自訂 Chat 多角色定位：移除「AI 選擇」位置選項，改用可點擊的 **5×5 位置網格**。
- 自訂 Chat 繪圖請求強制使用 `use_coords: true`，包括仍儲存舊 AI 選擇／自動定位設定的組態，避免角色位置被舊設定關閉。
- 將自訂介面的預估費用移入生成按鈕，移除獨立價格框；自訂費用數值邏輯與官方 Anlas 行為不變。
- **NovelAI official 模式保留原有 AI／手動定位行為**，不把自訂 Chat 強制座標規則套到官方路線。Preview3 動態定價、費用邊界、登入與生成協定不在本次擴充範圍內。

### 驗證與安裝邊界

2026-11-01 最終本機驗證：38 檔案 677 tests 通過（`00:35`，exit `0`），含新增 2 個 metadata 一致性案例；24 個 Dart 檔案 scoped analyze：`No issues found!`，後續 3 個改動檔案個別分析亦無問題；原始碼審閱 31 個路徑。

Preview4 的本機回歸、靜態分析、CI 建置及三平台附件回驗，僅以本版實際記錄為證；不把 Preview3 成功測試數、CI、來源 SHA 或套件檢查碼當作本版證據。定位操作、舊設定與 official 模式皆須個別回歸；未做真實安裝、UI 或付費生成，Windows／Android 熱重載工作階段未啟動；靜態檢查不能替代這些驗收。

發佈後以實際附件、`checksums.txt`、`release_manifest.json` 與來源識別為準。不要僅從發行說明推斷套件已存在、簽章已驗證或可覆蓋安裝。獨立預覽的 Windows 套件無 Authenticode 簽章，macOS 僅 ad-hoc、無 Developer ID／公證，Android 使用非上游臨時 debug key；完整性校驗不是發布者簽章。ID／安裝位置可能與上游重疊，不同簽章不能直接覆蓋，解除安裝可能刪除本機資料。先備份、核對來源與 SHA-256，不要全域停用系統安全保護。更新仍從本分支 Releases 手動下載安裝，自動檢查與應用程式內下載安裝停用。

如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報，分享前移除 Token 等敏感資訊。

## English

### Preview4 fix scope

- Fix custom Chat multi-character positioning: remove the AI position-selection option and use a clickable **5×5 positioning grid**.
- Custom Chat drawing requests enforce `use_coords: true`, including configurations saved with the old AI/automatic positioning setting, so old settings cannot disable character coordinates.
- Move the Custom API cost estimate into the Generate button and remove the separate price box; custom cost calculations and official Anlas behavior remain unchanged.
- **NovelAI official mode retains its existing AI/manual positioning behavior**; custom Chat's forced-coordinate rule does not apply to the official route. This update does not expand Preview3 dynamic pricing, billing boundaries, login, or generation protocols.

### Verification and installation limits

Final local validation on 2026-11-01: 677 tests in 38 files passed (`00:35`, exit `0`), including 2 added metadata-consistency cases; scoped analysis of 24 Dart files reported `No issues found!`, and the 3 subsequently changed files also passed separate analysis; 31 source paths were reviewed.

Only actual Preview4 records establish local regressions, static analysis, CI builds, and three-platform asset verification. Preview3 passing test counts, CI, source SHA, and package checksums are not evidence for this version. Position selection, old configurations, and official mode each need regression coverage; real installation, UI, and paid-generation testing were not performed, and Windows/Android hot-reload sessions were not started. Static checks cannot replace that acceptance testing.

After publication, actual assets, `checksums.txt`, `release_manifest.json`, and source identity are authoritative. Release notes alone do not establish that packages exist, signatures were verified, or replacement installation works. Independent preview Windows packages have no Authenticode signature; macOS is ad-hoc only without Developer ID/notarization; Android uses an ephemeral non-upstream debug key. Integrity checks are not publisher signatures. Application IDs/install locations may overlap upstream, differing signatures prevent direct replacement, and uninstalling can erase local data. Back up, verify provenance and SHA-256, and never globally disable system security. Updates remain manual downloads/installations from this fork's Releases; automatic checks and in-app installation are disabled.

Report issues through Settings → About → Export diagnostic logs, removing tokens and other sensitive information before sharing.

[协议与费用边界 / 協定與費用邊界 / Protocol and billing limits](../custom_api.md) · [分版本验证记录 / 分版本驗證記錄 / Version-separated verification](../custom_api_verification.md)

[Preview3 已发布发行说明 / 已發佈發行說明 / Published release notes](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3) · [Preview3 固定版本协议 / 固定版本協定 / Tagged protocol guide](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/blob/custom-api-v4.3.1-preview.3/docs/custom_api.md)
