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

echo "🚀 7. Configuring Auto-Start on macOS Login (LaunchAgent)..."
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENT_DIR"
cat <<EOF > "$LAUNCH_AGENT_DIR/com.neonpulse.cicdwidget.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.neonpulse.cicdwidget</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>-a</string>
        <string>$APP_DIR</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo "✨ 8. Launching Host Application..."
pkill -f CICDWidget || true
open "$APP_DIR"

echo "✅ Success! Auto-start at Login configured and WidgetKit extension registered."
