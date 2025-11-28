import SwiftUI

struct KanbanView: View {
    @EnvironmentObject var jobStore: JobStore
    
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
            .padding(24)
        }
        .background(Color(red: 0.12, green: 0.13, blue: 0.17))
    }
}

struct KanbanColumn: View {
    @EnvironmentObject var jobStore: JobStore
    let status: ApplicationStatus
    let jobs: [JobApplication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(status.color)
                        .frame(width: 10, height: 10)
                    
                    Text(status.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(jobs.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.4),
                        Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(10)
            
            // Cards Container
            ScrollView {
                VStack(spacing: 12) {
                    if jobs.isEmpty {
                        // Empty State
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 32))
                                .foregroundColor(Color.white.opacity(0.2))
                                .padding(.top, 40)
                            
                            Text("No applications")
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.bottom, 40)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(jobs) { job in
                            KanbanCard(job: job)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        jobStore.selectedJob = job
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .frame(height: 600)
        }
        .frame(width: 280)
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22).opacity(0.3),
                    Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct KanbanCard: View {
    @EnvironmentObject var jobStore: JobStore
    let job: JobApplication
    @State private var isHovered = false
    @State private var showingStatusMenu = false
    
    var isSelected: Bool {
        jobStore.selectedJob?.id == job.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text(job.company)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Spacer()
                
                Menu {
                    ForEach(ApplicationStatus.allCases, id: \.self) { status in
                        Button(action: {
                            jobStore.updateJobStatus(job, newStatus: status)
                        }) {
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 8, height: 8)
                                Text(status.rawValue)
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        jobStore.editingJob = job
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        jobStore.deleteJob(job)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                .buttonStyle(.plain)
                .opacity(isHovered || isSelected ? 1 : 0)
            }
            
            // Title
            Text(job.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Metadata
            VStack(alignment: .leading, spacing: 6) {
                if !job.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(job.location)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.white.opacity(0.5))
                }
                
                if !job.salary.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 10))
                        Text(job.salary)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.white.opacity(0.5))
                }
            }
            
            // Footer
            HStack {
                Text(job.dateString)
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.4))
                
                Spacer()
                
                if !job.notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
        }
        .padding(12)
        .background(
            ZStack {
                LinearGradient(
                    colors: isSelected
                        ? [
                            job.status.color.opacity(0.15),
                            job.status.color.opacity(0.08)
                        ]
                        : [
                            Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.4),
                            Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.25)
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
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected
                        ? job.status.color.opacity(0.4)
                        : Color.white.opacity(isHovered ? 0.15 : 0.08),
                    lineWidth: 1
                )
        )
        .cornerRadius(10)
        .shadow(
            color: isSelected ? job.status.color.opacity(0.2) : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    KanbanView()
        .environmentObject(JobStore())
        .frame(width: 1200, height: 700)
}
