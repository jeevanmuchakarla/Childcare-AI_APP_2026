import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    let role: UserRole
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    // Auth State
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showPendingApprovalAlert = false
    
    public init(role: UserRole) {
        self.role = role
    }
    
    private var roleTitle: String {
        switch role {
        case .parent: return "Parent Login"
        case .preschool: return "Preschool Login"
        case .daycare: return "Daycare Login"
        case .admin: return "Admin Login"
        }
    }
    
    private var roleSubtitle: String {
        switch role {
        case .parent: return "Access your childcare portal"
        case .preschool: return "Manage your early education center"
        case .daycare: return "Manage your daycare center"
        case .admin: return "Platform administration"
        }
    }
    
    private var roleIcon: String {
        switch role {
        case .parent: return "person.2.fill"
        case .preschool: return "graduationcap.fill"
        case .daycare: return "building.2.fill"
        case .admin: return "shield.fill"
        }
    }
    
    private var roleColor: Color {
        switch role {
        case .parent: return AppTheme.roleParent
        case .preschool: return Color(hex: "#FF8C00")
        case .daycare: return AppTheme.roleProvider
        case .admin: return AppTheme.roleAdmin
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "", showBackButton: true, onBack: {
                appRouter.navigate(to: .roleSelection)
            })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 32) {
                    // Role Icon & Title
                    VStack(alignment: .center, spacing: 20) {
                        ZStack {
                            Circle() // Changed to Circle for premium look
                                .fill(roleColor.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: roleIcon)
                                .foregroundColor(roleColor)
                                .font(.system(size: 30))
                        }
                        
                        VStack(alignment: .center, spacing: 12) {
                            Text(roleTitle)
                                .font(.system(size: 40, weight: .black)) // Increased size
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            Text(roleSubtitle)
                                .font(.headline) // More readable
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)
                    
                    // Input Fields
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email / Phone")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            TextField("name@example.com", text: $email)
                                .font(.body)
                                .padding(18)
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            HStack {
                                if showPassword {
                                    TextField("••••••••", text: $password)
                                        .font(.body)
                                } else {
                                    SecureField("••••••••", text: $password)
                                        .font(.body)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye" : "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(18)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
                            
                            HStack {
                                Spacer()
                                Button("Forgot password?") {
                                    appRouter.navigate(to: .forgotPassword)
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.primaryColor)
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 24) { 
                        if let error = errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                
                                if error.contains("connect to the server") || error.contains("offline") {
                                    Button(action: {
                                        Task {
                                            withAnimation { isLoading = true }
                                            let connected = await AuthService.shared.checkServerConnection()
                                            await MainActor.run {
                                                withAnimation {
                                                    isLoading = false
                                                    if connected {
                                                        errorMessage = nil
                                                    } else {
                                                        errorMessage = "Still cannot connect. Please check your internet or server status."
                                                    }
                                                }
                                            }
                                        }
                                    }) {
                                        Label("Retry Connection", systemImage: "arrow.clockwise")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(themeManager.primaryColor)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(themeManager.primaryColor.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.bottom, 4)
                        }
                        
                        PrimaryButton(title: isLoading ? "" : "Sign In") {
                            withAnimation { performLogin() }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .overlay(
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                    }
                    .padding(.top, 8)
                    
                    if role != .admin {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Button("Create Account") {
                                appRouter.navigate(to: .createAccount(role))
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                    }
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Approval Pending", isPresented: $showPendingApprovalAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your account is currently being reviewed by an admin. You will receive an email once your account is approved.")
        }
    }
    
    private func performLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await AuthService.shared.login(email: email, password: password)
                let returnedRole = user.role
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if AuthService.shared.isPendingApproval {
                        showPendingApprovalAlert = true
                        return
                    }

                    // Validate role matches the screen — Admin bypass is allowed via any screen
                    if returnedRole != role {
                        let expectedRoleName = role.rawValue
                        let actualRoleName = returnedRole.rawValue
                        errorMessage = "This account is registered as '\(actualRoleName)', not '\(expectedRoleName)'. Please use the correct login screen."
                        AuthService.shared.logout()
                        return
                    }
                    appRouter.login(as: returnedRole)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}
