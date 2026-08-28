import AppKit
import SwiftUI
import Combine

public class MenuBarController: NSObject {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private var spinTimer: Timer?
    private var spinAngle: CGFloat = 0
    
    public func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = createGitHubOctocatIcon()
            button.target = self
            button.action = #selector(menuBarButtonClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Listen to live GitHub runs
        GitHubAPIService.shared.$currentRun
            .receive(on: RunLoop.main)
            .sink { [weak self] run in
                guard let self = self else { return }
                if !AppSettings.shared.isSimulatorEnabled {
                    self.updateMenuBarState(run: run)
                }
            }
            .store(in: &cancellables)
        
        // Listen to simulator runs
        CISimulator.shared.$simulatedRun
            .receive(on: RunLoop.main)
            .sink { [weak self] run in
                guard let self = self else { return }
                if AppSettings.shared.isSimulatorEnabled {
                    self.updateMenuBarState(run: run)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func menuBarButtonClicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showContextMenu()
        } else {
            FloatingWidgetWindowController.shared.toggleVisibility()
        }
    }
    
    public func updateMenuBarState(run: WorkflowRun?) {
        guard let button = statusItem?.button else { return }
        
        guard let currentRun = run else {
            // Pure Idle: GitHub Icon only
            stopSpinnerAnimation()
            button.image = createGitHubOctocatIcon()
            return
        }
        
        switch currentRun.status {
        case .inProgress:
            // Running: Animated Spinner
            startSpinnerAnimation()
            
        case .success:
            // Successful: Checkmark / Tick
            stopSpinnerAnimation()
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            if let check = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Build Passed")?.withSymbolConfiguration(config) {
                check.isTemplate = false
                button.image = check
            }
            
        case .failure:
            // Failed: Cross / Xmark
            stopSpinnerAnimation()
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            if let cross = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Build Failed")?.withSymbolConfiguration(config) {
                cross.isTemplate = false
                button.image = cross
            }
            
