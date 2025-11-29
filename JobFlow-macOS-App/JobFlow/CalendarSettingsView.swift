import SwiftUI
import EventKit

struct CalendarSettingsView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var autoSyncEnabled: Bool = true
    @State private var showDayBeforeReminder: Bool = true
    @State private var show15MinReminder: Bool = true
    @State private var isSyncing: Bool = false
    @State private var lastSyncDate: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calendar Integration")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Text("Sync interviews to Apple Calendar")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Authorization Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calendar Access")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        HStack(spacing: 12) {
                            Image(systemName: calendarManager.hasAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(calendarManager.hasAccess ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(statusText)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                                
                                Text(statusDescription)
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            }
                            
                            Spacer()
                            
                            if !calendarManager.hasAccess {
                                Button(action: {
                                    Task {
                                        _ = await calendarManager.requestAccess()
                                    }
                                }) {
                                    if calendarManager.isRequesting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Grant Access")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(ThemeColors.accentBlue)
                                            .cornerRadius(8)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .cornerRadius(12)
                    }
                    
                    if calendarManager.hasAccess {
                        Divider()
                        
                        // Sync Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sync Settings")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            Toggle(isOn: $autoSyncEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Auto-sync interviews")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Automatically create calendar events when interviews are scheduled")
                                        .font(.system(size: 12))
                                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                }
                            }
                            .toggleStyle(.switch)
                            .padding(16)
                            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                            .cornerRadius(12)
                            
                            // Manual Sync Button
                            Button(action: {
                                Task {
                                    isSyncing = true
                                    await calendarManager.syncAllInterviews(from: jobStore.jobs)
                                    lastSyncDate = Date()
                                    isSyncing = false
                                }
                            }) {
                                HStack {
                                    if isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Syncing...")
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Sync All Interviews Now")
                                    }
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSyncing ? ThemeColors.inputBackground(for: themeManager.currentTheme) : ThemeColors.accentBlue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            .disabled(isSyncing)
                            
                            if let lastSync = lastSyncDate {
                                Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            }
                        }
                        
                        Divider()
                        
                        // Reminder Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reminders")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            VStack(spacing: 12) {
                                Toggle(isOn: $showDayBeforeReminder) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Day before at 9 AM")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Get reminded to prepare for tomorrow's interview")
                                            .font(.system(size: 12))
                                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                    }
                                }
                                .toggleStyle(.switch)
                                .padding(16)
                                .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                                .cornerRadius(12)
                                
                                Toggle(isOn: $show15MinReminder) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("15 minutes before")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Last-minute reminder to join the interview")
                                            .font(.system(size: 12))
                                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                    }
                                }
                                .toggleStyle(.switch)
                                .padding(16)
                                .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                                .cornerRadius(12)
                            }
                        }
                        
                        Divider()
                        
                        // Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistics")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Synced Events",
                                    value: "\(calendarManager.eventMappings.count)",
                                    icon: "calendar.badge.checkmark",
                                    color: .green,
                                    themeManager: themeManager
                                )
                                
                                StatCard(
                                    title: "Scheduled Interviews",
                                    value: "\(scheduledInterviewsCount)",
                                    icon: "calendar",
                                    color: .blue,
                                    themeManager: themeManager
                                )
                                
                                StatCard(
                                    title: "This Week",
                                    value: "\(interviewsThisWeek)",
                                    icon: "calendar.day.timeline.leading",
                                    color: .orange,
                                    themeManager: themeManager
                                )
                            }
                        }
                        
                        Divider()
                        
                        // Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How It Works")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(
                                    icon: "1.circle.fill",
                                    title: "Add Interview",
                                    description: "Schedule an interview in JobFlow"
                                )
                                
                                InfoRow(
                                    icon: "2.circle.fill",
                                    title: "Auto-Create Event",
                                    description: "Calendar event is created automatically"
                                )
                                
                                InfoRow(
                                    icon: "3.circle.fill",
                                    title: "Get Reminders",
                                    description: "Receive notifications before the interview"
                                )
                                
                                InfoRow(
                                    icon: "4.circle.fill",
                                    title: "Stay Synced",
                                    description: "Changes in JobFlow update your calendar"
                                )
                            }
                            .padding(16)
                            .background(ThemeColors.accentBlue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
            }
            
            // Footer
            HStack {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.accentBlue)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .frame(width: 600, height: 700)
        .onAppear {
            calendarManager.checkAuthorizationStatus()
            calendarManager.loadMappings()
        }
    }
    
    private var statusText: String {
        switch calendarManager.authorizationStatus {
        case .authorized, .fullAccess:
            return "Connected"
        case .denied:
            return "Access Denied"
        case .notDetermined:
            return "Not Connected"
        case .restricted:
            return "Restricted"
        case .writeOnly:
            return "Write Only"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var statusDescription: String {
        switch calendarManager.authorizationStatus {
        case .authorized, .fullAccess:
            return "JobFlow can create and update calendar events"
        case .denied:
            return "Please enable calendar access in System Settings"
        case .notDetermined:
            return "Click 'Grant Access' to sync interviews to your calendar"
        case .restricted:
            return "Calendar access is restricted on this device"
        case .writeOnly:
            return "Limited calendar access"
        @unknown default:
            return ""
        }
    }
    
    private var scheduledInterviewsCount: Int {
        jobStore.jobs.reduce(0) { count, job in
            count + job.interviews.filter { $0.scheduledDate != nil }.count
        }
    }
    
    private var interviewsThisWeek: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        return jobStore.jobs.reduce(0) { count, job in
            count + job.interviews.filter { interview in
                guard let date = interview.scheduledDate else { return false }
                return date >= now && date <= weekFromNow
            }.count
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let themeManager: ThemeManager
    
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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ThemeColors.accentBlue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CalendarSettingsView()
        .environmentObject(CalendarManager())
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
}
