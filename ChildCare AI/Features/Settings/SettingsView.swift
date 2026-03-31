import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAlert = false
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                ProfileMenuRow(title: "Profile", icon: "person", color: themeManager.primaryColor, destination: AnyView(ProfileView()))
                                Divider().padding(.leading, 56)
                                ProfileMenuRow(title: "Privacy", icon: "shield", color: Color(hex: "#00C853"), destination: AnyView(PrivacyAndDataScreen()))
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                        
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferences")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                ProfileMenuRow(title: "Dark Mode", icon: "moon", color: Color(hex: "#A061CF"), isToggle: true, destination: AnyView(EmptyView()))
                                Divider().padding(.leading, 56)
                                ProfileMenuRow(title: "Job Alerts", icon: "bell", color: themeManager.primaryColor, isToggle: true, destination: AnyView(EmptyView()))
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                        
                        // Support Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Support")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                ProfileMenuRow(title: "Help & Support", icon: "questionmark.circle", color: themeManager.primaryColor, destination: AnyView(SupportScreen()))
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Buttons Section
                    VStack(spacing: 16) {
                        // Sign Out Button
                        Button(action: { showingSignOutAlert = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                        
                        // Delete Account Button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "trash")
                                Text("Delete Account")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingSignOutAlert) {
                        Alert(
                            title: Text("Sign Out"),
                            message: Text("Are you sure you want to sign out?"),
                            primaryButton: .destructive(Text("Sign Out")) {
                                appRouter.logout()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete my account")) {
                                appRouter.logout() // Equivalent action for now
                            },
                            secondaryButton: .cancel()
                        )
                    }
                
                VStack(spacing: 8) {
                    Text("Version 1.0.0 (Build 204)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
        }
        .background(AppTheme.background.opacity(0.1))
    }
}

struct ProfileMenuRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String
    let color: Color
    var isToggle: Bool = false
    @State private var toggleValue: Bool = true
    let destination: AnyView
    
    var body: some View {
        Group {
            if isToggle {
                toggleContent
            } else {
                NavigationLink(destination: destination) {
                    rowContent
                }
            }
        }
    }
    
    private var rowContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
    }
    
    private var toggleContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
                    .tint(themeManager.primaryColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
    }
}
