import SwiftUI

struct DetailView: View {
    @EnvironmentObject var jobStore: JobStore
    
    var body: some View {
        ZStack {
            // Background with subtle gradients
            Color(red: 0.12, green: 0.13, blue: 0.17)
                .overlay(
                    RadialGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.03),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .overlay(
                    RadialGradient(
                        colors: [
                            Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.02),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
            
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
                                        .foregroundColor(.white)
                                    
                                    Text(selectedJob.company)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.7))
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
                                .foregroundColor(Color.white.opacity(0.85))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.3),
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Notes")
                            
                            Text(selectedJob.notes)
                                .font(.system(size: 15))
                                .foregroundColor(Color.white.opacity(0.85))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.3),
                                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
                                .foregroundColor(Color.white.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
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
                // Empty State
                VStack(spacing: 16) {
                    ZStack {
                        // Frosted glass background
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
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
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
                        
                        // Document icon
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Select an application")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Choose a job application from the list\nto view details and track progress")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
    }
}

struct MetaItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.7))
        }
    }
}

#Preview {
    DetailView()
        .environmentObject(JobStore())
        .frame(width: 800, height: 700)
}
