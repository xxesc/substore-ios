import SwiftUI

@main
struct SubStoreApp: App {
    @StateObject private var config = AppConfig.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(config)
                .preferredColorScheme(nil)
        }
    }
}
