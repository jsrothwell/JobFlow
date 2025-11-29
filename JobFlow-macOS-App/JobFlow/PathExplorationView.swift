import SwiftUI
import UniformTypeIdentifiers

struct PathExplorationView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingExportPanel = false
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundDeep(for: themeManager.currentTheme)
            
            VStack(spacing: 0) {
                // Header with Export Button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Application Flow")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        Text("Track how far your applications progressed")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    }
                    
                    Spacer()
                    
                    Button(action: exportVisualization) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                            Text("Export Image")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(ThemeColors.accentBlue)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .help("Export flow visualization as PNG image")
                }
                .padding(24)
                .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                
                // Sankey Flow Visualization
                ScrollView([.horizontal, .vertical]) {
                    SankeyFlowCanvas(jobs: jobStore.filteredJobs)
                        .environmentObject(themeManager)
                        .padding(60)
                }
            }
        }
    }
    
    private func exportVisualization() {
        let canvas = SankeyFlowCanvas(jobs: jobStore.filteredJobs)
            .environmentObject(themeManager)
            .frame(width: 1600, height: 900)
        
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 2.0
        
        if let nsImage = renderer.nsImage {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.png]
            savePanel.nameFieldStringValue = "JobFlow-Application-Flow-\(Date().formatted(date: .numeric, time: .omitted)).png"
            savePanel.title = "Export Application Flow"
            savePanel.message = "Choose where to save your application flow visualization"
            
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    if let tiffData = nsImage.tiffRepresentation,
                       let bitmapImage = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                        try? pngData.write(to: url)
                    }
                }
            }
        }
    }
}

struct SankeyFlowCanvas: View {
    let jobs: [JobApplication]
    @EnvironmentObject var themeManager: ThemeManager
    
    // Calculate flow statistics
    var flowStats: FlowStatistics {
        FlowStatistics(jobs: jobs)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
            
            if jobs.isEmpty {
                EmptyFlowState()
                    .environmentObject(themeManager)
            } else {
                SankeyDiagram(stats: flowStats)
                    .environmentObject(themeManager)
            }
        }
        .frame(width: 1600, height: 900)
    }
}

struct FlowStatistics {
    let applied: Int
    let interviewing: Int
    let offer: Int
    let rejected: Int
    let accepted: Int
    
    // Flow transitions
    let appliedToInterviewing: Int
    let appliedToRejected: Int
    let interviewingToOffer: Int
    let interviewingToRejected: Int
    let offerToAccepted: Int
    let offerToRejected: Int
    
    init(jobs: [JobApplication]) {
        // Count current statuses
        applied = jobs.filter { $0.status == .applied }.count
        interviewing = jobs.filter { $0.status == .interviewing }.count
        offer = jobs.filter { $0.status == .offer }.count
        rejected = jobs.filter { $0.status == .rejected }.count
        accepted = jobs.filter { $0.status == .accepted }.count
        
        // For flow visualization, we'll simulate the progression
        // In a real app, you'd track status history
        let total = jobs.count
        
        // Estimate flows (simplified model)
        appliedToInterviewing = interviewing + offer + accepted
        appliedToRejected = max(0, rejected - (interviewing + offer) / 3)
        interviewingToOffer = offer + accepted
        interviewingToRejected = max(0, interviewing / 3)
        offerToAccepted = accepted
        offerToRejected = max(0, offer / 4)
    }
    
    var totalApplications: Int {
        applied + interviewing + offer + rejected + accepted
    }
}

struct SankeyDiagram: View {
    let stats: FlowStatistics
    @EnvironmentObject var themeManager: ThemeManager
    
    let nodeWidth: CGFloat = 200
    let nodeSpacing: CGFloat = 350
    let canvasWidth: CGFloat = 1600
    let canvasHeight: CGFloat = 900
    
