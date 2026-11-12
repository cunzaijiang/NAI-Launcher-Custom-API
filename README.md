# NAI Launcher 自定义 API 版

基于 Aaalice NAI Launcher 二次开发，支持自定义绘图接口，适用于 Android、Windows 和 macOS。

## 最新版下载

**Preview6 · 应用版本 4.3.1+47**

本次更新：修复大尺寸图片返回时可能出现的栈溢出错误。

- [安卓手机版（APK）](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.6/NAI_Launcher_Custom_API_Android_4.3.1-custom-api-preview.6.apk)
- [Windows 安装版](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.6/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.6_Setup.exe)
- [Windows 便携版](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.6/NAI_Launcher_Custom_API_Windows_4.3.1-custom-api-preview.6_Portable.zip)
- [Mac 版](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/download/custom-api-v4.3.1-preview.6/NAI_Launcher_Custom_API_macOS_4.3.1-custom-api-preview.6_Portable.zip)

[发布页面与校验文件](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/releases/tag/custom-api-v4.3.1-preview.6)

## 使用方法

1. 下载安装对应平台的客户端。
2. 在登录页选择“自定义接口”。
3. 填写接口地址、昵称和 API 密钥，验证后使用。

自定义接口使用 `/v1/chat/completions` 绘图协议，并非所有图片 API 都兼容。[查看接口说明](docs/custom_api.md)。

## 注意事项

- 更新需手动下载安装，安装前请备份本地数据。
- 安卓版可能无法覆盖不同签名的旧版本；目前有小米手机安装失败反馈，原因仍在排查，请勿直接卸载旧版。
- Windows 版未签名，Mac 版未公证，可能出现系统安全提示。
- 仅使用可信的接口服务，生成费用以服务商计费为准。

## 反馈

[提交问题](https://github.com/cunzaijiang/NAI-Launcher-Custom-API/issues) · [QQ 交流群](https://qm.qq.com/q/jY8Pshi5os)

## 致谢与许可

基于 [Aaalice233 的 NAI Launcher](https://github.com/Aaalice233/Aaalice_NAI_Launcher)，由 cunzaijiang 独立维护，非上游或 NovelAI 官方发行版。

遵循 [MIT 许可证](LICENSE)，保留原作者版权与许可声明。
