import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var sortedJobs: [JobApplication] {
        jobStore.filteredJobs.sorted { $0.dateApplied > $1.dateApplied }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(sortedJobs.enumerated()), id: \.element.id) { index, job in
                    TimelineItemView(
                        job: job,
                        isFirst: index == 0,
                        isLast: index == sortedJobs.count - 1,
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
            .padding(24)
        }
        .navigationTitle("Application Timeline")
    }
}

struct TimelineItemView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let job: JobApplication
    let isFirst: Bool
    let isLast: Bool
    let isSelected: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Timeline Line and Dot
            VStack(spacing: 0) {
                // Top line
                if !isFirst {
                    Rectangle()
                        .fill(ThemeColors.border(for: themeManager.currentTheme))
                        .frame(width: 2)
                        .frame(height: 30)
                }
                
                // Dot
                ZStack {
                    Circle()
                        .fill(job.status.color)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .stroke(ThemeColors.backgroundDeep(for: themeManager.currentTheme), lineWidth: 3)
                        .frame(width: 16, height: 16)
                    
                    if isSelected {
                        Circle()
                            .stroke(job.status.color.opacity(0.3), lineWidth: 8)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Bottom line
                if !isLast {
                    Rectangle()
                        .fill(ThemeColors.border(for: themeManager.currentTheme))
                        .frame(width: 2)
                        .frame(minHeight: 80)
                }
            }
            
            // Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Date
                Text(job.dateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                // Job Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Text(job.company)
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    
                    if !job.description.isEmpty {
                        Text(job.description)
                            .font(.system(size: 13))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                    
                    HStack(spacing: 12) {
                        // Status
                        HStack(spacing: 4) {
                            Circle()
                                .fill(job.status.color)
                                .frame(width: 8, height: 8)
                            
                            Text(job.status.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(job.status.color)
                        }
                        
                        if !job.location.isEmpty {
                            Text("•")
                                .foregroundColor(ThemeColors.textPlaceholder(for: themeManager.currentTheme))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 10))
                                Text(job.location)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                        
                        if !job.salary.isEmpty {
                            Text("•")
                                .foregroundColor(ThemeColors.textPlaceholder(for: themeManager.currentTheme))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 10))
                                Text(job.salary)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        if isSelected {
                            // Selected state
                            ThemeColors.accentBlue.opacity(themeManager.currentTheme == .dark ? 0.12 : 0.08)
                        } else {
                            // Normal state
                            ThemeColors.cardBackground(for: themeManager.currentTheme)
                        }
                        
                        if isSelected {
                            VStack {
                                LinearGradient(
                                    colors: [job.status.color, Color.clear],
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
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected
                                ? job.status.color.opacity(0.3)
                                : ThemeColors.border(for: themeManager.currentTheme),
                            lineWidth: 1
                        )
                )
                .cornerRadius(12)
            }
            .padding(.bottom, isLast ? 0 : 20)
        }
    }
}

#Preview {
    TimelineView()
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
        .frame(width: 800, height: 700)
}
