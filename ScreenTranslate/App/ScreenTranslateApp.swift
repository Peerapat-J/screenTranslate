import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let translate = Self("translate", default: .init(.t, modifiers: [.control, .shift]))
}

@main
struct ScreenTranslateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppOrchestrator.shared.setup()
    }

    var body: some Scene {
        MenuBarExtra("ScreenTranslate", systemImage: "text.viewfinder") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
        }
    }
}

/// TranslationBridge를 상주시키기 위한 AppDelegate.
/// MenuBarExtra 콘텐츠는 메뉴가 열릴 때만 생성되므로,
/// TranslationBridge를 별도의 off-screen NSWindow에 호스팅한다.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var bridgeWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: TranslationBridgeView())
        window.orderOut(nil)  // 숨김 상태로 유지
        self.bridgeWindow = window
    }
}
