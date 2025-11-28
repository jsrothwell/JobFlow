import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jobStore: JobStore
    
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
                }
            }
        }
        .background(Color(red: 0.12, green: 0.13, blue: 0.17))
        .sheet(isPresented: $jobStore.showingAddSheet) {
            JobFormView()
                .environmentObject(jobStore)
        }
        .sheet(item: $jobStore.editingJob) { job in
            JobFormView(job: job)
                .environmentObject(jobStore)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(JobStore())
        .frame(width: 1280, height: 800)
}
