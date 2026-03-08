import SwiftUI

struct ShareView: View {
    let sharedURL: String
    let pageTitle: String
    let onSave: (JobApplication) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var company = ""
    @State private var status: ApplicationStatus = .applied

    init(
        sharedURL: String,
        pageTitle: String,
        onSave: @escaping (JobApplication) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.sharedURL = sharedURL
        self.pageTitle = pageTitle
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: pageTitle)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Job URL") {
                    Text(sharedURL.isEmpty ? "No URL captured" : sharedURL)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .lineLimit(2)
                }

                Section("Job Details") {
                    TextField("Job Title", text: $title)
                    TextField("Company", text: $company)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(ApplicationStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add to Jobflo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(company.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let job = JobApplication(
            title: title.trimmingCharacters(in: .whitespaces),
            company: company.trimmingCharacters(in: .whitespaces),
            status: status,
            notes: "",
            url: sharedURL.trimmingCharacters(in: .whitespaces)
        )
        onSave(job)
    }
}
