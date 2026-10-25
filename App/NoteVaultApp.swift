import SwiftUI

@main
struct NoteVaultApp: App {
    @StateObject private var store = AppDependencies.notes()
    @AppStorage("appearance") private var appearance = "dark"
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).tint(Design.accent)
                .preferredColorScheme(appearance == "system" ? nil : appearance == "light" ? .light : .dark)
        }
    }
}

