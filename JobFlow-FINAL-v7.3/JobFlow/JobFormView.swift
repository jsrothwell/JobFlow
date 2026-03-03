import SwiftUI

struct JobFormView: View {
    @EnvironmentObject var jobStore: JobStore
    @Environment(\.dismiss) var dismiss
    
    let editingJob: JobApplication?
    
    @State private var title: String
    @State private var company: String
    @State private var status: ApplicationStatus
    @State private var dateApplied: Date
    @State private var description: String
    @State private var salary: String
    @State private var location: String
    @State private var notes: String
    @State private var jobURL: String = ""
    @State private var isGhostJob: Bool = false
    
    @StateObject private var urlParser = JobURLParser()
    @State private var showingURLImport = false
    @State private var isImporting = false
    @State private var isImportingDetails = false
    
    init(job: JobApplication? = nil) {
        self.editingJob = job
        _title = State(initialValue: job?.title ?? "")
        _company = State(initialValue: job?.company ?? "")
        _status = State(initialValue: job?.status ?? .applied)
        _dateApplied = State(initialValue: job?.dateApplied ?? Date())
        _description = State(initialValue: job?.description ?? "")
        _salary = State(initialValue: job?.salary ?? "")
        _location = State(initialValue: job?.location ?? "")
        _notes = State(initialValue: job?.notes ?? "")
        _jobURL = State(initialValue: job?.url ?? "")
        _isGhostJob = State(initialValue: job?.isGhostJob ?? false)
    }
    
    var isValid: Bool {
        !title.isEmpty && !company.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(editingJob == nil ? "New Application" : "Edit Application")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    if editingJob == nil {
                        Button(action: {
                            showingURLImport.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showingURLImport ? "chevron.up" : "link")
                                    .font(.system(size: 12))
                                Text(showingURLImport ? "Hide URL Saver" : "Save from URL")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.16, green: 0.18, blue: 0.22).opacity(0.95),
                        Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // URL Import Section (Collapsible)
            if showingURLImport {
                URLImportSection(
                    jobURL: $jobURL,
                    urlParser: urlParser,
                    isImporting: $isImporting,
                    isImportingDetails: $isImportingDetails,
                    onImport: { importedJob in
                        title = importedJob.title
                        company = importedJob.company
                        location = importedJob.location
                        salary = importedJob.salary
                        description = importedJob.description
                        notes = importedJob.notes
                    },
                    onImportDetails: importDetailsFromURL
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Information
                    FormSection(title: "Basic Information") {
                        FormTextField(label: "Job Title", text: $title, placeholder: "e.g., Senior Product Designer")
                        FormTextField(label: "Company", text: $company, placeholder: "e.g., Apple")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            HStack(spacing: 4) {
                                ForEach(ApplicationStatus.allCases, id: \.self) { statusOption in
                                    Button(action: {
                                        status = statusOption
                                    }) {
                                        Text(statusOption.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(status == statusOption ? .white : Color.white.opacity(0.6))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 6)
                                            .background(
                                                status == statusOption
                                                    ? statusOption.color
                                                    : Color.white.opacity(0.05)
                                            )
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(4)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date Applied")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            DatePicker("", selection: $dateApplied, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        }
                        
                        // Ghost Job Flag
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $isGhostJob) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                    Text("Flag as Ghost Job")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .toggleStyle(.switch)
                            .tint(.orange)
                            
                            if isGhostJob {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("This job will be reported to ghostjobs.io")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Helps track fake/inactive job postings")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(10)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(6)
                            }
                        }
                    }
                    
                    // Job Details
                    FormSection(title: "Job Details") {
                        FormTextField(label: "Salary Range", text: $salary, placeholder: "e.g., $120,000 - $180,000")
                        FormTextField(label: "Location", text: $location, placeholder: "e.g., San Francisco, CA")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Describe the role, responsibilities, requirements...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .frame(height: 100)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(Color.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Add personal notes, interview details, follow-ups...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $notes)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .frame(height: 100)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(Color.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color(red: 0.12, green: 0.13, blue: 0.17))
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: saveJob) {
                    Text(editingJob == nil ? "Add Application" : "Save Changes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            isValid
                                ? Color(red: 0.0, green: 0.48, blue: 1.0)
                                : Color.white.opacity(0.1)
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!isValid)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.16, green: 0.18, blue: 0.22).opacity(0.95),
                        Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.6)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .frame(width: 600, height: 700)
        .background(Color(red: 0.12, green: 0.13, blue: 0.17))
    }
    
    private func saveJob() {
        if let editingJob = editingJob {
            // Update existing job
            var updatedJob = editingJob
            updatedJob.title = title
            updatedJob.company = company
            updatedJob.status = status
            updatedJob.dateApplied = dateApplied
            updatedJob.description = description
            updatedJob.salary = salary
            updatedJob.location = location
            updatedJob.notes = notes
            updatedJob.url = jobURL
            updatedJob.isGhostJob = isGhostJob
            
            // Submit to ghostjobs.io if flagged
            if isGhostJob {
                Task {
                    let success = await urlParser.submitGhostJob(updatedJob)
                    if success {
                        print("Ghost job reported to ghostjobs.io successfully")
                    }
                }
            }
            
            jobStore.updateJob(updatedJob)
        } else {
            // Create new job
            let newJob = JobApplication(
                title: title,
                company: company,
                status: status,
                dateApplied: dateApplied,
                description: description,
                salary: salary,
                location: location,
                notes: notes,
                url: jobURL,
                isGhostJob: isGhostJob
            )
            
            // Submit to ghostjobs.io if flagged
            if isGhostJob {
                Task {
                    let success = await urlParser.submitGhostJob(newJob)
                    if success {
                        print("Ghost job reported to ghostjobs.io successfully")
                    }
                }
            }
            
            jobStore.addJob(newJob)
        }
        
        dismiss()
    }
    
    private func importDetailsFromURL() {
        guard !jobURL.isEmpty else { return }
        
        isImportingDetails = true
        
        Task {
            if let importedJob = await urlParser.importJobDetails(from: jobURL) {
                await MainActor.run {
                    // Update form fields with imported data
                    if !importedJob.title.isEmpty {
                        title = importedJob.title
                    }
                    if !importedJob.company.isEmpty && !importedJob.company.hasPrefix("From ") {
                        company = importedJob.company
                    }
                    if !importedJob.description.isEmpty {
                        description = importedJob.description
                    }
                    if !importedJob.location.isEmpty {
                        location = importedJob.location
                    }
                    if !importedJob.salary.isEmpty {
                        salary = importedJob.salary
                    }
                    
                    isImportingDetails = false
                }
            } else {
                await MainActor.run {
                    isImportingDetails = false
                }
            }
        }
    }
}

struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                content
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.3),
                    Color(red: 0.23, green: 0.25, blue: 0.31).opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct FormTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.4))
                        .padding(.leading, 12)
                }
                
                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(12)
            }
            .background(Color.black.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

#Preview {
    JobFormView()
        .environmentObject(JobStore())
}

