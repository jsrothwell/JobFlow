import SwiftUI

struct AddJobView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var company = ""
    @State private var url = ""
    @State private var status: ApplicationStatus = .applied
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Job Details") {
                    TextField("Job Title", text: $title)
                    TextField("Company", text: $company)
                    TextField("Job URL (optional)", text: $url)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(ApplicationStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
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
            notes: notes.trimmingCharacters(in: .whitespaces),
            url: url.trimmingCharacters(in: .whitespaces)
        )
        jobStore.addJob(job)
        dismiss()
    }
}
