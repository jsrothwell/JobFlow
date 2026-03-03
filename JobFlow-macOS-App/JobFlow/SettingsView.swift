import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var selectedCategory: SettingsCategory = .general
    
    enum SettingsCategory: String, CaseIterable, Identifiable {
        case general = "General"
        case account = "Account & Security"
        case notifications = "Notifications"
        case integrations = "Integrations"
        case appearance = "Appearance"
        case advanced = "Advanced"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .general: return "gearshape.fill"
            case .account: return "person.badge.shield.checkmark.fill"
            case .notifications: return "bell.badge.fill"
            case .integrations: return "link.circle.fill"
            case .appearance: return "paintbrush.fill"
            case .advanced: return "slider.horizontal.3"
            }
        }
        
        var color: Color {
            switch self {
            case .general: return .blue
            case .account: return .green
            case .notifications: return .orange
            case .integrations: return .purple
            case .appearance: return .pink
            case .advanced: return .gray
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Navigation Panel
            VStack(spacing: 0) {
                // Settings Header
                HStack {
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Categories List
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(SettingsCategory.allCases) { category in
                            SettingsCategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(12)
                }
                
                Spacer()
                
                // Bottom Actions
                VStack(spacing: 12) {
                    Divider()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Close Settings")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(width: 260)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
            
            // Right Content Area
            VStack(spacing: 0) {
                // Category Header
                HStack(spacing: 12) {
                    Image(systemName: selectedCategory.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedCategory.color)
                    
                    Text(selectedCategory.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                    
                    Spacer()
                }
                .padding(24)
                
                Divider()
                
                // Settings Content
                ScrollView {
                    settingsContent
                        .padding(24)
                }
            }
            .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        }
        .frame(width: 900, height: 700)
    }
    
    @ViewBuilder
    var settingsContent: some View {
        switch selectedCategory {
        case .general:
            GeneralSettings()
        case .account:
            AccountSettings()
        case .notifications:
            NotificationSettings()
        case .integrations:
            IntegrationsSettings()
        case .appearance:
            AppearanceSettings()
        case .advanced:
            AdvancedSettings()
        }
    }
}

// MARK: - Category Button
struct SettingsCategoryButton: View {
    let category: SettingsView.SettingsCategory
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? category.color : ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .frame(width: 24)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? ThemeColors.textPrimary(for: themeManager.currentTheme) : ThemeColors.textSecondary(for: themeManager.currentTheme))
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(category.color)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? category.color.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - General Settings
struct GeneralSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var userName = "Job Seeker"
    @State private var userEmail = "user@example.com"
    @State private var language = "English"
    @State private var timeZone = "America/Los_Angeles"
    @State private var dateFormat = "MM/DD/YYYY"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "User Information", icon: "person.fill") {
                SettingsTextField(label: "Full Name", value: $userName, placeholder: "Enter your name")
                SettingsTextField(label: "Email Address", value: $userEmail, placeholder: "your@email.com")
            }
            
            SettingsSection(title: "Localization", icon: "globe") {
                SettingsPicker(label: "Language", selection: $language, options: ["English", "Spanish", "French", "German"])
                SettingsPicker(label: "Time Zone", selection: $timeZone, options: ["America/Los_Angeles", "America/New_York", "Europe/London", "Asia/Tokyo"])
                SettingsPicker(label: "Date Format", selection: $dateFormat, options: ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"])
            }
            
            SettingsSection(title: "Application Defaults", icon: "doc.text.fill") {
                Toggle("Auto-save changes", isOn: .constant(true))
                    .padding(.vertical, 4)
                Toggle("Show confirmation dialogs", isOn: .constant(true))
                    .padding(.vertical, 4)
                Toggle("Enable keyboard shortcuts", isOn: .constant(true))
                    .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Account Settings
struct AccountSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var twoFactorEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Password", icon: "key.fill") {
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                    .cornerRadius(6)
                
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                    .cornerRadius(6)
                
                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
                    .cornerRadius(6)
                
                Button("Change Password") {
                    // Change password logic
                }
                .buttonStyle(.borderedProminent)
            }
            
            SettingsSection(title: "Two-Factor Authentication", icon: "shield.checkered") {
                Toggle("Enable 2FA", isOn: $twoFactorEnabled)
                    .padding(.vertical, 4)
                
                if twoFactorEnabled {
                    Text("Two-factor authentication adds an extra layer of security to your account.")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        .padding(.top, 8)
                    
                    Button("Configure 2FA") {
                        // 2FA setup
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            SettingsSection(title: "Active Sessions", icon: "desktopcomputer") {
                VStack(alignment: .leading, spacing: 12) {
                    SessionRow(device: "MacBook Pro", location: "Burnaby, BC", isActive: true)
                    SessionRow(device: "iPhone", location: "Vancouver, BC", isActive: false)
                }
                
                Button("Sign Out All Other Sessions") {
                    // Sign out logic
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Notification Settings
struct NotificationSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var applicationUpdates = true
    @State private var interviewReminders = true
    @State private var weeklyDigest = true
    @State private var reminderTime = "9:00 AM"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Email Notifications", icon: "envelope.fill") {
                Toggle("Enable email notifications", isOn: $emailNotifications)
                    .padding(.vertical, 4)
                Toggle("Application status updates", isOn: $applicationUpdates)
                    .padding(.vertical, 4)
                    .disabled(!emailNotifications)
                Toggle("Interview reminders", isOn: $interviewReminders)
                    .padding(.vertical, 4)
                    .disabled(!emailNotifications)
                Toggle("Weekly digest", isOn: $weeklyDigest)
                    .padding(.vertical, 4)
                    .disabled(!emailNotifications)
            }
            
            SettingsSection(title: "Push Notifications", icon: "bell.fill") {
                Toggle("Enable push notifications", isOn: $pushNotifications)
                    .padding(.vertical, 4)
                
                if pushNotifications {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You'll receive notifications for:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        
                        NotificationTypeRow(icon: "calendar", text: "Upcoming interviews", enabled: true)
                        NotificationTypeRow(icon: "paperplane", text: "Follow-up reminders", enabled: true)
                        NotificationTypeRow(icon: "checkmark.circle", text: "Application updates", enabled: true)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            SettingsSection(title: "Calendar Integration", icon: "calendar.badge.clock") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calendar Status")
                            .font(.system(size: 14, weight: .medium))
                        Text(calendarManager.hasAccess ? "Connected" : "Not Connected")
                            .font(.system(size: 12))
                            .foregroundColor(calendarManager.hasAccess ? .green : .orange)
                    }
                    
                    Spacer()
                    
                    if !calendarManager.hasAccess {
                        Button("Grant Access") {
                            Task {
                                _ = await calendarManager.requestAccess()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Toggle("Sync interviews to calendar", isOn: .constant(calendarManager.hasAccess))
                    .padding(.vertical, 4)
                    .disabled(!calendarManager.hasAccess)
                
                Toggle("Set reminders 24h before", isOn: .constant(true))
                    .padding(.vertical, 4)
                    .disabled(!calendarManager.hasAccess)
                
                Toggle("Set reminders 15min before", isOn: .constant(true))
                    .padding(.vertical, 4)
                    .disabled(!calendarManager.hasAccess)
            }
            
            SettingsSection(title: "Reminder Preferences", icon: "clock.fill") {
                SettingsPicker(
                    label: "Default reminder time",
                    selection: $reminderTime,
                    options: ["7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "12:00 PM"]
                )
            }
        }
    }
}

// MARK: - Integrations Settings
struct IntegrationsSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var googleCalendarConnected = false
    @State private var linkedInConnected = false
    @State private var slackConnected = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Calendar Services", icon: "calendar") {
                IntegrationRow(
                    name: "Google Calendar",
                    icon: "calendar.badge.plus",
                    isConnected: $googleCalendarConnected,
                    color: .blue
                ) {
                    // Connect Google Calendar
                }
                
                IntegrationRow(
                    name: "Apple Calendar",
                    icon: "calendar.circle.fill",
                    isConnected: .constant(calendarManager.hasAccess),
                    color: .purple
                ) {
                    Task {
                        _ = await calendarManager.requestAccess()
                    }
                }
            }
            
            SettingsSection(title: "Professional Networks", icon: "person.2.fill") {
                IntegrationRow(
                    name: "LinkedIn",
                    icon: "link.circle.fill",
                    isConnected: $linkedInConnected,
                    color: .blue
                ) {
                    // Connect LinkedIn
                }
                
                Text("Import job applications directly from LinkedIn")
                    .font(.system(size: 12))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .padding(.top, 4)
            }
            
            SettingsSection(title: "Communication Tools", icon: "bubble.left.and.bubble.right.fill") {
                IntegrationRow(
                    name: "Slack",
                    icon: "message.fill",
                    isConnected: $slackConnected,
                    color: .purple
                ) {
                    // Connect Slack
                }
                
                Text("Get notifications in your Slack workspace")
                    .font(.system(size: 12))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .padding(.top, 4)
            }
            
            SettingsSection(title: "Data Export", icon: "arrow.up.doc.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export your data to use in other applications")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    
                    HStack(spacing: 12) {
                        Button("Export as CSV") {
                            // Export CSV
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Export as JSON") {
                            // Export JSON
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var accentColor = "Blue"
    @State private var fontSize = "Medium"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Theme", icon: "paintbrush.fill") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select your preferred theme")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    
                    HStack(spacing: 16) {
                        ThemeOption(
                            theme: .light,
                            isSelected: themeManager.currentTheme == .light
                        ) {
                            withAnimation {
                                themeManager.currentTheme = .light
                            }
                        }
                        
                        ThemeOption(
                            theme: .dark,
                            isSelected: themeManager.currentTheme == .dark
                        ) {
                            withAnimation {
                                themeManager.currentTheme = .dark
                            }
                        }
                    }
                }
            }
            
            SettingsSection(title: "Colors", icon: "paintpalette.fill") {
                SettingsPicker(
                    label: "Accent Color",
                    selection: $accentColor,
                    options: ["Blue", "Purple", "Green", "Orange", "Red"]
                )
                
                HStack(spacing: 12) {
                    ForEach(["Blue", "Purple", "Green", "Orange", "Red"], id: \.self) { colorName in
                        Circle()
                            .fill(colorForName(colorName))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: accentColor == colorName ? 3 : 0)
                            )
                            .onTapGesture {
                                accentColor = colorName
                            }
                    }
                }
                .padding(.top, 8)
            }
            
            SettingsSection(title: "Display", icon: "textformat.size") {
                SettingsPicker(
                    label: "Font Size",
                    selection: $fontSize,
                    options: ["Small", "Medium", "Large", "Extra Large"]
                )
                
                Toggle("Show compact views", isOn: .constant(false))
                    .padding(.vertical, 4)
                
                Toggle("Reduce motion", isOn: .constant(false))
                    .padding(.vertical, 4)
            }
        }
    }
    
    func colorForName(_ name: String) -> Color {
        switch name {
        case "Blue": return .blue
        case "Purple": return .purple
        case "Green": return .green
        case "Orange": return .orange
        case "Red": return .red
        default: return .blue
        }
    }
}

// MARK: - Advanced Settings
struct AdvancedSettings: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var debugMode = false
    @State private var showingClearDataAlert = false
    @State private var showingClearCacheConfirmation = false
    @State private var showingClearDataConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Performance", icon: "speedometer") {
                Toggle("Enable animations", isOn: .constant(true))
                    .padding(.vertical, 4)
                Toggle("Hardware acceleration", isOn: .constant(true))
                    .padding(.vertical, 4)
                Toggle("Preload data", isOn: .constant(true))
                    .padding(.vertical, 4)
            }
            
            SettingsSection(title: "Developer Options", icon: "wrench.and.screwdriver.fill") {
                Toggle("Debug mode", isOn: $debugMode)
                    .padding(.vertical, 4)
                
                if debugMode {
                    Text("⚠️ Debug mode shows additional information for troubleshooting")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                }
            }
            
            SettingsSection(title: "Data Management", icon: "externaldrive.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage Used")
                                .font(.system(size: 14, weight: .medium))
                            Text("2.3 MB")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        }
                        
                        Spacer()
                        
                        Button("Clear Cache") {
                            showingClearCacheConfirmation = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Divider()
                    
                    Button("Export All Data") {
                        // Export data
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear All Data") {
                        showingClearDataConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            
            SettingsSection(title: "About", icon: "info.circle.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Version", value: "7.1.0")
                    InfoRow(label: "Build", value: "2024.11.29")
                    InfoRow(label: "License", value: "Personal Use")
                }
            }
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                // Clear all data
            }
        } message: {
            Text("This will permanently delete all your job applications, interviews, and contacts. This action cannot be undone.")
        }
        .alert("Clear Cache?", isPresented: $showingClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                // Clear cache
            }
        } message: {
            Text("This will clear cached data to free up storage.")
        }
        .alert("Clear All Data?", isPresented: $showingClearDataConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                // Clear all user data
            }
        } message: {
            Text("This will permanently delete all your data. This cannot be undone.")
        }
    }
}

