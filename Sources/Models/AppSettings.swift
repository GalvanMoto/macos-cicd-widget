import SwiftUI
import Combine

public enum WidgetLayoutMode: String, CaseIterable, Codable, Identifiable {
    case compact = "Compact Pill"
    case detailed = "Detailed Card"
    case pipeline = "Pipeline Flow"
    
    public var id: String { rawValue }
}

public class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    @AppStorage("repoOwner") public var repoOwner: String = "GalvanMoto"
    @AppStorage("repoName") public var repoName: String = "Personal_OS"
    @AppStorage("githubToken") public var githubToken: String = ""
    @AppStorage("pollIntervalSeconds") public var pollIntervalSeconds: Double = 10.0
    @AppStorage("isSimulatorEnabled") public var isSimulatorEnabled: Bool = false
    @AppStorage("isAutoAccountWide") public var isAutoAccountWide: Bool = true
    @AppStorage("isAlwaysOnTop") public var isAlwaysOnTop: Bool = false
    @AppStorage("soundEffectsEnabled") public var soundEffectsEnabled: Bool = false // Disabled by default
    
    @Published public var theme: WidgetTheme = .appleSystem
    @Published public var layoutMode: WidgetLayoutMode = .pipeline
    
    private init() {}
    
    public var repositoryFullName: String {
        let o = repoOwner.trimmingCharacters(in: .whitespaces)
        let r = repoName.trimmingCharacters(in: .whitespaces)
        if o.isEmpty || r.isEmpty { return "" }
        return "\(o)/\(r)"
    }
}
