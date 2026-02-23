import SwiftUI

public struct ForgotPasswordView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var email = ""
    @State private var otp = ""
    @State private var currentStep = 1 // 1: Email, 2: OTP, 3: Success
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Top Bar
            HStack {
                Button(action: {
                    if currentStep > 1 && currentStep < 3 {
                        withAnimation {
                            currentStep -= 1
                        }
                    } else {
                        appRouter.navigate(to: .login)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(AppTheme.primary)
                }
                .opacity(currentStep == 3 ? 0 : 1) // Hide back button on success
                Spacer()
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            
            if currentStep == 3 {
                Spacer() // Center the success message
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.secondary.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.secondary)
                }
                .padding(.bottom, 24)
            }
            
            // Title & Subtitle
            VStack(alignment: currentStep == 3 ? .center : .leading, spacing: 8) {
                Text(currentStep == 1 ? "Reset Password" : currentStep == 2 ? "Verify Account" : "Password reset verified")
                    .font(.system(size: currentStep == 3 ? 24 : 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(currentStep == 3 ? .center : .leading)
                
                if currentStep < 3 {
                    Text(currentStep == 1 ? "Enter your email to receive a verification code" : "Enter the 4-digit code sent to your email")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                } else {
                    Text("Your account has been verified. Please\nlog in with your new credentials.")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: currentStep == 3 ? .center : .leading)
            .padding(.horizontal, currentStep == 3 ? 0 : AppTheme.padding)
            .padding(.top, currentStep == 3 ? 0 : 20)
            .padding(.bottom, 40)
            
            // Input Fields
            if currentStep == 1 {
                VStack(spacing: 20) {
                    CustomTextField(
                        placeholder: "Email",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                }
            } else if currentStep == 2 {
                // Mock OTP visual (6 boxes in Figma)
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .background(AppTheme.surface)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, AppTheme.padding)
            }
            
            if currentStep == 3 { Spacer() }
            
            // Action Buttons
            VStack(spacing: 24) {
                PrimaryButton(title: currentStep == 1 ? "Continue" : currentStep == 2 ? "Verify" : "Back to Login") {
                    withAnimation {
                        if currentStep == 3 {
                            appRouter.navigate(to: .login)
                        } else {
                            currentStep += 1
                        }
                    }
                }
                
                if currentStep == 1 {
                    Button("Back to login") {
                        appRouter.navigate(to: .login)
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                } else if currentStep == 2 {
                    Text("Didn't receive code? Resend in 37s")
                        .font(.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, currentStep == 3 ? 0 : 20)
            .padding(.bottom, 40)
            
            if currentStep < 3 { Spacer() }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
