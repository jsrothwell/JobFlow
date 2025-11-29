import SwiftUI

struct InterviewFormView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    
    let job: JobApplication
    let editingInterview: Interview?
    
    @State private var round: InterviewRound
    @State private var scheduledDate: Date
    @State private var hasScheduledDate: Bool
    @State private var duration: Int
    @State private var interviewerName: String
    @State private var interviewerTitle: String
    @State private var interviewerEmail: String
    @State private var location: String
    @State private var meetingLink: String
    @State private var notes: String
    @State private var preparation: [PreparationItem]
    @State private var outcome: InterviewOutcome
    @State private var feedback: String
    @State private var rating: Int
    @State private var newPrepItem: String = ""
    
    init(interview: Interview? = nil, job: JobApplication) {
        self.job = job
        self.editingInterview = interview
        
        _round = State(initialValue: interview?.round ?? .phoneScreen)
        _scheduledDate = State(initialValue: interview?.scheduledDate ?? Date())
        _hasScheduledDate = State(initialValue: interview?.scheduledDate != nil)
        _duration = State(initialValue: interview?.duration ?? 60)
        _interviewerName = State(initialValue: interview?.interviewerName ?? "")
        _interviewerTitle = State(initialValue: interview?.interviewerTitle ?? "")
        _interviewerEmail = State(initialValue: interview?.interviewerEmail ?? "")
        _location = State(initialValue: interview?.location ?? "")
        _meetingLink = State(initialValue: interview?.meetingLink ?? "")
        _notes = State(initialValue: interview?.notes ?? "")
        _preparation = State(initialValue: interview?.preparation ?? [])
        _outcome = State(initialValue: interview?.outcome ?? .scheduled)
        _feedback = State(initialValue: interview?.feedback ?? "")
        _rating = State(initialValue: interview?.rating ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(editingInterview == nil ? "Add Interview" : "Edit Interview")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Text(job.title + " at " + job.company)
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
            
            // Form Content
            ScrollView {
                VStack(spacing: 24) {
                    // Interview Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interview Round")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(InterviewRound.allCases, id: \.self) { roundType in
                                Button(action: {
                                    round = roundType
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: roundType.icon)
                                            .font(.system(size: 14))
                                        Text(roundType.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(round == roundType ? .white : ThemeColors.textPrimary(for: themeManager.currentTheme))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(round == roundType ? roundType.color : ThemeColors.inputBackground(for: themeManager.currentTheme))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $hasScheduledDate) {
                            Text("Schedule Interview")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        }
                        .toggleStyle(.switch)
                        
                        if hasScheduledDate {
                            DatePicker("Date & Time", selection: $scheduledDate)
                                .datePickerStyle(.graphical)
                                .frame(maxWidth: .infinity)
                            
                            HStack {
                                Text("Duration")
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                
                                Spacer()
                                
                                Picker("", selection: $duration) {
                                    Text("30 min").tag(30)
                                    Text("45 min").tag(45)
                                    Text("60 min").tag(60)
                                    Text("90 min").tag(90)
                                    Text("120 min").tag(120)
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Interviewer Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interviewer Details")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        TextField("Name", text: $interviewerName)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        
                        TextField("Title/Role", text: $interviewerTitle)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        
                        TextField("Email", text: $interviewerEmail)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        TextField("e.g., Zoom, Google Meet, On-site", text: $location)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        
                        TextField("Meeting Link (optional)", text: $meetingLink)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Preparation Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preparation Checklist")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        ForEach(preparation.indices, id: \.self) { index in
                            HStack {
                                Button(action: {
                                    preparation[index].isCompleted.toggle()
                                }) {
                                    Image(systemName: preparation[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(preparation[index].isCompleted ? .green : ThemeColors.textTertiary(for: themeManager.currentTheme))
                                }
                                .buttonStyle(.plain)
                                
                                Text(preparation[index].title)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                                    .strikethrough(preparation[index].isCompleted)
                                
                                Spacer()
                                
                                Button(action: {
                                    preparation.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(10)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            TextField("Add preparation item...", text: $newPrepItem)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    addPrepItem()
                                }
                            
                            Button(action: addPrepItem) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(ThemeColors.accentBlue)
                            }
                            .buttonStyle(.plain)
                            .disabled(newPrepItem.isEmpty)
                        }
                        .padding(10)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Outcome & Feedback (show after interview)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Outcome")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        Picker("Status", selection: $outcome) {
                            ForEach(InterviewOutcome.allCases, id: \.self) { outcomeType in
                                Label(outcomeType.rawValue, systemImage: outcomeType.icon)
                                    .tag(outcomeType)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        if outcome == .completed || outcome == .passed || outcome == .rejected {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rating")
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                
                                HStack(spacing: 12) {
                                    ForEach(1...5, id: \.self) { star in
                                        Button(action: {
                                            rating = star
                                        }) {
                                            Image(systemName: star <= rating ? "star.fill" : "star")
                                                .font(.system(size: 24))
                                                .foregroundColor(star <= rating ? .yellow : ThemeColors.textTertiary(for: themeManager.currentTheme))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            TextEditor(text: $feedback)
                                .frame(height: 100)
                                .padding(8)
                                .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                                .cornerRadius(8)
                                .overlay(
                                    Group {
                                        if feedback.isEmpty {
                                            Text("Add feedback notes...")
                                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                                                .padding(12)
                                                .allowsHitTesting(false)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                    }
                    
                    Divider()
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("Add any additional notes...")
                                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                                            .padding(12)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }
                .padding(24)
            }
            
            // Footer Buttons
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(action: saveInterview) {
                    Text(editingInterview == nil ? "Add Interview" : "Save Changes")
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
        .frame(width: 700, height: 800)
    }
    
    private func addPrepItem() {
        guard !newPrepItem.isEmpty else { return }
        preparation.append(PreparationItem(title: newPrepItem))
        newPrepItem = ""
    }
    
    private func saveInterview() {
        let interview = Interview(
            id: editingInterview?.id ?? UUID(),
            round: round,
            scheduledDate: hasScheduledDate ? scheduledDate : nil,
            duration: duration,
            interviewerName: interviewerName,
            interviewerTitle: interviewerTitle,
            interviewerEmail: interviewerEmail,
            location: location,
            meetingLink: meetingLink,
            notes: notes,
            preparation: preparation,
            outcome: outcome,
            feedback: feedback,
            rating: rating
        )
        
        if editingInterview != nil {
            jobStore.updateInterview(interview, in: job)
            
            // Update calendar event if exists
            if let eventID = calendarManager.getEventID(for: interview.id) {
                Task {
                    _ = await calendarManager.updateEvent(for: interview, job: job, eventID: eventID)
                    calendarManager.saveMappings()
                }
            } else if hasScheduledDate && calendarManager.hasAccess {
                // Create new event if scheduled
                Task {
                    if let eventID = await calendarManager.createEvent(for: interview, job: job) {
                        calendarManager.saveMappings()
                    }
                }
            }
        } else {
            jobStore.addInterview(interview, to: job)
            
            // Create calendar event if scheduled and has access
            if hasScheduledDate && calendarManager.hasAccess {
                Task {
                    if let eventID = await calendarManager.createEvent(for: interview, job: job) {
                        calendarManager.saveMappings()
                    }
                }
            }
        }
        
        dismiss()
    }
}
