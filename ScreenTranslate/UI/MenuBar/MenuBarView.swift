import SwiftUI

struct MenuBarView: View {
    var body: some View {
        Button("번역하기") {
            AppOrchestrator.shared.startTranslation()
        }
        .keyboardShortcut("T", modifiers: [.control, .shift])

        Divider()

        SettingsLink {
            Text("설정...")
        }

        Divider()

        Button("ScreenTranslate 종료") {
            NSApplication.shared.terminate(nil)
        }
    }
}
