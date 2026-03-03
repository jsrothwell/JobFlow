import SwiftUI

struct CustomReportsView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedReport: ReportType = .weeklyProgress
    @State private var dateRange: DateRangeOption = .lastWeek
    @State private var includeCharts = true
    @State private var includeStats = true
    @State private var includeDetails = false
    @State private var showingExportSheet = false
    
    enum ReportType: String, CaseIterable {
        case weeklyProgress = "Weekly Progress"
        case monthlyAnalysis = "Monthly Analysis"
        case conversionFunnel = "Conversion Funnel"
        case interviewPerformance = "Interview Performance"
        case companyBreakdown = "Company Breakdown"
        case timeToResponse = "Response Time Analysis"
    }
    
    enum DateRangeOption: String, CaseIterable {
        case lastWeek = "Last 7 Days"
        case lastMonth = "Last 30 Days"
        case lastQuarter = "Last 90 Days"
        case thisYear = "This Year"
        case allTime = "All Time"
        
        var dateRange: (start: Date, end: Date) {
            let now = Date()
            let calendar = Calendar.current
            switch self {
            case .lastWeek:
                return (calendar.date(byAdding: .day, value: -7, to: now)!, now)
            case .lastMonth:
                return (calendar.date(byAdding: .day, value: -30, to: now)!, now)
            case .lastQuarter:
                return (calendar.date(byAdding: .day, value: -90, to: now)!, now)
            case .thisYear:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return (startOfYear, now)
            case .allTime:
                return (Date.distantPast, now)
            }
        }
    }
    
    var filteredJobs: [JobApplication] {
        let range = dateRange.dateRange
        return jobStore.jobs.filter { job in
            job.dateApplied >= range.start && job.dateApplied <= range.end
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Custom Reports")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Text("Generate detailed insights about your job search")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                
                Spacer()
                
                Button(action: {
                    showingExportSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Report")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Configuration Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Report Configuration")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        VStack(spacing: 12) {
                            // Report Type
                            HStack {
                                Text("Report Type")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                    .frame(width: 140, alignment: .leading)
                                
                                Picker("Report Type", selection: $selectedReport) {
                                    ForEach(ReportType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 240)
                            }
                            
                            // Date Range
                            HStack {
                                Text("Date Range")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                    .frame(width: 140, alignment: .leading)
                                
                                Picker("Date Range", selection: $dateRange) {
                                    ForEach(DateRangeOption.allCases, id: \.self) { range in
                                        Text(range.rawValue).tag(range)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 240)
                            }
                            
                            Divider()
                            
                            // Options
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Include Charts & Visualizations", isOn: $includeCharts)
                                Toggle("Include Statistical Summary", isOn: $includeStats)
                                Toggle("Include Application Details", isOn: $includeDetails)
                            }
                            .font(.system(size: 14))
                        }
                        .padding(20)
                        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    // Report Preview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Report Preview")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        reportContent
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
            }
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .sheet(isPresented: $showingExportSheet) {
            ExportReportView(
                reportType: selectedReport,
                dateRange: dateRange,
                jobs: filteredJobs,
                includeCharts: includeCharts,
                includeStats: includeStats,
                includeDetails: includeDetails
            )
            .environmentObject(jobStore)
            .environmentObject(themeManager)
        }
    }
    
    @ViewBuilder
    var reportContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch selectedReport {
            case .weeklyProgress:
                WeeklyProgressReport(jobs: filteredJobs, includeCharts: includeCharts, includeStats: includeStats, includeDetails: includeDetails)
            case .monthlyAnalysis:
                MonthlyAnalysisReport(jobs: filteredJobs, includeCharts: includeCharts, includeStats: includeStats, includeDetails: includeDetails)
            case .conversionFunnel:
                ConversionFunnelReport(jobs: filteredJobs, includeCharts: includeCharts, includeStats: includeStats)
            case .interviewPerformance:
                InterviewPerformanceReport(jobs: filteredJobs, includeCharts: includeCharts, includeStats: includeStats, includeDetails: includeDetails)
            case .companyBreakdown:
                CompanyBreakdownReport(jobs: filteredJobs, includeStats: includeStats, includeDetails: includeDetails)
            case .timeToResponse:
                TimeToResponseReport(jobs: filteredJobs, includeCharts: includeCharts, includeStats: includeStats)
            }
        }
        .padding(24)
        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

// MARK: - Weekly Progress Report
struct WeeklyProgressReport: View {
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    let includeDetails: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Progress Report")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Text("Activity summary for the selected period")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }
            
            if includeStats {
                // Key Metrics
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    MetricCard(title: "Applications", value: "\(jobs.count)", icon: "doc.text.fill", color: .blue)
                    MetricCard(title: "Interviews", value: "\(jobs.flatMap { $0.interviews }.count)", icon: "person.2.fill", color: .purple)
                    MetricCard(title: "Offers", value: "\(jobs.filter { $0.status == .offer || $0.status == .accepted }.count)", icon: "star.fill", color: .green)
                    MetricCard(title: "Rejections", value: "\(jobs.filter { $0.status == .rejected }.count)", icon: "xmark.circle.fill", color: .red)
                }
            }
            
            if includeDetails {
                // Recent Applications
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Applications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    ForEach(jobs.prefix(5)) { job in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.company)
                                    .font(.system(size: 14, weight: .medium))
                                Text(job.title)
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            }
                            Spacer()
                            Text(job.status.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(job.status.color.opacity(0.2))
                                .foregroundColor(job.status.color)
                                .cornerRadius(6)
                        }
                        .padding(12)
                        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Monthly Analysis Report
struct MonthlyAnalysisReport: View {
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    let includeDetails: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var trendsData: [(week: String, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: jobs) { job in
            calendar.component(.weekOfYear, from: job.dateApplied)
        }
        return grouped.sorted { $0.key < $1.key }.map { ("Week \($0.key)", $0.value.count) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Monthly Analysis Report")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            
            if includeStats {
                // Trends
                VStack(alignment: .leading, spacing: 12) {
                    Text("Application Trends")
                        .font(.system(size: 16, weight: .semibold))
                    
                    ForEach(trendsData, id: \.week) { data in
                        HStack {
                            Text(data.week)
                                .font(.system(size: 14))
                                .frame(width: 100, alignment: .leading)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(height: 24)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue)
                                    .frame(width: CGFloat(data.count) * 20, height: 24)
                                
                                Text("\(data.count)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Other Report Types (simplified for brevity)
struct ConversionFunnelReport: View {
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Conversion Funnel Report")
                .font(.system(size: 22, weight: .bold))
            
            // Funnel visualization would go here
            Text("Applied: \(jobs.count) → Screening: \(jobs.filter { $0.status == .applied }.count) → Interviewing: \(jobs.filter { $0.status == .interviewing }.count) → Offered: \(jobs.filter { $0.status == .offer }.count)")
                .font(.system(size: 14))
        }
    }
}

struct InterviewPerformanceReport: View {
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    let includeDetails: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Interview Performance Report")
                .font(.system(size: 22, weight: .bold))
            
            let totalInterviews = jobs.flatMap { $0.interviews }.count
            let passedInterviews = jobs.flatMap { $0.interviews }.filter { $0.outcome == .passed }.count
            
            if includeStats {
                Text("Success Rate: \(totalInterviews > 0 ? String(format: "%.1f%%", Double(passedInterviews) / Double(totalInterviews) * 100) : "N/A")")
                    .font(.system(size: 16))
            }
        }
    }
}

struct CompanyBreakdownReport: View {
    let jobs: [JobApplication]
    let includeStats: Bool
    let includeDetails: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Company Breakdown Report")
                .font(.system(size: 22, weight: .bold))
            
            if includeDetails {
                let companies = Dictionary(grouping: jobs, by: { $0.company })
                ForEach(companies.keys.sorted(), id: \.self) { company in
                    HStack {
                        Text(company)
                        Spacer()
                        Text("\(companies[company]?.count ?? 0) applications")
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
}

struct TimeToResponseReport: View {
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Response Time Analysis")
                .font(.system(size: 22, weight: .bold))
            
            Text("Average response time and patterns")
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

// MARK: - Export Report View
struct ExportReportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    let reportType: CustomReportsView.ReportType
    let dateRange: CustomReportsView.DateRangeOption
    let jobs: [JobApplication]
    let includeCharts: Bool
    let includeStats: Bool
    let includeDetails: Bool
    
    @State private var exportFormat: ExportFormat = .pdf
    @State private var isExporting = false
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF Document"
        case markdown = "Markdown"
        case csv = "CSV Data"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Export Report")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding(20)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose export format:")
                    .font(.system(size: 14, weight: .medium))
                
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button(action: {
                        exportFormat = format
                    }) {
                        HStack {
                            Image(systemName: exportFormat == format ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(exportFormat == format ? .blue : .gray)
                            Text(format.rawValue)
                            Spacer()
                        }
                        .padding(12)
                        .background(exportFormat == format ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(action: {
                    exportReport()
                }) {
                    Text(isExporting ? "Exporting..." : "Export Report")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isExporting ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isExporting)
            }
            .padding(20)
        }
        .frame(width: 400, height: 400)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
    
    func exportReport() {
        isExporting = true
        
        switch exportFormat {
        case .csv:
            exportCSV()
        case .markdown:
            exportMarkdown()
        case .pdf:
            // PDF export would require additional framework
            showAlert("PDF export coming soon")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isExporting = false
            dismiss()
        }
    }
    
    func exportCSV() {
        var csv = "Company,Title,Status,Date Applied,Salary,Location\n"
        for job in jobs {
            let fields = [
                job.company,
                job.title,
                job.status.rawValue,
                job.dateApplied.formatted(date: .abbreviated, time: .omitted),
                job.salary,
                job.location
            ]
            csv += fields.map { "\"\($0)\"" }.joined(separator: ",") + "\n"
        }
        
        saveToFile(content: csv, filename: "JobFlow_Report.csv")
    }
    
    func exportMarkdown() {
        var markdown = "# \(reportType.rawValue)\n\n"
        markdown += "Generated: \(Date().formatted(date: .long, time: .shortened))\n\n"
        markdown += "## Applications\n\n"
        markdown += "| Company | Title | Status | Date Applied |\n"
        markdown += "|---------|-------|--------|--------------|\n"
        
        for job in jobs {
            markdown += "| \(job.company) | \(job.title) | \(job.status.rawValue) | \(job.dateApplied.formatted(date: .abbreviated, time: .omitted)) |\n"
        }
        
        saveToFile(content: markdown, filename: "JobFlow_Report.md")
    }
    
    func saveToFile(content: String, filename: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.canCreateDirectories = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
}