// MARK: - URL Import Section
struct URLImportSection: View {
    @Binding var jobURL: String
    @ObservedObject var urlParser: JobURLParser
    @Binding var isImporting: Bool
    @Binding var isImportingDetails: Bool
    let onImport: (JobApplication) -> Void
    let onImportDetails: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Save Job URL")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Paste a job posting URL to save it and detect the company")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            // URL Input
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    if jobURL.isEmpty {
                        Text("Paste job posting URL (company name will be auto-detected from some URLs)")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.4))
                            .padding(.leading, 12)
                    }
                    
                    TextField("", text: $jobURL)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(10)
                        .disabled(isImporting)
                }
                .background(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            urlParser.isURLSupported(jobURL) && !jobURL.isEmpty
                                ? Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.5)
                                : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .cornerRadius(8)
                
                HStack(spacing: 12) {
                    Button(action: importFromURL) {
                        HStack(spacing: 6) {
                            if isImporting {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 14, height: 14)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isImporting ? "Saving..." : "Save URL")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            jobURL.isEmpty || isImporting
                                ? Color.white.opacity(0.1)
                                : Color(red: 0.0, green: 0.48, blue: 1.0)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(jobURL.isEmpty || isImporting)
                    
                    Button(action: onImportDetails) {
                        HStack(spacing: 6) {
                            if isImportingDetails {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 14, height: 14)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isImportingDetails ? "Importing..." : "Import Details")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            jobURL.isEmpty || isImportingDetails
                                ? Color.white.opacity(0.1)
                                : Color.green
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(jobURL.isEmpty || isImportingDetails)
                }
            }
            
            // Supported boards hint
            if !jobURL.isEmpty {
                HStack(spacing: 6) {
                    if let boardName = urlParser.getSupportedBoardName(jobURL) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .font(.system(size: 12))
                        Text("Recognized: \(boardName)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    } else if urlParser.isURLSupported(jobURL) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .font(.system(size: 12))
                        Text("Recognized job board - URL will be saved")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    } else {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 12))
                        Text("URL will be saved to notes")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    Spacer()
                }
            }
            
            // Success message
            if let success = urlParser.successMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                        .font(.system(size: 12))
                    Text(success)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    Spacer()
                }
            }
            
            // Error message
            if let error = urlParser.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.19))
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.19))
                    Spacer()
                }
            }
            
            // Supported boards list
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .font(.system(size: 12))
                        Text("This feature saves the URL and extracts company names from ATS platforms")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 8)
                    
                    Text("🇨🇦 Canadian:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Indeed.ca, Job Bank Canada, Workopolis, Eluta, CharityVillage")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Text("🌎 International:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text("LinkedIn, Indeed, Glassdoor, Monster, ZipRecruiter, Stack Overflow")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Text("🏢 ATS (Company extracted from URL):")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text("Greenhouse, Lever, Workday, Taleo, iCIMS, BambooHR, Breezy")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.top, 8)
            } label: {
                HStack {
                    Text("View supported job boards & ATS platforms")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    Spacer()
                }
            }
            .accentColor(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.08),
                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    private func importFromURL() {
        isImporting = true
        
        Task {
            if let job = await urlParser.parseJobURL(jobURL) {
                await MainActor.run {
                    // Actually populate the form fields
                    onImport(job)
                    isImporting = false
                    // Clear the URL field after successful import
                    jobURL = ""
                }
            } else {
                await MainActor.run {
                    isImporting = false
                }
            }
        }
    }
}