    var body: some View {
        ZStack {
            // Draw flows (behind nodes)
            FlowPath(
                from: nodePosition(column: 0, value: stats.totalApplications, maxValue: stats.totalApplications),
                fromHeight: nodeHeight(value: stats.totalApplications, maxValue: stats.totalApplications),
                to: nodePosition(column: 1, value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                toHeight: nodeHeight(value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                color: ApplicationStatus.interviewing.color,
                value: stats.appliedToInterviewing,
                total: stats.totalApplications
            )
            
            FlowPath(
                from: nodePosition(column: 0, value: stats.totalApplications, maxValue: stats.totalApplications),
                fromHeight: nodeHeight(value: stats.totalApplications, maxValue: stats.totalApplications),
                fromOffset: nodeHeight(value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                to: nodePosition(column: 1, value: stats.appliedToRejected, maxValue: stats.totalApplications, offset: stats.appliedToInterviewing + stats.interviewingToOffer),
                toHeight: nodeHeight(value: stats.appliedToRejected, maxValue: stats.totalApplications),
                color: ApplicationStatus.rejected.color,
                value: stats.appliedToRejected,
                total: stats.totalApplications
            )
            
            if stats.appliedToInterviewing > 0 {
                FlowPath(
                    from: nodePosition(column: 1, value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                    fromHeight: nodeHeight(value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                    to: nodePosition(column: 2, value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    toHeight: nodeHeight(value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    color: ApplicationStatus.offer.color,
                    value: stats.interviewingToOffer,
                    total: stats.totalApplications
                )
                
                FlowPath(
                    from: nodePosition(column: 1, value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                    fromHeight: nodeHeight(value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                    fromOffset: nodeHeight(value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    to: nodePosition(column: 2, value: stats.interviewingToRejected, maxValue: stats.totalApplications, offset: stats.interviewingToOffer),
                    toHeight: nodeHeight(value: stats.interviewingToRejected, maxValue: stats.totalApplications),
                    color: ApplicationStatus.rejected.color,
                    value: stats.interviewingToRejected,
                    total: stats.totalApplications
                )
            }
            
            if stats.interviewingToOffer > 0 {
                FlowPath(
                    from: nodePosition(column: 2, value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    fromHeight: nodeHeight(value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    to: nodePosition(column: 3, value: stats.offerToAccepted, maxValue: stats.totalApplications),
                    toHeight: nodeHeight(value: stats.offerToAccepted, maxValue: stats.totalApplications),
                    color: ApplicationStatus.accepted.color,
                    value: stats.offerToAccepted,
                    total: stats.totalApplications
                )
            }
            
            // Draw nodes (on top of flows)
            FlowNode(
                title: "Applied",
                count: stats.totalApplications,
                color: ApplicationStatus.applied.color,
                position: nodePosition(column: 0, value: stats.totalApplications, maxValue: stats.totalApplications),
                height: nodeHeight(value: stats.totalApplications, maxValue: stats.totalApplications)
            )
            .environmentObject(themeManager)
            
            if stats.appliedToInterviewing > 0 {
                FlowNode(
                    title: "Interviewing",
                    count: stats.appliedToInterviewing,
                    color: ApplicationStatus.interviewing.color,
                    position: nodePosition(column: 1, value: stats.appliedToInterviewing, maxValue: stats.totalApplications),
                    height: nodeHeight(value: stats.appliedToInterviewing, maxValue: stats.totalApplications)
                )
                .environmentObject(themeManager)
            }
            
            if stats.interviewingToOffer > 0 {
                FlowNode(
                    title: "Offer",
                    count: stats.interviewingToOffer,
                    color: ApplicationStatus.offer.color,
                    position: nodePosition(column: 2, value: stats.interviewingToOffer, maxValue: stats.totalApplications),
                    height: nodeHeight(value: stats.interviewingToOffer, maxValue: stats.totalApplications)
                )
                .environmentObject(themeManager)
            }
            
            if stats.offerToAccepted > 0 {
                FlowNode(
                    title: "Accepted",
                    count: stats.offerToAccepted,
                    color: ApplicationStatus.accepted.color,
                    position: nodePosition(column: 3, value: stats.offerToAccepted, maxValue: stats.totalApplications),
                    height: nodeHeight(value: stats.offerToAccepted, maxValue: stats.totalApplications)
                )
                .environmentObject(themeManager)
            }
            
            // Rejected node (bottom)
            if stats.rejected > 0 {
                FlowNode(
                    title: "Rejected",
                    count: stats.rejected,
                    color: ApplicationStatus.rejected.color,
                    position: CGPoint(x: canvasWidth / 2, y: canvasHeight - 100),
                    height: nodeHeight(value: stats.rejected, maxValue: stats.totalApplications)
                )
                .environmentObject(themeManager)
            }
            
            // Statistics summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Conversion Funnel")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                if stats.totalApplications > 0 {
                    StatRow(
                        label: "Interview Rate",
                        value: "\(Int(Double(stats.appliedToInterviewing) / Double(stats.totalApplications) * 100))%"
                    )
                    .environmentObject(themeManager)
                    
                    if stats.appliedToInterviewing > 0 {
                        StatRow(
                            label: "Offer Rate",
                            value: "\(Int(Double(stats.interviewingToOffer) / Double(stats.appliedToInterviewing) * 100))%"
                        )
                        .environmentObject(themeManager)
                    }
                    
                    if stats.interviewingToOffer > 0 {
                        StatRow(
                            label: "Acceptance Rate",
                            value: "\(Int(Double(stats.offerToAccepted) / Double(stats.interviewingToOffer) * 100))%"
                        )
                        .environmentObject(themeManager)
                    }
                }
            }
            .padding(20)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.border(for: themeManager.currentTheme), lineWidth: 1)
            )
            .position(x: 150, y: 100)
        }
    }
    
    private func nodePosition(column: Int, value: Int, maxValue: Int, offset: Int = 0) -> CGPoint {
        let x = 200 + CGFloat(column) * nodeSpacing
        let centerY = canvasHeight / 2
        let offsetY = CGFloat(offset) * (canvasHeight * 0.6 / CGFloat(maxValue))
        return CGPoint(x: x, y: centerY + offsetY - nodeHeight(value: value, maxValue: maxValue) / 2)
    }
    
    private func nodeHeight(value: Int, maxValue: Int) -> CGFloat {
        guard maxValue > 0 else { return 60 }
        let minHeight: CGFloat = 60
        let maxHeight: CGFloat = canvasHeight * 0.6
        let ratio = CGFloat(value) / CGFloat(maxValue)
        return max(minHeight, ratio * maxHeight)
    }
}

struct FlowNode: View {
    let title: String
    let count: Int
    let color: Color
    let position: CGPoint
    let height: CGFloat
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 180, height: height)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.5), lineWidth: 2)
        )
        .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 4)
        .position(position)
    }
}

struct FlowPath: View {
    let from: CGPoint
    let fromHeight: CGFloat
    let fromOffset: CGFloat
    let to: CGPoint
    let toHeight: CGFloat
    let color: Color
    let value: Int
    let total: Int
    
    init(from: CGPoint, fromHeight: CGFloat, fromOffset: CGFloat = 0, to: CGPoint, toHeight: CGFloat, color: Color, value: Int, total: Int) {
        self.from = from
        self.fromHeight = fromHeight
        self.fromOffset = fromOffset
        self.to = to
        self.toHeight = toHeight
        self.color = color
        self.value = value
        self.total = total
    }
    
    var flowHeight: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(value) / CGFloat(total) * fromHeight
    }
    
    var body: some View {
        Path { path in
            // Start from right edge of source node
            let startX = from.x + 90
            let startY = from.y + fromHeight / 2 + fromOffset
            
            // End at left edge of target node
            let endX = to.x - 90
            let endY = to.y + toHeight / 2
            
            // Control points for smooth curve
            let controlX = (startX + endX) / 2
            
            // Top curve
            path.move(to: CGPoint(x: startX, y: startY - flowHeight / 2))
            path.addCurve(
                to: CGPoint(x: endX, y: endY - flowHeight / 2),
                control1: CGPoint(x: controlX, y: startY - flowHeight / 2),
                control2: CGPoint(x: controlX, y: endY - flowHeight / 2)
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: endX, y: endY + flowHeight / 2))
            
            // Bottom curve (reverse)
            path.addCurve(
                to: CGPoint(x: startX, y: startY + flowHeight / 2),
                control1: CGPoint(x: controlX, y: endY + flowHeight / 2),
                control2: CGPoint(x: controlX, y: startY + flowHeight / 2)
            )
            
            path.closeSubpath()
        }
        .fill(color.opacity(0.4))
        .overlay(
            Path { path in
                let startX = from.x + 90
                let startY = from.y + fromHeight / 2 + fromOffset
                let endX = to.x - 90
                let endY = to.y + toHeight / 2
                let controlX = (startX + endX) / 2
                
                // Top border
                path.move(to: CGPoint(x: startX, y: startY - flowHeight / 2))
                path.addCurve(
                    to: CGPoint(x: endX, y: endY - flowHeight / 2),
                    control1: CGPoint(x: controlX, y: startY - flowHeight / 2),
                    control2: CGPoint(x: controlX, y: endY - flowHeight / 2)
                )
            }
            .stroke(color.opacity(0.6), lineWidth: 1)
        )
    }
}

struct StatRow: View {
    let label: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeColors.accentBlue)
        }
    }
}

struct EmptyFlowState: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 64))
                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
            
            Text("No Flow Data Yet")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            
            Text("Add job applications to see your conversion funnel")
                .font(.system(size: 16))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
        }
    }
}

#Preview {
    PathExplorationView()
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
        .frame(width: 1200, height: 800)
}
