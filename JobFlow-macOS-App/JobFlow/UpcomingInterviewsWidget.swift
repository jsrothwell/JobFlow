import SwiftUI

struct UpcomingInterviewsWidget: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var upcomingInterviews: [(job: JobApplication, interview: Interview)] {
        var interviews: [(JobApplication, Interview)] = []
        
        for job in jobStore.jobs {
            for interview in job.interviews {
                if let date = interview.scheduledDate, date > Date() {
                    interviews.append((job, interview))
                }
            }
        }
        
        return interviews
            .sorted { (a: (JobApplication, Interview), b: (JobApplication, Interview)) -> Bool in
                guard let dateA = a.1.scheduledDate, let dateB = b.1.scheduledDate else {
                    return false
                }
                return dateA < dateB
            }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                
                Text("Upcoming Interviews")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            }
            
            if upcomingInterviews.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    
                    Text("No upcoming interviews")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ThemeColors.cardBackground(for: themeManager.currentTheme).opacity(0.5))
                .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    ForEach(upcomingInterviews, id: \.interview.id) { item in
                        UpcomingInterviewRow(job: item.job, interview: item.interview)
                            .environmentObject(themeManager)
                    }
                }
            }
        }
        .padding(12)
        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

struct UpcomingInterviewRow: View {
    let job: JobApplication
    let interview: Interview
    @EnvironmentObject var themeManager: ThemeManager
    
    private var timeUntil: String {
        guard let date = interview.scheduledDate else { return "" }
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour], from: now, to: date)
        
        if let days = components.day, days > 0 {
            return "in \(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "in \(hours)h"
        } else {
            return "soon"
        }
    }
    
    private var isToday: Bool {
        guard let date = interview.scheduledDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    private var isTomorrow: Bool {
        guard let date = interview.scheduledDate else { return false }
        return Calendar.current.isDateInTomorrow(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(interview.round.color)
                    .frame(width: 8, height: 8)
                
                Text(interview.round.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(interview.round.color)
                
                Spacer()
                
                if isToday {
                    Text("TODAY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                } else if isTomorrow {
                    Text("TOMORROW")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                } else {
                    Text(timeUntil)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
            }
            
            Text(job.company)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                .lineLimit(1)
            
            if let date = interview.scheduledDate {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 10))
                }
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }
            
            if !interview.interviewerName.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.system(size: 9))
                    Text(interview.interviewerName)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }
                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
            }
        }
        .padding(10)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(interview.round.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    UpcomingInterviewsWidget()
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
        .padding()
        .frame(width: 280)
}
