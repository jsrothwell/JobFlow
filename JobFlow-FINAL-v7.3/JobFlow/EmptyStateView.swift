import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var jobStore: JobStore
    let type: EmptyStateType
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: type.icon)
                .font(.system(size: 64))
                .foregroundColor(type.color.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(type.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Text(type.message)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if type.showButton {
                Button(action: {
                    jobStore.showingAddSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Your First Job")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}

enum EmptyStateType {
    case kanban, timeline, list, flow, reports, reminders, search
    
    var icon: String {
        switch self {
        case .kanban: return "square.grid.2x2"
        case .timeline: return "calendar.badge.clock"
        case .list: return "list.bullet.rectangle"
        case .flow: return "chart.bar.fill"
        case .reports: return "doc.text.magnifyingglass"
        case .reminders: return "bell.badge"
        case .search: return "magnifyingglass"
        }
    }
    
    var title: String {
        switch self {
        case .kanban: return "No Applications Yet"
        case .timeline: return "Timeline Starts Here"
        case .list: return "Your Job List is Empty"
        case .flow: return "Not Enough Data"
        case .reports: return "No Data to Report"
        case .reminders: return "All Caught Up!"
        case .search: return "No Results Found"
        }
    }
    
    var message: String {
        switch self {
        case .kanban:
            return "Start tracking your job search journey! Add your first application to see it appear in the Kanban board."
        case .timeline:
            return "Your application timeline will appear here. Add your first job to see your journey come to life."
        case .list:
            return "Begin by adding your job applications. Track companies, positions, statuses, and interview progress all in one place."
        case .flow:
            return "Add more applications to see your success rate, conversion metrics, and application flow visualization."
        case .reports:
            return "Generate insights once you have applications to analyze. Add jobs to get started."
        case .reminders:
            return "You have no pending reminders. We'll notify you about upcoming interviews and follow-ups."
        case .search:
            return "Try adjusting your search terms or filters to find what you're looking for."
        }
    }
    
    var color: Color {
        switch self {
        case .kanban: return .blue
        case .timeline: return .purple
        case .list: return .green
        case .flow: return .orange
        case .reports: return .cyan
        case .reminders: return .mint
        case .search: return .gray
        }
    }
    
    var showButton: Bool {
        switch self {
        case .kanban, .timeline, .list: return true
        default: return false
        }
    }
}
