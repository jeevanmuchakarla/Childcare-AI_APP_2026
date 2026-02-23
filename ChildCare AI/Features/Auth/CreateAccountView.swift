import SwiftUI

public struct CreateAccountView: View {
    @EnvironmentObject var appRouter: AppRouter
    let role: UserRole
    
    // Shared
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var phone = ""
    @State private var agreeToTerms = false
    
    // Parent
    @State private var childsName = ""
    @State private var childsAge = ""
    
    // Center (Preschool/Daycare)
    @State private var centerName = ""
    @State private var licenseNumber = ""
    @State private var capacity = ""
    
    // Babysitter
    @State private var backgroundCheckId = ""
    @State private var hourlyRate = ""
    
    // Admin
    @State private var employeeId = ""
    @State private var adminToken = ""
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        VStack(spacing: 0) {
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
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text(role == .parent ? "Create Account" : role == .preschool ? "Preschool Onboarding" : role == .daycare ? "Daycare Registration" : role == .babysitter ? "Babysitter Signup" : "Admin Provisioning")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // Dynamic Form based on role
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    if role == .parent {
                        CustomTextField(placeholder: "Full Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        CustomTextField(placeholder: "Phone", text: $phone)
                            .keyboardType(.phonePad)
                        CustomTextField(placeholder: "Child's Name", text: $childsName)
                        
                        // Fake Age Selector for Figma match
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Child's Age")
                                .font(.footnote)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, AppTheme.padding)
                            
                            HStack {
                                Text(childsAge.isEmpty ? "Select Age" : childsAge)
                                    .foregroundColor(childsAge.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, AppTheme.padding)
                            .onTapGesture {
                                childsAge = "2-3 years" // Mock action
                            }
                        }
                    } else if role == .preschool || role == .daycare {
                        CustomTextField(placeholder: "Center/School Name", text: $centerName)
                        CustomTextField(placeholder: "Contact Person Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Phone", text: $phone)
                        CustomTextField(placeholder: "State License Number", text: $licenseNumber)
                    } else if role == .babysitter {
                        CustomTextField(placeholder: "Full Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Phone", text: $phone)
                        CustomTextField(placeholder: "Background Check ID", text: $backgroundCheckId)
                    } else if role == .admin {
                        CustomTextField(placeholder: "Full Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Employee ID", text: $employeeId)
                    }
                    
                    CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                    
                    // Terms Checkbox
                    HStack(spacing: 12) {
                        Button(action: { agreeToTerms.toggle() }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? AppTheme.primary : AppTheme.textSecondary)
                                .font(.system(size: 20))
                        }
                        
                        Text("I agree to the Terms of Service and Privacy Policy")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            
            // Action Buttons
            VStack(spacing: 24) {
                DarkNavyButton(title: "Create Account", hasChevron: true) {
                    appRouter.login(as: role)
                }
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Button("Sign In") {
                        appRouter.navigate(to: .login)
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.bottom, 40)
            .background(AppTheme.background)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
