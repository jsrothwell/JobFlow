import Foundation
import SwiftUI

struct Contact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var role: ContactRole
    var title: String
    var company: String
    var email: String
    var phone: String
    var linkedInURL: String
    var notes: String
    var lastContactDate: Date?
    var interactions: [Interaction]
    var tags: [String]
    
    var initialsIcon: String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if !name.isEmpty {
            return String(name.prefix(2)).uppercased()
        }
        return "?"
    }
    
    var lastContactString: String {
        guard let date = lastContactDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        role: ContactRole = .recruiter,
        title: String = "",
        company: String = "",
        email: String = "",
        phone: String = "",
        linkedInURL: String = "",
        notes: String = "",
        lastContactDate: Date? = nil,
        interactions: [Interaction] = [],
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.title = title
        self.company = company
        self.email = email
        self.phone = phone
        self.linkedInURL = linkedInURL
        self.notes = notes
        self.lastContactDate = lastContactDate
        self.interactions = interactions
        self.tags = tags
    }
}

enum ContactRole: String, Codable, CaseIterable {
    case recruiter = "Recruiter"
    case hiringManager = "Hiring Manager"
    case teamMember = "Team Member"
    case referrer = "Referrer"
    case hr = "HR"
    case interviewer = "Interviewer"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .recruiter: return "person.crop.circle.badge.checkmark"
        case .hiringManager: return "person.crop.circle.fill.badge.checkmark"
        case .teamMember: return "person.fill"
        case .referrer: return "person.crop.circle.badge.plus"
        case .hr: return "briefcase.fill"
        case .interviewer: return "person.crop.square.fill"
        case .other: return "person.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .recruiter: return .blue
        case .hiringManager: return .purple
        case .teamMember: return .green
        case .referrer: return .orange
        case .hr: return .pink
        case .interviewer: return .indigo
        case .other: return .gray
        }
    }
}

struct Interaction: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var type: InteractionType
    var subject: String
    var notes: String
    var followUpDate: Date?
    var completed: Bool
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: InteractionType = .email,
        subject: String = "",
        notes: String = "",
        followUpDate: Date? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.subject = subject
        self.notes = notes
        self.followUpDate = followUpDate
        self.completed = completed
    }
}

enum InteractionType: String, Codable, CaseIterable {
    case email = "Email"
    case phone = "Phone Call"
    case meeting = "Meeting"
    case message = "Message"
    case linkedIn = "LinkedIn"
    case coffee = "Coffee Chat"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .email: return "envelope.fill"
        case .phone: return "phone.fill"
        case .meeting: return "video.fill"
        case .message: return "message.fill"
        case .linkedIn: return "link"
        case .coffee: return "cup.and.saucer.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .email: return .blue
        case .phone: return .green
        case .meeting: return .purple
        case .message: return .orange
        case .linkedIn: return .indigo
        case .coffee: return .brown
        case .other: return .gray
        }
    }
}
