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
        
        // Estimate flows (simplified model based on current status counts)
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
    
    let canvasWidth: CGFloat = 1400
    let canvasHeight: CGFloat = 800
    let nodeWidth: CGFloat = 180
    let columnSpacing: CGFloat = 280
    
    var body: some View {
        ZStack {
            // Statistics summary - top left
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
            
            // Draw flows (background layer)
            if stats.totalApplications > 0 {
                // Applied to Interviewing and Rejected
                SankeyFlow(
                    fromX: 200,
                    fromY: canvasHeight / 2,
                    fromHeight: barHeight(value: stats.totalApplications),
                    toX: 480,
                    toY: canvasHeight / 2 - 150,
                    toHeight: barHeight(value: stats.appliedToInterviewing),
                    color: Color.purple.opacity(0.5)
                )
                
                SankeyFlow(
                    fromX: 200,
                    fromY: canvasHeight / 2,
                    fromHeight: barHeight(value: stats.totalApplications),
                    toX: 480,
                    toY: canvasHeight / 2 + 150,
                    toHeight: barHeight(value: stats.appliedToRejected),
                    fromOffset: barHeight(value: stats.appliedToInterviewing),
                    color: Color.red.opacity(0.5)
                )
                
                // Interviewing to Offer and Rejected
                if stats.appliedToInterviewing > 0 {
                    SankeyFlow(
                        fromX: 480,
                        fromY: canvasHeight / 2 - 150,
                        fromHeight: barHeight(value: stats.appliedToInterviewing),
                        toX: 760,
                        toY: canvasHeight / 2 - 200,
                        toHeight: barHeight(value: stats.interviewingToOffer),
                        color: Color.green.opacity(0.5)
                    )
                    
                    SankeyFlow(
                        fromX: 480,
                        fromY: canvasHeight / 2 - 150,
                        fromHeight: barHeight(value: stats.appliedToInterviewing),
                        toX: 760,
                        toY: canvasHeight / 2 + 150,
                        toHeight: barHeight(value: stats.interviewingToRejected),
                        fromOffset: barHeight(value: stats.interviewingToOffer),
                        color: Color.red.opacity(0.5)
                    )
                }
                
                // Offer to Accepted and Rejected
                if stats.interviewingToOffer > 0 {
                    SankeyFlow(
                        fromX: 760,
                        fromY: canvasHeight / 2 - 200,
                        fromHeight: barHeight(value: stats.interviewingToOffer),
                        toX: 1040,
                        toY: canvasHeight / 2 - 250,
                        toHeight: barHeight(value: stats.offerToAccepted),
                        color: Color.blue.opacity(0.5)
                    )
                    
                    if stats.offerToRejected > 0 {
                        SankeyFlow(
                            fromX: 760,
                            fromY: canvasHeight / 2 - 200,
                            fromHeight: barHeight(value: stats.interviewingToOffer),
                            toX: 1040,
                            toY: canvasHeight / 2 + 150,
                            toHeight: barHeight(value: stats.offerToRejected),
                            fromOffset: barHeight(value: stats.offerToAccepted),
                            color: Color.red.opacity(0.5)
                        )
                    }
                }
            }
            
            // Draw stage labels and bars (foreground layer)
            if stats.totalApplications > 0 {
                // Applied
                SankeyBar(
                    label: "Applied",
                    count: stats.totalApplications,
                    height: barHeight(value: stats.totalApplications),
                    color: Color.blue,
                    x: 200,
                    y: canvasHeight / 2
                )
                .environmentObject(themeManager)
                
                // Interviewing
                if stats.appliedToInterviewing > 0 {
                    SankeyBar(
                        label: "Interviewing",
                        count: stats.appliedToInterviewing,
                        height: barHeight(value: stats.appliedToInterviewing),
                        color: Color.purple,
                        x: 480,
                        y: canvasHeight / 2 - 150
                    )
                    .environmentObject(themeManager)
                }
                
                // Offer
                if stats.interviewingToOffer > 0 {
                    SankeyBar(
                        label: "Offer",
                        count: stats.interviewingToOffer,
                        height: barHeight(value: stats.interviewingToOffer),
                        color: Color.green,
                        x: 760,
                        y: canvasHeight / 2 - 200
                    )
                    .environmentObject(themeManager)
                }
                
                // Accepted
                if stats.offerToAccepted > 0 {
                    SankeyBar(
                        label: "Accepted",
                        count: stats.offerToAccepted,
                        height: barHeight(value: stats.offerToAccepted),
                        color: Color.blue,
                        x: 1040,
                        y: canvasHeight / 2 - 250
                    )
                    .environmentObject(themeManager)
                }
                
                // Rejected (at bottom, accumulated)
                if stats.rejected > 0 {
                    SankeyBar(
                        label: "Rejected",
                        count: stats.rejected,
                        height: barHeight(value: stats.rejected),
                        color: Color.red,
                        x: 760,
                        y: canvasHeight / 2 + 150
                    )
                    .environmentObject(themeManager)
                }
            }
        }
        .frame(width: canvasWidth, height: canvasHeight)
    }
    
    private func barHeight(value: Int) -> CGFloat {
        guard stats.totalApplications > 0 else { return 60 }
        let maxHeight: CGFloat = 400
        let minHeight: CGFloat = 40
        let ratio = CGFloat(value) / CGFloat(stats.totalApplications)
        return max(minHeight, ratio * maxHeight)
    }
}

struct SankeyBar: View {
    let label: String
    let count: Int
    let height: CGFloat
    let color: Color
    let x: CGFloat
    let y: CGFloat
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            
            ZStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 180, height: height)
                    .cornerRadius(6)
                
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .position(x: x, y: y)
    }
}

struct SankeyFlow: View {
    let fromX: CGFloat
    let fromY: CGFloat
    let fromHeight: CGFloat
    let toX: CGFloat
    let toY: CGFloat
    let toHeight: CGFloat
    var fromOffset: CGFloat = 0
    let color: Color
    
    var body: some View {
        Path { path in
            // Calculate start and end points
            let startX = fromX + 90 // Right edge of source bar
            let endX = toX - 90 // Left edge of target bar
            
            let startY = fromY + fromOffset
            let endY = toY
            
            let flowHeight = min(fromHeight - fromOffset, toHeight)
            
            // Control points for smooth curve
            let controlX = (startX + endX) / 2
            
            // Top curve
            path.move(to: CGPoint(x: startX, y: startY - fromHeight / 2 + fromOffset))
            path.addCurve(
                to: CGPoint(x: endX, y: endY - toHeight / 2),
                control1: CGPoint(x: controlX, y: startY - fromHeight / 2 + fromOffset),
                control2: CGPoint(x: controlX, y: endY - toHeight / 2)
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: endX, y: endY - toHeight / 2 + flowHeight))
            
            // Bottom curve
            path.addCurve(
                to: CGPoint(x: startX, y: startY - fromHeight / 2 + fromOffset + flowHeight),
                control1: CGPoint(x: controlX, y: endY - toHeight / 2 + flowHeight),
                control2: CGPoint(x: controlX, y: startY - fromHeight / 2 + fromOffset + flowHeight)
            )
            
            path.closeSubpath()
        }
        .fill(color)
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
