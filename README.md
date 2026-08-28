# 🚀 GitHub CI/CD Pulse Widget for macOS

> A minimal, native macOS Desktop Widget & Menu Bar Companion built in **Swift & SwiftUI** that automatically monitors all GitHub Actions workflows across your entire account in real time.

---

## ✨ Features

- **🍏 Minimal Apple Design**:
  - Native **Apple System Dark Gray** palette adapting seamlessly to macOS Dark & Light modes.
  - Authentic continuous 22pt Apple squircle geometry, frosted glass vibrancy (`NSVisualEffectView`), and hairline borders.
  - Borderless, clean desktop widget with zero titlebar chrome.
- **⚡ Account-Wide Auto Workflow Tracking**:
  - Automatically queries and monitors pushes across **all repositories** in your GitHub account (`@me` / orgs).
  - Automatically surfaces whichever workflow is currently building or finished most recently without requiring manual configuration.
- **📡 Active Push Detection**:
  - Detects `git push` events within seconds and gives immediate visual feedback before and during GitHub Actions execution.
- **🔄 Animated Multi-Stage Pipeline DAG**:
  - Interactive stage tracker (`Setup` ➔ `Build` ➔ `Lint` ➔ `Test` ➔ `Deploy`) with live animated spinners and glowing node connections.
  - Real-time ticking runtime counter (`04:16`).
- **🎛️ Dynamic Menu Bar Companion**:
  - **Idle**: Clean GitHub Octocat icon.
  - **Running**: Animated amber spinner (`⟳`).
  - **Success**: Green tick checkmark (`✓`) + native macOS notification.
  - **Failed**: Red cross (`✕`) + failure notification.
- **🧩 Native Apple WidgetKit Extension**:
  - Includes a signed `WidgetKit` extension (`.appex`) compatible with **macOS Sonoma & Sequoia**.
  - Add directly to your Desktop or Notification Center via **"Edit Widgets..."** in **Small**, **Medium**, and **Large** sizes.
- **🎨 Tabler Vector Icons**:
  - Pure 2px-stroke vector Tabler icons for GitHub Octocat, Git Branch, Git Commit, PR, Check, Cross, Clock, and Settings.

---

## 🛠️ Architecture & Project Structure

```
widget-gh/
├── Package.swift                     # Swift Package Manager definition
├── App.entitlements                  # Sandboxing entitlements for host app
├── Extension.entitlements            # Sandboxing entitlements for WidgetKit
├── Info.plist                        # Host application bundle metadata
├── ExtensionInfo.plist               # WidgetKit extension bundle metadata
├── install.sh                        # Automated build, codesign & registration script
├── WidgetExtension/
│   └── CICDWidgetExtension.swift     # Native Apple WidgetKit Extension & TimelineProvider
└── Sources/
    ├── App/
    │   ├── Main.swift                # App entry point & accessory lifecycle
    │   ├── WindowController.swift    # Borderless floating HUD window & dynamic resizing
    │   └── MenuBarController.swift   # Dynamic menu bar icon & context menu
    ├── Models/
    │   ├── WorkflowRun.swift         # CI/CD run model, status colors, pipeline steps
    │   ├── WidgetTheme.swift         # Apple System Gray & GitHub dark themes
    │   └── AppSettings.swift         # User preferences & monitoring scope
    ├── Services/
    │   ├── GitHubAPIService.swift    # Account-wide GitHub REST API client & notifications
    │   ├── GitHubAuthService.swift   # Automatic `gh` CLI detection & keychain token reader
    │   ├── CISimulator.swift         # Real-time interactive demo pipeline simulator
    │   └── SoundEffects.swift        # Audio feedback manager
    └── Views/
        ├── WidgetContainerView.swift # Master container with fluid responsive resizing
        ├── CompactWidgetView.swift   # Mini pill widget mode
        ├── DetailedWidgetView.swift  # Full card visualizer with commit details
        ├── PipelineGraphView.swift   # Multi-stage animated pipeline graph
        ├── IdleStateView.swift       # Ultra-minimal ambient idle & active push view
        ├── EmptyStateView.swift      # Disconnected empty state & setup guide
        ├── SettingsView.swift        # Apple System Settings layout with grouped cards
        └── Components/
            ├── TablerIcons.swift     # 2px-stroke Tabler vector icons
            ├── PulsingGlowOrb.swift  # Rotating radar sweep & multi-layer glowing orb
            ├── LiveTimerView.swift   # Monospaced ticking duration counter
            ├── ParticleBurstView.swift # Celebration confetti & warning sparks
            └── VisualEffectBlur.swift # NSVisualEffectView glassmorphism wrapper
```

---

## 🚀 Quick Start & Installation

### Option 1: One-Click Build & Install
Clone the repository and run the installer script:
```bash
./install.sh
```
This will:
1. Build the optimized release binary (`swift build -c release`).
2. Compile and sign the **WidgetKit Extension** (`.appex`).
3. Package and install to `~/Applications/CICDWidget.app` and `/Applications/CICDWidget.app`.
4. Register the extension with macOS `LaunchServices` and refresh `chronod`.

---

## 🖥️ How to Add to your macOS Desktop

1. **Right-click** anywhere on your Desktop wallpaper.
2. Click **"Edit Widgets..."**.
3. Search for **"GitHub CI/CD"** in the sidebar.
4. Drag your preferred size (**Small**, **Medium**, or **Large**) onto your desktop!

---

## 📄 License
MIT License. Created by [GalvanMoto](https://github.com/GalvanMoto).
