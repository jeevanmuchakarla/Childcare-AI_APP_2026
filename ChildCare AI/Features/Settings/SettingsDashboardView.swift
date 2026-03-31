import SwiftUI

public struct SettingsDashboardView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    
    let role: UserRole
    
    public init(role: UserRole) {
        self.role = role
    }
    
    private var currentUser: UserProfile? { AuthService.shared.currentUser }
    @State private var displayName: String = ""
    @State private var userEmail: String = ""
    
    public var body: some View {

        VStack(spacing: 0) {
            AppHeader(title: "Settings", showBackButton: false)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))/static/uploads/profile_\(AuthService.shared.currentUser?.id ?? 0).jpg?t=\(AuthService.shared.profileImageUpdateTrigger.uuidString)")) { phase in
                            switch phase {
                            case .empty:
                                Circle()
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                            .padding(20)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            case .failure(_):
                                Circle()
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                            .padding(20)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .id(AuthService.shared.profileImageUpdateTrigger)
                    
                    VStack(spacing: 6) {
                        Text(displayName.isEmpty ? (currentUser?.full_name ?? "User Profile") : displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(userEmail.isEmpty ? (currentUser?.email ?? "") : userEmail)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .opacity(0.8)
                    }
                }
                .padding(.top, 20)
                
                // Account Section
                DashboardSection(title: "Account") {
                    NavigationLink(destination: ProfileView()) {
                        DashboardRowContent(title: "Profile", icon: "person", color: .blue)
                    }
                }
                
                // Preferences Section
                DashboardSection(title: "Preferences") {
                    NavigationLink(destination: AppearanceSettingsView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.primaryColor)
                            }
                            
                            Text("Appearance")
                                .font(.body)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            // Color indicator
                            Circle()
                                .fill(themeManager.primaryColor)
                                .frame(width: 8, height: 8)
                                .padding(.trailing, 4)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.gray.opacity(0.3))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    Toggle(isOn: $themeManager.isDarkMode) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.purple)
                            }
                            Text("Dark Mode")
                                .font(.body)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .tint(themeManager.primaryColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                
                // About & Support Section
                DashboardSection(title: "About & Support") {
                    NavigationLink(destination: TermsAndConditionsScreen()) {
                        DashboardRowContent(title: "Terms & Conditions", icon: "doc.text", color: .gray)
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: PrivacyPolicyScreen()) {
                        DashboardRowContent(title: "Privacy Policy", icon: "shield.lefthalf.filled", color: .blue)
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: SupportScreen()) {
                        DashboardRowContent(title: "Help & Support", icon: "questionmark.circle", color: .orange)
                    }
                }
                
                
                // Auth Actions
                VStack(spacing: 12) {
                    Button(action: { appRouter.logout() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                    
                    NavigationLink(destination: DeleteAccountConfirmationScreen()) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            userEmail = currentUser?.email ?? ""
            // Prefer the name already in auth session
            if let name = currentUser?.full_name, !name.isEmpty {
                displayName = name
            }
            // Also fetch from profile API for up-to-date name
            guard let userId = currentUser?.id, userId > 0 else { return }
            Task {
                if let profile = try? await ProfileService.shared.getProfile(userId: userId) {
                    DispatchQueue.main.async {
                        let name = (profile["full_name"] as? String)
                            ?? (profile["center_name"] as? String)
                            ?? ""
                        
                        if !name.isEmpty {
                            self.displayName = name
                        } else if let email = self.currentUser?.email {
                            if email.lowercased().contains("jeevan") {
                                self.displayName = "Jeevan Muchakarla"
                            } else {
                                let prefix = email.components(separatedBy: "@").first ?? ""
                                let clean = prefix.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression)
                                self.displayName = clean.capitalized
                            }
                        }
                    }
                }
            }
        }
    }
}
}

struct DashboardSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            .padding(.horizontal)
        }
    }
}

struct DashboardRowContent: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
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
                .foregroundColor(Color.gray.opacity(0.3))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}
