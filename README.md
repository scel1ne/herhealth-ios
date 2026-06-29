# HerHealth iOS

一个面向女性健康管理的 iOS 应用（Swift / SwiftUI）。

## 技术栈

- 语言：Swift
- 框架：SwiftUI
- 平台：iOS
- 集成：HealthKit

## 项目结构

```
HerHealth/
├── HerHealth/                  # 应用源码
│   ├── App/                    # App 入口、Info.plist
│   ├── Home/                   # 首页模块
│   ├── Chat/                   # AI 聊天
│   ├── Journal/                # 日记
│   ├── BodyCheck/              # 身体检查
│   ├── Stats/                  # 统计
│   ├── Learn/                  # 学习中心
│   ├── Quiz/                   # 测验
│   ├── Library/                # 内容库
│   ├── Calm/                   # 放松冥想
│   ├── Me/                     # 个人中心
│   ├── Settings/               # 设置
│   ├── Models/                 # 数据模型
│   ├── Components/             # 通用组件
│   ├── Theme/                  # 主题样式
│   └── Resources/              # 资源文件（图标、颜色）
├── HerHealth.xcodeproj/        # Xcode 工程文件
└── generate_pbxproj.py         # 工程文件生成脚本
```

## 开发

```bash
open HerHealth.xcodeproj
```

要求：
- Xcode 15+
- iOS 16+

## License

Private — All rights reserved.
