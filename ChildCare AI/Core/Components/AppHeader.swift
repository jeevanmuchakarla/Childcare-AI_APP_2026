import SwiftUI

    public struct AppHeader: View {
    let title: String
    var showBackButton: Bool = true
    var trailingAction: AnyView? = nil
    var onBack: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public init(title: String, 
                showBackButton: Bool = true, 
                trailingAction: AnyView? = nil,
                onBack: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.trailingAction = trailingAction
        self.onBack = onBack
    }
    
    public var body: some View {
        ZStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                if showBackButton {
                    backButton
                }
                Spacer()
                if let action = trailingAction {
                    action
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppTheme.surface)
    }
    
    private var backButton: some View {
        Button(action: {
            if let onBack = onBack {
                onBack()
            } else {
                dismiss()
            }
        }) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryColor)
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
}
