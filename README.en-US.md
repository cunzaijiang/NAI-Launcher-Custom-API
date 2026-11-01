# NAI Launcher Custom API

> **Preview3 is publicly released; all four packages were downloaded and verified.** Final local validation: 615 tests in 32 files passed; the additional 17 Agent wording tests in 3 files remain passed. All CI jobs succeeded; the cloud gate passed 32 files. Seven assets were downloaded, six checksum entries verified, and four package hashes, ZIP CRCs, and APK/EXE checks passed. Real installation, UI, and paid-generation acceptance remain unverified. Tag: `custom-api-v4.3.1-preview.3` · [Verification / 验证 / 驗證](docs/custom_api_verification.md).

<p align="center">
  <a href="README.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · English
</p>

<p align="center">
  <img src="assets/icons/Icon.png" alt="NAI Launcher icon" width="112">
</p>

<p align="center">
  <strong>An independent, Custom API-first preview fork with optional official NovelAI access.</strong>
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3"><img src="https://img.shields.io/badge/Custom_API-custom--api--preview-blue" alt="Custom API preview"></a>
  <img src="https://img.shields.io/badge/Windows%20%7C%20macOS%20%7C%20Android-available-6f7785" alt="Supported platforms">
  <img src="https://img.shields.io/badge/license-MIT-5b8c5a" alt="MIT License">
</p>

<p align="center">
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3">Download Preview3 (with dynamic pricing)</a> ·
  <a href="docs/releases/custom_api_preview.md">Fork release notes</a> ·
  <a href="https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues">Report a fork issue</a>
</p>

**NAI Launcher Custom API** is an independently maintained Custom API fork of upstream NAI Launcher by **cunzaijiang**, **not an official upstream release or an official NovelAI product**. See Acknowledgments for the original author and MIT attribution. Custom image services do not require a NovelAI account; official sign-in remains optional. Follow your provider's terms, content rules, and local laws.

The primary entry is **Custom API** on the sign-in page: enter **one API URL, a nickname, and an API key / token**, using either the site root or a `/v1` URL. Windows, macOS, and Android retain upstream local tools and creative interfaces; local tools work without signing in.

## Preview3 downloads (with dynamic pricing)

**4.3.1 Custom API Preview3 is publicly released with dynamic pricing.** [Release and checksums](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3) · [Read this fork's release notes](docs/releases/custom_api_preview.md). Use these four actual packages, not the source archives, to install:

| Platform | Direct package download |
| --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe) |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip) |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk) |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip) |

