import SwiftUI

struct ContactFormView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    let editingContact: Contact?
    
    @State private var name: String
    @State private var role: ContactRole
    @State private var title: String
    @State private var company: String
    @State private var email: String
    @State private var phone: String
    @State private var linkedInURL: String
    @State private var notes: String
    @State private var tags: [String]
    @State private var newTag: String = ""
    
    init(contact: Contact? = nil) {
        self.editingContact = contact
        
        _name = State(initialValue: contact?.name ?? "")
        _role = State(initialValue: contact?.role ?? .recruiter)
        _title = State(initialValue: contact?.title ?? "")
        _company = State(initialValue: contact?.company ?? "")
        _email = State(initialValue: contact?.email ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _linkedInURL = State(initialValue: contact?.linkedInURL ?? "")
        _notes = State(initialValue: contact?.notes ?? "")
        _tags = State(initialValue: contact?.tags ?? [])
    }
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(editingContact == nil ? "Add Contact" : "Edit Contact")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Text("Track recruiters, hiring managers, and referrers")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
            
            // Form Content
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Information")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        TextField("Full Name *", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        
                        TextField("Job Title", text: $title)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                        
                        TextField("Company", text: $company)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Role
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Role")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(ContactRole.allCases, id: \.self) { roleType in
                                Button(action: {
                                    role = roleType
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: roleType.icon)
                                            .font(.system(size: 14))
                                        Text(roleType.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(role == roleType ? .white : ThemeColors.textPrimary(for: themeManager.currentTheme))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(role == roleType ? roleType.color : ThemeColors.inputBackground(for: themeManager.currentTheme))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Contact Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Details")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            TextField("Email", text: $email)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "phone")
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            TextField("Phone", text: $phone)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                            TextField("LinkedIn URL", text: $linkedInURL)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        if !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags.indices, id: \.self) { index in
                                    HStack(spacing: 6) {
                                        Text(tags[index])
                                            .font(.system(size: 12, weight: .medium))
                                        
                                        Button(action: {
                                            tags.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 12))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .foregroundColor(ThemeColors.accentBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(ThemeColors.accentBlue.opacity(0.15))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        HStack {
                            TextField("Add tag...", text: $newTag)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(ThemeColors.accentBlue)
                            }
                            .buttonStyle(.plain)
                            .disabled(newTag.isEmpty)
                        }
                        .padding(10)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                            .cornerRadius(8)
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("Add notes about this contact...")
                                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                                            .padding(12)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }
                .padding(24)
            }
            
            // Footer Buttons
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(action: saveContact) {
                    Text(editingContact == nil ? "Add Contact" : "Save Changes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isValid ? ThemeColors.accentBlue : ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(!isValid)
            }
            .padding(24)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        }
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .frame(width: 600, height: 700)
    }
    
    private func addTag() {
        guard !newTag.isEmpty else { return }
        tags.append(newTag)
        newTag = ""
    }
    
    private func saveContact() {
        let contact = Contact(
            id: editingContact?.id ?? UUID(),
            name: name,
            role: role,
            title: title,
            company: company,
            email: email,
            phone: phone,
            linkedInURL: linkedInURL,
            notes: notes,
            lastContactDate: editingContact?.lastContactDate,
            interactions: editingContact?.interactions ?? [],
            tags: tags
        )
        
        if editingContact != nil {
            jobStore.updateContact(contact)
        } else {
            jobStore.addContact(contact)
        }
        
        dismiss()
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    ContactFormView()
        .environmentObject(JobStore())
        .environmentObject(ThemeManager())
}
