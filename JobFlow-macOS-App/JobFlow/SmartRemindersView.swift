import SwiftUI

struct SmartRemindersView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart Reminders")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        Text("AI-powered follow-up suggestions")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Reminder Categories
                VStack(spacing: 16) {
                    // Urgent Reminders
                    if !urgentReminders.isEmpty {
                        ReminderSection(
                            title: "Urgent",
                            icon: "exclamationmark.triangle.fill",
                            color: .red,
                            reminders: urgentReminders
                        )
                    }
                    
                    // High Priority
                    if !highPriorityReminders.isEmpty {
                        ReminderSection(
                            title: "High Priority",
                            icon: "star.fill",
                            color: .orange,
                            reminders: highPriorityReminders
                        )
                    }
                    
                    // Medium Priority
                    if !mediumPriorityReminders.isEmpty {
                        ReminderSection(
                            title: "Medium Priority",
                            icon: "clock.fill",
                            color: .blue,
                            reminders: mediumPriorityReminders
                        )
                    }
                    
                    // Low Priority
                    if !lowPriorityReminders.isEmpty {
                        ReminderSection(
                            title: "Low Priority",
                            icon: "info.circle.fill",
                            color: .gray,
                            reminders: lowPriorityReminders
                        )
                    }
                    
                    // All caught up message
                    if urgentReminders.isEmpty && highPriorityReminders.isEmpty && 
                       mediumPriorityReminders.isEmpty && lowPriorityReminders.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("All Caught Up!")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            Text("No pending reminders at this time")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
    
    // Urgent: Applications with interviews in next 48 hours
    var urgentReminders: [Reminder] {
        let now = Date()
        let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: now)!
        
        return jobStore.jobs.flatMap { job in
            job.interviews.compactMap { interview in
                guard let date = interview.scheduledDate,
                      date > now,
                      date <= twoDaysFromNow,
                      interview.outcome == .scheduled else {
                    return nil
                }
                
                return Reminder(
                    id: UUID(),
                    job: job,
                    type: .upcomingInterview,
                    priority: .urgent,
                    message: "Interview for \(job.title) at \(job.company) in \(daysUntil(date)) days",
                    actionDate: date
                )
            }
        }
    }
    
    // High Priority: Applications needing follow-up (7+ days old, no response)
    var highPriorityReminders: [Reminder] {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        return jobStore.jobs.compactMap { job in
            guard job.status == .applied,
                  job.dateApplied <= sevenDaysAgo else {
                return nil
            }
            
            let daysOld = Calendar.current.dateComponents([.day], from: job.dateApplied, to: now).day ?? 0
            
            return Reminder(
                id: UUID(),
                job: job,
                type: .followUp,
                priority: .high,
                message: "Follow up on \(job.title) application at \(job.company) (\(daysOld) days old)",
                actionDate: now
            )
        }
    }
    
    // Medium Priority: Interviews to prepare for (3-7 days away)
    var mediumPriorityReminders: [Reminder] {
        let now = Date()
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: now)!
        let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        return jobStore.jobs.flatMap { job in
            job.interviews.compactMap { interview in
                guard let date = interview.scheduledDate,
                      date > threeDaysFromNow,
                      date <= sevenDaysFromNow,
                      interview.outcome == .scheduled else {
                    return nil
                }
                
                return Reminder(
                    id: UUID(),
                    job: job,
                    type: .prepareInterview,
                    priority: .medium,
                    message: "Prepare for \(job.title) interview at \(job.company) in \(daysUntil(date)) days",
                    actionDate: date
                )
            }
        }
    }
    
    // Low Priority: General updates (interviewing status, no recent activity)
    var lowPriorityReminders: [Reminder] {
        let now = Date()
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: now)!
        
        return jobStore.jobs.compactMap { job in
            guard job.status == .interviewing,
                  job.dateApplied <= fourteenDaysAgo,
                  !job.interviews.contains(where: { $0.scheduledDate ?? Date.distantPast > fourteenDaysAgo }) else {
                return nil
            }
            
            return Reminder(
                id: UUID(),
                job: job,
                type: .checkStatus,
                priority: .low,
                message: "Check status of \(job.title) at \(job.company) (no recent updates)",
                actionDate: now
            )
        }
    }
    
    func daysUntil(_ date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(0, days)
    }
}

struct ReminderSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String
    let color: Color
    let reminders: [Reminder]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Spacer()
                
                Text("\(reminders.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 8) {
                ForEach(reminders) { reminder in
                    ReminderCard(reminder: reminder, color: color)
                }
            }
        }
        .padding(16)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

struct ReminderCard: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    let reminder: Reminder
    let color: Color
    @State private var isDismissed = false
    
    var body: some View {
        if !isDismissed {
            HStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: reminder.type.icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.message)
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    if let date = reminder.actionDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    jobStore.selectedJob = reminder.job
                }) {
                    Text("View")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    withAnimation {
                        isDismissed = true
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
            .cornerRadius(8)
        }
    }
}

// Reminder model
struct Reminder: Identifiable {
    let id: UUID
    let job: JobApplication
    let type: ReminderType
    let priority: ReminderPriority
    let message: String
    let actionDate: Date?
}

enum ReminderType {
    case upcomingInterview
    case followUp
    case prepareInterview
    case checkStatus
    
    var icon: String {
        switch self {
        case .upcomingInterview: return "calendar"
        case .followUp: return "arrow.turn.up.right"
        case .prepareInterview: return "book.fill"
        case .checkStatus: return "questionmark.circle"
        }
    }
}

enum ReminderPriority {
    case urgent
    case high
    case medium
    case low
}

#Preview {
    SmartRemindersView()
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
}
