# Simple Anime

一个使用网络爬虫抓取精美动漫并在屏幕上展示的项目。

## 项目描述

本项目通过爬虫技术从网络上抓取动漫信息，并将其展示在应用中。支持多平台运行（Android、iOS、Web、Windows、macOS、Linux）。

## 功能特性

- **动漫展示**：抓取并展示精美的动漫图片和信息。
- **多平台支持**：支持 Android、iOS、Web、Windows、macOS 和 Linux。
- **本地存储**：使用 SQLite 和 SharedPreferences 存储数据。
- **通知功能**：集成 Firebase Messaging 和本地通知。
- **权限管理**：动态请求设备权限。
- **图片处理**：支持图片选择和保存到相册。

## 技术栈

- **Flutter**：跨平台应用开发框架。
- **Dio**：网络请求库。
- **SQLite**：本地数据库存储。
- **Firebase Messaging**：推送通知服务。
- **Logger**：日志记录工具。
- **Provider**：状态管理。

## 依赖项

### 主要依赖

- `flutter`: ^3.8.1
- `dio`: ^5.9.0
- `sqflite`: ^2.4.2
- `firebase_messaging`: ^16.0.0
- `logger`: ^2.6.1
- `provider`: ^6.1.5+1

完整依赖列表请查看 [pubspec.yaml](./pubspec.yaml)。

## 运行指南

### 环境准备

1. 确保已安装 Flutter SDK 和 Dart。
2. 运行 `flutter doctor` 检查环境配置。

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
flutter run
```

### 构建发布版本

```bash
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## 项目结构

```
simple_anime/
├── android/          # Android 平台代码
├── ios/             # iOS 平台代码
├── lib/             # 主应用代码
├── web/             # Web 平台代码
├── windows/         # Windows 平台代码
├── macos/           # macOS 平台代码
├── linux/           # Linux 平台代码
├── pubspec.yaml     # 项目依赖配置
└── README.md        # 项目说明文档
```

## 贡献指南

欢迎提交 Pull Request 或 Issue 来改进项目！

## 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](./LICENSE) 文件。
