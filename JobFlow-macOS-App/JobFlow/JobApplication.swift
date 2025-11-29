import Foundation
import SwiftUI

struct JobApplication: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var company: String
    var status: ApplicationStatus
    var dateApplied: Date
    var description: String
    var salary: String
    var location: String
    var notes: String
    var url: String
    var isGhostJob: Bool
    var interviews: [Interview]
    var contactIDs: [UUID] // References to Contact objects
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case id, title, company, status, dateApplied, description
        case salary, location, notes, url, isGhostJob, interviews, contactIDs
    }
    
    // Custom init for Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decode(String.self, forKey: .company)
        status = try container.decode(ApplicationStatus.self, forKey: .status)
        dateApplied = try container.decode(Date.self, forKey: .dateApplied)
        description = try container.decode(String.self, forKey: .description)
        salary = try container.decode(String.self, forKey: .salary)
        location = try container.decode(String.self, forKey: .location)
        notes = try container.decode(String.self, forKey: .notes)
        url = try container.decode(String.self, forKey: .url)
        isGhostJob = try container.decode(Bool.self, forKey: .isGhostJob)
        interviews = try container.decode([Interview].self, forKey: .interviews)
        contactIDs = try container.decode([UUID].self, forKey: .contactIDs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(company, forKey: .company)
        try container.encode(status, forKey: .status)
        try container.encode(dateApplied, forKey: .dateApplied)
        try container.encode(description, forKey: .description)
        try container.encode(salary, forKey: .salary)
        try container.encode(location, forKey: .location)
        try container.encode(notes, forKey: .notes)
        try container.encode(url, forKey: .url)
        try container.encode(isGhostJob, forKey: .isGhostJob)
        try container.encode(interviews, forKey: .interviews)
        try container.encode(contactIDs, forKey: .contactIDs)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: dateApplied)
    }
    
    var upcomingInterview: Interview? {
        interviews
            .filter { $0.outcome == .scheduled && $0.scheduledDate ?? Date.distantPast > Date() }
            .sorted { ($0.scheduledDate ?? Date.distantPast) < ($1.scheduledDate ?? Date.distantPast) }
            .first
    }
    
    var interviewCount: Int {
        interviews.count
    }
    
    var passedInterviewCount: Int {
        interviews.filter { $0.outcome == .passed }.count
    }
    
    // Initialize with empty values
    init(
        id: UUID = UUID(),
        title: String = "",
        company: String = "",
        status: ApplicationStatus = .applied,
        dateApplied: Date = Date(),
        description: String = "",
        salary: String = "",
        location: String = "",
        notes: String = "",
        url: String = "",
        isGhostJob: Bool = false,
        interviews: [Interview] = [],
        contactIDs: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.status = status
        self.dateApplied = dateApplied
        self.description = description
        self.salary = salary
        self.location = location
        self.notes = notes
        self.url = url
        self.isGhostJob = isGhostJob
        self.interviews = interviews
        self.contactIDs = contactIDs
    }
}

enum ApplicationStatus: String, CaseIterable, Codable {
    case applied = "Applied"
    case interviewing = "Interviewing"
    case offer = "Offer"
    case rejected = "Rejected"
    case accepted = "Accepted"
    
    var color: Color {
        switch self {
        case .applied:
            return Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        case .interviewing:
            return Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
        case .offer:
            return Color(red: 1.0, green: 0.58, blue: 0.0) // Orange
        case .rejected:
            return Color(red: 1.0, green: 0.23, blue: 0.19) // Red
        case .accepted:
            return Color(red: 0.35, green: 0.34, blue: 0.84) // Purple
        }
    }
    
    var backgroundColor: Color {
        color.opacity(0.15)
    }
}