[History: old Preview2 (no dynamic pricing)](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.2). This version updates the QQ group entry and standard QQ icon; other functionality is unchanged. [QQ](https://qm.qq.com/q/jY8Pshi5os)

> **Preview and installation risks**: Back up first. Both Windows packages are unsigned (no Authenticode); macOS has only an ad-hoc signature, no Apple Developer ID and no notarization. Android is a release-mode APK signed with an ephemeral debug key, retaining the upstream application ID: it cannot replace a differently signed upstream installation, and upgrades between preview builds are not guaranteed. Windows installation directories may overlap upstream; uninstalling can erase local data. Verify provenance and SHA-256; do not globally disable system security. This preview has not undergone end-to-end testing against real services; arbitrary third-party providers are not guaranteed to work.

> **Preview3 update boundaries**: In-app GitHub links now point to this fork. Automatic update checks and in-app download/installation are disabled; Check for Updates offers manual downloads from this fork's [Releases page](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases). Independent preview manifests are incompatible with upstream signed update metadata and are not parsed as trusted updates. Already-published Preview 1 packages remain unchanged; upgrade manually from this page.

## Custom API support boundaries

- Uses **OpenAI Chat `/v1/chat/completions`**: outer `model` and `messages`, a JSON drawing payload inside message content, and only inline Markdown PNG data URI responses; HTTPS/HTTP remote image URLs are unsupported. This is not the generic `/v1/images/generations` API. Main and image APIs share one URL with no protocol switch.
- Login only reads `/v1/models` for validation, without test generation. Only five exact model IDs are accepted: `nai-diffusion-4-full`, `nai-diffusion-4-5-full`, `nai-diffusion-4-5-curated`, `nai-diffusion-5-full`, `nai-diffusion-5-curated`.
- **V5 Medium effort is not supported; V5 Vibe / Precise Reference features are unavailable.** Other models' reference, generation, and editing capabilities still depend on the provider; successful login does not guarantee every feature. Final images only, no intermediate streaming previews or automatic retries.
- **Chat Vibe sends raw reference images for server-side encoding and caching; its budget field is ignored.** The client does not persist or reuse returned `vibe_cache_ids`; cross-request cache reuse is not guaranteed. Custom drawing does not call native `/v1/ai` generation or encoding endpoints. Independent Encode is separate from drawing and does not establish Chat Vibe support.
- **Preview3 dynamic pricing is limited to the exact origin `https://api.cunzaijiang.cn`** (root or `/v1` entry, not other sites, subdomains, or proxy path prefixes). An isolated client makes a public GET to `https://api.cunzaijiang.cn/api/pricing`, without an API key, Authorization, Cookie, or redirects; pricing retrieval is not login or test generation. Only bounded whitelist expressions for four models, V4.5 Full/Curated and V5 Full/Curated, are parsed, never `eval`. Unknown expressions, models, or origins stay unknown: no invented prices or reuse of this origin's rules on other sites.
- `pricing_version` and fetch time are saved in a device-local durable cache with a 1-hour TTL, excluded from cloud backups. Hourly automatic refresh has been added, including hourly retries after an initial fetch failure. Clicking, touching, or keyboard-activating the price badge only refreshes prices. A failed refresh retains the last successful rules with an offline/stale warning; unavailable estimates show `--`. At the user's explicit request, quotes and usage-derived amounts show **unitless raw numbers only**, without USD, CNY, currency symbols, or an inferred currency.
- The synchronized rules describe a **NAI4.5 standard baseline of 0, with possible extras, and a NAI5 base of 0.05**. These values follow synchronized rates, not hardcoded stable promises. Provider-specific extra-Anlas estimation uses a zero base component at effective area `≤1048576` and actual steps `≤28`; above either limit it uses the existing area/step formula. Supported Precise References add 5 each; Vibe encoding is estimated at 0–2 per reference per request because server cache state is unknown (extras beyond four references are separate). Batch totals sum all independent requests. See [pricing formulas and limits](docs/custom_api.md).
- Response amounts apply synchronized expressions to the actual raw response `p` / `c`; they are **not actual wallet bills**. The warning about `p=100000` versus the expression's `p=1` requirement is retained; usage is never rewritten to match an estimate. Balances, subscription eligibility, and wallet debits remain unknown. Official integer Anlas and authorization gates are unchanged: Agent/MCP still requires unknown-cost confirmation and cannot automatically treat a zero estimate as free. Vibe budgets are not hard caps; confirm prices and limits with your provider.
- Your API key / token, Prompts, parameters, and required images go to the URL you configure. Use trusted services only; see the [custom API guide](docs/custom_api.md).

> **The inherited full feature descriptions below describe the official NovelAI route, not a promise that Custom API supports them all.** Local gallery and tag-library tools remain available. Online generation, models, references, balances, free allowances, and billing behavior depend on the selected route and the limits above.

## ✨ One complete creative workflow

| What you want to do | How NAI Launcher helps |
| --- | --- |
| **Start creating** | Write a Prompt, choose a model and parameters, then add characters, Vibes, Precise References, or a source image. |
| **Keep refining** | Use image-to-image, inpainting, outpainting, variations, and enhancement, or restore selected settings from an older image. |
| **Process a batch** | Queue multiple jobs, pause, resume, reorder, retry, and see real progress and Anlas cost. |
| **Build a library** | Organize artwork in the local gallery and turn tags, Vibes, and references into searchable personal libraries. |
| **Find inspiration** | Search several online galleries, inspect original Prompts and metadata, then continue from them in generation. |
| **Move between tools** | Connect Krita, ComfyUI, and cloud backup so the same workflow can continue on Android. |

## 🚀 Feature guide

### 🎨 NovelAI generation and editing (official route)

- Text-to-image, image-to-image, regular Inpaint, Focused Inpaint, Outpaint, variations, and enhancement are supported.
- Common NovelAI V5 Curated / Full, V4.5, V4, and V3 workflows are available. Controls, defaults, Token limits, and reference features follow the selected model's capabilities.
- V5 Full offers the Medium / High effort switch: Medium costs fewer Anlas and less of the Opus allowance, and like the official site it fixes the steps, sampler and Undesired Content preset. V4 and later models offer Anime / Furry mode; Furry mode adds the fur dataset tag to the start of the prompt and is recognized automatically when importing images.
- Configure size, sampler, Steps, CFG, Seed, noise schedule, and related parameters. Invalid NovelAI dimensions are caught early with a usable size suggestion.
- Estimated Anlas cost appears before generation. Important paid actions require separate confirmation, and balances and statistics refresh afterward.
- Built-in history and previews let you reuse Prompts, Seeds, models, or selected settings without overwriting work still being edited.
- Previews and history images support "Save as": pick a location and file name for one image from its context menu, More menu, or the full-screen detail toolbar, or save a multi-selection into one folder. Save as exports a copy with its full generation parameters and does not add it to the app gallery. With Protection Mode and "Avoid overwriting existing files on export" enabled, name conflicts are numbered automatically.

### ✍️ Prompts, pinned tags, and characters

- Positive Prompts, negative Prompts, positive and negative pinned tags, and character content have clear editing areas, even in complex setups.
- Each character can have separate positive and negative Prompts, reference images, and a position. Character count and positioning adapt to the current model.
- The offline Danbooru / e621 catalog and aliases show completion, tag type, popularity, and translations. Optional Chinese and related-tag data packs add more context.
- Related-tag completion helps explore composition, clothing, poses, and visual elements, while Danbooru online results can fill in newer tags.
- Personal tag, pinned-tag, and random-tag libraries support categories, search, batch editing, and quick insertion.
- Switch between text and tag mode at the bottom-right of the input to edit original text, adjust weights, long-press and drag selected tags to reorder them, and undo. Simplified and Traditional Chinese interfaces display the same local Chinese translations below tags; other languages show only the original text. Selecting a complete tag in text mode also displays its translation when using a Chinese interface.
- Drag the bottom edge of the main prompt editor to resize it, or double-click the handle to restore automatic height. Text and tag modes share the same height.
- Disable and restore tags without losing their content. The `/*disabled:original fragment*/` notation is saved and cloud-synced with the Prompt, while disabled content is excluded from generation, effective previews, and Token counts. This is Launcher editing syntax; older clients and external tools may not recognize it. Choose “Copy effective prompt” from the menu for external use.
- Local translation misses can be sent to a configured AI translation service.
- Prompt Assistant tasks, including reverse prompting, optimization, and translation, share a configurable response wait timeout: 1, 2, 5, 10, 15, or 30 minutes, with a 5-minute default.
- Each Prompt Assistant provider saves its own automatic or manual concurrency mode. Automatic mode starts at 5 concurrent requests, and independent tag batches translate in parallel. Each task offers the thinking levels supported by its model. Manage providers, API keys, and models under Settings → Integrations → Model services, and task routing and thinking levels under Settings → Integrations → Prompt Assistant. Both stay on this device.

### 🧬 Vibe, Precise Reference, and image editing

The online reference and editing capabilities below describe the official route. Custom API depends on the provider, and V5 Vibe and Precise Reference are unavailable. Local library management does not imply server-side generation support.

- Vibe Transfer accepts images, pre-encoded Vibes, and Bundles, with information extraction and reference strength controls and model-aware encoding reuse.
- Precise Reference supports character and style references, multi-select, batch type changes, and portable packages that include their images.
- Dedicated Vibe and Precise Reference libraries provide categories, search, previews, batch management, import/export, and direct use in the current generation.
- The inpaint editor includes brushes, masks, Focused Inpaint regions, and canvas expansion. Agent Chat can prepare a mask or outpaint draft for review.
- NovelAI image metadata can restore selected model, size, sampler, Steps, CFG, Seed, pinned tags, and character content; the next import reuses the items you last checked.
- On Android, share a single image or a direct image link from apps such as Discord to NAI Launcher, then choose metadata import, img2img, or reference use. Direct links must be accessible, and restoring parameters requires an original image with metadata intact.

### 🗂️ Local gallery and artwork organization

- Scan only the folders you choose, then find artwork by folder, album, favorite status, Prompt, or generation metadata.
- Image details separate positive and negative Prompts, pinned tags, character content, and full parameters for all-at-once or selective copying.
- Batch categorization, favorites, moving, and deletion sit alongside comparison, slideshows, watermarks, redacted copies, and several viewing modes.
- In Settings → Privacy & Sharing, independently enable "Add watermark when copying or dragging" to apply the saved default watermark to an output copy without changing the original. Adding a watermark does not remove metadata. To remove it, also enable Protection Mode and "Remove all metadata when copying or dragging"; metadata is removed before the watermark is added.
- The watermark editor offers Auto placement: the anchor you set is preferred, and when another corner is clearly cleaner, the whole watermark is mirrored there. Text and logo each have Auto grayscale, which picks a gray from the background beneath them, with Tone difference controlling how far it stands out.
- Desktop gets context menus, hover previews, and drag-and-drop; touch devices get equivalent menus instead of losing features.
- Persistent sidebars in the local gallery, Vibe library, Precise Reference library, and tag library can be resized by dragging. Each page remembers its width on this device only, outside cloud sync.
- Local gallery folders, albums, Vibe categories, and tag-library categories support original order or ascending/descending name and count sorting, remembered separately on this device only. Folders default to descending names, placing consistently formatted date folders newest first. Dragging to reorder starts from the displayed order and switches to original order automatically. Drag directly on desktop or long-press and drag on touchscreens; folders, albums, and tag-library categories also support nesting, while Vibe categories remain flat.
- Under Custom Sort, tag-library entries can be reordered by dragging: drag cards directly on desktop, or long-press and drag on touchscreens, where multi-select is entered from the card's More menu instead. Dragging a selected entry moves the whole selection, favorites always stay first, and in the grouped view dropping onto another category moves the entry into that category at the drop position.
- Image and resource cards use consistent actions across context menus, More menus, and batch toolbars. Selected cards open batch actions; unselected cards act only on themselves. Desktop supports Ctrl/Cmd toggling, Shift range selection, and selecting the current page, with selection preserved across pages.
- Dragging a selected card includes the entire selected set: actual images for image cards and portable resource files for Vibes, Bundles, and Precise References. In-app targets include compatible generation references, Agent, categories, and albums; single-item targets reject multiple items.
- Local images can go directly to generation, Agent Chat, or Krita without repeated exports and file picking.
- Choose how the gallery stores images in Settings → Data & Storage → Folders & File Names: subfolders by date, by month, by year then month, or none; file names as time + seed, date and time + seed, or prompt + seed, or a custom template using the same syntax as the NovelAI website (for example `{prompt} s-{seed}` or `{model}/{date}`), with a live preview of the full path. By default images still go into date folders and are named by time and seed; changes only apply to images saved afterwards, and existing files are not renamed or moved.
- On Android, saved images are copied to the photo gallery by default. Turn off "Sync to photo gallery" in Settings → Data & Storage to keep generated and saved images in the app gallery only; you can still save individual images to the photo gallery when needed.

### 🔎 Online galleries and inspiration

- Browse Danbooru, Safebooru, Gelbooru, AI TAG, and Codex Gallery (NovelAI QuickTagCloud) from one place.
- Search, popular, random, ranking, date, rating, blacklist, and output filters appear according to each source's real capabilities.
- Local favorites work independently. Danbooru sign-in and Gelbooru API settings unlock the matching account features.
- Inspect multi-image posts, original Prompts, and structured generation metadata, download a set, or return recognized settings to generation.
- Codex Gallery includes public codices, categories, versions, multi-image and text entries, contributor credits, and recently viewed items.

### 🤖 Agent Chat

- From a desktop sidebar or mobile drawer, the agent can search tags, organize Prompts, inspect generation history, use libraries, and prepare generation tasks.
- Images, Vibes, and Precise References can be added directly as context. Images can also be pasted into the input with Ctrl/Cmd+V or dragged onto the panel from a file manager or browser, and Android keyboards can insert them. The agent can also prepare masks, expanded canvases, and inpaint drafts, or upscale and enhance images directly.
- **The following billing and Autopilot behavior describes the official route only; Custom API still requires unknown-cost confirmation.** Preparation verifies the cost before generation. In Full Access, verified zero-Anlas generations proceed directly; deleting saved data and paid operations still require approval. For unattended batch work, switch to Autopilot: paid operations run directly and only ask when a single request reaches the Protection Mode high-cost threshold, while deleting saved data still requires approval.
- The default character research workflow combines online identity verification, canonical tag lookup, and gallery appearance evidence, noting disabled web access or missing evidence.
- Customize the system prompt by adding plain-language instructions or replacing the built-in body; no placeholders are needed. The working directory, web availability, Skills, and app execution rules are added automatically, with a preview of the final prompt. Customization does not bypass app permission checks.
- Structured questions offer three feasible directions, one Recommended marker, and a custom-answer option per question. Answer sequentially, then review and submit the full set. After two minutes without submission, all recommended options are selected automatically. New questions show a Toast, a question-mark entry icon, and an Android system notification.
- On Windows and macOS, a local MCP server can be enabled under Settings → Integrations → MCP, letting external agents such as Claude Code, Codex CLI, Cursor, Cherry Studio, Pi, and Claude Desktop drive Launcher through the same tools. The server is off by default; approvals and Anlas cost confirmations still happen inside Launcher. See [MCP server](docs/mcp_server.md).
- MCP generation and image retrieval return original-resolution images by default. Clients may show them inside collapsed tool details. Inline answers can use temporary loopback HTTP image URLs for same-machine clients such as Cherry Studio, or optional display-cache files for Codex, without saving gallery copies. HTTP links last at most one hour and are revoked on server shutdown or cache eviction. With Protection Mode and "Remove all metadata when copying or dragging" enabled, MCP images, HTTP display, display-cache files, saved exports, and clipboard output all remove metadata and NAI steganographic watermark data without exposing original file paths. Local originals remain unchanged. Sanitized exports use PNG and retain destination-permission and no-overwrite checks.
- Supports OpenAI-compatible APIs, Google's native Gemini API, third-party Gemini-compatible relays, and OpenRouter. Pick models from each provider's list or add a model ID by hand, with thinking levels and tool calls when supported.
- Your provider controls API keys, regional availability, and fees. Extra network tools such as web search are off by default.

### 📋 Queue, history, and statistics

- Queue multiple generations, pause, resume, reorder, cancel, and retry failures.
- See per-job status, overall progress, and failure details without supervising every request.
- Review creation activity by time, image size, sampler, model, and Anlas usage.

### 🧩 Krita and ComfyUI

- **Krita Bridge** sends a Krita canvas to Launcher for generation or inpainting, then returns the result.
- **ComfyUI** connects to a local server for regular upscale or SeedVR2 workflows. Models and custom nodes stay under your ComfyUI installation.
- **DLSSNR image enhancement (Windows)**: Install the public runtime on demand and test your NVIDIA GPU under Settings → Integrations → DLSSNR. Supports automatic enhancement after generation (off by default), manual image-card enhancement, and a draggable before/after divider. The shared comparison viewer offers a Follow mouse toggle for inspecting details while zoomed in; the toggle preference is saved on this device. SR scale defaults to 2× and accepts manual input. SR upscaling is followed by a single NR evaluation, then enhancement/color blending. Includes seven built-in style presets, with Texture & light as the default and alternatives such as Color-preserving enhancement and Vivid, plus custom presets you can save, rename, and delete; the current selection and adjustments are saved automatically. Parameters include explanations and numeric input. Images are processed locally; manual saves create a new file, add it to the generation history as the latest result, and never overwrite the original.
- Gallery, preview, and editing flows can open these tools directly instead of requiring repeated manual exports.

### ☁️ Sync and backup

- Supports OneDrive, GitHub, and WebDAV. New Google Drive connections are temporarily disabled pending authorization approval. Connecting an account never uploads, downloads, or overwrites content by itself.
- Push, pull, and restore start only when requested, with change previews and conflict handling.
- Select settings, Prompts and libraries, previews, online-gallery settings and favorites, local albums, fixed-tag usage records, Agent Prompts and Skills, and optional Vibe or Precise Reference content independently.
- Original local and remote gallery images, credentials, caches, and logs never enter a backup.
- Backups use readable plain data and need no separate recovery key. Check the destination's permissions before syncing.

## 🖼️ Interface preview

These screenshots are inherited from upstream and are illustrations only, not evidence of this fork's Preview2 / Preview3 Custom API appearance, supported capabilities, or real-service testing.

### 🖥️ Desktop

<table>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-generation-desktop.png" alt="Generation workspace and Agent Chat" width="100%"><br>
      <sub>Generation workspace: Prompts, parameters, preview, and Agent Chat together</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-local-gallery-desktop.png" alt="Local gallery" width="100%"><br>
      <sub>Local gallery: search, albums, folders, and batch organization</sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-online-gallery-desktop.png" alt="Online galleries" width="100%"><br>
      <sub>Online galleries: multiple sources, filters, and masonry browsing</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/screenshots/overview-statistics-desktop.png" alt="Statistics dashboard" width="100%"><br>
      <sub>Statistics dashboard: artwork, settings, and Anlas usage</sub>
    </td>
  </tr>
</table>

## 💻 Platform support

| Platform | Current status | Notes |
| --- | --- | --- |
| **Windows** | Primary development and release platform | Installer and portable packages are available. Well suited to long sessions, batch work, Krita / ComfyUI integration, and external MCP access. |
| **macOS** | Available and still being refined | Requires macOS 12 or later. A portable package is available. If macOS blocks an unnotarized build, allow it through the system security prompt. |
| **Android** | Beta | Supports phones, landscape, tablets, and large screens, with touch access to generation, galleries, libraries, queues, Agent Chat, and settings. |
| **Linux** | No official release package | No official download is currently provided. |

## ⚡ Download and get started

### 1. Download and install Preview3

Preview3 is publicly released with dynamic pricing. To install, use the [release page](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3). The filenames below match the direct links above:

| Platform | File | Usage |
| --- | --- | --- |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Setup.exe) | Unsigned installer; back up and check the installation directory first. |
| Windows | [NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.3_Portable.zip) | Unsigned portable package; extract and run. |
| Android | [NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.3.apk) | Sideload the debug-key-signed APK; permission to install unknown apps may be required. Cannot replace a differently signed upstream installation. |
| macOS | [NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.3/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.3_Portable.zip) | Extract and open `Aaalice NAI Launcher.app`; ad-hoc signed only and unnotarized. |

