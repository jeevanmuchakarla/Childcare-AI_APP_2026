import SwiftUI

public struct AdminLoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Admin Login", onBack: {
                appRouter.navigate(to: .roleSelection)
            })
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Shield Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.primaryGradient)
                            .frame(width: 48, height: 48)
                        Image(systemName: "shield.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Login")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Platform administration access")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(12)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(8)
                    }
                    
                    VStack(spacing: 24) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email / Phone")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray.opacity(0.8))
                            TextField("name@example.com", text: $email)
                                .padding()
                                .background(Color(hex: "#F1F4F9").opacity(0.3))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray.opacity(0.8))
                            HStack {
                                if showPassword {
                                    TextField("••••••••", text: $password)
                                } else {
                                    SecureField("••••••••", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(hex: "#F1F4F9").opacity(0.3))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: { appRouter.navigate(to: .forgotPassword) }) {
                            Text("Forgot password?")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.primaryColor)
                        }
                    }
                    
                    Button(action: performAdminLogin) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.isMulticolor ? AnyView(themeManager.primaryGradient) : AnyView(AppTheme.roleAdmin))
                        .cornerRadius(16)
                        .shadow(color: AppTheme.roleAdmin.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .buttonStyle(BounceButtonStyle())
                    .padding(.top, 10)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func performAdminLogin() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let user = try await AuthService.shared.login(email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                    if user.role == UserRole.admin {
                        appRouter.login(as: .admin)
                    } else {
                        self.errorMessage = "This account is not an Admin. Please use the correct login screen."
                        AuthService.shared.logout()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
