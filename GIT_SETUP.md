# ChatterBox iOS — Git Repository Setup

## What you have (download all files above)

```
ChatterBoxApp.swift         -> Sources/App/
AppDelegate.swift           -> Sources/App/
AppConfig.swift             -> Sources/App/
WebViewContainerFull.swift  -> Sources/WebView/WebViewContainer.swift
WebViewModel.swift          -> Sources/ViewModels/
SettingsViewModel.swift     -> Sources/ViewModels/
LoadingView.swift           -> Sources/Views/
ErrorView.swift             -> Sources/Views/
1_AppConfig_AppEntry_...md  -> reference docs (not in Xcode)
```

## Step 1 — Create directory structure

```bash
mkdir -p ChatterBox-iOS/ChatterBox/Sources/App
mkdir -p ChatterBox-iOS/ChatterBox/Sources/Views
mkdir -p ChatterBox-iOS/ChatterBox/Sources/ViewModels
mkdir -p ChatterBox-iOS/ChatterBox/Sources/Services
mkdir -p ChatterBox-iOS/ChatterBox/Sources/WebView
mkdir -p ChatterBox-iOS/ChatterBox/Resources/Assets.xcassets/AppIcon.appiconset
mkdir -p ChatterBox-iOS/ChatterBox/Resources/Assets.xcassets/LaunchBackground.colorset
mkdir -p ChatterBox-iOS/ChatterBox/Resources/Assets.xcassets/AccentColor.colorset
```

## Step 2 — Copy downloaded Swift files

```bash
cd ChatterBox-iOS

cp ~/Downloads/ChatterBoxApp.swift        ChatterBox/Sources/App/
cp ~/Downloads/AppDelegate.swift          ChatterBox/Sources/App/
cp ~/Downloads/AppConfig.swift            ChatterBox/Sources/App/
cp ~/Downloads/WebViewContainerFull.swift ChatterBox/Sources/WebView/WebViewContainer.swift
cp ~/Downloads/WebViewModel.swift         ChatterBox/Sources/ViewModels/
cp ~/Downloads/SettingsViewModel.swift    ChatterBox/Sources/ViewModels/
cp ~/Downloads/LoadingView.swift          ChatterBox/Sources/Views/
cp ~/Downloads/ErrorView.swift            ChatterBox/Sources/Views/
```

## Step 3 — Create Info.plist

Save as `ChatterBox/Resources/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key><string>ChatterBox</string>
    <key>CFBundleIdentifier</key><string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleShortVersionString</key><string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key><string>$(CURRENT_PROJECT_VERSION)</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>ChatterBox uses your microphone to record and transmit voice messages.</string>
    <key>UIBackgroundModes</key>
    <array><string>audio</string></array>
    <key>NSAppTransportSecurity</key>
    <dict><key>NSAllowsArbitraryLoads</key><false/></dict>
    <key>UILaunchScreen</key>
    <dict><key>UIColorName</key><string>LaunchBackground</string></dict>
    <key>UIRequiresFullScreen</key><true/>
    <key>UIStatusBarStyle</key><string>UIStatusBarStyleLightContent</string>
    <key>UIViewControllerBasedStatusBarAppearance</key><false/>
    <key>UISupportedInterfaceOrientations</key>
    <array><string>UIInterfaceOrientationPortrait</string></array>
    <key>MinimumOSVersion</key><string>16.0</string>
</dict>
</plist>
```

## Step 4 — Create Entitlements

Save as `ChatterBox/Resources/ChatterBox.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key><true/>
    <key>com.apple.security.network.client</key><true/>
    <key>com.apple.security.device.audio-input</key><true/>
</dict>
</plist>
```

## Step 5 — Create .gitignore

Save as `.gitignore` in project root:

```
*.xcworkspace/xcuserdata/
*.xcodeproj/xcuserdata/
DerivedData/
build/
*.ipa
*.dSYM.zip
xcuserdata/
.DS_Store
Secrets.swift
*.p12
*.p8
*.mobileprovision
.env
```

## Step 6 — Create Xcode project

```bash
# Open Xcode
open -a Xcode

# File > New > Project > iOS > App
# Product Name:             ChatterBox
# Organization Identifier: com.yourcompany
# Bundle Identifier:       com.yourcompany.chatterbox
# Interface:               SwiftUI
# Language:                Swift
# Deployment:              iOS 16.0
# Save inside: ChatterBox-iOS/
```

Delete the auto-generated ContentView.swift and App entry file.
Then drag all files from Sources/ and Resources/ into the Xcode navigator.

## Step 7 — Initialize git and push

```bash
cd ChatterBox-iOS
git init
git add .
git commit -m "feat: initial ChatterBox iOS wrapper

- WKWebView shell (remote URL strategy)
- AVAudioSession background audio for lock screen PTT
- Quiet Mode toggle with UserDefaults persistence
- JS bridge: window.nativeApp, __applyQuietMode
- LoadingView, ErrorView, SettingsView
- Info.plist: NSMicrophoneUsageDescription, UIBackgroundModes audio
- iOS 16.0+ deployment target"

# Push to GitHub (option A — GitHub CLI)
gh repo create chatterbox-ios --private --source=. --push

# Push to GitHub (option B — manual)
git remote add origin https://github.com/YOUR_ORG/chatterbox-ios.git
git branch -M main
git push -u origin main
```

## Final file tree

```
ChatterBox-iOS/
├── .gitignore
├── ChatterBox.xcodeproj/          (created by Xcode)
└── ChatterBox/
    ├── Sources/
    │   ├── App/
    │   │   ├── ChatterBoxApp.swift
    │   │   ├── AppDelegate.swift
    │   │   └── AppConfig.swift       <- EDIT remoteURL here
    │   ├── Views/
    │   │   ├── ContentView.swift
    │   │   ├── LoadingView.swift
    │   │   ├── ErrorView.swift
    │   │   └── SettingsView.swift
    │   ├── ViewModels/
    │   │   ├── WebViewModel.swift
    │   │   └── SettingsViewModel.swift
    │   ├── Services/
    │   │   └── AudioSessionManager.swift
    │   └── WebView/
    │       └── WebViewContainer.swift
    └── Resources/
        ├── Info.plist
        ├── ChatterBox.entitlements
        └── Assets.xcassets/
```