Preview3 includes `checksums.txt`, `release_manifest.json`, and `release_notes_custom_api.md` to verify SHA-256, sizes, and provenance. Checksums are not publisher digital signatures. Read the installation risks and in-app update warning above as well.

### 2. Start with Custom API

1. Choose **Custom API** on the sign-in page; do not enter a third-party key in official login.
2. Enter **one API URL**, either the site root or a URL ending in `/v1`, such as `https://provider.example` or `https://provider.example/v1/`. Main and image APIs share this URL; no separate image address or protocol selection is needed.
3. Enter the required **nickname** and **API key / token**. The key stays in device secure storage and is excluded from cloud backups, but validation sends it to the configured site.
4. Login validation only requests `/v1/models`, without test generation. Preview3 separately reads public pricing on the supported origin, without a key. After validation, confirm provider billing and capabilities before actively generating. See the five-model allowlist, no-Medium, unavailable V5 references, and unknown-cost limits above.

**Optional: official NovelAI route.** For the official service, sign in with NovelAI credentials or a **Persistent API Token**. If web security verification blocks password login, use a Persistent API Token instead. Official tokens stay in device secure storage. Official model and Anlas descriptions do not promise equivalent pricing for custom services.

### 3. Set up the resources you use

- Select your artwork folders in Settings, then open the local gallery to start scanning.
- Manage the Chinese translation catalog, related-tag data pack, and online caches under **Settings → Data Sources & Cache**.
- For Krita, enable Krita Bridge and follow the [Krita plugin guide](krita_plugin/README.md).
- For ComfyUI, enter the local address and choose a workflow under **Settings → ComfyUI**.
- For cross-device use, connect a destination on the cloud-sync page and carefully select what should be included.

