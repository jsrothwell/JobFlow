import SwiftUI

struct JobDetailView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var job: JobApplication
    @State private var isEditing = false
    @State private var showDeleteConfirm = false

    init(job: JobApplication) {
        _job = State(initialValue: job)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    if !job.url.isEmpty { urlSection }
                    statusSection
                    if !job.notes.isEmpty || isEditing { notesSection }
                    if !job.salary.isEmpty { infoRow(icon: "dollarsign.circle.fill", label: "Salary", value: job.salary) }
                    if !job.location.isEmpty { infoRow(icon: "mappin.circle.fill", label: "Location", value: job.location) }
                    interviewsSection
                    Spacer(minLength: 40)
                    deleteButton
                }
                .padding(20)
            }
            .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing { jobStore.updateJob(job) }
                        isEditing.toggle()
                    }
                    .fontWeight(isEditing ? .semibold : .regular)
                }
            }
            .alert("Delete Job?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    jobStore.deleteJob(job)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove \(job.title) at \(job.company).")
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.company)
                .font(.title2.weight(.bold))
                .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))

            if isEditing {
                TextField("Job Title", text: $job.title)
                    .font(.body)
                    .foregroundStyle(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(job.title.isEmpty ? "Untitled Position" : job.title)
                    .font(.body)
                    .foregroundStyle(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }

            HStack(spacing: 8) {
                StatusBadge(status: job.status)
                Text("Applied \(job.dateString)")
                    .font(.caption)
                    .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))
            }
        }
    }

    private var urlSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Job Posting", systemImage: "link")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))

            if let url = URL(string: job.url) {
                Link(destination: url) {
                    Text(job.url)
                        .font(.subheadline)
                        .foregroundStyle(ThemeColors.accentBlue)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ApplicationStatus.allCases, id: \.self) { status in
                        Button {
                            job.status = status
                            if !isEditing { jobStore.updateJob(job) }
                        } label: {
                            Text(status.rawValue)
                                .font(.subheadline.weight(job.status == status ? .semibold : .regular))
                                .foregroundStyle(job.status == status ? .white : status.color)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(job.status == status ? status.color : status.color.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))

            if isEditing {
                TextEditor(text: $job.notes)
                    .frame(minHeight: 80)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            } else {
                Text(job.notes)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var interviewsSection: some View {
        if !job.interviews.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label("Interviews", systemImage: "person.2.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))

                ForEach(job.interviews) { interview in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(interview.round.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))
                            Text(interview.dateString)
                                .font(.caption)
                                .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))
                        }
                        Spacer()
                        Text(interview.outcome.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(interview.outcome.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(interview.outcome.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(ThemeColors.accentBlue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(ThemeColors.textTertiary(for: themeManager.currentTheme))
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColors.textPrimary(for: themeManager.currentTheme))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete Job", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.red)
        }
        .buttonStyle(.plain)
    }
}
