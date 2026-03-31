import SwiftUI

public struct AdminAccessView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var name = ""
    @State private var email = ""
    @State private var accessCode = ""
    @State private var password = ""
    @State private var agreeToTerms = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Top Bar
            HStack {
                Button(action: { appRouter.navigate(to: .roleSelection) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Admin Access")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Secure platform access")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    VStack(spacing: 20) {
                        AdminInputField(label: "Admin Name", placeholder: "Full Name", text: $name)
                        AdminInputField(label: "Admin Email", placeholder: "admin@carenest.ai", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        AdminInputField(label: "Secure Access Code", placeholder: "Enter secure code", text: $accessCode)
                        AdminInputField(label: "Password", placeholder: "Create a password", text: $password, isSecure: true)
                    }
                    
                    HStack(alignment: .top, spacing: 4) {
                        Button(action: { agreeToTerms.toggle() }) {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(themeManager.primaryColor, lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    agreeToTerms ? Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(themeManager.primaryColor) : nil
                                )
                        }
                        
                        Text("I agree to the \(Text("Terms of Service").fontWeight(.bold).foregroundColor(themeManager.primaryColor)) and \(Text("Privacy Policy").fontWeight(.bold).foregroundColor(themeManager.primaryColor))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 16) {
                        Text("Admin registration is restricted. Please contact the system owner if you require access.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Spacer()
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(action: { appRouter.navigate(to: .adminLogin) }) {
                            Text("Sign In")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.primaryColor)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct AdminInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color(hex: "#F1F4F9").opacity(0.3))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color(hex: "#F1F4F9").opacity(0.3))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
        }
    }
}