## 🔒 Data and privacy

NAI Launcher does not host your account or artwork on a project-operated server. Data is sent to another service only when you actively use the related feature:

| Feature in use | Where the data goes |
| --- | --- |
| Generation, image-to-image, inpainting, Vibe encoding | NovelAI or the third-party image API site you explicitly configure, including the Prompt, parameters, and source or reference images required for that request. Third-party tokens are sent to the entered URL; use trusted services only. |
| Preview3 public pricing retrieval | Public `/api/pricing` on the exact origin `https://api.cunzaijiang.cn` only; no key, Cookie, Prompt, image, or generation. |
| Online gallery search and downloads | The third-party gallery you selected. Availability, rate limits, and content rules belong to each site. |
| AI translation or Agent Chat | The model service you configured. Conversations, attached images, and tool results required by the task may incur provider fees. |
| Sync and backup | Your selected Google Drive, OneDrive, GitHub, or WebDAV destination. Only explicitly selected content is uploaded. |

- NovelAI Tokens, OAuth access/refresh tokens, WebDAV passwords, and GitHub Tokens use device secure storage and are never written into backups.
- Local Prompts, gallery indexes, tags, resource libraries, and Agent sessions stay on the device by default.
- Cloud backups store selected data in plaintext. Local gallery image files are not uploaded; albums, categories, membership references, and fixed-tag usage records can sync as lightweight data.
- Online galleries can contain third-party content. Rating filters do not replace user judgment.
- WebDAV security depends on the server and transport you configure. Keep a local copy of important data.

