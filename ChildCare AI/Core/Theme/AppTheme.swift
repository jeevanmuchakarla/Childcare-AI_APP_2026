import SwiftUI

public enum AppTheme {
    // Basic App Colors with Dynamic Support
    public static var dynamicPrimaryHex: String = "#00A3FF"
    public static var primary: Color { Color(hex: dynamicPrimaryHex) }
    public static var secondary: Color { Color(hex: "#20C997") }
    
    public static var background: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1A1B2E") : UIColor(hex: "#F5F5F5")
        })
    }
    
    public static var surface: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#252638") : .white
        })
    }
    
    public static var accentBlack: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(hex: "#0F172A")
        })
    }
    
    // Role Colors
    public static var roleParent: Color { Color(hex: "#00A3FF") }
    public static var roleProvider: Color { Color(hex: "#20C997") }
    public static var roleAdmin: Color { Color(hex: "#8B5CF6") }
    
    public static var textPrimary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(hex: "#111827")
        })
    }
    
    public static var textSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor(hex: "#6B7280")
        })
    }
    
    public static var cardBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#2D2E3F") : .white
        })
    }
    
    public static var cardSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#35364A") : UIColor(hex: "#F9FAFB")
        })
    }
    
    public static var divider: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1) : UIColor.black.withAlphaComponent(0.05)
        })
    }
    
    // Core Layout Constants
    public static let cornerRadius: CGFloat = 16.0
    public static let padding: CGFloat = 20.0
    public static let buttonHeight: CGFloat = 56.0
    
    // Gradients
    public static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [primary, Color(hex: "#6A11CB")], // Deep purple mix
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public static var darkNavyGradient: LinearGradient {
        LinearGradient(
            colors: [accentBlack, Color(hex: "#1E293B")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Premium Visual Tokens
    public static var cardShadow: Color {
        Color.black.opacity(0.04)
    }
    
    public static var premiumShadow: Color {
        primary.opacity(0.12)
    }
    
    // Theme Presets for Phase 13
    public enum ColorPreset: String, CaseIterable, Identifiable {
        case azure = "#00A3FF"
        case mint = "#20C997"
        case lavender = "#8B5CF6"
        case coral = "#FF4757"
        case sunset = "#FF8C00"
        case stealth = "#2D3436"
        case prussian = "#E84393"
        case tropical = "#00D2D3"
        case indigo = "#5F27CD"
        case emerald = "#2ECC71"
        case ruby = "#E74C3C"
        case amethyst = "#9B59B6"
        case sapphire = "#2980B9"
        case midnight = "#2C3E50"
        case amber = "#F39C12"
        case slate = "#95A5A6"
        case crimson = "#C0392B"
        case forest = "#27AE60"
        case navy = "#34495E"
        case rainbow = "#FF9F43" // This will signal multi
        case indian = "#FF9933" // Saffron / Indian Theme

        public var id: String { self.rawValue }
        
        public var name: String {
            switch self {
            case .azure: return "Azure Blue"
            case .mint: return "Mint Green"
            case .lavender: return "Lavender Purple"
            case .coral: return "Coral Red"
            case .sunset: return "Sunset Orange"
            case .stealth: return "Stealth Gray"
            case .prussian: return "Prussian Pink"
            case .tropical: return "Tropical Teal"
            case .indigo: return "Indigo Night"
            case .emerald: return "Emerald Green"
            case .ruby: return "Ruby Red"
            case .amethyst: return "Amethyst"
            case .sapphire: return "Sapphire"
            case .midnight: return "Midnight"
            case .amber: return "Amber"
            case .slate: return "Slate"
            case .crimson: return "Crimson"
            case .forest: return "Forest Green"
            case .navy: return "Navy Blue"
            case .rainbow: return "Multicolor"
            case .indian: return "Indian Theme"
            }
        }
    }
}

extension Font {
    public static var trackerTitle: Font {
        .system(size: 32, weight: .bold, design: .rounded)
    }
}

extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
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



