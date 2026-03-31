import SwiftUI

public struct RoleSelectionView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var appear = false
    @State private var showProviderOptions = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer() // Flexible spacer at the top
                
                VStack(spacing: 0) {
                    // Top Icon matching splash
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.primaryColor)
                            .frame(width: 50, height: 50)
                        
                        BabySymbol(size: 32)
                    }
                    .padding(.bottom, 24)
                    
                    // Header
                    VStack(alignment: .center, spacing: 12) {
                        Text("Welcome to\nChildCare AI")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Choose how you'd like to continue")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 24) // Reduced padding for better centering
                
                    // Role buttons
                    VStack(spacing: 16) {
                        RoleCard(
                            title: "Parent",
                            subtitle: "Find & book trusted childcare",
                            iconName: "person.2.fill",
                            color: AppTheme.roleParent,
                            action: { appRouter.navigate(to: .login(.parent)) }
                        )
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appear)
                        
                        // Grouped Provider Button
                        VStack(spacing: 12) {
                            RoleCard(
                                title: "Childcare Providers",
                                subtitle: "Daycares & Preschools",
                                iconName: "building.2.fill",
                                color: themeManager.primaryColor,
                                action: { 
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showProviderOptions.toggle()
                                    }
                                }
                            )
                            
                            if showProviderOptions {
                                VStack(spacing: 12) {
                                    RoleCard(
                                        title: "Preschool Provider",
                                        subtitle: "Early childhood education",
                                        iconName: "graduationcap.fill",
                                        color: Color(hex: "#FF8C00"),
                                        action: { appRouter.navigate(to: .login(.preschool)) }
                                    )
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    
                                    RoleCard(
                                        title: "Daycare Provider",
                                        subtitle: "Full-day professional care",
                                        iconName: "house.fill",
                                        color: themeManager.primaryColor,
                                        action: { appRouter.navigate(to: .login(.daycare)) }
                                    )
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                                .padding(.leading, 32) 
                                .padding(.vertical, 8)
                            }
                        }
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appear)
                        
                        RoleCard(
                            title: "Platform Admin",
                            subtitle: "Manage users & analytics",
                            iconName: "shield.lefthalf.filled",
                            color: Color(hex: "#7D61FF"),
                            action: { appRouter.navigate(to: .login(.admin)) }
                        )
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)
                    }
                    .padding(.horizontal, AppTheme.padding)
                }
                .padding(.vertical, 20) // Spacing from top/bottom
                
                Spacer() // Flexible spacer at the bottom
                
                // Footer Terms Link
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("Terms & Conditions")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                    }
                    
                    Text("Privacy Policy")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Role Card Component
struct RoleCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 82) // Standardized height for premium look
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            // Extra visual cue matching Figma (soft border)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(BounceButtonStyle())
    }
}
