import SwiftUI
import AppKit

public struct WidgetContainerView: View {
    @ObservedObject var settings: AppSettings = .shared
    @ObservedObject var simulator: CISimulator = .shared
    @ObservedObject var apiService: GitHubAPIService = .shared
    @ObservedObject var authService: GitHubAuthService = .shared
    
    @State private var showingSettings: Bool = false
    @State private var isHovered: Bool = false
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    private var activeRun: WorkflowRun? {
        if settings.isSimulatorEnabled {
            return simulator.simulatedRun
        } else {
            return apiService.currentRun
        }
    }
    
    private var isCurrentlyBuilding: Bool {
        activeRun?.status.isRunning == true
    }
    
    private var currentTargetSize: CGSize {
        if showingSettings {
            return CGSize(width: 480, height: 490)
        } else if isCurrentlyBuilding {
            switch settings.layoutMode {
            case .compact: return CGSize(width: 380, height: 95)
            case .detailed, .pipeline: return CGSize(width: 400, height: 210)
            }
        } else {
            // Minimal Idle State
            return CGSize(width: 380, height: 135)
        }
    }
    
    public var body: some View {
        ZStack {
            // Apple Frosted Glass / HUD Base
            VisualEffectBlur(material: .popover, blendingMode: .behindWindow)
            
            // Theme / Apple System Dark Gray Background
            settings.theme.backgroundGradient
            
            // Particle Burst for Transitions
            if let run = activeRun {
                ParticleBurstView(triggerStatus: run.status)
            }
            
            if showingSettings {
                SettingsView {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showingSettings = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                VStack(spacing: 0) {
                    // Minimal Apple Widget Header
                    HStack(spacing: 6) {
                        TablerIcon(.brandGithub, size: 13, color: .primary)
                        
                        if isCurrentlyBuilding, let run = activeRun {
                            Circle()
                                .fill(run.status.primaryColor)
                                .frame(width: 6, height: 6)
                            
                            Text(run.repositoryName)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        } else {
                            Text("GitHub CI/CD")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                                .font(.system(size: 9))
                            
                            Text("Idle")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        if settings.isSimulatorEnabled {
                            Text("DEMO")
                                .font(.system(size: 7.5, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 3.5)
                                .padding(.vertical, 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.yellow)
                                )
                        }
                        
                        Spacer()
                        
                        // Controls (Refresh, GitHub Link, Settings, Close)
                        HStack(spacing: 6) {
                            if !settings.isSimulatorEnabled {
                                Button(action: {
                                    apiService.refresh(settings: settings)
                                }) {
                                    TablerIcon(.refresh, size: 11, color: .secondary, isSpinning: apiService.isLoading)
                                }
                                .buttonStyle(.plain)
                                .focusable(false)
                                .help("Refresh Status")
                            }
                            
                            if let run = activeRun, let url = run.htmlURL {
                                Button(action: {
                                    openURL(url)
                                }) {
                                    TablerIcon(.externalLink, size: 11, color: .secondary)
                                }
                                .buttonStyle(.plain)
                                .focusable(false)
                                .help("Open in GitHub Actions")
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    showingSettings = true
                                }
                            }) {
                                TablerIcon(.settings, size: 11, color: .secondary)
                            }
                            .buttonStyle(.plain)
                            .focusable(false)
                            .help("Widget Settings")
                            
                            Button(action: {
                                FloatingWidgetWindowController.shared.hideWindow()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .focusable(false)
                            .help("Close Window")
                        }
                        .opacity(isHovered ? 1.0 : 0.7)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    Divider()
                        .background(Color(nsColor: .separatorColor))
                    
                    // Main Body: Active Building Pipeline vs Idle / No Active Actions
                    Group {
                        if isCurrentlyBuilding, let run = activeRun {
                            switch settings.layoutMode {
                            case .compact:
                                CompactWidgetView(run: run, theme: settings.theme)
                            case .detailed, .pipeline:
                                DetailedWidgetView(run: run, theme: settings.theme)
                            }
                        } else if authService.account.isLoggedIn || settings.isSimulatorEnabled {
                            IdleStateView(
                                lastRun: activeRun,
                                recentPush: apiService.recentPush,
                                username: authService.account.username.isEmpty ? "GalvanMoto" : authService.account.username
                            )
                        } else {
                            EmptyStateView {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    showingSettings = true
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .frame(width: currentTargetSize.width, height: currentTargetSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(settings.theme.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15), radius: 16, x: 0, y: 6)
        .onHover { hovered in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovered
            }
        }
        .onAppear {
            authService.checkSystemGitHubStatus()
            if !settings.isSimulatorEnabled {
                apiService.startPolling(settings: settings)
            }
            updateWindowFrame()
        }
        .onChange(of: showingSettings) { _ in
            updateWindowFrame()
        }
        .onChange(of: isCurrentlyBuilding) { _ in
            updateWindowFrame()
        }
        .onChange(of: settings.layoutMode) { _ in
            updateWindowFrame()
        }
    }
    
    private func updateWindowFrame() {
        FloatingWidgetWindowController.shared.resizeWindow(
            width: currentTargetSize.width,
            height: currentTargetSize.height
        )
    }
}
