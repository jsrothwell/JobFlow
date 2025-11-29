import SwiftUI

struct DetailView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Background
            ThemeColors.backgroundDeep(for: themeManager.currentTheme)
            
            if let selectedJob = jobStore.selectedJob {
                // Job Details
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(selectedJob.title)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                                    
                                    Text(selectedJob.company)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                }
                                
                                Spacer()
                                
                                // Status Badge
                                Text(selectedJob.status.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedJob.status.color)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedJob.status.backgroundColor)
                                    .cornerRadius(8)
                            }
                            
                            // Meta information
                            HStack(spacing: 24) {
                                MetaItem(icon: "mappin.circle.fill", text: selectedJob.location)
                                MetaItem(icon: "dollarsign.circle.fill", text: selectedJob.salary)
                                MetaItem(icon: "calendar.circle.fill", text: "Applied \(selectedJob.dateString)")
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.4),
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Description Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Job Description")
                            
                            Text(selectedJob.description)
                                .font(.system(size: 15))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeColors.border(for: themeManager.currentTheme), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Notes")
                            
                            Text(selectedJob.notes)
                                .font(.system(size: 15))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeColors.border(for: themeManager.currentTheme), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Menu {
                                ForEach(ApplicationStatus.allCases, id: \.self) { status in
                                    Button(action: {
                                        jobStore.updateJobStatus(selectedJob, newStatus: status)
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(status.color)
                                                .frame(width: 8, height: 8)
                                            Text(status.rawValue)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Update Status")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                jobStore.editingJob = selectedJob
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Edit")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeColors.border(for: themeManager.currentTheme), lineWidth: 1)
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                jobStore.deleteJob(selectedJob)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Delete")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.19))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(red: 1.0, green: 0.23, blue: 0.19).opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 1.0, green: 0.23, blue: 0.19).opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(32)
                }
            } else {
                // Empty State with JobFlow Branding
                VStack(spacing: 32) {
                    VStack(spacing: 20) {
                        // JobFlow Logo
                        Image("JobFlowLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        
                        // JobFlow Branding
                        VStack(spacing: 8) {
                            Text("JobFlow")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            Text("Track Your Career Journey")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.accentBlue)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Text("Select an application to get started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        Text("Choose a job application from the sidebar\nto view details and track your progress")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Application Details")
    }
}

struct SectionHeader: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
    }
}

struct MetaItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.accentBlue)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
        }
    }
}

#Preview {
    DetailView()
        .environmentObject(JobStore())
        .frame(width: 800, height: 700)
}
