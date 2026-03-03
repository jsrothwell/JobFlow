import SwiftUI

struct ConfirmationDialog: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let message: String
    let confirmText: String
    let confirmColor: Color
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @State private var confirmationText = ""
    let requiresTyping: Bool
    let requiredText: String
    
    init(
        title: String,
        message: String,
        confirmText: String = "Confirm",
        confirmColor: Color = .red,
        requiresTyping: Bool = false,
        requiredText: String = "DELETE",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.confirmColor = confirmColor
        self.requiresTyping = requiresTyping
        self.requiredText = requiredText
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            if requiresTyping {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type \"\(requiredText)\" to confirm:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                    
                    TextField("", text: $confirmationText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium))
                        .padding(10)
                        .background(ThemeColors.inputBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            
            Divider()
            
            // Actions
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                
                Button(action: onConfirm) {
                    Text(confirmText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isConfirmEnabled ? confirmColor : Color.gray)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!isConfirmEnabled)
                .keyboardShortcut(.defaultAction)
            }
            .padding(20)
        }
        .frame(width: 450)
        .background(ThemeColors.backgroundDeep(for: themeManager.currentTheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    var isConfirmEnabled: Bool {
        if requiresTyping {
            return confirmationText == requiredText
        }
        return true
    }
}
