import Foundation
import SwiftUI

class JobURLParser: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Supported job boards and their URL patterns
    private let supportedPatterns = [
        // North American Boards
        "linkedin.com",
        "indeed.com",
        "indeed.ca",
        "glassdoor.com",
        "glassdoor.ca",
        "monster.com",
        "monster.ca",
        "ziprecruiter.com",
        "careerbuilder.com",
        
        // Canadian Specific
        "jobbank.gc.ca",
        "workopolis.com",
        "eluta.ca",
        "charity village.com",
        "canadajobs.com",
        
        // Tech Focused
        "stackoverflow.com/jobs",
        "github.com/jobs",
        "angel.co",
        "wellfound.com",
        "dice.com",
        "hired.com",
        "triplebyte.com",
        
        // International
        "seek.com.au",
        "seek.co.nz",
        "totaljobs.com",
        "reed.co.uk",
        "cv-library.co.uk",
        
        // Company Career Pages
        "greenhouse.io",
        "lever.co",
        "workday.com",
        "taleo.net",
        "icims.com",
        "myworkdayjobs.com",
        "successfactors.com",
        "brassring.com",
        "ultipro.com",
        "paylocity.com",
        "bamboohr.com"
    ]
    
    func parseJobURL(_ urlString: String) async -> JobApplication? {
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                errorMessage = "Invalid URL format"
            }
            return nil
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Check if URL is from a supported job board
        let host = url.host?.lowercased() ?? ""
        let isSupportedBoard = supportedPatterns.contains { pattern in
            host.contains(pattern.lowercased())
        }
        
        if !isSupportedBoard {
            await MainActor.run {
                isLoading = false
            }
            // Still allow it, but with limited parsing
            return parseGenericURL(url)
        }
        
        // Parse based on job board
        let job = await parseSpecificJobBoard(url: url, host: host)
        
        await MainActor.run {
            isLoading = false
        }
        
        return job
    }
    
    private func parseSpecificJobBoard(url: URL, host: String) async -> JobApplication {
        var job = JobApplication()
        job.notes = "Imported from: \(url.absoluteString)"
        
        // LinkedIn
        if host.contains("linkedin.com") {
            return await parseLinkedIn(url: url, job: job)
        }
        
        // Indeed
        if host.contains("indeed.com") || host.contains("indeed.ca") {
            return await parseIndeed(url: url, job: job)
        }
        
        // Glassdoor
        if host.contains("glassdoor.com") || host.contains("glassdoor.ca") {
            return await parseGlassdoor(url: url, job: job)
        }
        
        // Government of Canada Job Bank
        if host.contains("jobbank.gc.ca") {
            return await parseJobBank(url: url, job: job)
        }
        
        // Greenhouse (ATS)
        if host.contains("greenhouse.io") {
            return await parseGreenhouse(url: url, job: job)
        }
        
        // Lever (ATS)
        if host.contains("lever.co") {
            return await parseLever(url: url, job: job)
        }
        
        // Workday (ATS)
        if host.contains("myworkdayjobs.com") || host.contains("workday.com") {
            return await parseWorkday(url: url, job: job)
        }
        
        // Generic parsing for other boards
        return await parseGenericJobBoard(url: url, job: job)
    }
    
    // MARK: - LinkedIn Parser
    private func parseLinkedIn(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        // Try to fetch the page
        guard let html = await fetchHTML(from: url) else {
            return parseLinkedInFromURL(url: url, job: job)
        }
        
        // Extract job title
        if let titleRange = html.range(of: #"<h1[^>]*class="[^"]*top-card-layout__title[^"]*"[^>]*>(.*?)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        // Extract company name
        if let companyRange = html.range(of: #"<a[^>]*class="[^"]*topcard__org-name-link[^"]*"[^>]*>(.*?)</a>"#, options: .regularExpression) {
            let companyHTML = String(html[companyRange])
            result.company = cleanHTML(companyHTML)
        }
        
        // Extract location
        if let locationRange = html.range(of: #"<span[^>]*class="[^"]*topcard__flavor[^"]*"[^>]*>(.*?)</span>"#, options: .regularExpression) {
            let locationHTML = String(html[locationRange])
            result.location = cleanHTML(locationHTML)
        }
        
        // Extract description
        if let descRange = html.range(of: #"<div[^>]*class="[^"]*description__text[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let descHTML = String(html[descRange])
            result.description = cleanHTML(descHTML).prefix(500).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
        }
        
        return result
    }
    
    private func parseLinkedInFromURL(url: URL, job: JobApplication) -> JobApplication {
        var result = job
        
        // Extract from URL path if possible
        let pathComponents = url.pathComponents
        if let viewIndex = pathComponents.firstIndex(of: "view"),
           viewIndex + 1 < pathComponents.count {
            // Job ID is usually after "view"
            let jobId = pathComponents[viewIndex + 1]
            result.notes += "\nJob ID: \(jobId)"
        }
        
        return result
    }
    
    // MARK: - Indeed Parser
    private func parseIndeed(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            return result
        }
        
        // Extract job title
        if let titleRange = html.range(of: #"<h1[^>]*class="[^"]*jobsearch-JobInfoHeader-title[^"]*"[^>]*>(.*?)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        // Extract company
        if let companyRange = html.range(of: #"<div[^>]*class="[^"]*jobsearch-InlineCompanyRating[^"]*"[^>]*>.*?<a[^>]*>(.*?)</a>"#, options: .regularExpression) {
            let companyHTML = String(html[companyRange])
            result.company = cleanHTML(companyHTML)
        }
        
        // Extract location
        if let locationRange = html.range(of: #"<div[^>]*class="[^"]*jobsearch-JobInfoHeader-subtitle[^"]*"[^>]*>.*?<div[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let locationHTML = String(html[locationRange])
            result.location = cleanHTML(locationHTML)
        }
        
        // Extract salary if available
        if let salaryRange = html.range(of: #"<div[^>]*class="[^"]*salary-snippet[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let salaryHTML = String(html[salaryRange])
            result.salary = cleanHTML(salaryHTML)
        }
        
        return result
    }
    
    // MARK: - Glassdoor Parser
    private func parseGlassdoor(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            return result
        }
        
        // Extract job title
        if let titleRange = html.range(of: #"<div[^>]*class="[^"]*jobTitle[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        // Extract company
        if let companyRange = html.range(of: #"<div[^>]*class="[^"]*employerName[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let companyHTML = String(html[companyRange])
            result.company = cleanHTML(companyHTML)
        }
        
        // Extract location
        if let locationRange = html.range(of: #"<div[^>]*class="[^"]*location[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let locationHTML = String(html[locationRange])
            result.location = cleanHTML(locationHTML)
        }
        
        // Extract salary
        if let salaryRange = html.range(of: #"<span[^>]*class="[^"]*salary[^"]*"[^>]*>(.*?)</span>"#, options: .regularExpression) {
            let salaryHTML = String(html[salaryRange])
            result.salary = cleanHTML(salaryHTML)
        }
        
        return result
    }
    
    // MARK: - Job Bank Canada Parser
    private func parseJobBank(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            return result
        }
        
        // Job Bank has specific structure
        if let titleRange = html.range(of: #"<h1[^>]*id="jb-jobtitle"[^>]*>(.*?)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        if let companyRange = html.range(of: #"<span[^>]*class="[^"]*noc-no-wrap[^"]*"[^>]*>(.*?)</span>"#, options: .regularExpression) {
            let companyHTML = String(html[companyRange])
            result.company = cleanHTML(companyHTML)
        }
        
        result.location = "Canada" // Job Bank is Canadian
        
        return result
    }
    
    // MARK: - Greenhouse Parser
    private func parseGreenhouse(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            // Try to extract company from subdomain
            if let host = url.host,
               let companyName = host.components(separatedBy: ".").first {
                result.company = companyName.capitalized
            }
            return result
        }
        
        // Greenhouse has consistent structure
        if let titleRange = html.range(of: #"<h1[^>]*class="[^"]*app-title[^"]*"[^>]*>(.*?)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        // Company is usually in subdomain
        if let host = url.host,
           let companyName = host.components(separatedBy: ".").first {
            result.company = companyName.capitalized.replacingOccurrences(of: "-", with: " ")
        }
        
        // Extract location
        if let locationRange = html.range(of: #"<div[^>]*class="[^"]*location[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let locationHTML = String(html[locationRange])
            result.location = cleanHTML(locationHTML)
        }
        
        return result
    }
    
    // MARK: - Lever Parser
    private func parseLever(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        // Extract company from subdomain
        if let host = url.host,
           let companyName = host.components(separatedBy: ".").first {
            result.company = companyName.capitalized.replacingOccurrences(of: "-", with: " ")
        }
        
        guard let html = await fetchHTML(from: url) else {
            return result
        }
        
        // Lever structure
        if let titleRange = html.range(of: #"<h2[^>]*class="[^"]*posting-headline[^"]*"[^>]*>(.*?)</h2>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        if let locationRange = html.range(of: #"<div[^>]*class="[^"]*location[^"]*"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            let locationHTML = String(html[locationRange])
            result.location = cleanHTML(locationHTML)
        }
        
        return result
    }
    
    // MARK: - Workday Parser
    private func parseWorkday(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            return result
        }
        
        // Workday uses complex structure
        if let titleRange = html.range(of: #"<h1[^>]*data-automation-id="jobPostingHeader"[^>]*>(.*?)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleRange])
            result.title = cleanHTML(titleHTML)
        }
        
        // Company from subdomain or title
        if let host = url.host {
            let parts = host.components(separatedBy: ".")
            if parts.count > 0 {
                result.company = parts[0].capitalized.replacingOccurrences(of: "-", with: " ")
            }
        }
        
        return result
    }
    
    // MARK: - Generic Parser
    private func parseGenericJobBoard(url: URL, job: JobApplication) async -> JobApplication {
        var result = job
        
        guard let html = await fetchHTML(from: url) else {
            return parseGenericURL(url)
        }
        
        // Try common patterns for job title
        let titlePatterns = [
            #"<h1[^>]*>(.*?)</h1>"#,
            #"<title>(.*?)</title>"#,
            #"<meta[^>]*property="og:title"[^>]*content="([^"]*)"#
        ]
        
        for pattern in titlePatterns {
            if let range = html.range(of: pattern, options: .regularExpression) {
                let matched = String(html[range])
                let cleaned = cleanHTML(matched)
                if !cleaned.isEmpty && cleaned.count > 5 {
                    result.title = cleaned
                    break
                }
            }
        }
        
        return result
    }
    
    private func parseGenericURL(_ url: URL) -> JobApplication {
        var job = JobApplication()
        job.notes = "Imported from: \(url.absoluteString)"
        
        // Try to extract company from domain
        if let host = url.host {
            let parts = host.components(separatedBy: ".")
            if parts.count > 1 {
                // Get the main domain (e.g., "company" from "company.com")
                let companyPart = parts[parts.count - 2]
                job.company = companyPart.capitalized
            }
        }
        
        return job
    }
    
    // MARK: - Helper Methods
    private func fetchHTML(from url: URL) async -> String? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error fetching URL: \(error)")
            return nil
        }
    }
    
    private func cleanHTML(_ html: String) -> String {
        var cleaned = html
        
        // Remove HTML tags
        cleaned = cleaned.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        
        // Decode HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        
        // Clean up whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        return cleaned
    }
    
    func isURLSupported(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return false
        }
        
        return supportedPatterns.contains { pattern in
            host.contains(pattern.lowercased())
        }
    }
    
    func getSupportedBoardName(_ urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return nil
        }
        
        if host.contains("linkedin.com") { return "LinkedIn" }
        if host.contains("indeed.com") || host.contains("indeed.ca") { return "Indeed" }
        if host.contains("glassdoor") { return "Glassdoor" }
        if host.contains("jobbank.gc.ca") { return "Job Bank Canada" }
        if host.contains("greenhouse.io") { return "Greenhouse" }
        if host.contains("lever.co") { return "Lever" }
        if host.contains("workday") { return "Workday" }
        if host.contains("monster") { return "Monster" }
        if host.contains("ziprecruiter") { return "ZipRecruiter" }
        
        return "Job Board"
    }
}
