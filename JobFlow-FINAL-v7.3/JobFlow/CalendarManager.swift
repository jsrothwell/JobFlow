import Foundation
import EventKit
import SwiftUI

@MainActor
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var hasAccess: Bool = false
    @Published var isRequesting: Bool = false
    
    // Store mapping between interview IDs and calendar event IDs
    @Published var eventMappings: [UUID: String] = [:] // [interviewID: eventID]
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        if #available(macOS 14.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            hasAccess = (authorizationStatus == .fullAccess)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            hasAccess = (authorizationStatus == .authorized)
        }
    }
    
    func requestAccess() async -> Bool {
        isRequesting = true
        defer { isRequesting = false }
        
        do {
            if #available(macOS 14.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    authorizationStatus = granted ? .fullAccess : .denied
                    hasAccess = granted
                }
                return granted
            } else {
                return await withCheckedContinuation { continuation in
                    eventStore.requestAccess(to: .event) { granted, error in
                        Task { @MainActor in
                            self.authorizationStatus = granted ? .authorized : .denied
                            self.hasAccess = granted
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
        } catch {
            print("Calendar access error: \(error.localizedDescription)")
            await MainActor.run {
                authorizationStatus = .denied
                hasAccess = false
            }
            return false
        }
    }
    
    // MARK: - Event Creation
    
    func createEvent(for interview: Interview, job: JobApplication) async -> String? {
        guard hasAccess else {
            print("No calendar access")
            return nil
        }
        
        guard let scheduledDate = interview.scheduledDate else {
            print("No scheduled date for interview")
            return nil
        }
        
        let event = EKEvent(eventStore: eventStore)
        
        // Event details
        event.title = "\(job.company) - \(interview.round.rawValue)"
        event.startDate = scheduledDate
        event.endDate = scheduledDate.addingTimeInterval(TimeInterval(interview.duration * 60))
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Location
        if !interview.location.isEmpty {
            event.location = interview.location
        }
        
        // Notes - Include all relevant info
        var notesText = "Job Application: \(job.title) at \(job.company)\n"
        notesText += "Interview Round: \(interview.round.rawValue)\n\n"
        
        if !interview.interviewerName.isEmpty {
            notesText += "Interviewer: \(interview.interviewerName)"
            if !interview.interviewerTitle.isEmpty {
                notesText += " (\(interview.interviewerTitle))"
            }
            notesText += "\n"
        }
        
        if !interview.interviewerEmail.isEmpty {
            notesText += "Email: \(interview.interviewerEmail)\n"
        }
        
        if !interview.meetingLink.isEmpty {
            notesText += "\nMeeting Link: \(interview.meetingLink)\n"
        }
        
        if !interview.preparation.isEmpty {
            notesText += "\nPreparation Checklist:\n"
            for item in interview.preparation {
                notesText += "• \(item.title)\n"
            }
        }
        
        if !interview.notes.isEmpty {
            notesText += "\nNotes:\n\(interview.notes)\n"
        }
        
        event.notes = notesText
        
        // URL - Add meeting link if available
        if !interview.meetingLink.isEmpty {
            event.url = URL(string: interview.meetingLink)
        }
        
        // Alarms/Reminders
        // 1 day before at 9 AM
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: scheduledDate)!
        let oneDayBeforeAt9AM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: oneDayBefore)!
        let alarm1 = EKAlarm(absoluteDate: oneDayBeforeAt9AM)
        
        // 15 minutes before
        let alarm2 = EKAlarm(relativeOffset: -15 * 60) // -15 minutes in seconds
        
        event.alarms = [alarm1, alarm2]
        
        // Save event
        do {
            try eventStore.save(event, span: .thisEvent)
            print("✅ Calendar event created: \(event.eventIdentifier ?? "unknown")")
            
            // Store mapping
            await MainActor.run {
                eventMappings[interview.id] = event.eventIdentifier
            }
            
            return event.eventIdentifier
        } catch {
            print("❌ Error creating calendar event: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Event Update
    
    func updateEvent(for interview: Interview, job: JobApplication, eventID: String) async -> Bool {
        guard hasAccess else { return false }
        
        guard let event = eventStore.event(withIdentifier: eventID) else {
            print("Event not found with ID: \(eventID)")
            return false
        }
        
        guard let scheduledDate = interview.scheduledDate else {
            // If no date, delete the event
            return await deleteEvent(eventID: eventID)
        }
        
        // Update event details
        event.title = "\(job.company) - \(interview.round.rawValue)"
        event.startDate = scheduledDate
        event.endDate = scheduledDate.addingTimeInterval(TimeInterval(interview.duration * 60))
        
        if !interview.location.isEmpty {
            event.location = interview.location
        }
        
        // Update notes
        var notesText = "Job Application: \(job.title) at \(job.company)\n"
        notesText += "Interview Round: \(interview.round.rawValue)\n\n"
        
        if !interview.interviewerName.isEmpty {
            notesText += "Interviewer: \(interview.interviewerName)"
            if !interview.interviewerTitle.isEmpty {
                notesText += " (\(interview.interviewerTitle))"
            }
            notesText += "\n"
        }
        
        if !interview.interviewerEmail.isEmpty {
            notesText += "Email: \(interview.interviewerEmail)\n"
        }
        
        if !interview.meetingLink.isEmpty {
            notesText += "\nMeeting Link: \(interview.meetingLink)\n"
        }
        
        if !interview.preparation.isEmpty {
            notesText += "\nPreparation Checklist:\n"
            for item in interview.preparation {
                let status = item.isCompleted ? "✓" : "○"
                notesText += "\(status) \(item.title)\n"
            }
        }
        
        if !interview.notes.isEmpty {
            notesText += "\nNotes:\n\(interview.notes)\n"
        }
        
        event.notes = notesText
        
        if !interview.meetingLink.isEmpty {
            event.url = URL(string: interview.meetingLink)
        }
        
        // Update alarms
        event.alarms = []
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: scheduledDate)!
        let oneDayBeforeAt9AM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: oneDayBefore)!
        let alarm1 = EKAlarm(absoluteDate: oneDayBeforeAt9AM)
        let alarm2 = EKAlarm(relativeOffset: -15 * 60)
        event.alarms = [alarm1, alarm2]
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("✅ Calendar event updated")
            return true
        } catch {
            print("❌ Error updating calendar event: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Event Deletion
    
    func deleteEvent(eventID: String) async -> Bool {
        guard hasAccess else { return false }
        
        guard let event = eventStore.event(withIdentifier: eventID) else {
            print("Event not found for deletion")
            return false
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            print("✅ Calendar event deleted")
            return true
        } catch {
            print("❌ Error deleting calendar event: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Upcoming Interviews
    
    func getUpcomingInterviews(daysAhead: Int = 30) async -> [EKEvent] {
        guard hasAccess else { return [] }
        
        let now = Date()
        let future = Calendar.current.date(byAdding: .day, value: daysAhead, to: now)!
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: future, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // Filter for interview-related events (contain company names or "Interview")
        let interviewEvents = events.filter { event in
            event.title.contains("Interview") ||
            event.title.contains("Phone Screen") ||
            event.title.contains("Technical") ||
            event.title.contains("Coding") ||
            event.title.contains("Behavioral")
        }
        
        return interviewEvents.sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - Conflict Detection
    
    func hasConflict(at date: Date, duration: Int) async -> [EKEvent] {
        guard hasAccess else { return [] }
        
        let startDate = date
        let endDate = date.addingTimeInterval(TimeInterval(duration * 60))
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        return events
    }
    
    // MARK: - Helper Methods
    
    func getEventID(for interviewID: UUID) -> String? {
        return eventMappings[interviewID]
    }
    
    func removeMapping(for interviewID: UUID) {
        eventMappings.removeValue(forKey: interviewID)
    }
    
    // MARK: - Batch Operations
    
    func syncAllInterviews(from jobs: [JobApplication]) async {
        guard hasAccess else {
            print("No calendar access for sync")
            return
        }
        
        for job in jobs {
            for interview in job.interviews {
                // Only create events for scheduled interviews
                guard interview.scheduledDate != nil else { continue }
                
                // Check if already has event
                if let eventID = eventMappings[interview.id] {
                    // Update existing event
                    _ = await updateEvent(for: interview, job: job, eventID: eventID)
                } else {
                    // Create new event
                    if let eventID = await createEvent(for: interview, job: job) {
                        await MainActor.run {
                            eventMappings[interview.id] = eventID
                        }
                    }
                }
            }
        }
        
        print("✅ Calendar sync complete")
    }
    
    // MARK: - Save/Load Mappings
    
    func saveMappings() {
        if let encoded = try? JSONEncoder().encode(eventMappings) {
            UserDefaults.standard.set(encoded, forKey: "calendarEventMappings")
        }
    }
    
    func loadMappings() {
        if let data = UserDefaults.standard.data(forKey: "calendarEventMappings"),
           let decoded = try? JSONDecoder().decode([UUID: String].self, from: data) {
            eventMappings = decoded
        }
    }
}
