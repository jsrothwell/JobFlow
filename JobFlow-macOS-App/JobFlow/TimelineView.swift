import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var jobStore: JobStore
    
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
                }
            }
            .padding(24)
        }
    }
}

struct TimelineItemView: View {
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
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(height: 30)
                }
                
                // Dot
                ZStack {
                    Circle()
                        .fill(job.status.color)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .stroke(Color(red: 0.12, green: 0.13, blue: 0.17), lineWidth: 3)
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
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(minHeight: 80)
                }
            }
            
            // Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Date
                Text(job.dateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                // Job Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(job.company)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    if !job.description.isEmpty {
                        Text(job.description)
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.6))
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
                                .foregroundColor(Color.white.opacity(0.3))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 10))
                                Text(job.location)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(Color.white.opacity(0.5))
                        }
                        
                        if !job.salary.isEmpty {
                            Text("•")
                                .foregroundColor(Color.white.opacity(0.3))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 10))
                                Text(job.salary)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
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
                                : Color.white.opacity(0.08),
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
        .frame(width: 800, height: 700)
        .background(Color(red: 0.12, green: 0.13, blue: 0.17))
}
