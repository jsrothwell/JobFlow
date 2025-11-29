import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    @State private var showingCalendarSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // JobFlow branding with logo
                    HStack(spacing: 10) {
                        Image("JobFlowLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                        
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
                
                // View Tabs
                HStack(spacing: 8) {
                    ForEach(ViewType.allCases, id: \.self) { viewType in
                        ViewTabButton(
                            title: viewType.rawValue,
                            isSelected: jobStore.selectedView == viewType
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                jobStore.selectedView = viewType
                            }
                        }
                    }
                }
                .padding(4)
                .background(ThemeColors.inputBackground(for: themeManager.currentTheme).opacity(themeManager.currentTheme == .dark ? 1 : 0.5))
                .cornerRadius(8)
            }
            .padding(20)
            .padding(.bottom, 4)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
            .overlay(
                Rectangle()
                    .fill(ThemeColors.borderSubtle(for: themeManager.currentTheme))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    .font(.system(size: 14))
                
                TextField("Search applications...", text: $jobStore.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    .font(.system(size: 13))
            }
            .padding(10)
            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ThemeColors.inputBorder(for: themeManager.currentTheme), lineWidth: 1)
            )
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                    .overlay(
                        Rectangle()
                            .fill(ThemeColors.borderSubtle(for: themeManager.currentTheme))
                            .frame(height: 1),
                        alignment: .bottom
                    )
            )
            
            // Calendar Settings Button
            Button(action: {
                showingCalendarSettings = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.gearshape")
                        .font(.system(size: 14))
                    Text("Calendar Settings")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                }
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                .padding(12)
                .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
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
                LazyVStack(spacing: 6) {
                    ForEach(jobStore.filteredJobs) { job in
                        JobItemView(
                            jobStore: jobStore,
                            job: job,
                            isSelected: jobStore.selectedJob?.id == job.id
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                jobStore.selectedJob = job
                            }
                        }
                        .onTapGesture(count: 2) {
                            // Double-click to edit
                            jobStore.editingJob = job
                        }
                    }
                }
                .padding(12)
            }
            .background(Color.clear)
        }
        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        .sheet(isPresented: $showingCalendarSettings) {
            CalendarSettingsView()
                .environmentObject(calendarManager)
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
    }
}

struct ViewTabButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : ThemeColors.textSecondary(for: themeManager.currentTheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? ThemeColors.accentBlue
                        : Color.clear
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct JobItemView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var jobStore: JobStore
    let job: JobApplication
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                .lineLimit(1)
            
            Text(job.company)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                .lineLimit(1)
            
            HStack {
                // Status Badge
                Text(job.status.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(job.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(job.status.backgroundColor)
                    .cornerRadius(6)
                
                Spacer()
                
                // Date
                Text(job.dateString)
                    .font(.system(size: 11))
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
            }
        }
        .padding(12)
        .background(
            ZStack {
                // Base background
                if isSelected {
                    ThemeColors.accentBlue.opacity(themeManager.currentTheme == .dark ? 0.12 : 0.08)
                } else {
                    ThemeColors.cardBackground(for: themeManager.currentTheme)
                }
                
                // Top accent line for selected item
                if isSelected {
                    VStack {
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 2)
                        
                        Spacer()
                    }
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected
                        ? ThemeColors.accentBlue.opacity(0.4)
                        : ThemeColors.border(for: themeManager.currentTheme),
                    lineWidth: 1
                )
        )
        .cornerRadius(10)
        .contextMenu {
            Button(action: {
                jobStore.editingJob = job
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                jobStore.deleteJob(job)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(JobStore())
        .frame(width: 280, height: 700)
}
