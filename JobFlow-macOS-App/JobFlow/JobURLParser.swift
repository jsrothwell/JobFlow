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
        
        // Save the URL in the url field
        job.url = url.absoluteString
        
        // Save minimal info in notes
        job.notes = "📎 Saved from job posting\n\n"
        
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
        job.notes += "4. Use 'Import from URL' to auto-fill details!"
        
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
        
        // Not a ghost job by default
        job.isGhostJob = false
        
        return job
    }
    
    // New method to import full job details from URL
    func importJobDetails(from urlString: String) async -> JobApplication? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Fetch the webpage content
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                let job = parseHTMLForJobDetails(html: html, url: url)
                
                await MainActor.run {
                    isLoading = false
                    successMessage = "Job details imported successfully!"
                }
                
                return job
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Could not fetch job details. Please fill manually."
            }
        }
        
        return nil
    }
    
    private func parseHTMLForJobDetails(html: String, url: URL) -> JobApplication {
        var job = extractJobInfo(from: url)
        
        // Simple HTML parsing for common job posting patterns
        // Extract title
        if let titleMatch = extractBetween(html, start: "<title>", end: "</title>") {
            let cleanTitle = titleMatch
                .replacingOccurrences(of: " - \\w+", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanTitle.isEmpty {
                job.title = cleanTitle
            }
        }
        
        // Extract description from common meta tags
        if let descMatch = extractBetween(html, start: "description\" content=\"", end: "\"") {
            job.description = descMatch
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&amp;", with: "&")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Try to extract salary
        let salaryPatterns = [
            "\\$[0-9,]+(k|K)?\\s*-\\s*\\$[0-9,]+(k|K)?",
            "\\$[0-9,]+(k|K)?\\+?",
            "[0-9,]+\\s*-\\s*[0-9,]+\\s*per\\s*(year|hour|month)"
        ]
        
        for pattern in salaryPatterns {
            if let range = html.range(of: pattern, options: .regularExpression) {
                job.salary = String(html[range])
                break
            }
        }
        
        return job
    }
    
    private func extractBetween(_ text: String, start: String, end: String) -> String? {
        guard let startRange = text.range(of: start),
              let endRange = text[startRange.upperBound...].range(of: end) else {
            return nil
        }
        
        return String(text[startRange.upperBound..<endRange.lowerBound])
    }
    
    // Submit ghost job to ghostjobs.io
    func submitGhostJob(_ job: JobApplication) async -> Bool {
        guard let url = URL(string: "https://ghostjobs.io/api/report") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "jobTitle": job.title,
            "company": job.company,
            "url": job.url,
            "datePosted": ISO8601DateFormatter().string(from: job.dateApplied),
            "location": job.location,
            "salary": job.salary
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200 || httpResponse.statusCode == 201
            }
        } catch {
            print("Error submitting ghost job: \(error)")
        }
        
        return false
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
