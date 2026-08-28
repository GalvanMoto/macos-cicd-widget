#!/usr/bin/env bash
set -e

APP_DIR="$HOME/Applications/CICDWidget.app"
PLUGINS_DIR="$APP_DIR/Contents/PlugIns/CICDWidgetExtension.appex"
SDK_PATH=$(xcrun --show-sdk-path)

echo "🚀 1. Building Host Application (Release)..."
swift build -c release

echo "⚡ 2. Compiling Apple WidgetKit Extension (.appex)..."
rm -rf "$APP_DIR"
mkdir -p "$PLUGINS_DIR/Contents/MacOS"
mkdir -p "$PLUGINS_DIR/Contents/Resources"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

swiftc \
  -O \
  -target arm64-apple-macos14.0 \
  -sdk "$SDK_PATH" \
  -framework WidgetKit \
  -framework SwiftUI \
  -framework AppKit \
  -framework Foundation \
  -o "$PLUGINS_DIR/Contents/MacOS/CICDWidgetExtension" \
  Sources/Models/WorkflowRun.swift \
  Sources/Views/Components/TablerIcons.swift \
  Sources/Views/Components/PulsingGlowOrb.swift \
  Sources/Views/Components/LiveTimerView.swift \
  Sources/Views/PipelineGraphView.swift \
  WidgetExtension/CICDWidgetExtension.swift

echo "📦 3. Packaging .app Bundle & Info.plist..."
cp -f .build/release/CICDWidget "$APP_DIR/Contents/MacOS/CICDWidget"
cp -f Info.plist "$APP_DIR/Contents/Info.plist"
cp -f ExtensionInfo.plist "$PLUGINS_DIR/Contents/Info.plist"

printf "APPL????" > "$APP_DIR/Contents/PkgInfo"
printf "XPC!????" > "$PLUGINS_DIR/Contents/PkgInfo"

echo "✍️ 4. Code Signing Bundle and WidgetKit Extension with App Sandbox..."
codesign -f -s - --entitlements Extension.entitlements --timestamp=none "$PLUGINS_DIR"
codesign -f -s - --entitlements App.entitlements --timestamp=none "$APP_DIR"
xattr -cr "$APP_DIR"

echo "🔄 5. Registering with macOS LaunchServices & PluginKit..."
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -f "$LSREGISTER" ]; then
  "$LSREGISTER" -f -r "$APP_DIR"
fi

pluginkit -a "$PLUGINS_DIR" || true
pluginkit -e use -i com.neonpulse.cicdwidget.extension || true

echo "🔄 6. Refreshing macOS Widget Daemon (chronod)..."
killall -9 chronod NotificationCenter 2>/dev/null || true
sleep 1

echo "✨ 7. Launching Host Application..."
pkill -f CICDWidget || true
open "$APP_DIR"

echo "✅ Success! WidgetKit extension is registered."
