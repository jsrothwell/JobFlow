import SwiftUI

@main
struct JobfloApp: App {
    @StateObject private var jobStore = JobStore()
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            JobsListView()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .tint(Color(hex: "007AFF"))
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        jobStore.importPendingJobs()
                    }
                }
        }
    }
}
