import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .parent // Used for frontend simulation
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Top Bar
            HStack {
                Button(action: {
                    appRouter.navigate(to: .roleSelection)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(AppTheme.primary)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.primary)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 40)
            .padding(.bottom, 24)
            
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Sign in to continue to ChildCare AI")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.bottom, 40)
            
            // Simulation role selector (kept for functional prototype purposes)
            VStack(alignment: .leading) {
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, AppTheme.padding)
                .padding(.bottom, 20)
            }
            
            // Input Fields
            VStack(spacing: 20) {
                CustomTextField(
                    placeholder: "Email / Phone",
                    text: $email
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                VStack(alignment: .trailing, spacing: 12) {
                    CustomTextField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    
                    Button("Forgot password?") {
                        appRouter.navigate(to: .forgotPassword)
                    }
                    .font(.footnote)
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, AppTheme.padding)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 24) {
                DarkNavyButton(title: "Sign In", hasChevron: true) {
                    appRouter.login(as: selectedRole)
                }
                
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Button("Sign Up") {
                        appRouter.navigate(to: .roleSelection)
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
