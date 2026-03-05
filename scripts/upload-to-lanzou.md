# 蓝奏云上传操作指南

## 前置条件
- 蓝奏云 VIP 账号（免费版限制 100MB，VIP 可上传更大文件）
- 浏览器已登录蓝奏云

## 操作步骤

1. 从 GitHub Releases 下载本次发布的 APK 和 Windows ZIP
2. 登录 https://up.woozooo.com 或 https://pc.woozooo.com
3. 上传文件到指定文件夹（建议按版本号命名文件夹）
4. 设置提取码（4位字母数字）
5. 获取分享链接
6. 在 GitHub Actions 中手动触发 "Update Lanzou Links" workflow：
   - 填入版本号、各平台蓝奏云链接和提取码
   - 或直接编辑 `versions-manifest.json` 并提交

## 文件命名规范
- Android: `busic-android-v{version}.apk`
- Windows: `busic-windows-v{version}.zip`