        case .queued, .waiting:
            stopSpinnerAnimation()
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            if let clock = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "Build Queued")?.withSymbolConfiguration(config) {
                button.image = clock
            }
            
        case .cancelled:
            stopSpinnerAnimation()
            button.image = createGitHubOctocatIcon()
        }
    }
    
    private func startSpinnerAnimation() {
        guard spinTimer == nil else { return }
        
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let button = self.statusItem?.button else { return }
            self.spinAngle += 30
            if self.spinAngle >= 360 { self.spinAngle = 0 }
            
            button.image = self.createRotatedSpinnerIcon(angle: self.spinAngle)
        }
    }
    
    private func stopSpinnerAnimation() {
        spinTimer?.invalidate()
        spinTimer = nil
        spinAngle = 0
    }
    
    // Draw vector GitHub Octocat icon for menu bar
    private func createGitHubOctocatIcon() -> NSImage {
        let size = NSSize(width: 17, height: 17)
        let image = NSImage(size: size, flipped: false) { rect in
            let path = NSBezierPath()
            
            // Tabler GitHub Octocat path scaled to 17x17
            let s: CGFloat = 17.0 / 24.0
            
            path.move(to: NSPoint(x: 9 * s, y: (24 - 19) * s))
            path.curve(to: NSPoint(x: 3 * s, y: (24 - 16) * s), controlPoint1: NSPoint(x: 4.7 * s, y: (24 - 20.4) * s), controlPoint2: NSPoint(x: 4.7 * s, y: (24 - 16.5) * s))
            path.move(to: NSPoint(x: 16 * s, y: (24 - 22) * s))
            path.line(to: NSPoint(x: 16 * s, y: (24 - 18.5) * s))
            path.curve(to: NSPoint(x: 15.5 * s, y: (24 - 16.5) * s), controlPoint1: NSPoint(x: 16 * s, y: (24 - 17.5) * s), controlPoint2: NSPoint(x: 16.1 * s, y: (24 - 17.1) * s))
            path.curve(to: NSPoint(x: 21 * s, y: (24 - 10.5) * s), controlPoint1: NSPoint(x: 18.3 * s, y: (24 - 16.2) * s), controlPoint2: NSPoint(x: 21 * s, y: (24 - 15.1) * s))
            path.curve(to: NSPoint(x: 19.7 * s, y: (24 - 7.3) * s), controlPoint1: NSPoint(x: 21 * s, y: (24 - 8.9) * s), controlPoint2: NSPoint(x: 20.5 * s, y: (24 - 7.8) * s))
            path.curve(to: NSPoint(x: 19.6 * s, y: (24 - 4.1) * s), controlPoint1: NSPoint(x: 19.7 * s, y: (24 - 6.5) * s), controlPoint2: NSPoint(x: 19.7 * s, y: (24 - 5.3) * s))
            path.curve(to: NSPoint(x: 16.1 * s, y: (24 - 5.4) * s), controlPoint1: NSPoint(x: 18.5 * s, y: (24 - 4.1) * s), controlPoint2: NSPoint(x: 16.1 * s, y: (24 - 5.4) * s))
            path.curve(to: NSPoint(x: 9.9 * s, y: (24 - 5.4) * s), controlPoint1: NSPoint(x: 14.1 * s, y: (24 - 4.8) * s), controlPoint2: NSPoint(x: 11.9 * s, y: (24 - 4.8) * s))
            path.curve(to: NSPoint(x: 6.4 * s, y: (24 - 4.1) * s), controlPoint1: NSPoint(x: 9.9 * s, y: (24 - 5.4) * s), controlPoint2: NSPoint(x: 7.5 * s, y: (24 - 4.1) * s))
            path.curve(to: NSPoint(x: 6.3 * s, y: (24 - 7.3) * s), controlPoint1: NSPoint(x: 6.3 * s, y: (24 - 5.3) * s), controlPoint2: NSPoint(x: 6.3 * s, y: (24 - 6.5) * s))
            path.curve(to: NSPoint(x: 5 * s, y: (24 - 10.5) * s), controlPoint1: NSPoint(x: 5.5 * s, y: (24 - 7.8) * s), controlPoint2: NSPoint(x: 5 * s, y: (24 - 8.9) * s))
            path.curve(to: NSPoint(x: 10.5 * s, y: (24 - 16.5) * s), controlPoint1: NSPoint(x: 5 * s, y: (24 - 15.1) * s), controlPoint2: NSPoint(x: 7.7 * s, y: (24 - 16.2) * s))
            path.curve(to: NSPoint(x: 10 * s, y: (24 - 18.5) * s), controlPoint1: NSPoint(x: 9.9 * s, y: (24 - 17.1) * s), controlPoint2: NSPoint(x: 10 * s, y: (24 - 17.5) * s))
            path.line(to: NSPoint(x: 10 * s, y: (24 - 22) * s))
            
            NSColor.labelColor.setStroke()
            path.lineWidth = 1.6
            path.lineCapStyle = .round
            path.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }
    
    // Draw animated spinner for menu bar
    private func createRotatedSpinnerIcon(angle: CGFloat) -> NSImage {
        let size = NSSize(width: 17, height: 17)
        let image = NSImage(size: size, flipped: false) { rect in
            let center = NSPoint(x: 8.5, y: 8.5)
            let path = NSBezierPath()
            path.appendArc(withCenter: center, radius: 6.5, startAngle: angle, endAngle: angle + 240, clockwise: false)
            
            NSColor.systemYellow.setStroke()
            path.lineWidth = 2.0
            path.lineCapStyle = .round
            path.stroke()
            return true
        }
        image.isTemplate = false
        return image
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Show / Hide Widget", action: #selector(toggleWidget), keyEquivalent: "w"))
        menu.addItem(NSMenuItem(title: "Check Status Now", action: #selector(refreshStatus), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit CI/CD Widget", action: #selector(quitApp), keyEquivalent: "q"))
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc private func toggleWidget() {
        FloatingWidgetWindowController.shared.toggleVisibility()
    }
    
    @objc private func refreshStatus() {
        GitHubAPIService.shared.refresh(settings: AppSettings.shared)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
