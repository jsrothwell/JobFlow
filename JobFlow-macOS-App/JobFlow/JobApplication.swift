import Foundation
import SwiftUI

struct JobApplication: Identifiable, Hashable {
    let id = UUID()
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
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: dateApplied)
    }
    
    // Initialize with empty values
    init(
        title: String = "",
        company: String = "",
        status: ApplicationStatus = .applied,
        dateApplied: Date = Date(),
        description: String = "",
        salary: String = "",
        location: String = "",
        notes: String = "",
        url: String = "",
        isGhostJob: Bool = false
    ) {
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
    }
}

enum ApplicationStatus: String, CaseIterable {
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
