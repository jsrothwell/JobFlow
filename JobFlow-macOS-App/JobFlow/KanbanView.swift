import SwiftUI
import UniformTypeIdentifiers

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
    @State private var isTargeted = false
    
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
            
            // Cards Container with Drop Zone
            ScrollView {
                VStack(spacing: 12) {
                    if jobs.isEmpty {
                        // Empty State with Drop Zone
                        VStack(spacing: 8) {
                            Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "tray")
                                .font(.system(size: 32))
                                .foregroundColor(isTargeted ? status.color.opacity(0.6) : Color.white.opacity(0.2))
                            
                            Text(isTargeted ? "Drop here" : "No applications")
                                .font(.system(size: 13))
                                .foregroundColor(isTargeted ? status.color.opacity(0.8) : Color.white.opacity(0.4))
                                .padding(.bottom, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isTargeted ? status.color.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isTargeted ? status.color.opacity(0.5) : Color.clear, lineWidth: 2)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: isTargeted ? [5, 5] : []))
                                )
                        )
                    } else {
                        ForEach(jobs) { job in
                            KanbanCard(job: job)
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
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .frame(height: 600)
            .onDrop(of: [UTType.text], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
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
                .stroke(
                    isTargeted ? status.color.opacity(0.5) : Color.white.opacity(0.08),
                    lineWidth: isTargeted ? 2 : 1
                )
        )
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            guard let data = data as? Data,
                  let jobId = String(data: data, encoding: .utf8),
                  let uuid = UUID(uuidString: jobId),
                  let job = jobStore.jobs.first(where: { $0.id == uuid }) else {
                return
            }
            
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    jobStore.updateJobStatus(job, newStatus: status)
                }
            }
        }
        
        return true
    }
}

struct KanbanCard: View {
    @EnvironmentObject var jobStore: JobStore
    let job: JobApplication
    @State private var isHovered = false
    @State private var isDragging = false
    
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                jobStore.updateJobStatus(job, newStatus: status)
                            }
                        }) {
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 8, height: 8)
                                Text(status.rawValue)
                                    .foregroundColor(.white)
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
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(isHovered || isSelected ? 0.7 : 0.4))
                }
                .buttonStyle(.plain)
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
                    .foregroundColor(Color.white.opacity(0.6))
                }
                
                if !job.salary.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 10))
                        Text(job.salary)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.white.opacity(0.6))
                }
            }
            
            // Footer
            HStack {
                Text(job.dateString)
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.5))
                
                Spacer()
                
                HStack(spacing: 4) {
                    if !job.notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    
                    Image(systemName: "hand.draw")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(isDragging ? 0.8 : (isHovered ? 0.5 : 0.3)))
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
        .scaleEffect(isDragging ? 0.95 : (isHovered ? 1.02 : 1.0))
        .opacity(isDragging ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isDragging)
        .onHover { hovering in
            isHovered = hovering
        }
        .onDrag {
            isDragging = true
            
            // Reset dragging state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isDragging = false
            }
            
            return NSItemProvider(object: job.id.uuidString as NSString)
        }
    }
}

#Preview {
    KanbanView()
        .environmentObject(JobStore())
        .frame(width: 1200, height: 700)
}
