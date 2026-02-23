import SwiftUI

public enum AppTheme {
    // Basic App Colors
    public static let primary = Color(hex: "#00A3FF")
    public static let secondary = Color(hex: "#20C997")
    public static let background = Color(hex: "#F5F5F5")
    public static let surface = Color.white
    public static let accentBlack = Color(hex: "#0F172A")
    
    // Role Colors
    public static let roleParent = Color(hex: "#00A3FF")
    public static let roleProvider = Color(hex: "#20C997")
    public static let roleAdmin = Color(hex: "#8B5CF6")
    
    public static let textPrimary = Color(hex: "#111827")
    public static let textSecondary = Color(hex: "#6B7280")
    
    // Core Layout Constants
    public static let cornerRadius: CGFloat = 16.0
    public static let padding: CGFloat = 20.0 // Adjusted for Figma
    public static let buttonHeight: CGFloat = 56.0
    
    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let darkNavyGradient = LinearGradient(
        colors: [accentBlack, Color(hex: "#1E293B")],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    // Providing default hex initializers roughly matching the spec
    static let customPrimary = Color(hex: "#4A90E2") // Soft Blue
    static let customSecondary = Color(hex: "#7ED321") // Muted Green
    static let customBackground = Color(hex: "#F8F9FA") // Soft Neutral
    
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
