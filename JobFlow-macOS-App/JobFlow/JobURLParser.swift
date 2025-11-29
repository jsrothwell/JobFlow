import Foundation
import SwiftUI

class JobURLParser: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Supported job boards and their URL patterns
    private let supportedPatterns: [String: String] = [
        // North American Boards
        "linkedin.com": "LinkedIn",
        "indeed.com": "Indeed",
        "indeed.ca": "Indeed Canada",
        "glassdoor.com": "Glassdoor",
        "glassdoor.ca": "Glassdoor Canada",
        "monster.com": "Monster",
        "monster.ca": "Monster Canada",
        "ziprecruiter.com": "ZipRecruiter",
        "careerbuilder.com": "CareerBuilder",
        
        // Canadian Specific
        "jobbank.gc.ca": "Job Bank Canada",
        "workopolis.com": "Workopolis",
        "eluta.ca": "Eluta",
        "charityvillage.com": "CharityVillage",
        "canadajobs.com": "CanadaJobs",
        
        // Tech Focused
        "stackoverflow.com": "Stack Overflow",
        "github.com": "GitHub Jobs",
        "angel.co": "AngelList",
        "wellfound.com": "Wellfound",
        "dice.com": "Dice",
        "hired.com": "Hired",
        
        // International
        "seek.com.au": "SEEK Australia",
        "seek.co.nz": "SEEK New Zealand",
        "totaljobs.com": "TotalJobs UK",
        "reed.co.uk": "Reed UK",
        "cv-library.co.uk": "CV-Library UK",
        
        // Company Career Pages / ATS
        "greenhouse.io": "Greenhouse",
        "lever.co": "Lever",
        "workday.com": "Workday",
        "myworkdayjobs.com": "Workday",
        "taleo.net": "Taleo",
        "icims.com": "iCIMS",
        "bamboohr.com": "BambooHR",
        "successfactors.com": "SuccessFactors",
        "brassring.com": "Brassring",
        "ultipro.com": "UltiPro",
        "paylocity.com": "Paylocity"
    ]
    
    func parseJobURL(_ urlString: String) async -> JobApplication? {
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                errorMessage = "Invalid URL format. Please enter a complete URL starting with https://"
                successMessage = nil
            }
            return nil
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        
        // Small delay for UX feedback
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let job = extractJobInfo(from: url)
        
        await MainActor.run {
            isLoading = false
            if job.company.isEmpty || job.company == "Unknown Company" {
                successMessage = "URL saved! Please fill in the job details from the posting."
            } else {
                successMessage = "Company detected! Fill in the job title and other details."
            }
        }
        
        return job
    }
    
    private func extractJobInfo(from url: URL) -> JobApplication {
        var job = JobApplication()
        let host = url.host?.lowercased() ?? ""
        
        // Save the URL in notes
        job.notes = "📎 Job Posting: \(url.absoluteString)\n\n"
        
        // Detect the job board
        var boardName: String?
        for (pattern, name) in supportedPatterns {
            if host.contains(pattern.lowercased()) {
                boardName = name
                break
            }
        }
        
        // Extract company from URL based on the platform
        if host.contains("greenhouse.io") {
            // Greenhouse: company.greenhouse.io/jobs/...
            if let companyName = host.components(separatedBy: ".").first {
                job.company = formatCompanyName(companyName)
                job.notes += "💼 Company extracted from Greenhouse URL\n"
            }
        } else if host.contains("lever.co") {
            // Lever: jobs.lever.co/company/...
            let pathComponents = url.pathComponents
            if pathComponents.count > 1 {
                let companyPart = pathComponents[1]
                job.company = formatCompanyName(companyPart)
                job.notes += "💼 Company extracted from Lever URL\n"
            }
        } else if host.contains("myworkdayjobs.com") {
            // Workday: company.myworkdayjobs.com/...
            if let companyName = host.components(separatedBy: ".").first {
                job.company = formatCompanyName(companyName)
                job.notes += "💼 Company extracted from Workday URL\n"
            }
        } else if host.contains("breezy.hr") {
            // Breezy: company.breezy.hr/...
            if let companyName = host.components(separatedBy: ".").first {
                job.company = formatCompanyName(companyName)
                job.notes += "💼 Company extracted from Breezy URL\n"
            }
        } else if let board = boardName {
            // For job boards, use the board name as a placeholder
            job.company = "From \(board)"
            job.notes += "🔍 Found on: \(board)\n"
        } else {
            // Try to extract from domain for direct company websites
            let parts = host.components(separatedBy: ".")
            if parts.count >= 2 {
                let companyPart = parts[parts.count - 2]
                if companyPart != "com" && companyPart != "co" {
                    job.company = formatCompanyName(companyPart)
                    job.notes += "💼 Company extracted from URL\n"
                }
            }
        }
        
        // Add helpful instructions
        job.notes += "\n📝 Next Steps:\n"
        job.notes += "1. Fill in the job title above\n"
        job.notes += "2. Add salary and location if shown on posting\n"
        job.notes += "3. Copy key details from the job description\n"
        job.notes += "4. Click the URL anytime to return to the posting!"
        
        // Leave title empty so user fills it in
        job.title = ""
        
        // Set location placeholder
        job.location = ""
        
        // Set salary placeholder
        job.salary = ""
        
        // Set description placeholder
        job.description = ""
        
        // Set date to today
        job.dateApplied = Date()
        
        // Default status
        job.status = .applied
        
        return job
    }
    
    private func formatCompanyName(_ rawName: String) -> String {
        // Remove hyphens and underscores, capitalize words
        let cleaned = rawName
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
        
        // Capitalize each word
        let words = cleaned.components(separatedBy: " ")
        let capitalized = words.map { word in
            word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
        
        return capitalized
    }
    
    func isURLSupported(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return false
        }
        
        return supportedPatterns.keys.contains { pattern in
            host.contains(pattern.lowercased())
        }
    }
    
    func getSupportedBoardName(_ urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return nil
        }
        
        for (pattern, name) in supportedPatterns {
            if host.contains(pattern.lowercased()) {
                return name
            }
        }
        
        return nil
    }
}