// MARK: - Supporting Components

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            }
            
            content
        }
        .padding(20)
        .background(ThemeColors.panelSecondary(for: themeManager.currentTheme))
        .cornerRadius(12)
    }
}

struct SettingsTextField: View {
    let label: String
    @Binding var value: String
    let placeholder: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            
            TextField(placeholder, text: $value)
                .textFieldStyle(.plain)
                .padding(10)
                .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
                .cornerRadius(6)
        }
    }
}

struct SettingsPicker: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200)
        }
    }
}

struct SessionRow: View {
    let device: String
    let location: String
    let isActive: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: device.contains("iPhone") ? "iphone" : "desktopcomputer")
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(device)
                    .font(.system(size: 14, weight: .medium))
                Text(location)
                    .font(.system(size: 12))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }
            
            Spacer()
            
            if isActive {
                Text("Active Now")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .cornerRadius(8)
    }
}

struct NotificationTypeRow: View {
    let icon: String
    let text: String
    let enabled: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(enabled ? .green : .gray)
            
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
        }
    }
}

struct IntegrationRow: View {
    let name: String
    let icon: String
    @Binding var isConnected: Bool
    let color: Color
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            if isConnected {
                Text("Connected")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Button("Disconnect") {
                    isConnected = false
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Button("Connect") {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ThemeOption: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme == .dark ? Color.black : Color.white)
                        .frame(width: 120, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        )
                    
                    Image(systemName: theme == .dark ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 32))
                        .foregroundColor(theme == .dark ? .white : .orange)
                }
                
                Text(theme == .dark ? "Dark" : "Light")
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
        }
    }
}
