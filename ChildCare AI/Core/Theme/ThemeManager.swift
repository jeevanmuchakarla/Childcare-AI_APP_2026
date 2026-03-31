import SwiftUI
import Combine

public class ThemeManager: ObservableObject {
    @AppStorage("primaryColorHex") public var primaryColorHex: String = "#00A3FF" {
        didSet {
            AppTheme.dynamicPrimaryHex = primaryColorHex
        }
    }
    @AppStorage("isDarkMode") public var isDarkMode: Bool = false
    
    public init() {
        AppTheme.dynamicPrimaryHex = primaryColorHex
    }
    
    public var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    public var secondaryColor: Color {
        // Derive or provide a complementary color
        primaryColor.opacity(0.8)
    }
    
    public var primaryGradient: LinearGradient {
        if isMulticolor {
            return LinearGradient(
                colors: [
                    Color(hex: "#FF4757"), // Coral
                    Color(hex: "#FF8C00"), // Orange
                    Color(hex: "#FFD166"), // Yellow
                    Color(hex: "#20C997"), // Mint
                    Color(hex: "#00A3FF"), // Azure
                    Color(hex: "#8B5CF6")  // Lavender
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if isIndian {
            return LinearGradient(
                colors: [Color(hex: "#FF9933"), Color(hex: "#FFFFFF"), Color(hex: "#138808")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [primaryColor, primaryColor.opacity(0.8), primaryColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    public var selectedPreset: AppTheme.ColorPreset {
        AppTheme.ColorPreset(rawValue: primaryColorHex) ?? .azure
    }
    
    public var isMulticolor: Bool {
        selectedPreset == .rainbow
    }
    
    public var isIndian: Bool {
        selectedPreset == .indian
    }
    
    public func updatePrimaryColor(hex: String) {
        primaryColorHex = hex
    }
    
    public func updatePreset(_ preset: AppTheme.ColorPreset) {
        primaryColorHex = preset.rawValue
    }
}
