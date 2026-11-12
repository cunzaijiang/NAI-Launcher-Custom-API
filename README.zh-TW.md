# NAI Launcher Custom API

> **Preview6 大圖修復正在建置。** 修復自訂 Chat 繪圖的大型圖片解析；發佈成功前，下方 Preview5 仍是可下載版本。[Preview6 更新說明](docs/releases/custom_api_preview.md)。

> **Preview5 已公開發佈，七附件已下載回驗。** CI run 41297577735 六個 job 全部成功；tag／manifest／source SHA、六項校驗、四包雜湊、ZIP CRC、APK／EXE 檢查通過。本機最終定向 42 檔案 740 tests 通過（`00:30`，exit `0`），不代表全倉 green。[驗證記錄](docs/custom_api_verification.md)。

> **Preview5 目前下載（預發佈版）**：desktop/mobile 恢復 Preview3 主按鈕核心版面，金額純文字、價格 spinner 僅重新整理；`isSaving` 明確儲存回饋、準備錯誤可見，Chat 背景解析保留 PNG 校驗。完整 shell 與 mobile widget 回歸不等於使用者機器驗收；Android／Windows 實際 UI 皆 blocked，不承諾全部延遲或 Windows 根因已解決。[發行說明](docs/releases/custom_api_preview.md)。

<p align="center">
  <a href="README.md">简体中文</a> · 繁體中文 · <a href="README.en-US.md">English</a>
</p>

<p align="center">
  <img src="assets/icons/Icon.png" alt="NAI Launcher 圖示" width="112">
</p>

<p align="center">
  <strong>以自訂影像 API 為優先的獨立預覽分支，保留可選的 NovelAI 官方入口。</strong>
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5"><img src="https://img.shields.io/badge/Custom_API-custom--api--preview-blue" alt="Custom API preview"></a>
  <img src="https://img.shields.io/badge/Windows%20%7C%20macOS%20%7C%20Android-available-6f7785" alt="支援平台">
  <img src="https://img.shields.io/badge/license-MIT-5b8c5a" alt="MIT License">
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5">下載 Preview5（含動態定價）</a> ·
  <a href="docs/releases/custom_api_preview.md">本分支更新說明</a> ·
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues">回報本分支問題</a>
</p>

**NAI Launcher Custom API** 是由 **cunzaijiang** 獨立維護、基於 NAI Launcher 上游的 Custom API 二次開發分支，**不是上游官方發行版，也不是 NovelAI 官方產品**。原作者與 MIT 歸屬見文末致謝。使用自訂影像服務不需要 NovelAI 帳號；官方登入保留為可選路線。請遵守所用服務的條款、內容規則與當地法律。

本分支以登入頁的「自訂介面」為主要入口：只需 **一個 API URL、暱稱和 API Key / Token**，支援站點根位址或 `/v1` 位址。Windows、macOS 與 Android 保留上游的本機工具和創作介面，不登入也能先使用本機工具。

## Preview5 下載（含動態定價）

**4.3.1 Custom API Preview5 已公開發佈，包含動態定價。** [發佈頁與檢查碼](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5) · [閱讀本分支更新說明](docs/releases/custom_api_preview.md)。請使用以下四個實際安裝包，不要下載原始碼封存檔來安裝：

| 平台 | 直接下載安裝包 |
| --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Setup.exe) |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Portable.zip) |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.5.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.5.apk) |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.5_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.5_Portable.zip) |

