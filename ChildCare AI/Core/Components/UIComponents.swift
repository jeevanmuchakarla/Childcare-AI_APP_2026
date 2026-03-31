import SwiftUI

public struct BounceButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

public struct DarkNavyButton: View {
    public let title: String
    public let hasChevron: Bool
    public let action: () -> Void
    
    public init(title: String, hasChevron: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.hasChevron = hasChevron
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                if hasChevron {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#000000")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, AppTheme.padding)
        .buttonStyle(BounceButtonStyle())
    }
}
public struct PrimaryButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let title: String
    public let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(
                    ZStack {
                        themeManager.primaryGradient
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(18)
                .shadow(color: themeManager.primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, AppTheme.padding)
        .buttonStyle(BounceButtonStyle())
    }
}

public struct SecondaryButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let title: String
    public let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(themeManager.primaryColor, lineWidth: 2)
                )
        }
        .padding(.horizontal, AppTheme.padding)
        .buttonStyle(BounceButtonStyle())
    }
}

public struct CustomTextField: View {
    public let placeholder: String
    @Binding public var text: String
    public let isSecure: Bool
    
    public init(placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(placeholder)
                .font(.footnote)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.padding)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(AppTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.padding)
        }
    }
}

public struct ActionCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let title: String
    public let iconName: String
    public let action: () -> Void
    
    public init(title: String, iconName: String, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(themeManager.primaryColor)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

public struct AvatarButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(themeManager.primaryColor)
        }
    }
}

public struct SegmentedSelectionCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let title: String
    public let description: String
    public let priceText: String
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(title: String, description: String, priceText: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.priceText = priceText
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? themeManager.primaryColor : AppTheme.textPrimary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    if !priceText.isEmpty {
                        Text(priceText)
                            .font(.caption) // Changed from .caption2 to .caption
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 8) // Increased padding from 4 to 8
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? themeManager.primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(themeManager.primaryGradient)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(20)
            .background(AppTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.primaryColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .padding(.horizontal, AppTheme.padding)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct GrowthChartView: View {
    @EnvironmentObject var themeManager: ThemeManager
    public let data: [Double]
    
    public init(data: [Double]) {
        self.data = data
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack(spacing: 8) {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        Capsule()
                            .fill(Color(hex: "#F1F4F9"))
                            .frame(width: 20)
                        
                        Capsule()
                            .fill(themeManager.primaryGradient)
                            .frame(width: 20, height: max(0, min(120, CGFloat(data[index]))))
                    }
                }
            }
        }
    }
}
