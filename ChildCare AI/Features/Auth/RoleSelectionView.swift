import SwiftUI

public struct RoleSelectionView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Top Icon matching splash
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.primary)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            .padding(.horizontal, AppTheme.padding)
            .padding(.bottom, 24)
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to\nChildCare AI")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Choose how you'd like to continue")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.bottom, 40)
            
            // Fixed list of role buttons
            VStack(spacing: 16) {
                RoleCard(
                    title: "Parent",
                    subtitle: "Find & book trusted childcare",
                    iconName: "person.2.fill",
                    color: AppTheme.roleParent,
                    action: { appRouter.navigate(to: .createAccount(.parent)) }
                )
                
                RoleCard(
                    title: "Childcare Provider",
                    subtitle: "Manage your childcare center",
                    iconName: "building.2.fill",
                    color: AppTheme.roleProvider,
                    action: { appRouter.navigate(to: .createAccount(.daycare)) }
                )
                
                RoleCard(
                    title: "Admin",
                    subtitle: "Platform administration",
                    iconName: "shield.fill",
                    color: AppTheme.roleAdmin,
                    action: { appRouter.navigate(to: .createAccount(.admin)) }
                )
            }
            .padding(.horizontal, AppTheme.padding)
            
            Spacer()
            
            // Footer Terms Link
            HStack(spacing: 4) {
                Text("By continuing, you agree to our")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text("Terms of Service")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                
                Text("and")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            Text("Privacy Policy")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}

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
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            // Extra visual cue matching Figma (soft border)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
