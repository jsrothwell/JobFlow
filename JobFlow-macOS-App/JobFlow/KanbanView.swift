import SwiftUI
import UniformTypeIdentifiers

struct KanbanView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
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
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}

struct KanbanColumn: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
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
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                }
                
                Spacer()
                
                Text("\(jobs.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ThemeColors.borderSubtle(for: themeManager.currentTheme))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ThemeColors.glassBackground(for: themeManager.currentTheme))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ThemeColors.border(for: themeManager.currentTheme), lineWidth: 1)
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
                                .foregroundColor(isTargeted ? status.color.opacity(0.8) : ThemeColors.textPlaceholder(for: themeManager.currentTheme))
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
        .background(ThemeColors.panelBackground(for: themeManager.currentTheme))
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
    @EnvironmentObject var themeManager: ThemeManager
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
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
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
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
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
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                
                if !job.salary.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 10))
                        Text(job.salary)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
            }
            
            // Footer
            HStack {
                Text(job.dateString)
                    .font(.system(size: 10))
                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                
                Spacer()
                
                HStack(spacing: 4) {
                    if !job.notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.system(size: 10))
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    }
                    
                    Image(systemName: "hand.draw")
                        .font(.system(size: 10))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme).opacity(isDragging ? 1 : (isHovered ? 0.7 : 0.5)))
                }
            }
        }
        .padding(12)
        .background(
            ZStack {
                if isSelected {
                    // Selected state
                    job.status.color.opacity(themeManager.currentTheme == .dark ? 0.12 : 0.08)
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
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected
                        ? job.status.color.opacity(0.4)
                        : ThemeColors.border(for: themeManager.currentTheme).opacity(isHovered ? 1.5 : 1.0),
                    lineWidth: 1
                )
        )
        .cornerRadius(10)
        .shadow(
            color: isSelected ? job.status.color.opacity(0.2) : ThemeColors.cardShadow(for: themeManager.currentTheme),
            radius: isSelected ? 8 : 4,
            x: 0,
            y: isSelected ? 4 : 2
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
