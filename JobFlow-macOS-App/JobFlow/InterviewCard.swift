import SwiftUI

struct InterviewCard: View {
    let interview: Interview
    let job: JobApplication
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    var body: some View {
        Button(action: {
            showingEditSheet = true
        }) {
            HStack(spacing: 16) {
                // Left: Icon and Round Type
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(interview.round.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: interview.round.icon)
                            .font(.system(size: 20))
                            .foregroundColor(interview.round.color)
                    }
                    
                    Text(interview.round.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        .multilineTextAlignment(.center)
                        .frame(width: 70)
                }
                
                // Middle: Details
                VStack(alignment: .leading, spacing: 6) {
                    // Date/Time
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        
                        Text(interview.dateString)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    }
                    
                    // Interviewer
                    if !interview.interviewerName.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            
                            Text(interview.interviewerName)
                                .font(.system(size: 13))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            
                            if !interview.interviewerTitle.isEmpty {
                                Text("• \(interview.interviewerTitle)")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            }
                        }
                    }
                    
                    // Location/Link
                    if !interview.location.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: interview.location.lowercased().contains("zoom") ? "video.fill" : 
                                            interview.location.lowercased().contains("meet") ? "video.fill" :
                                            interview.location.lowercased().contains("site") ? "building.2.fill" : "mappin.circle")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            
                            Text(interview.location)
                                .font(.system(size: 13))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                    }
                    
                    // Preparation Progress
                    if !interview.preparation.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            
                            let completed = interview.preparation.filter { $0.isCompleted }.count
                            let total = interview.preparation.count
                            Text("\(completed)/\(total) prep items complete")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                    }
                }
                
                Spacer()
                
                // Right: Outcome Badge
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: interview.outcome.icon)
                            .font(.system(size: 12))
                        Text(interview.outcome.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(interview.outcome.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(interview.outcome.color.opacity(0.15))
                    .cornerRadius(8)
                    
                    // Rating (if completed)
                    if interview.rating > 0 {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= interview.rating ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(star <= interview.rating ? .yellow : ThemeColors.textTertiary(for: themeManager.currentTheme))
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(interview.round.color.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: ThemeColors.cardShadow(for: themeManager.currentTheme), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEditSheet) {
            InterviewFormView(interview: interview, job: job)
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    InterviewCard(
        interview: Interview(
            round: .technical,
            scheduledDate: Date(),
            duration: 60,
            interviewerName: "Sarah Chen",
            interviewerTitle: "Senior Engineer",
            location: "Zoom",
            preparation: [
                PreparationItem(title: "Review system design", isCompleted: true),
                PreparationItem(title: "Prepare questions", isCompleted: false)
            ],
            outcome: .scheduled,
            rating: 4
        ),
        job: JobApplication(title: "iOS Engineer", company: "Apple")
    )
    .environmentObject(JobStore())
    .environmentObject(ThemeManager())
    .padding()
}
