import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var showingSignOutAlert = false
    @State private var darkModeEnabled = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Account
                    SettingsGroup(title: "Account") {
                        SettingsNavRow(title: "Profile", icon: "person.crop.rectangle", destination: AnyView(ProfileScreen()))
                        SettingsNavRow(title: "Privacy", icon: "shield.lefthalf.filled", color: AppTheme.secondary, destination: AnyView(PrivacyAndDataScreen()))
                    }
                    
                    // Preferences
                    SettingsGroup(title: "Preferences") {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.primary.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "moon.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.primary)
                            }
                            
                            Text("Dark Mode")
                                .font(.body)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $darkModeEnabled)
                                .labelsHidden()
                                .tint(AppTheme.primary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        
                        Divider().padding(.leading, 64)
                        
                        SettingsNavRow(title: "Notifications", icon: "bell.badge", color: .orange, destination: AnyView(NotificationPreferencesScreen()))
                    }
                    
                    // Support
                    SettingsGroup(title: "Support") {
                        SettingsNavRow(title: "Help & Support", icon: "questionmark.circle.fill", color: AppTheme.roleAdmin, destination: AnyView(SupportScreen()))
                    }
                    
                    // Sign Out
                    Button(action: { showingSignOutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                    .padding(.horizontal, AppTheme.padding)
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
                    
                    // Delete Account
                    NavigationLink(destination: DeleteAccountConfirmationScreen()) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 10)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Reusable Settings Components
struct SettingsGroup<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, AppTheme.padding)
            
            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal, AppTheme.padding)
            .shadow(color: Color.black.opacity(0.03), radius: 3)
        }
    }
}

struct SettingsNavRow: View {
    let title: String
    let icon: String
    var color: Color = AppTheme.primary
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            SettingsRow(title: title, icon: icon, color: color, showChevron: true)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    var color: Color = AppTheme.primary
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        
        Divider()
            .padding(.leading, 64)
    }
}

