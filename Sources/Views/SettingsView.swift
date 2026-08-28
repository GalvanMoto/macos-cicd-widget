import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject var settings: AppSettings = .shared
    @ObservedObject var authService: GitHubAuthService = .shared
    @ObservedObject var simulator: CISimulator = .shared
    @ObservedObject var apiService: GitHubAPIService = .shared
    
    var onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 32, height: 32)
                        TablerIcon(.settings, size: 16, color: .primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Widget Settings")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Configure GitHub Actions & Appearance")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color(nsColor: .separatorColor))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // SECTION 1: GITHUB ACCOUNT
                    SettingsSection(title: "GITHUB ACCOUNT") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(authService.account.isLoggedIn ? Color(red: 0.137, green: 0.525, blue: 0.212).opacity(0.15) : Color.secondary.opacity(0.15))
                                        .frame(width: 34, height: 34)
                                    TablerIcon(.brandGithub, size: 19, color: authService.account.isLoggedIn ? Color(red: 0.137, green: 0.525, blue: 0.212) : .secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(authService.account.isLoggedIn ? "Connected as @\(authService.account.username)" : "No GitHub CLI Account")
                                        .font(.system(size: 12.5, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(authService.account.isLoggedIn ? "Auto-monitoring all pushes & workflows" : "Run `gh auth login` in Terminal")
                                        .font(.system(size: 10.5))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    authService.checkSystemGitHubStatus()
                                    apiService.refresh(settings: settings)
                                }) {
                                    HStack(spacing: 4) {
                                        TablerIcon(.refresh, size: 10.5, color: .primary, isSpinning: authService.isChecking)
                                        Text("Refresh")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .focusable(false)
                            }
                            
                            Divider()
                            
                            Toggle(isOn: $settings.isAutoAccountWide) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Auto-Track Across All Repos")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("Shows whichever workflow is currently building or finished")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(.switch)
                        }
                    }
                    
                    // SECTION 2: WORKFLOW SOURCE
                    SettingsSection(title: "SOURCE MODE") {
                        VStack(spacing: 10) {
                            Picker("", selection: $settings.isSimulatorEnabled) {
                                Text("Live GitHub Actions").tag(false)
                                Text("Interactive Demo Simulator").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            
                            if settings.isSimulatorEnabled {
                                HStack(spacing: 6) {
                                    Button("▶ Run") { simulator.setSimulatedState(.inProgress) }
                                        .buttonStyle(.borderedProminent).tint(Color(red: 0.824, green: 0.600, blue: 0.133))
                                    
                                    Button("✓ Pass") { simulator.setSimulatedState(.success) }
                                        .buttonStyle(.borderedProminent).tint(Color(red: 0.137, green: 0.525, blue: 0.212))
                                    
                                    Button("✕ Fail") { simulator.setSimulatedState(.failure) }
                                        .buttonStyle(.borderedProminent).tint(Color(red: 0.855, green: 0.212, blue: 0.200))
                                    
                                    Button("⏱ Queue") { simulator.setSimulatedState(.queued) }
                                        .buttonStyle(.bordered)
                                }
                                .controlSize(.small)
                                .font(.system(size: 11, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    
                    // SECTION 3: APPEARANCE
                    SettingsSection(title: "APPEARANCE") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Theme")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Picker("", selection: $settings.theme) {
                                    ForEach(WidgetTheme.allCases) { theme in
                                        Text(theme.rawValue).tag(theme)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Layout Mode")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Picker("", selection: $settings.layoutMode) {
                                    ForEach(WidgetLayoutMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                            }
                        }
                    }
                    
                    // SECTION 4: NOTIFICATIONS
                    SettingsSection(title: "NOTIFICATIONS & AUDIO") {
                        Toggle(isOn: $settings.soundEffectsEnabled) {
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Play Audio Chimes on Build Pass / Fail")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Plays a subtle chime when build status updates")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(minWidth: 420, maxWidth: .infinity, minHeight: 440, maxHeight: .infinity)
    }
}

// Reusable Apple Grouped Section View
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
                .tracking(0.6)
            
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.65))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
