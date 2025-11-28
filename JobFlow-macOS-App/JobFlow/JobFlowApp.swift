import SwiftUI

@main
struct JobFlowApp: App {
    @StateObject private var jobStore = JobStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jobStore)
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class JobStore: ObservableObject {
    @Published var jobs: [JobApplication] = [
        JobApplication(
            title: "Director of Design",
            company: "Coinbase",
            status: .applied,
            dateApplied: Date(),
            description: "Lead the design team in creating innovative crypto products",
            salary: "$180,000 - $250,000",
            location: "San Francisco, CA",
            notes: "Great culture, strong design team"
        ),
        JobApplication(
            title: "Senior Product Designer",
            company: "Stripe",
            status: .interviewing,
            dateApplied: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            description: "Design payment experiences for millions of businesses",
            salary: "$170,000 - $230,000",
            location: "Remote",
            notes: "Second round interview scheduled for next week"
        ),
        JobApplication(
            title: "Lead UX Designer",
            company: "Airbnb",
            status: .applied,
            dateApplied: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
            description: "Shape the future of travel and hospitality",
            salary: "$160,000 - $220,000",
            location: "San Francisco, CA",
            notes: "Applied through referral"
        ),
        JobApplication(
            title: "Design Systems Lead",
            company: "Figma",
            status: .offer,
            dateApplied: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            description: "Build and maintain design system used by millions",
            salary: "$190,000 - $260,000",
            location: "San Francisco, CA",
            notes: "Offer received, negotiating compensation"
        ),
        JobApplication(
            title: "Principal Designer",
            company: "Apple",
            status: .applied,
            dateApplied: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            description: "Design next-generation hardware and software experiences",
            salary: "$200,000 - $280,000",
            location: "Cupertino, CA",
            notes: "Dream job!"
        )
    ]
    
    @Published var selectedJob: JobApplication?
    @Published var selectedView: ViewType = .list
    @Published var searchText: String = ""
    @Published var showingAddSheet = false
    @Published var editingJob: JobApplication?
    
    var filteredJobs: [JobApplication] {
        if searchText.isEmpty {
            return jobs.sorted { $0.dateApplied > $1.dateApplied }
        } else {
            return jobs.filter { job in
                job.title.localizedCaseInsensitiveContains(searchText) ||
                job.company.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateApplied > $1.dateApplied }
        }
    }
    
    // CRUD Operations
    func addJob(_ job: JobApplication) {
        jobs.append(job)
        selectedJob = job
    }
    
    func updateJob(_ job: JobApplication) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index] = job
            selectedJob = job
        }
    }
    
    func deleteJob(_ job: JobApplication) {
        jobs.removeAll { $0.id == job.id }
        if selectedJob?.id == job.id {
            selectedJob = nil
        }
    }
    
    func updateJobStatus(_ job: JobApplication, newStatus: ApplicationStatus) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index].status = newStatus
            selectedJob = jobs[index]
        }
    }
}

enum ViewType: String, CaseIterable {
    case list = "List"
    case timeline = "Timeline"
    case kanban = "Kanban"
}
