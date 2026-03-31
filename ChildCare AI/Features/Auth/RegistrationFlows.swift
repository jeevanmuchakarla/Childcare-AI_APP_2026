import SwiftUI

// MARK: - Center Type Selection
public struct CenterTypeSelectionView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedType: String? = nil
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Select Center Type")
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Your Center Type")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Choose the type of childcare you provide")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 20) {
                    CenterTypeCard(
                        title: "Preschool",
                        description: "Educational focus for 3-5 years",
                        icon: "building.columns.fill",
                        color: themeManager.primaryColor,
                        isSelected: selectedType == "Preschool"
                    ) {
                        selectedType = "Preschool"
                        // Navigate to preschool registration
                    }
                    
                    CenterTypeCard(
                        title: "Daycare Center",
                        description: "Full-day care for infants & toddlers",
                        icon: "house.fill",
                        color: .green,
                        isSelected: selectedType == "Daycare"
                    ) {
                        selectedType = "Daycare"
                    }
                }
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
    }
}

struct CenterTypeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Daycare Registration
public struct DaycareRegistrationView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var centerName = ""
    @State private var address = ""
    @State private var openingTime = ""
    @State private var closingTime = ""
    @State private var selectedAgeGroups: Set<String> = []
    @State private var safetyCertifications = ""
    @State private var password = ""
    @State private var agreeTerms = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let ageGroups = ["Infant", "Toddler", "Preschool"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Daycare Registration")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daycare Registration")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Register your daycare center")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    VStack(spacing: 24) {
                        RegField(label: "Center Name", placeholder: "Enter center name", text: $centerName)
                        RegField(label: "Address", placeholder: "Full address", text: $address)
                        
                        HStack(spacing: 16) {
                            RegField(label: "Opening Time", placeholder: "08:00 AM", text: $openingTime)
                            RegField(label: "Closing Time", placeholder: "06:00 PM", text: $closingTime)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Age Groups Accepted")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(ageGroups, id: \.self) { group in
                                    AgeGroupChip(title: group, isSelected: selectedAgeGroups.contains(group)) {
                                        if selectedAgeGroups.contains(group) {
                                            selectedAgeGroups.remove(group)
                                        } else {
                                            selectedAgeGroups.insert(group)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RegField(label: "Safety Certifications", placeholder: "e.g. First Aid, CPR", text: $safetyCertifications)
                        RegField(label: "Password", placeholder: "Create a password", text: $password, isSecure: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        Toggle(isOn: $agreeTerms) {
                            HStack(spacing: 2) {
                                Text("I agree to the ")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Button("Terms") {}
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                                Text(" & ")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Button("Privacy Policy") {}
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                            }
                        }
                        .toggleStyle(CheckboxStyle())
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            performRegistration()
                        }) {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryGradient)
                            .cornerRadius(16)
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                        }
                        .buttonStyle(BounceButtonStyle())
                        .disabled(isLoading || centerName.isEmpty || address.isEmpty || password.isEmpty || !agreeTerms)
                        
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Button("Sign In") {
                                appRouter.navigate(to: .login(.daycare))
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                            Spacer()
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
    }
    
    private func performRegistration() {
        isLoading = true
        errorMessage = nil
        
        // Format payload to match FLASK backend for Daycare Center
        let payload: [String: Any] = [
            "email": "auto@\(centerName.replacingOccurrences(of: " ", with: "")).com", // Mock email generation or add email field to UI
            "password": password,
            "role": UserRole.daycare.rawValue,
            "center_name": centerName,
            "address": address,
            "opening_time": openingTime,
            "closing_time": closingTime,
            "safety_certifications": safetyCertifications,
            "capacity": "Capacity depends on age group selections" // Simplified mapping
        ]
        
        Task {
            do {
                _ = try await AuthService.shared.register(payload: payload)
                DispatchQueue.main.async {
                    isLoading = false
                    appRouter.login(as: .daycare)
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

struct AgeGroupChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSelected ? Color(hex: "#EEF4FF") : Color(hex: "#F1F4F9"))
                .foregroundColor(isSelected ? Color(hex: "#0061A4") : .gray)
                .cornerRadius(12)
        }
    }
}

// MARK: - Preschool Registration
public struct PreschoolRegistrationView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var schoolName = ""
    @State private var licenseNumber = ""
    @State private var address = ""
    @State private var contactEmail = ""
    @State private var phone = ""
    @State private var capacity = ""
    @State private var password = ""
    @State private var agreeTerms = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Preschool Registration")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preschool Registration")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Register your preschool center")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 24) {
                        RegField(label: "School Name", placeholder: "Enter school name", text: $schoolName)
                        RegField(label: "License Number", placeholder: "License / Reg Number", text: $licenseNumber)
                        RegField(label: "Address", placeholder: "Full address", text: $address)
                        RegField(label: "Contact Email", placeholder: "School email", text: $contactEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        RegField(label: "Phone", placeholder: "School phone", text: $phone)
                        RegField(label: "Capacity", placeholder: "Max student capacity", text: $capacity)
                        RegField(label: "Password", placeholder: "Create a password", text: $password, isSecure: true)
                    }
                    
                    Toggle(isOn: $agreeTerms) {
                        HStack(spacing: 4) {
                            Text("I agree to the")
                                .font(.caption)
                            Text("Terms of Service")
                                .font(.caption)
                                .foregroundColor(themeManager.primaryColor)
                            Text("and")
                                .font(.caption)
                            Text("Privacy Policy")
                                .font(.caption)
                                .foregroundColor(themeManager.primaryColor)
                        }
                    }
                    .toggleStyle(CheckboxStyle())
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        performRegistration()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                            }
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.primaryColor)
                        .cornerRadius(16)
                        .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .buttonStyle(BounceButtonStyle())
                    .disabled(isLoading || schoolName.isEmpty || contactEmail.isEmpty || password.isEmpty || !agreeTerms)
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("Sign In") {
                            appRouter.navigate(to: .login(.preschool))
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryColor)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
    }
    
    private func performRegistration() {
        isLoading = true
        errorMessage = nil
        
        let payload: [String: Any] = [
            "email": contactEmail,
            "password": password,
            "role": UserRole.preschool.rawValue,
            "center_name": schoolName,
            "address": address,
            "license_number": licenseNumber,
            "phone": phone,
            "capacity": capacity
        ]
        
        Task {
            do {
                _ = try await AuthService.shared.register(payload: payload)
                DispatchQueue.main.async {
                    isLoading = false
                    appRouter.login(as: .preschool)
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

struct RegField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(16)
                    .background(Color(hex: "#F1F4F9"))
                    .cornerRadius(12)
            } else {
                TextField(placeholder, text: $text)
                    .padding(16)
                    .background(Color(hex: "#F1F4F9"))
                    .cornerRadius(12)
            }
        }
    }
}

struct CheckboxStyle: ToggleStyle {
    @EnvironmentObject var themeManager: ThemeManager
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack(spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? themeManager.primaryColor : .gray)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
