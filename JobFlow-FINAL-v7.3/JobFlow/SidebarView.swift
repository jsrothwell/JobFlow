import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with branding
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // JobFlow branding
                    HStack(spacing: 10) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("JobFlow")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            Text("Applications")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                    }
                    
                    Spacer()
                    
                    // Theme Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.toggle()
                        }
                    }) {
                        Image(systemName: themeManager.currentTheme == .dark ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 18))
                            .foregroundColor(ThemeColors.accentBlue)
                    }
                    .buttonStyle(.plain)
                    .help(themeManager.currentTheme == .dark ? "Switch to Light Mode" : "Switch to Dark Mode")
                    
                    // Add Button
                    Button(action: {
                        jobStore.showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    }
                    .buttonStyle(.plain)
                }
                

            }
            .padding(20)
            
            Divider()
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                
                TextField("Search jobs...", text: $jobStore.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                if !jobStore.searchText.isEmpty {
                    Button(action: {
                        jobStore.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Upcoming Interviews Widget
            UpcomingInterviewsWidget()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
                .padding(.horizontal, 20)
                .padding(.top, 12)
            
            // Job List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(jobStore.filteredJobs) { job in
                        JobListItem(job: job)
                            .environmentObject(jobStore)
                            .environmentObject(themeManager)
                    }
                }
                .padding(20)
            }
        }
        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
    }
}

struct JobListItem: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    let job: JobApplication
    
    var isSelected: Bool {
        jobStore.selectedJob?.id == job.id
    }
    
    var body: some View {
        Button(action: {
            jobStore.selectedJob = job
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(job.company)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    StatusBadge(status: job.status)
                }
                
                Text(job.title)
                    .font(.system(size: 12))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(job.dateApplied.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11))
                }
                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? ThemeColors.accentBlue.opacity(0.15) : ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? ThemeColors.accentBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    @EnvironmentObject var themeManager: ThemeManager
    let status: ApplicationStatus
    
    var statusColor: Color {
        switch status {
        case .applied: return .blue
        case .interviewing: return .purple
        case .offer: return .green
        case .rejected: return .red
        case .accepted: return .mint
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(6)
    }
}
