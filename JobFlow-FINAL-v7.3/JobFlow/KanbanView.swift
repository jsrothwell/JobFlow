import SwiftUI
import UniformTypeIdentifiers

struct KanbanView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var jobsByStatus: [ApplicationStatus: [JobApplication]] {
        Dictionary(grouping: jobStore.filteredJobs, by: { $0.status })
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(ApplicationStatus.allCases, id: \.self) { status in
                    KanbanColumn(
                        status: status,
                        jobs: jobsByStatus[status] ?? []
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}

struct KanbanColumn: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    let status: ApplicationStatus
    let jobs: [JobApplication]
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                Text(status.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Spacer()
                
                Text("\(jobs.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.color)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(12)
            
            // Cards with drop target
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(jobs) { job in
                        KanbanCard(job: job, status: status)
                            .onDrag {
                                NSItemProvider(object: job.id.uuidString as NSString)
                            }
                    }
                    
                    if jobs.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 32))
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            
                            Text("No jobs")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            }
            .onDrop(of: [UTType.text], isTargeted: $isTargeted) { providers in
                providers.first?.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                    guard let data = item as? Data,
                          let jobIdString = String(data: data, encoding: .utf8),
                          let jobId = UUID(uuidString: jobIdString) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let index = jobStore.jobs.firstIndex(where: { $0.id == jobId }) {
                            let oldStatus = jobStore.jobs[index].status
                            
                            // Update status
                            jobStore.jobs[index].status = status
                            
                            // Show toast with undo
                            jobStore.toastManager.show(
                                "Moved to \(status.rawValue)",
                                icon: "arrow.right.circle.fill",
                                onUndo: {
                                    if let idx = jobStore.jobs.firstIndex(where: { $0.id == jobId }) {
                                        jobStore.jobs[idx].status = oldStatus
                                    }
                                }
                            )
                            
                            // Add to undo stack
                            jobStore.performUndoableAction("Move to \(status.rawValue)") {
                                if let idx = jobStore.jobs.firstIndex(where: { $0.id == jobId }) {
                                    jobStore.jobs[idx].status = oldStatus
                                }
                            }
                        }
                    }
                }
                return true
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTargeted ? status.color.opacity(0.1) : Color.clear)
            )
        }
        .frame(width: 280)
    }
}

struct KanbanCard: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    let job: JobApplication
    let status: ApplicationStatus
    
    var isSelected: Bool {
        jobStore.selectedJob?.id == job.id
    }
    
    var body: some View {
        Button(action: {
            jobStore.selectedJob = job
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Company
                Text(job.company)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    .lineLimit(1)
                
                // Title
                Text(job.title)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .lineLimit(2)
                
                Divider()
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    if !job.salary.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.accentBlue)
                            Text(job.salary)
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                    }
                    
                    if !job.location.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.accentBlue)
                            Text(job.location)
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                .lineLimit(1)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.accentBlue)
                        Text(job.dateApplied.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    }
                    
                    if job.interviewCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.accentBlue)
                            Text("\(job.interviewCount) interview\(job.interviewCount == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? status.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(themeManager.currentTheme == .dark ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
