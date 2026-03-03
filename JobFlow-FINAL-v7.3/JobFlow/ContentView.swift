import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            TopBarView()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
                .environmentObject(calendarManager)
            
            // Main Content with Sidebar
            NavigationSplitView {
                SidebarView()
                    .navigationSplitViewColumnWidth(min: 260, ideal: 280, max: 320)
            } detail: {
                ZStack {
                    // Switch based on selected view
                    switch jobStore.selectedView {
                    case .list:
                        DetailView()
                    case .timeline:
                        TimelineView()
                    case .kanban:
                        KanbanView()
                    case .path:
                        PathExplorationView()
                    case .flow:
                        SankeyFlowView()
                    case .reports:
                        CustomReportsView()
                    case .reminders:
                        SmartRemindersView()
                    }
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
        .environmentObject(ThemeManager())
        .environmentObject(CalendarManager())
        .frame(width: 1280, height: 800)
}
