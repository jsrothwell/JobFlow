import Foundation
import SwiftUI

struct Interview: Identifiable, Codable, Hashable {
    let id: UUID
    var round: InterviewRound
    var scheduledDate: Date?
    var duration: Int // minutes
    var interviewerName: String
    var interviewerTitle: String
    var interviewerEmail: String
    var location: String // "Zoom", "Google Meet", "On-site", etc.
    var meetingLink: String
    var notes: String
    var preparation: [PreparationItem]
    var outcome: InterviewOutcome
    var feedback: String
    var rating: Int // 1-5 stars
    
    var dateString: String {
        guard let date = scheduledDate else { return "Not scheduled" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    var shortDateString: String {
        guard let date = scheduledDate else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    init(
        id: UUID = UUID(),
        round: InterviewRound = .phoneScreen,
        scheduledDate: Date? = nil,
        duration: Int = 60,
        interviewerName: String = "",
        interviewerTitle: String = "",
        interviewerEmail: String = "",
        location: String = "",
        meetingLink: String = "",
        notes: String = "",
        preparation: [PreparationItem] = [],
        outcome: InterviewOutcome = .scheduled,
        feedback: String = "",
        rating: Int = 0
    ) {
        self.id = id
        self.round = round
        self.scheduledDate = scheduledDate
        self.duration = duration
        self.interviewerName = interviewerName
        self.interviewerTitle = interviewerTitle
        self.interviewerEmail = interviewerEmail
        self.location = location
        self.meetingLink = meetingLink
        self.notes = notes
        self.preparation = preparation
        self.outcome = outcome
        self.feedback = feedback
        self.rating = rating
    }
}

enum InterviewRound: String, Codable, CaseIterable {
    case phoneScreen = "Phone Screen"
    case technical = "Technical"
    case coding = "Coding Challenge"
    case behavioral = "Behavioral"
    case systemDesign = "System Design"
    case hiring = "Hiring Manager"
    case panel = "Panel Interview"
    case onsite = "On-site"
    case final = "Final Round"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .phoneScreen: return "phone.fill"
        case .technical: return "laptopcomputer"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .behavioral: return "person.2.fill"
        case .systemDesign: return "square.grid.3x3.fill"
        case .hiring: return "person.fill.checkmark"
        case .panel: return "person.3.fill"
        case .onsite: return "building.2.fill"
        case .final: return "flag.checkered"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .phoneScreen: return .blue
        case .technical: return .purple
        case .coding: return .green
        case .behavioral: return .orange
        case .systemDesign: return .pink
        case .hiring: return .indigo
        case .panel: return .teal
        case .onsite: return .cyan
        case .final: return .mint
        case .other: return .gray
        }
    }
}

enum InterviewOutcome: String, Codable, CaseIterable {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case passed = "Passed"
    case rejected = "Rejected"
    case cancelled = "Cancelled"
    case noShow = "No Show"
    
    var color: Color {
        switch self {
        case .scheduled: return .blue
        case .completed: return .gray
        case .passed: return .green
        case .rejected: return .red
        case .cancelled: return .orange
        case .noShow: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .completed: return "checkmark.circle"
        case .passed: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "slash.circle"
        case .noShow: return "exclamationmark.triangle.fill"
        }
    }
}

struct PreparationItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