[歷史版本：Preview4](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.4) · [歷史版本：Preview3（無本次定位與費用版面修復）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3)。 [QQ](https://qm.qq.com/q/jY8Pshi5os)

> **預覽版與安裝風險**：請先備份。Windows 安裝版與可攜版均未做 Authenticode 簽章；macOS 僅 ad-hoc 簽章，無 Apple Developer ID 且未公證；Android 為 release 模式、臨時 debug key 簽章，應用程式 ID 沿用上游，不能覆蓋不同簽章的上游安裝，也不保證不同預覽建置間直接覆蓋安裝。Windows 安裝目錄可能與上游重疊；解除安裝可能刪除本機資料。請核對來源與 SHA-256，不要全域停用系統安全保護。本預覽未完成應用程式端對端驗收，不保證任意第三方站點可用。

> **Preview5 更新邊界**：應用程式內 GitHub 入口指向本分支；自動檢查更新與應用程式內下載安裝已停用，「檢查更新」只提供本分支 [Releases 頁面](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases)的手動下載入口。獨立預覽清單不相容上游簽章更新格式，不會當作可信任自動更新解析。舊 Preview 1 套件不會因此改變，請從本頁手動升級。

## 自訂 API 支援邊界

- 使用 **OpenAI Chat `/v1/chat/completions`**：外層 `model` 與 `messages`，訊息內容是 JSON 繪圖參數，回應僅接受 Markdown 行內 PNG data URI，不支援 HTTPS/HTTP 遠端圖片 URL；不是 `/v1/images/generations` 通用影像 API。主 API 與影像 API 共用一個 URL，沒有協定切換。
- 登入僅讀取 `/v1/models` 驗證，不觸發試畫。僅接受五個精確模型 ID：`nai-diffusion-4-full`、`nai-diffusion-4-5-full`、`nai-diffusion-4-5-curated`、`nai-diffusion-5-full`、`nai-diffusion-5-curated`。
- **不支援 V5 Medium（節約檔）；V5 的 Vibe／Precise Reference 參考功能不可用。** 其他模型的參考圖、生成與編輯能力仍取決於服務商；登入成功不等於所有功能可用。僅回傳最終影像，沒有中間串流預覽，失敗不自動重試。
- **Chat Vibe 將原始參考圖交給伺服器編碼與快取；其預算欄位會被忽略。** 目前用戶端不持久儲存或重用回傳的 `vibe_cache_ids`，不保證跨請求快取重用。 自訂繪圖不呼叫原生 `/v1/ai` 生成或編碼端點；獨立 Encode 操作不屬於繪圖鏈路，不能據此推斷 Chat Vibe 能力。
- **動態定價僅適用於精確 origin `https://api.cunzaijiang.cn`**（根位址或 `/v1` 入口，不接受其他站點、子網域或代理路徑前綴）。獨立用戶端公開 GET `https://api.cunzaijiang.cn/api/pricing`，不傳送 API Key、Authorization 或 Cookie，不跟隨重新導向；定價讀取不是登入或試畫。僅解析 V4.5 Full/Curated、V5 Full/Curated 四個模型的受限白名單運算式，不使用 `eval`；未知運算式、模型或站點顯示未知，不猜價格，也不把此來源的規則套到其他站點。
- 儲存 `pricing_version` 與擷取時間，裝置本機持久快取 TTL 為 1 小時，不進入雲端備份；已補每小時自動重新整理，首次擷取失敗後每小時重試。預估費用顯示在生成按鈕內；價格重新整理不觸發生成；失敗保留最近成功規則並提示離線／過期，無法估價時顯示 `--`。依使用者明確要求，報價與 usage 計算值只顯示**無單位原始數字**，不顯示 USD、CNY 或貨幣符號，不推斷幣別。
- 同步規則所描述的 **NAI4.5 標準基本值為 0，仍可能有附加費用；NAI5 基本值為 0.05**，這些數值隨同步費率變化，不是硬編碼的穩定承諾。服務商專屬 extra-Anlas 估算在有效面積 `≤1048576` 且實際步數 `≤28` 時基本部分為 0，超出則使用現有面積／步數公式；可用的 Precise Reference 每張加 5，Vibe 編碼每張每次請求估計 0–2（伺服器快取未知，超過四張的附加費另計），批次按所有獨立請求加總。詳見[定價公式與邊界](docs/custom_api.md)。
- 回應費用顯示使用實際回傳的原始 `p` / `c` 代入同步運算式，**不是實際錢包帳單**；保留 `p=100000` 與運算式要求 `p=1` 不一致的警告，不改寫 usage 來迎合預估。餘額、訂閱資格與錢包實扣仍未知；官方整數 Anlas 與授權門檻不變，Agent/MCP 仍須確認未知費用，不能因預估為 0 自動按免費放行。Vibe 預算不是硬上限，請向服務商確認價格與限額。
- API Key / Token、Prompt、參數與所需影像會傳送至你填寫的站點，請僅使用可信服務。詳見[自訂 API 說明](docs/custom_api.md)。

> **下方繼承的完整功能介紹以 NovelAI 官方路線為基準，不是自訂介面全部支援的承諾。** 本機圖庫與詞庫等工具仍可使用；線上生成、模型、參考圖、餘額、免費額度與費用行為請以所選路線及上述限制為準。

## ✨ 一套完整的創作流程

| 你想做什麼 | NAI Launcher 可以怎麼幫你 |
| --- | --- |
| **開始創作** | 寫 Prompt、選模型和參數，再加入角色、Vibe、Precise Reference 或來源圖片。 |
| **反覆調整** | 圖片生成圖片、局部重繪、擴圖、變體、增強，隨時從歷史圖片取回部分參數。 |
| **批次處理** | 把多組任務交給佇列，暫停、繼續、排序、重試，並查看真實進度與 Anlas 消耗。 |
| **累積素材** | 將作品放進本機圖庫，把標籤、Vibe 和精準參考整理成可搜尋、可分類的個人資源庫。 |
| **尋找靈感** | 搜尋多個線上圖庫，查看原始 Prompt 與生成資訊，再送回生成頁面繼續創作。 |
| **跨工具與裝置** | 連接 Krita、ComfyUI 和雲端備份，讓桌面創作流程延續到 Android。 |

## 🚀 功能總覽

### 🎨 NovelAI 生成與編輯（官方路線）

- 支援文字生成圖片、圖片生成圖片、一般 Inpaint、Focused Inpaint、Outpaint、變體和增強。
- 支援 NovelAI V5 Curated / Full、V4.5、V4 與 V3 系列常用工作流程；切換模型時，可用參數、預設值、Token 上限與參考功能會跟隨模型能力變化。
- V5 Full 可切換「節約 / 標準」生成檔位：節約檔消耗較少 Anlas 與 Opus 免費額度，並與官網一樣固定步數、取樣器和負面預設；V4 及之後的模型可切換動漫 / 獸人模式，獸人模式會在提示詞開頭加入 fur dataset 資料集標籤，匯入圖片時自動辨識。
- 可設定尺寸、採樣器、Steps、CFG、Seed、噪聲排程等參數；尺寸不符合 NovelAI 限制時，會先提供可用建議。
- 生成前顯示預估 Anlas 消耗；可能產生費用的重要操作會另外確認，完成後自動更新餘額與統計。
- 內建生成歷史與預覽，可重用 Prompt、Seed、模型和部分參數，不會覆蓋仍在編輯的內容。
- 預覽圖和歷史記錄支援「另存為」：單張可從右鍵、更多選單或全螢幕詳情頁頂欄自選位置和檔名，多選後可一次存入同一資料夾。另存為只匯出保留完整生成參數的副本，不寫入應用程式圖庫；開啟保護模式及「匯出時避免覆蓋已有檔案」後，重名檔案自動編號。

### ✍️ Prompt、固定詞與角色

- 正向 Prompt、負向 Prompt、正負面固定詞和角色內容分區編輯，複雜工作流程也能看清每一部分的來源。
- 多角色可以分別設定正負面 Prompt、參考圖與畫面位置，並依目前模型處理角色數量和定位能力。
- 內建 Danbooru / e621 基礎標籤與別名，可離線顯示補全、類型、熱度和翻譯；也可安裝中文詞庫與相關標籤資料包。
- 相關標籤補全能繼續尋找構圖、服裝、動作和畫面元素；Danbooru 線上結果可補充較新的標籤。
- 自訂標籤詞庫、固定詞和隨機詞庫都支援分類、搜尋、批次編輯與快速插入。
- 輸入框右下角可切換文字／標籤模式，直接編輯原文、調整權重、多選後長按標籤拖動排序及復原；簡中與繁中介面在標籤下顯示同一份本機中文譯文，其他語言只顯示原文。文字模式選取完整標籤時也可查看譯文。
- 主提示詞輸入框底部可拖動調整高度，按兩下拖動條恢復自動增高；文字與標籤模式共用高度。
- 標籤可停用後恢復，原文中的 `/*disabled:原片段*/` 會隨提示詞儲存和雲端同步，但停用內容不參與生成、有效預覽和 Token 計數。這是 Launcher 編輯語法，舊版用戶端及外部工具不保證識別；外部使用請在選單選擇「複製有效提示詞」。
- 本機譯文未命中的內容可交給你設定的 AI 翻譯服務。
- 提示詞助手的反推、最佳化、翻譯等任務支援統一設定回應等待逾時，可選 1、2、5、10、15 或 30 分鐘，預設 5 分鐘。
- 提示詞助手的提供商可獨立儲存自動或手動並行模式，預設自動從 5 個請求開始調整；獨立標籤批次並行翻譯。各任務可選擇模型支援的思考等級。服務商、API Key 與模型在「設定 → 整合 → 模型服務」管理，任務路由與思考等級位於「設定 → 整合 → 提示詞助手」，均儲存在本機。

### 🧬 Vibe、精準參考與圖片編輯

以下線上參考與編輯能力描述官方路線；自訂介面受服務商限制，V5 的 Vibe 與 Precise Reference 不可用。本機資源庫管理不等於伺服器支援相應生成能力。

- Vibe Transfer 支援圖片、預編碼 Vibe 與 Bundle，可調整資訊提取和參考強度，並依模型重用已有編碼。
- Precise Reference 可用於角色或風格參考，支援多選、批次修改類型，以及包含圖片的設定包匯入匯出。
- Vibe 與 Precise Reference 都有獨立資源庫，可分類、搜尋、預覽、批次管理，並直接送到目前生成任務。
- 重繪編輯器提供畫筆、遮罩、Focused Inpaint 區域和畫布擴展；也可先讓智慧代理準備遮罩或擴圖草稿，再由你檢查後送出。
- 可從 NovelAI 圖片中讀取模型、尺寸、採樣器、Steps、CFG、Seed、固定詞和角色內容，並選擇性還原；下次匯入會沿用上次勾選的項目。
- Android 可從 Discord 等應用程式將單張圖片或圖片直連連結分享到 NAI Launcher，讀取圖片後選擇擷取中繼資料、圖生圖或參考圖等用途；圖片連結須可存取，還原參數須原圖保留中繼資料。

### 🗂️ 本機圖庫與作品整理

- 只掃描你指定的目錄，再依資料夾、相簿、收藏、Prompt 和生成資訊尋找作品。
- 圖片詳情會拆分正負面 Prompt、固定詞、角色內容與完整參數，可整組複製，也可只取需要的部分。
- 支援批次分類、收藏、移動與刪除，並提供圖片比較、幻燈片、浮水印、遮蔽副本和多種檢視方式。
- 在「設定 → 安全與分享」中可獨立開啟「複製/拖拽時添加浮水印」，使用已儲存的預設浮水印方案產生輸出副本，不修改原圖。添加浮水印不會清除後設資料；如需清除，請同時開啟保護模式及「複製/拖拽時移除全部後設資料」，處理順序為先清除、再加浮水印。
- 浮水印編輯器支援「自動選位」：以設定的錨點為首選位置，其他角落明顯更乾淨時，整套浮水印會鏡像過去；文字與 Logo 可分別開啟「自動灰階」，依浮水印下方的背景亮度取灰，並以「明暗差」控制與背景的反差。
- 桌面版提供右鍵、懸停預覽和拖放，觸控端提供對應選單；核心操作不會因換到手機而消失。
- 本機圖庫、Vibe 庫、精準參考庫與詞庫的常駐側欄支援拖曳調整寬度，各頁面寬度僅儲存在本機，不參與雲端同步。
- 本機圖庫資料夾、相簿、Vibe 與詞庫類別支援原有順序、名稱及數量升降冪，各群組僅在本機記憶排序。資料夾預設按名稱降冪，讓統一格式的日期資料夾最新在前；拖曳調序以目前顯示順序為基礎，並自動切換為原有順序。桌面直接拖曳，觸控長按拖曳；資料夾、相簿和詞庫類別還支援拖入子層級，Vibe 保持平面類別。
- 詞庫條目在「自定義排序」下可拖曳調序：桌面直接拖曳卡片，觸控長按拖曳，此時多選改從卡片的「更多」選單進入。拖曳選取項目時整組移動，收藏條目始終在前；分組檢視中拖到其他類別會移入該類別並放在落點處。
- 圖片和資源卡片的右鍵、更多選單與批次工具列使用一致的操作；已選取項目開啟批次選單，未選取項目仍只操作自身。桌面支援 Ctrl/Cmd 多選、Shift 範圍選取及目前頁面全選，翻頁保留選取狀態。
- 從已選取卡片拖出時會攜帶整組資源：圖片使用實際圖像，Vibe/Bundle 與精準參考使用各自的資源檔案。應用程式內可拖到支援的生成參考、Agent、分類或相簿入口；單項入口會拒絕多項拖入。
- 本機圖片可直接傳送到生成頁面、智慧代理或 Krita，省去重複匯出和選擇檔案。
- 在「設定 → 資料與儲存 → 資料夾與檔案名稱」中決定圖庫怎麼存：子資料夾可按日期、按月份、按年／月兩層或不建立子資料夾，檔案名稱可用「時間 + 種子」「日期時間 + 種子」或「提示詞 + 種子」，也可以用與 NovelAI 官網相同的範本語法自訂（如 `{prompt} s-{seed}`、`{model}/{date}`），編輯時即時預覽完整路徑。預設仍按日期分資料夾、以時間和種子命名；修改只影響之後儲存的圖片，既有檔案不會被重新命名或移動。
- Android 儲存圖片時預設同步一份到系統相簿；在「設定 → 資料與儲存」關閉「同步到系統相簿」後，生成和儲存的圖片只留在應用程式圖庫，需要時仍可單張「儲存到系統相簿」。

### 🔎 線上圖庫與靈感收集

- 聚合 Danbooru、Safebooru、Gelbooru、AI TAG 與法典圖鑑（NovelAI QuickTagCloud）。
- 依來源提供搜尋、熱門、隨機、排行榜、日期、內容分級、黑名單與輸出篩選，不把不支援的功能硬套到所有網站。
- 支援本機收藏；登入 Danbooru 或設定 Gelbooru API 後，可使用對應帳號功能。
- 可查看多圖作品、原始 Prompt 和結構化生成資訊，整組下載，或把可識別的參數送回生成頁面。
- 法典圖鑑支援公開法典、分類、版本、多圖與純文字條目、貢獻者資訊和最近瀏覽。

### 🤖 智慧代理

- 在桌面側欄或行動版抽屜中對話，讓代理查詢標籤、整理 Prompt、查看生成歷史、操作資源庫並準備生成任務。
- 圖片、Vibe 和 Precise Reference 可直接加入會話；圖片也能在輸入框按 Ctrl/Cmd+V 貼上，或從檔案管理員、瀏覽器拖到面板，Android 可從輸入法插入。代理也能準備重繪遮罩、擴展畫布與重繪草稿，或直接放大、增強圖片。
- **以下費用與全自動行為僅描述官方路線；自訂介面仍須確認未知費用。** 「準備任務」和「真正生成」嚴格分開：準備階段核實費用；完全存取模式下，已核實為零 Anlas 的生成直接執行，刪除已儲存的資料與付費操作仍需確認。需要無人值守批次出圖時可切換到「全自動」：付費操作直接執行，只有單次消耗達到保護模式的高消耗閾值時才確認，刪除已儲存的資料仍需確認。
- 預設角色調查流程會結合連網身分核實、標準標籤檢索和畫廊特徵；連網關閉或證據不足時會說明限制。
- 系統提示詞可直接以自然語言補充要求或替換內建正文，無需佔位符。工作目錄、連網狀態、Skills 與應用程式執行規則會自動補充，並可預覽最終內容；自訂不會繞過應用程式的權限確認。
- 支援逐題回答的結構化提問：每題三個可行方向、一個「推薦」標記和一個自訂入口，最後統一檢查並提交。預設兩分鐘未提交會自動採用全部推薦選項；提問時顯示 Toast、入口問號和 Android 系統通知。
- Windows 與 macOS 可在「設定 → 整合 → MCP」開啟本機 MCP 服務，讓 Claude Code、Codex CLI、Cursor、Cherry Studio、Pi、Claude Desktop 等外部智慧代理透過同一套工具操作 Launcher；服務預設關閉，授權確認與 Anlas 消耗確認仍在 Launcher 內完成。詳見 [MCP 服務說明](docs/mcp_server.md)。
- MCP 生成與取圖預設回傳原解析度圖片；用戶端可能在摺疊的工具詳情中顯示。正文顯示支援供 Cherry Studio 等同機用戶端使用的短期本機 HTTP 圖片位址，以及供 Codex 使用的可選顯示快取，無需另存圖庫副本。HTTP 位址最長有效 1 小時，服務關閉或快取淘汰後失效。開啟保護模式及「複製/拖拽時移除全部後設資料」後，MCP 圖片、HTTP 顯示、顯示快取、另存匯出與剪貼簿輸出同樣清除後設資料與 NAI 隱寫水印，且不回傳原圖路徑；本機原圖不受影響。淨化另存使用 PNG，仍保留目標路徑權限與禁止覆寫檢查。
- 支援 OpenAI 相容介面、Google Gemini 原生介面、第三方 Gemini 相容中轉與 OpenRouter；每個服務商可從介面清單挑選模型或手動新增模型 ID，並依模型能力啟用思考等級和工具呼叫。
- 模型服務、API Key、可用地區和費用由你選擇的供應商負責；網路搜尋等額外工具預設關閉。

### 📋 佇列、歷史與統計

- 生成任務可批次加入佇列，支援暫停、繼續、調整順序、取消和重試失敗任務。
- 執行中可查看單項狀態、整體進度和失敗原因，不必守著每一次請求。
- 統計頁面可依時間、尺寸、採樣器、模型與 Anlas 消耗回顧創作記錄。

### 🧩 Krita 與 ComfyUI

- **Krita Bridge**：把 Krita 畫布送到 Launcher 生成或重繪，再將結果送回 Krita。
- **ComfyUI**：連接本機伺服器，執行一般放大或 SeedVR2 工作流程；伺服器模型與自訂節點仍由你的 ComfyUI 環境負責。
- **DLSSNR 圖像增強（Windows）**：在「設定 → 整合 → DLSSNR」按需安裝公開執行階段並檢測 NVIDIA GPU；支援生成後自動增強（預設關閉）、圖片卡片手動增強與拖曳分隔線比較；共用比較元件支援「跟隨滑鼠」開關，方便放大後比較局部，開關偏好儲存在本機。SR 放大倍率預設 2 倍，可手動輸入；SR 放大後執行單次 NR，再完成增強與色彩混合。提供 7 套內建風格預設，預設使用「質感光影」，另有「保色增強」「濃郁」等風格可選；可另存、重新命名和刪除自訂預設；目前選擇和調整自動儲存。參數附帶說明和數值輸入。圖像在本機處理，手動儲存建立新檔案並作為最新結果加入歷史記錄，不覆寫原圖。
- 從圖庫、預覽和編輯流程都能進入這些工具，不必每次手動匯出再重新選擇檔案。

### ☁️ 同步與備份

- 支援 OneDrive、GitHub 與 WebDAV；Google Drive 因授權審核尚未通過，暫時停用新增連線入口。連接帳號不會自動上傳、下載或覆蓋內容。
- 推送、拉取和還原都由你主動開始，並可預覽差異與處理衝突。
- 可分別選擇設定、Prompt 與詞庫、詞庫預覽圖、線上圖庫設定與收藏、本機相簿、固定詞使用記錄、智慧代理 Prompt 與 Skill，以及可選的 Vibe、Precise Reference。
- 本機圖庫原圖、遠端圖庫原圖、帳號憑證、快取和日誌不會進入備份。
- 備份使用方便查看與移轉的明文資料，不需要額外復原金鑰；請自行確認目標空間的存取權限。

## 🖼️ 介面預覽

以下截圖沿用上游，僅作介面示意，不代表本分支 Preview2／Preview5 的自訂介面外觀、支援範圍或真實服務測試結果。

### 🖥️ 桌面版

<table>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-generation-desktop.png" alt="生成工作區與智慧代理" width="100%"><br>
      <sub>生成工作區：Prompt、參數、預覽與智慧代理同畫面協作</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-local-gallery-desktop.png" alt="本機圖庫" width="100%"><br>
      <sub>本機圖庫：搜尋、相簿、資料夾與批次整理</sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-online-gallery-desktop.png" alt="線上圖庫" width="100%"><br>
      <sub>線上圖庫：多個來源、篩選與瀑布流瀏覽</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-statistics-desktop.png" alt="統計儀表板" width="100%"><br>
      <sub>統計儀表板：作品、參數與 Anlas 使用情況</sub>
    </td>
  </tr>
</table>

## 💻 支援平台

| 平台 | 目前狀態 | 說明 |
| --- | --- | --- |
| **Windows** | 主要開發與發佈平台 | 提供安裝版和可攜版，適合長時間創作、批次任務、Krita / ComfyUI 串接以及 MCP 外部接入。 |
| **macOS** | 可用，持續改善中 | 需要 macOS 12 或更新版本。提供可攜版；若系統阻止開啟未公證應用程式，請依 macOS 安全提示手動允許。 |
| **Android** | Beta | 支援手機、橫向畫面、平板和大螢幕；生成、圖庫、詞庫、佇列、代理與設定都有觸控入口。 |
| **Linux** | 暫無正式發行包 | 目前不提供正式下載包。 |

## ⚡ 下載與開始使用

### 1. 下載並安裝 Preview5

Preview5 已公開發佈並包含動態定價。安裝請查看[發佈頁面](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5)，檔名如下（與上方直接連結一致）：

| 平台 | 檔案 | 用法 |
| --- | --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Setup.exe) | 未簽章安裝版；先備份並檢查安裝目錄。 |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.5_Portable.zip) | 未簽章可攜版；解壓縮後直接執行。 |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.5.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.5.apk) | 側載 debug key 簽章 APK；可能需要允許安裝未知來源軟體，不能覆蓋不同簽章的上游安裝。 |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.5_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.5/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.5_Portable.zip) | 解壓縮後開啟 `Aaalice NAI Launcher.app`；僅 ad-hoc 簽章且未公證。 |

