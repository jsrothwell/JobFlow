import SwiftUI

struct JobsListView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager

    @State private var activeFilter: ApplicationStatus? = nil
    @State private var selectedJob: JobApplication? = nil
    @State private var showingAddSheet = false
    @State private var searchText = ""

    private var displayedJobs: [JobApplication] {
        jobStore.jobs
            .filter { job in
                let matchesFilter = activeFilter == nil || job.status == activeFilter
                let matchesSearch = searchText.isEmpty
                    || job.title.localizedCaseInsensitiveContains(searchText)
                    || job.company.localizedCaseInsensitiveContains(searchText)
                return matchesFilter && matchesSearch
            }
            .sorted { $0.dateApplied > $1.dateApplied }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                jobList
            }
            .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
            .navigationTitle("Jobflo")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search jobs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedJob) { job in
                JobDetailView(job: job)
                    .environmentObject(jobStore)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddJobView()
                    .environmentObject(jobStore)
                    .environmentObject(themeManager)
            }
            .refreshable {
                jobStore.importPendingJobs()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "All",
                    count: jobStore.jobs.count,
                    isActive: activeFilter == nil,
                    color: ThemeColors.accentBlue
                ) {
                    activeFilter = nil
                }

                ForEach(ApplicationStatus.allCases, id: \.self) { status in
                    FilterChip(
                        label: status.rawValue,
                        count: jobStore.jobs.filter { $0.status == status }.count,
                        isActive: activeFilter == status,
                        color: status.color
                    ) {
                        activeFilter = activeFilter == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }

    // MARK: - Job List

    @ViewBuilder
    private var jobList: some View {
        if displayedJobs.isEmpty {
            emptyState
        } else {
            List {
                ForEach(displayedJobs) { job in
                    JobRow(job: job, theme: themeManager.currentTheme)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedJob = job }
                        .listRowBackground(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .listRowSeparatorTint(ThemeColors.border(for: themeManager.currentTheme))
                }
                .onDelete { indexSet in
                    for i in indexSet { jobStore.deleteJob(displayedJobs[i]) }
                }
            }
            .listStyle(.plain)
            .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
            .scrollContentBackground(.hidden)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "briefcase.fill")
                .font(.system(size: 52))
                .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))

            if activeFilter == nil && searchText.isEmpty {
                Text("No jobs yet")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))
                Text("Share a job posting URL from Safari\nand it will appear here.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ThemeColors.textSecondary(for: themeManager.currentTheme))
            } else {
                Text("No results")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let count: Int
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline.weight(isActive ? .semibold : .regular))
                if count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(isActive ? Color.white.opacity(0.25) : color.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isActive ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isActive ? color : color.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Job Row

private struct JobRow: View {
    let job: JobApplication
    let theme: AppTheme

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            // Company initial circle
            ZStack {
                Circle()
                    .fill(job.status.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(String(job.company.prefix(1)).uppercased())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(job.status.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(job.company)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ThemeColors.textPrimary(for: theme))
                    .lineLimit(1)

                Text(job.title.isEmpty ? "Untitled Position" : job.title)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColors.textSecondary(for: theme))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: job.status)

                Text(Self.dateFormatter.string(from: job.dateApplied))
                    .font(.caption)
                    .foregroundStyle(ThemeColors.textTertiary(for: theme))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: ApplicationStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.medium))
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.color.opacity(0.12))
            .clipShape(Capsule())
    }
}
