import SwiftUI

public struct ForgotPasswordView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var step: ResetStep = .email
    @State private var email = ""
    @State private var otpCode = ["", "", "", "", "", ""]
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum ResetStep {
        case email, otp, newPassword, success
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Top Bar
            HStack {
                Button(action: {
                    if step == .email {
                        appRouter.navigate(to: .roleSelection)
                    } else if step == .otp {
                        step = .email
                    } else if step == .newPassword {
                        step = .otp
                    }
                }) {
                    if step != .success {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(themeManager.primaryColor)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 32) {
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    switch step {
                    case .email:
                        emailStep
                    case .otp:
                        otpStep
                    case .newPassword:
                        newPasswordStep
                    case .success:
                        successStep
                    }
                }
                .padding(24)
            }
            
            Spacer()
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
    
    // MARK: - Email Step
    private var emailStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Reset Password")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Enter your email to receive a verification\ncode")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Email")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray.opacity(0.8))
                TextField("Enter your email", text: $email)
                    .padding(16)
                    .background(Color(hex: "#F1F4F9").opacity(0.3))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding(.top, 10)
            
            Button(action: handleSendOTP) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.primaryColor)
                .cornerRadius(16)
            }
            .disabled(isLoading || email.isEmpty)
            
            Button(action: { appRouter.navigate(to: .roleSelection) }) {
                Text("Back to Login")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - OTP Step
    private var otpStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Verify Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Enter the 6-digit code sent to \n\(email)")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<6) { index in
                    TextField("", text: $otpCode[index])
                        .frame(width: 44, height: 56)
                        .background(Color(hex: "#F1F4F9").opacity(0.3))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1)))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .onChange(of: otpCode[index]) { oldValue, newValue in
                            if newValue.count > 1 {
                                otpCode[index] = String(newValue.last!)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: handleVerifyOTP) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.primaryColor)
                .cornerRadius(16)
            }
            .disabled(isLoading || otpCode.contains { $0.isEmpty })
            
            HStack(spacing: 4) {
                Text("Didn't receive code?")
                    .font(.caption)
                    .foregroundColor(.gray)
                Button(action: handleSendOTP) {
                    Text("Resend OTP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryColor)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - New Password Step
    private var newPasswordStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("New Password")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Set a strong password for your \naccount")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Password")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray.opacity(0.8))
                SecureField("Enter new password", text: $newPassword)
                    .padding(16)
                    .background(Color(hex: "#F1F4F9").opacity(0.3))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
            
            Button(action: handleResetPassword) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Reset Password")
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.primaryColor)
                .cornerRadius(16)
            }
            .disabled(isLoading || newPassword.count < 6)
        }
    }
    
    // MARK: - Success Step
    private var successStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#EEFBF4"))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#4CAF50"))
            }
            
            VStack(spacing: 12) {
                Text("Password Reset Successful")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text("Your password has been changed.\nYou can now login with your new credentials.")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Button(action: { appRouter.navigate(to: .roleSelection) }) {
                Text("Back to Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(themeManager.primaryColor)
                    .cornerRadius(16)
                    .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Handlers
    
    private func handleSendOTP() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let _ = try await AuthService.shared.forgotPassword(email: email)
                DispatchQueue.main.async {
                    isLoading = false
                    withAnimation { step = .otp }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleVerifyOTP() {
        isLoading = true
        errorMessage = nil
        let code = otpCode.joined()
        Task {
            do {
                let _ = try await AuthService.shared.verifyOTP(email: email, code: code)
                DispatchQueue.main.async {
                    isLoading = false
                    withAnimation { step = .newPassword }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleResetPassword() {
        isLoading = true
        errorMessage = nil
        let code = otpCode.joined()
        Task {
            do {
                let _ = try await AuthService.shared.resetPassword(email: email, code: code, newPassword: newPassword)
                DispatchQueue.main.async {
                    isLoading = false
                    withAnimation { step = .success }
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
