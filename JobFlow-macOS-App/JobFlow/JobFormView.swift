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
    
    @StateObject private var urlParser = JobURLParser()
    @State private var showingURLImport = false
    @State private var isImporting = false
    
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
                                Text(showingURLImport ? "Hide URL Import" : "Import from URL")
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
                    onImport: { importedJob in
                        title = importedJob.title
                        company = importedJob.company
                        location = importedJob.location
                        salary = importedJob.salary
                        description = importedJob.description
                        notes = importedJob.notes
                    }
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
                notes: notes
            )
            
            jobStore.addJob(newJob)
        }
        
        dismiss()
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
    let onImport: (JobApplication) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    .font(.system(size: 16))
                
                Text("Import Job from URL")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // URL Input
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    if jobURL.isEmpty {
                        Text("Paste job posting URL (LinkedIn, Indeed, etc.)")
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
                
                Button(action: importFromURL) {
                    HStack(spacing: 6) {
                        if isImporting {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 14))
                        }
                        Text(isImporting ? "Importing..." : "Import")
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
            }
            
            // Supported boards hint
            if !jobURL.isEmpty {
                HStack(spacing: 6) {
                    if let boardName = urlParser.getSupportedBoardName(jobURL) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .font(.system(size: 12))
                        Text("Supported: \(boardName)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    } else if urlParser.isURLSupported(jobURL) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .font(.system(size: 12))
                        Text("Supported job board")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    } else {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 12))
                        Text("Will attempt to extract basic info")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
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
                    
                    Text("🏢 ATS Systems:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text("Greenhouse, Lever, Workday, Taleo, iCIMS, BambooHR")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.top, 8)
            } label: {
                HStack {
                    Text("View 30+ supported job boards")
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
                    onImport(job)
                    isImporting = false
                }
            } else {
                await MainActor.run {
                    isImporting = false
                }
            }
        }
    }
}
