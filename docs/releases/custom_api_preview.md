# NAI Launcher Custom API 4.3.1 Preview5

Planned tag: `custom-api-v4.3.1-preview.5` · Filename version: `4.3.1-custom-api-preview.5`

**待发布 / 待發佈 / Unreleased.** 当前实际下载仍为 / 目前實際下載仍為 / Current download remains [Preview4](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.4)。[分版本验证 / 分版本驗證 / Version-separated verification](../custom_api_verification.md)。

独立修改版预览，不是上游官方发行版或 NovelAI 官方产品。 / 獨立修改預覽，不是上游官方發行版或 NovelAI 官方產品。 / An independent modified preview, not an official upstream release or NovelAI product. 新 tag 与文件版本不覆盖旧包、校验值或发行记录 / 新 tag 與檔案版本不覆蓋舊套件、檢查碼或發行記錄 / The new tag and filename version do not overwrite prior packages, checksums or releases.

## 简体中文

- desktop/mobile 恢复 Preview3 主生成按钮核心布局，完整桌面 shell 验证点击；金额为纯文字，价格 spinner 仅在刷新时显示。
- `isSaving` 显式反馈保存状态，区分生成完成与保存中；准备阶段错误可见。
- Chat 响应后台解析，保留 PNG 校验与现有协议限制；新增阶段日志便于后续设备定位。

**验证**：最终定向 42 文件、740 tests 全通过（`00:30`，exit `0`）；完整 shell 4/4，mobile 单文件 17 passed（含 fake callback）。此前全仓 10634 passed / 3 skipped / 5 failed，后续 4 项修复或复测通过；installer `hiddenPowerShell` marker 仍失败，其生产／测试 baseline 未改、child probe 单独成功，环境原因未知。不能宣称全仓 green。

**真实 API 探测不是应用 E2E**：8 请求、7 次 HTTP 200／有效 PNG、1 失败，均 `stream=false`、无重试。V4.5 Curated single 在 152.177 秒 `RemoteDisconnected`，扣费未知。成功请求 headers 约 3–11 秒、body 完成约 20–86 秒（均从请求开始计）；离线 Dart 样本解析 84 ms、metadata 30 ms。不将整段等待归因为本地，不承诺一分钟延迟全修或 Windows 根因已确认。

**实际 UI blocked**：Android 无 SDK／emulator／device；Windows debug 构建因固定 NVIDIA DLSS 头下载 TLS 错误 `35` 阻塞。未完成真实 UI／安装验收；Preview5 CI、发布及附件回验待完成。

安装前备份、核对来源与 SHA-256。Windows 无 Authenticode；macOS 仅 ad-hoc、无 Developer ID／公证；Android 使用非上游临时 debug key，不保证覆盖安装，卸载可能删除数据。完整性校验不是发布者签名，不要全局关闭系统安全保护；从本分支 Releases 手动更新。如遇异常，请通过“设置 → 关于 → 导出诊断日志”反馈，分享前删除 Token 等敏感信息。

## 繁體中文

- desktop/mobile 恢復 Preview3 主要生成按鈕核心版面，以完整桌面 shell 驗證點擊；金額為純文字，價格 spinner 僅在重新整理時顯示。
- `isSaving` 明確回饋儲存狀態，區分生成完成與儲存中；準備階段錯誤可見。
- Chat 回應背景解析，保留 PNG 校驗與既有協定限制；新階段日誌方便後續裝置定位。

**驗證**：最終定向 42 檔案、740 tests 全通過（`00:30`，exit `0`）；完整 shell 4/4，mobile 單檔 17 passed（含 fake callback）。先前全倉 10634 passed / 3 skipped / 5 failed，後續 4 項修復或複測通過；installer `hiddenPowerShell` marker 仍失敗，其生產／測試 baseline 未改、child probe 單獨成功，環境原因未知。不能宣稱全倉 green。

**真實 API 探測不是應用程式 E2E**：8 請求、7 次 HTTP 200／有效 PNG、1 失敗，皆 `stream=false`、無重試。V4.5 Curated single 在 152.177 秒 `RemoteDisconnected`，扣費未知。成功請求 headers 約 3–11 秒、body 完成約 20–86 秒（皆從請求開始計）；離線 Dart 樣本解析 84 ms、metadata 30 ms。不將全部等待歸因本機，不承諾一分鐘延遲全修或 Windows 根因已確認。

**實際 UI blocked**：Android 無 SDK／emulator／device；Windows debug 建置因固定 NVIDIA DLSS 標頭下載 TLS 錯誤 `35` 阻塞。未完成真實 UI／安裝驗收；Preview5 CI、發佈及附件回驗待完成。

安裝前備份、核對來源與 SHA-256。Windows 無 Authenticode；macOS 僅 ad-hoc、無 Developer ID／公證；Android 使用非上游臨時 debug key，不保證覆蓋安裝，解除安裝可能刪除資料。完整性校驗不是發布者簽章，不要全域停用系統安全保護；從本分支 Releases 手動更新。如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」回報，分享前移除 Token 等敏感資訊。

## English

- Restore the Preview3 main Generate button core layout on desktop/mobile and verify clicks in the complete desktop shell. Amounts are plain text; the pricing spinner is refresh-only.
- Explicit saving feedback through `isSaving` distinguishes generation completion from saving; preparation errors are visible.
- Parse Chat responses in the background, retaining PNG validation and existing protocol limits. New phase logs support later device diagnosis.

**Verification**: all 740 tests in 42 targeted files passed (`00:30`, exit `0`); complete shell 4/4, mobile file 17 passed (including a fake callback). The earlier full suite recorded 10634 passed / 3 skipped / 5 failed. Four items were subsequently fixed or retested successfully; the installer `hiddenPowerShell` marker still fails. Its production/test baseline is unchanged, an isolated child probe succeeds, and the environmental cause is unknown. The full suite is not claimed green.

**Real API probes are not app E2E**: 8 requests, 7 HTTP 200/valid PNG successes, 1 failure; all `stream=false`, no retries. V4.5 Curated single raised `RemoteDisconnected` after 152.177 seconds; billing is unknown. Successful requests reached headers in about 3–11 seconds and body completion in about 20–86 seconds, both measured from request start. One offline Dart sample took 84 ms to parse and 30 ms for metadata. The whole wait is not attributed to local work; neither elimination of all minute-long delays nor a confirmed Windows root cause is claimed.

**Actual UI blocked**: Android has no SDK/emulator/device; the Windows debug build hit TLS error `35` downloading pinned NVIDIA DLSS headers. Real UI/installation acceptance is incomplete; Preview5 CI, publication and asset verification remain pending.

Back up and verify provenance/SHA-256 before installation. Windows has no Authenticode; macOS is ad-hoc only without Developer ID/notarization; Android uses an ephemeral non-upstream debug key. Replacement installation is not guaranteed, and uninstalling can erase data. Integrity checks are not publisher signatures; never globally disable system security. Update manually from this fork's Releases. Report issues through Settings → About → Export diagnostic logs, removing tokens and other sensitive information before sharing.

[协议与费用边界 / 協定與費用邊界 / Protocol and billing limits](../custom_api.md) · [Preview4 已发布说明 / 已發佈說明 / Published notes](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.4)