Preview5 附帶 `checksums.txt`、`release_manifest.json` 和 `release_notes_custom_api.md`，可核對 SHA-256、檔案大小與來源；檢查碼不等於發佈者數位簽章。請同時閱讀上方安裝風險與應用程式內更新警告。

### 2. 優先使用「自訂介面」

1. 在登入頁選擇 **「自訂介面」**，不要將第三方 Key 填入官方登入。
2. 填寫 **一個 API URL**：站點根位址或以 `/v1` 結尾的位址均可；例如 `https://provider.example` 或 `https://provider.example/v1/`。主 API 與影像 API 共用此位址，無需另填影像位址或選擇協定。
3. 填寫必需的 **暱稱** 和 **API Key / Token**。Key 僅儲存在目前裝置安全儲存空間，不進入雲端備份，但驗證時會傳送至所填站點。
4. 登入驗證僅請求 `/v1/models`，不會試畫；Preview5 在受支援站點另行公開讀取定價，不使用 Key。通過驗證後，先確認服務商計費與能力，再主動生成。五模型白名單、無 Medium、V5 參考不可用及未知費用限制見上方。

**可選：NovelAI 官方路線。** 如需官方服務，可使用 NovelAI 帳號密碼或 **Persistent API Token** 登入；網頁安全驗證造成密碼登入失敗時可改用 Persistent API Token。官方 Token 僅儲存在目前裝置安全儲存空間。官方模型與 Anlas 說明不適用於自訂服務的費用承諾。

