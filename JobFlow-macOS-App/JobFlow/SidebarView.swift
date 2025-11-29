import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Applications")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
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
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }
            .padding(20)
            .padding(.bottom, 4)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.16, green: 0.18, blue: 0.22).opacity(0.95),
                        Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 14))
                
                TextField("Search applications...", text: $jobStore.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
            }
            .padding(10)
            .background(Color.black.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.02))
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1),
                        alignment: .bottom
                    )
            )
            
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
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22).opacity(0.4),
                    Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct ViewTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : Color.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color(red: 0.0, green: 0.48, blue: 1.0)
                        : Color.clear
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct JobItemView: View {
    @ObservedObject var jobStore: JobStore
    let job: JobApplication
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(job.company)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.6))
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
                    .foregroundColor(Color.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: isSelected
                        ? [
                            Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15),
                            Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.08)
                        ]
                        : [
                            Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.3),
                            Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.2)
                        ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
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
                        ? Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.4)
                        : Color.white.opacity(0.1),
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
