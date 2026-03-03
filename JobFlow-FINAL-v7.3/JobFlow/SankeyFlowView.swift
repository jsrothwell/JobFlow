import SwiftUI

struct SankeyFlowView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFilter: FlowFilter = .all
    
    enum FlowFilter: String, CaseIterable {
        case all = "All Applications"
        case lastMonth = "Last 30 Days"
        case lastQuarter = "Last 90 Days"
        case thisYear = "This Year"
    }
    
    var filteredJobs: [JobApplication] {
        let now = Date()
        switch selectedFilter {
        case .all:
            return jobStore.jobs
        case .lastMonth:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
            return jobStore.jobs.filter { $0.dateApplied >= thirtyDaysAgo }
        case .lastQuarter:
            let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: now)!
            return jobStore.jobs.filter { $0.dateApplied >= ninetyDaysAgo }
        case .thisYear:
            let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: now))!
            return jobStore.jobs.filter { $0.dateApplied >= startOfYear }
        }
    }
    
    // Flow statistics - using actual enum cases
    var flowStats: (applied: Int, interviewing: Int, offer: Int, accepted: Int, rejected: Int) {
        let jobs = filteredJobs
        return (
            applied: jobs.filter { $0.status == .applied }.count,
            interviewing: jobs.filter { $0.status == .interviewing }.count,
            offer: jobs.filter { $0.status == .offer }.count,
            accepted: jobs.filter { $0.status == .accepted }.count,
            rejected: jobs.filter { $0.status == .rejected }.count
        )
    }
    
    var conversionStats: (interview: Double, offer: Double, acceptance: Double) {
        let stats = flowStats
        let total = Double(filteredJobs.count)
        
        guard total > 0 else {
            return (0, 0, 0)
        }
        
        return (
            interview: (Double(stats.interviewing) / total) * 100,
            offer: (Double(stats.offer) / total) * 100,
            acceptance: (Double(stats.accepted) / total) * 100
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with filter
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Application Flow")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        Text("Track your job search journey")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    }
                    
                    Spacer()
                    
                    Picker("Time Period", selection: $selectedFilter) {
                        ForEach(FlowFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 180)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, 24)
                
                // Native Flow Visualization
                NativeFlowDiagram(stats: flowStats)
                    .frame(height: 400)
                    .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Conversion Metrics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Conversion Rates")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ConversionCard(
                            title: "To Interview",
                            percentage: conversionStats.interview,
                            color: .purple
                        )
                        
                        ConversionCard(
                            title: "To Offer",
                            percentage: conversionStats.offer,
                            color: .green
                        )
                        
                        ConversionCard(
                            title: "To Acceptance",
                            percentage: conversionStats.acceptance,
                            color: .mint
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Summary Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Summary")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Applications",
                            value: "\(filteredJobs.count)",
                            icon: "paperplane.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Active Processes",
                            value: "\(flowStats.applied + flowStats.interviewing)",
                            icon: "arrow.triangle.2.circlepath",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Rejected",
                            value: "\(flowStats.rejected)",
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.bottom, 24)
            }
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}

// Native Flow Diagram (macOS-compatible)
struct NativeFlowDiagram: View {
    let stats: (applied: Int, interviewing: Int, offer: Int, accepted: Int, rejected: Int)
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                
                VStack(spacing: 0) {
                    // Stage boxes
                    HStack(spacing: 20) {
                        FlowStageBox(title: "Applied", count: stats.applied, color: .blue, total: stats.applied + stats.interviewing + stats.offer + stats.accepted + stats.rejected)
                        FlowArrow()
                        FlowStageBox(title: "Interview", count: stats.interviewing, color: .purple, total: stats.applied + stats.interviewing + stats.offer + stats.accepted + stats.rejected)
                        FlowArrow()
                        FlowStageBox(title: "Offer", count: stats.offer, color: .green, total: stats.applied + stats.interviewing + stats.offer + stats.accepted + stats.rejected)
                        FlowArrow()
                        FlowStageBox(title: "Accepted", count: stats.accepted, color: .mint, total: stats.applied + stats.interviewing + stats.offer + stats.accepted + stats.rejected)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Rejection flow
                    HStack {
                        Spacer()
                        FlowStageBox(title: "Rejected", count: stats.rejected, color: .red, total: stats.applied + stats.interviewing + stats.offer + stats.accepted + stats.rejected)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

struct FlowStageBox: View {
    let title: String
    let count: Int
    let color: Color
    let total: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return (Double(count) / Double(total)) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
                
                VStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(String(format: "%.1f%%", percentage))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
            }
            .frame(width: 80, height: 80)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
        }
    }
}

struct FlowArrow: View {
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.gray)
    }
}

struct ConversionCard: View {
    let title: String
    let percentage: Double
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}