### 3. 設定常用資源

- 在「設定」中選擇本機作品目錄，進入本機圖庫後開始掃描。
- 在「設定 → 資料來源與快取」中管理中文詞庫、相關標籤資料包和線上快取。
- 需要 Krita 串接時，先啟用 Krita Bridge，再按照 [Krita 外掛說明](krita_plugin/README.md) 安裝外掛。
- 需要 ComfyUI 時，在「設定 → ComfyUI」中填寫本機位址並選擇工作流程。
- 需要跨裝置使用時，在雲端同步頁面連接一個備份目標，並仔細確認要同步的內容。

## 🔒 資料與隱私

NAI Launcher 不會在專案自有伺服器上託管你的帳號或作品。只有在你主動使用對應功能時，資料才會傳送給相關服務：

| 使用的功能 | 資料會傳送到哪裡 |
| --- | --- |
| 生成、圖片生成圖片、重繪、Vibe 編碼 | NovelAI 或你明確設定的第三方影像 API 站點；包括本次請求所需的 Prompt、參數和來源圖片或參考圖。第三方 Token 會傳送到所填位址，請僅使用可信服務。 |
| Preview5 公開定價讀取 | 僅精確 origin `https://api.cunzaijiang.cn` 的公開 `/api/pricing`；不傳送 Key、Cookie、Prompt 或圖片，不進行生成。 |
| 線上圖庫搜尋與下載 | 你選擇的第三方圖庫；可用性、速率限制和內容規則由各網站決定。 |
| AI 翻譯或智慧代理 | 你設定的模型服務；對話、附加圖片和完成任務所需的工具結果可能產生服務費用。 |
| 同步與備份 | 你選擇的 Google Drive、OneDrive、GitHub 或 WebDAV；只上傳明確勾選的內容。 |

