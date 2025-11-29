import SwiftUI

@main
struct JobFlowApp: App {
    @StateObject private var jobStore = JobStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
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
    
    @Published var contacts: [Contact] = []
    
    @Published var selectedJob: JobApplication?
    @Published var selectedView: ViewType = .kanban // Changed to Kanban as default
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
    
    // CRUD Operations - Jobs
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
    
    // Interview Management
    func addInterview(_ interview: Interview, to job: JobApplication) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index].interviews.append(interview)
            selectedJob = jobs[index]
        }
    }
    
    func updateInterview(_ interview: Interview, in job: JobApplication) {
        if let jobIndex = jobs.firstIndex(where: { $0.id == job.id }),
           let interviewIndex = jobs[jobIndex].interviews.firstIndex(where: { $0.id == interview.id }) {
            jobs[jobIndex].interviews[interviewIndex] = interview
            selectedJob = jobs[jobIndex]
        }
    }
    
    func deleteInterview(_ interview: Interview, from job: JobApplication) {
        if let jobIndex = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[jobIndex].interviews.removeAll { $0.id == interview.id }
            selectedJob = jobs[jobIndex]
        }
    }
    
    // Contact Management
    func addContact(_ contact: Contact) {
        contacts.append(contact)
    }
    
    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        }
    }
    
    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        // Remove contact references from jobs
        for (index, job) in jobs.enumerated() {
            jobs[index].contactIDs.removeAll { $0 == contact.id }
        }
    }
    
    func getContact(byID id: UUID) -> Contact? {
        contacts.first { $0.id == id }
    }
    
    func getContacts(for job: JobApplication) -> [Contact] {
        job.contactIDs.compactMap { getContact(byID: $0) }
    }
    
    func linkContact(_ contact: Contact, to job: JobApplication) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }),
           !jobs[index].contactIDs.contains(contact.id) {
            jobs[index].contactIDs.append(contact.id)
            selectedJob = jobs[index]
        }
    }
    
    func unlinkContact(_ contact: Contact, from job: JobApplication) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index].contactIDs.removeAll { $0 == contact.id }
            selectedJob = jobs[index]
        }
    }
}

enum ViewType: String, CaseIterable {
    case list = "List"
    case timeline = "Timeline"
    case kanban = "Kanban"
    case path = "Path"
}
