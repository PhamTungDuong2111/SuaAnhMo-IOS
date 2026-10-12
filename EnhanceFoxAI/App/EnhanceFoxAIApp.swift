import SwiftUI

@main
struct EnhanceFoxAIApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var photoManager = PhotoManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(localization)
                .environmentObject(photoManager)
                .preferredColorScheme(.dark)
        }
    }
}