- NovelAI Token、OAuth access/refresh token、WebDAV 密碼和 GitHub Token 使用裝置安全儲存，不會寫入備份。
- 本機 Prompt、圖庫索引、標籤、資源庫和代理工作階段預設儲存在本機。
- 雲端備份以明文儲存所選資料；本機圖庫的圖像本體不上傳，相簿、分類、成員引用和固定詞使用記錄可作為輕量資料同步。
- 線上圖庫可能包含第三方內容；分級篩選不能取代使用者判斷。
- WebDAV 的安全性取決於你設定的伺服器與傳輸方式，請保留重要資料的本機副本。

## 🆘 支援與回饋

- 如遇異常，請透過「設定 → 關於 → 匯出診斷日誌」儲存排查資訊，並在回報時一併提供。
- [提交本分支 Issue](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues)：回報可以重現的問題或提出功能建議；分享日誌前請移除 Token 等敏感資訊。
- [Preview5 發佈頁（含動態定價）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.5)並核對檢查碼檔案；更新內容見[本分支更新說明](docs/releases/custom_api_preview.md)。Preview5 已發佈並完成附件回驗；目前發行版僅支援本分支手動下載，不支援應用程式內安裝更新。

## 🙏 致謝

感謝上游作者 **Aaalice233** 及 [NAI Launcher 上游專案](https://github.com/Aaalice233/Aaalice_NAI_Launcher) 提供原始程式碼、詳細功能介紹與介面截圖。本分支由 **cunzaijiang** 獨立維護，保留上游 **MIT License**、原版權與授權聲明；本分支的問題與下載請使用本頁入口，不要作為上游官方發行版回報。

感謝 [NovelAI](https://novelai.net/)、[法典圖鑑](https://novelai.quicktagcloud.com/)、[AgIzT/NovelAI-Tag](https://github.com/AgIzT/NovelAI-Tag)、[Flutter](https://flutter.dev/)、[Riverpod](https://riverpod.dev/) 以及所有貢獻者和測試使用者。

## 📄 授權條款

本分支繼續依照 [MIT License](LICENSE) 開源，並保留上游版權與授權聲明。
