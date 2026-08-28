import SwiftUI
import AppKit

public class FloatingWidgetWindowController: NSObject, ObservableObject {
    public static let shared = FloatingWidgetWindowController()
    
    public var window: NSWindow?
    
    public func showWindow() {
        if let win = window {
            if win.isVisible {
                win.orderOut(nil)
            } else {
                win.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }
        
        let win = NSWindow(
            contentRect: NSRect(x: 120, y: 120, width: 380, height: 160),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        win.level = .normal
        win.isMovableByWindowBackground = true
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = false
        
        win.standardWindowButton(.closeButton)?.isHidden = true
        win.standardWindowButton(.miniaturizeButton)?.isHidden = true
        win.standardWindowButton(.zoomButton)?.isHidden = true
        
        let contentView = WidgetContainerView()
        win.contentView = NSHostingView(rootView: contentView)
        
        win.center()
        win.makeKeyAndOrderFront(nil)
        self.window = win
    }
    
    public func resizeWindow(width: CGFloat, height: CGFloat) {
        guard let win = window else { return }
        let currentFrame = win.frame
        let newX = currentFrame.origin.x
        let newY = currentFrame.origin.y + (currentFrame.size.height - height) // Keep top-left anchored
        let newFrame = NSRect(x: newX, y: newY, width: width, height: height)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            win.animator().setFrame(newFrame, display: true)
        }
    }
    
    public func toggleVisibility() {
        showWindow()
    }
    
    public func hideWindow() {
        window?.orderOut(nil)
    }
}
