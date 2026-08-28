import SwiftUI
import AppKit

public enum WidgetTheme: String, CaseIterable, Codable, Identifiable {
    case appleSystem = "Apple System Gray"
    case githubDark = "GitHub Dark"
    case githubDimmed = "GitHub Dimmed"
    case cyberpunk = "Neon Cyber"
    
    public var id: String { rawValue }
    
    public var backgroundGradient: LinearGradient {
        switch self {
        case .appleSystem:
            // Apple System Dynamic Gray (Dark in Dark mode, Light in Light mode)
            return LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor).opacity(0.85),
                    Color(nsColor: .underPageBackgroundColor).opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .githubDark:
            return LinearGradient(
                colors: [
                    Color(red: 0.051, green: 0.067, blue: 0.090).opacity(0.95), // #0d1117
                    Color(red: 0.086, green: 0.106, blue: 0.133).opacity(0.95)  // #161b22
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .githubDimmed:
            return LinearGradient(
                colors: [
                    Color(red: 0.133, green: 0.157, blue: 0.192).opacity(0.95), // #22272e
                    Color(red: 0.110, green: 0.129, blue: 0.161).opacity(0.95)  // #1c2128
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cyberpunk:
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.14).opacity(0.92),
                    Color(red: 0.08, green: 0.03, blue: 0.18).opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    public var cardBackground: Color {
        switch self {
        case .appleSystem:
            return Color(nsColor: .controlBackgroundColor).opacity(0.65)
        case .githubDark:
            return Color(red: 0.129, green: 0.149, blue: 0.176).opacity(0.6)
        case .githubDimmed:
            return Color(red: 0.176, green: 0.208, blue: 0.247).opacity(0.6)
        case .cyberpunk:
            return Color.black.opacity(0.4)
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .appleSystem:
            return Color.accentColor
        case .githubDark:
            return Color(red: 0.345, green: 0.651, blue: 1.000)
        case .githubDimmed:
            return Color(red: 0.404, green: 0.686, blue: 1.000)
        case .cyberpunk:
            return Color(red: 0.0, green: 0.95, blue: 0.85)
        }
    }
    
    public var borderColor: Color {
        switch self {
        case .appleSystem:
            return Color(nsColor: .separatorColor).opacity(0.8)
        case .githubDark:
            return Color(red: 0.188, green: 0.212, blue: 0.239)
        case .githubDimmed:
            return Color(red: 0.267, green: 0.302, blue: 0.345)
        case .cyberpunk:
            return Color(red: 0.0, green: 0.95, blue: 0.85).opacity(0.4)
        }
    }
}
