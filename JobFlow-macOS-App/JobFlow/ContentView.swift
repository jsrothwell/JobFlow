import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 260, ideal: 280, max: 320)
        } detail: {
            ZStack {
                // Main content based on selected view
                switch jobStore.selectedView {
                case .list:
                    DetailView()
                case .timeline:
                    TimelineView()
                case .kanban:
                    KanbanView()
                case .path:
                    PathExplorationView()
                }
            }
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .sheet(isPresented: $jobStore.showingAddSheet) {
            JobFormView()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
        .sheet(item: $jobStore.editingJob) { job in
            JobFormView(job: job)
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(JobStore())
        .frame(width: 1280, height: 800)
}
