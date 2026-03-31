import SwiftUI

public struct CreateAccountView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
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
    @State private var allergies = ""
    @State private var medicalNotes = ""
    @State private var emergencyContact = ""
    
    // Center (Preschool/Daycare)
    @State private var centerName = ""
    @State private var licenseNumber = ""
    @State private var capacity = ""
    @State private var address = ""
    @State private var openingTime = "08:00 AM"
    @State private var closingTime = "05:00 PM"
    @State private var certifications = ""
    @State private var yearsExperience = ""
    @State private var latitude = ""
    @State private var longitude = ""
    
    @State private var showingOpeningTimePicker = false
    @State private var showingClosingTimePicker = false
    @State private var tempOpeningDate = Date()
    @State private var tempClosingDate = Date()
    
    // Admin
    @State private var employeeId = ""
    @State private var adminToken = ""
    
    // Auth State
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 20)
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text(role == .parent ? "Create Account" : role == .preschool ? "Preschool Onboarding" : role == .daycare ? "Daycare Registration" : "Admin Provisioning")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
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
                            .autocorrectionDisabled()
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
                        
                        CustomTextField(placeholder: "Allergies (None if none)", text: $allergies)
                        CustomTextField(placeholder: "Medical Notes", text: $medicalNotes)
                        CustomTextField(placeholder: "Emergency Contact Info", text: $emergencyContact)
                    } else if role == .preschool || role == .daycare {
                        CustomTextField(placeholder: "Center/School Name", text: $centerName)
                        CustomTextField(placeholder: "Contact Person Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        CustomTextField(placeholder: "Phone", text: $phone)
                        CustomTextField(placeholder: "State License Number", text: $licenseNumber)
                        CustomTextField(placeholder: "Address", text: $address)
                        CustomTextField(placeholder: "Capacity", text: $capacity)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Opening Time")
                                    .font(.footnote)
                                    .foregroundColor(AppTheme.textSecondary)
                                Button(action: { showingOpeningTimePicker = true }) {
                                    HStack {
                                        Text(openingTime)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "clock")
                                    }
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Closing Time")
                                    .font(.footnote)
                                    .foregroundColor(AppTheme.textSecondary)
                                Button(action: { showingClosingTimePicker = true }) {
                                    HStack {
                                        Text(closingTime)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "clock")
                                    }
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        
                        CustomTextField(placeholder: "Years of Experience", text: $yearsExperience)
                            .keyboardType(.numberPad)
                        CustomTextField(placeholder: "Certifications (e.g. CPR, First Aid)", text: $certifications)
                        
                        HStack {
                            CustomTextField(placeholder: "Lat (e.g. 13.08)", text: $latitude)
                                .keyboardType(.decimalPad)
                            CustomTextField(placeholder: "Lon (e.g. 80.27)", text: $longitude)
                                .keyboardType(.decimalPad)
                        }
                    } else if role == .admin {
                        CustomTextField(placeholder: "Full Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        CustomTextField(placeholder: "Employee ID", text: $employeeId)
                    }
                    
                    CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                    
                    // Terms Checkbox
                    HStack(spacing: 12) {
                        Button(action: { agreeToTerms.toggle() }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? themeManager.primaryColor : AppTheme.textSecondary)
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
                if let error = errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                PrimaryButton(title: "Create Account") {
                    performRegistration()
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty || !agreeToTerms)
                .opacity(isLoading ? 0.6 : 1.0)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                )
                .disabled(isLoading || email.isEmpty || password.isEmpty || !agreeToTerms)
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Button("Sign In") {
                        appRouter.navigate(to: .login(role))
                    }
                    .buttonStyle(BounceButtonStyle())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryColor)
                }
            }
            .padding(.bottom, 24)
            .background(AppTheme.background)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showingOpeningTimePicker) {
            TimePickerSheet(title: "Opening Time", selection: $tempOpeningDate) {
                openingTime = tempOpeningDate.formatted(date: .omitted, time: .shortened)
                showingOpeningTimePicker = false
            }
        }
        .sheet(isPresented: $showingClosingTimePicker) {
            TimePickerSheet(title: "Closing Time", selection: $tempClosingDate) {
                closingTime = tempClosingDate.formatted(date: .omitted, time: .shortened)
                showingClosingTimePicker = false
            }
        }
    }
    
    private func performRegistration() {
        isLoading = true
        errorMessage = nil
        
        var payload: [String: Any] = [
            "email": email,
            "password": password,
            "role": role.rawValue
        ]
        
        // Role-specific data
        switch role {
        case .parent:
            payload["full_name"] = fullName
            payload["phone"] = phone
            payload["child_name"] = childsName
            payload["child_age"] = childsAge
            payload["allergies"] = allergies
            payload["medical_notes"] = medicalNotes
            payload["emergency_contact"] = emergencyContact
        case .preschool, .daycare:
            payload["center_name"] = centerName
            payload["full_name"] = fullName
            payload["phone"] = phone
            payload["license_number"] = licenseNumber
            payload["address"] = address
            payload["capacity"] = capacity
            payload["opening_time"] = openingTime
            payload["closing_time"] = closingTime
            payload["certifications"] = certifications
            payload["years_experience"] = Int(yearsExperience) ?? 0
            payload["latitude"] = Double(latitude) ?? 0.0
            payload["longitude"] = Double(longitude) ?? 0.0
        case .admin:
            payload["full_name"] = fullName
        }
        
        Task {
            do {
                let _ = try await AuthService.shared.register(payload: payload)
                DispatchQueue.main.async {
                    isLoading = false
                    // Show success alert and navigate to login
                    let alert = UIAlertController(title: "Request Sent", message: "Your registration request has been sent to the admin for approval. You will receive an email once your account is live.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        appRouter.navigate(to: .login(role))
                    })
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(alert, animated: true)
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

struct TimePickerSheet: View {
    let title: String
    @Binding var selection: Date
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
            
            Button(action: onDone) {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.height(350)])
    }
}
