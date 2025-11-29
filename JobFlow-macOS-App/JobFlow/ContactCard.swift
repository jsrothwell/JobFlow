import SwiftUI

struct ContactCard: View {
    let contact: Contact
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    var body: some View {
        Button(action: {
            showingEditSheet = true
        }) {
            HStack(spacing: 16) {
                // Left: Avatar
                ZStack {
                    Circle()
                        .fill(contact.role.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(contact.initialsIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(contact.role.color)
                }
                
                // Middle: Contact Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(contact.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    HStack(spacing: 8) {
                        Label(contact.role.rawValue, systemImage: contact.role.icon)
                            .font(.system(size: 12))
                            .foregroundColor(contact.role.color)
                        
                        if !contact.company.isEmpty {
                            Text("•")
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            Text(contact.company)
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                    }
                    
                    if !contact.title.isEmpty {
                        Text(contact.title)
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                    }
                    
                    if !contact.email.isEmpty || !contact.phone.isEmpty {
                        HStack(spacing: 12) {
                            if !contact.email.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 10))
                                    Text(contact.email)
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            }
                            
                            if !contact.phone.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone")
                                        .font(.system(size: 10))
                                    Text(contact.phone)
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Right: Quick Actions
                VStack(alignment: .trailing, spacing: 8) {
                    if contact.lastContactDate != nil {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Last contact")
                                .font(.system(size: 10))
                                .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                            Text(contact.lastContactString)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                    }
                    
                    HStack(spacing: 8) {
                        if !contact.email.isEmpty {
                            Button(action: {
                                if let url = URL(string: "mailto:\(contact.email)") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Image(systemName: "envelope.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(ThemeColors.accentBlue)
                            }
                            .buttonStyle(.plain)
                            .help("Send email")
                        }
                        
                        if !contact.linkedInURL.isEmpty {
                            Button(action: {
                                if let url = URL(string: contact.linkedInURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.blue)
                            }
                            .buttonStyle(.plain)
                            .help("Open LinkedIn")
                        }
                    }
                }
            }
            .padding(16)
            .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(contact.role.color.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: ThemeColors.cardShadow(for: themeManager.currentTheme), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEditSheet) {
            ContactFormView(contact: contact)
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    ContactCard(
        contact: Contact(
            name: "Sarah Johnson",
            role: .recruiter,
            title: "Senior Technical Recruiter",
            company: "Apple",
            email: "sarah.j@apple.com",
            phone: "+1 (555) 123-4567",
            linkedInURL: "https://linkedin.com/in/sarahjohnson",
            lastContactDate: Date().addingTimeInterval(-86400 * 3)
        )
    )
    .environmentObject(JobStore())
    .environmentObject(ThemeManager())
    .padding()
}
