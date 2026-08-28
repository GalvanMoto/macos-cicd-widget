import AppKit

public struct SoundEffects {
    public static func playSuccess() {
        guard AppSettings.shared.soundEffectsEnabled else { return }
        NSSound(named: "Glass")?.play()
    }
    
    public static func playFailure() {
        guard AppSettings.shared.soundEffectsEnabled else { return }
        NSSound(named: "Basso")?.play()
    }
}
