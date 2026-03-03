import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var jobStore: JobStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingSettings = false
    @State private var showingProfile = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Unified view picker with all options
            Picker("View", selection: $jobStore.selectedView) {
                ForEach(ViewType.allCases, id: \.self) { viewType in
                    if viewType.isMainView {
                        Text(viewType.rawValue).tag(viewType)
                    }
                }
                
                // Divider in picker
                Divider()
                
                ForEach(ViewType.allCases, id: \.self) { viewType in
                    if !viewType.isMainView {
                        Label(viewType.rawValue, systemImage: viewType.icon ?? "").tag(viewType)
                    }
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
            .padding(.leading, 80) // Clear traffic lights
            
            Spacer()
            
            // Center: Current view indicator
            HStack(spacing: 8) {
                if let icon = jobStore.selectedView.icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(jobStore.selectedView.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(ThemeColors.panelSecondary(for: themeManager.currentTheme).opacity(0.5))
            .cornerRadius(12)
            
            Spacer()
            
            // Right: Utilities
            HStack(spacing: 12) {
                Button(action: {
                    showingProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
                .help("Profile")
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
                .help("Settings")
                
                Divider()
                    .frame(height: 24)
                
                Button(action: {
                    jobStore.showingAddSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("New Job")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 20)
        }
        .frame(height: 56)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .overlay(
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(ThemeColors.textTertiary(for: themeManager.currentTheme).opacity(0.1)),
            alignment: .bottom
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(jobStore)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(themeManager)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeColors.textTertiary(for: themeManager.currentTheme))
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Profile features coming soon")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
            }
            
            Spacer()
        }
        .padding(24)
        .frame(width: 500, height: 600)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
    }
}
