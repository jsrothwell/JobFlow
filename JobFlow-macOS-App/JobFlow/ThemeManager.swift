import SwiftUI

enum AppTheme: String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    
    var colorScheme: ColorScheme {
        switch self {
        case .dark: return .dark
        case .light: return .light
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.dark.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .dark
    }
    
    func toggle() {
        currentTheme = currentTheme == .dark ? .light : .dark
    }
}

// MARK: - Theme Colors
struct ThemeColors {
    // MARK: - Background Colors
    static func backgroundDeep(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "1E212B") // Dark: Main Background
            : Color(hex: "FFFFFF") // Light: Main Background (White)
    }
    
    static func panelSecondary(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "3A404F") // Dark: Secondary Elements
            : Color(hex: "F2F4F7") // Light: Secondary Elements
    }
    
    static func panelBackground(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "1E212B").opacity(0.8)
            : Color(hex: "FFFFFF")
    }
    
    // MARK: - Text Colors
    static func textPrimary(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white
            : Color(hex: "1E212B") // Light: Primary Text (same as dark bg)
    }
    
    static func textSecondary(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.7)
            : Color(hex: "1E212B").opacity(0.8)
    }
    
    static func textTertiary(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.5)
            : Color(hex: "757985") // Light: Tertiary Text
    }
    
    static func textPlaceholder(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.4)
            : Color(hex: "757985").opacity(0.6)
    }
    
    // MARK: - Border Colors
    static func border(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.1)
            : Color(hex: "757985").opacity(0.2)
    }
    
    static func borderSubtle(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.06)
            : Color(hex: "F2F4F7").opacity(0.8)
    }
    
    // MARK: - Input Colors
    static func inputBackground(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.black.opacity(0.2)
            : Color.white
    }
    
    static func inputBorder(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.white.opacity(0.1)
            : Color(hex: "757985").opacity(0.3)
    }
    
    // MARK: - Overlay Colors (Liquid Glass Effects)
    static func overlayBackground(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.black.opacity(0.4)
            : Color.white.opacity(0.9)
    }
    
    static func glassBackground(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "3A404F").opacity(0.6)
            : Color(hex: "F2F4F7").opacity(0.8)
    }
    
    // MARK: - Card/Item Colors
    static func cardBackground(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "3A404F").opacity(0.4)
            : Color.white
    }
    
    static func cardBackgroundHover(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color(hex: "3A404F").opacity(0.6)
            : Color(hex: "F2F4F7").opacity(0.5)
    }
    
    static func cardShadow(for theme: AppTheme) -> Color {
        theme == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.08)
    }
    
    // MARK: - Shared Accent (same for both themes)
    static let accentBlue = Color(hex: "007AFF") // Shared Accent
    static let successGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let warningOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let errorRed = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let acceptedPurple = Color(red: 0.35, green: 0.34, blue: 0.84)
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