## 🆘 Support and feedback

- If something goes wrong, use **Settings → About → Export diagnostic logs** and attach the exported information to your report.
- [Open a fork Issue](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues) for a reproducible bug or feature request. Remove tokens and other sensitive data before sharing logs.
- [Preview3 release (with dynamic pricing)](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.3) and verify checksums; read the [fork release notes](docs/releases/custom_api_preview.md) for changes. Preview3 is released and its assets have been verified; the current distribution only offers manual downloads from this fork, not in-app update installation.

## 🙏 Acknowledgments

Thanks to upstream author **Aaalice233** and [upstream NAI Launcher](https://github.com/Aaalice233/Aaalice_NAI_Launcher) for the original code, detailed feature descriptions, and interface screenshots. This fork is independently maintained by **cunzaijiang**, retaining the upstream **MIT License**, original copyright, and permission notices. Use this page for fork downloads and issues; do not report it as an official upstream release.

Thanks to [NovelAI](https://novelai.net/), [Codex Gallery](https://novelai.quicktagcloud.com/), [AgIzT/NovelAI-Tag](https://github.com/AgIzT/NovelAI-Tag), [Flutter](https://flutter.dev/), [Riverpod](https://riverpod.dev/), and all contributors and testers.

## 📄 License

This fork remains open source under the [MIT License](LICENSE), retaining upstream copyright and permission notices.
