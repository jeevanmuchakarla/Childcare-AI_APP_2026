import SwiftUI

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
            HStack {
                Text(title)
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(AppTheme.accentBlack)
            .cornerRadius(AppTheme.cornerRadius)
        }
        .padding(.horizontal, AppTheme.padding)
    }
}
public struct PrimaryButton: View {
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
                .foregroundColor(AppTheme.surface)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(AppTheme.primaryGradient)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, AppTheme.padding)
    }
}

public struct SecondaryButton: View {
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
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.primary, lineWidth: 2)
                )
        }
        .padding(.horizontal, AppTheme.padding)
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
                    .foregroundColor(AppTheme.primary)
                
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
    }
}

public struct AvatarButton: View {
    public let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(AppTheme.primary)
        }
    }
}

public struct SegmentedSelectionCard: View {
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
                        .font(.headline)
                        .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    if !priceText.isEmpty {
                        Text(priceText)
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.primary : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(AppTheme.primary)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .padding(.horizontal, AppTheme.padding)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
