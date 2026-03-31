import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

// MARK: - General Settings Screen (Replacement for old Settings content)
public struct GeneralSettingsScreen: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Settings", showBackButton: true)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Account Section
                    SettingsSection(title: "Account") {
                        SettingsRowSimple(title: "View Profile", icon: "person.fill", color: .blue, destination: AnyView(ProfileView()))
                        SettingsRowSimple(title: "Privacy", icon: "shield.fill", color: .green, destination: AnyView(PrivacyAndDataScreen()))
                    }
                    
                    // Preferences Section
                    SettingsSection(title: "Preferences") {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.12))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.purple)
                            }
                            Text("Dark Mode")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Toggle("", isOn: $appRouter.isDarkMode)
                                .labelsHidden()
                                .tint(themeManager.primaryColor)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        
                    }
                    
                    // Support Section
                    SettingsSection(title: "Support") {
                        SettingsRowSimple(title: "Help & Support", icon: "questionmark.circle.fill", color: .indigo, destination: AnyView(SupportScreen()))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Components
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
    }
}

struct SettingsRowSimple: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 15))
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.4))
                }
                .padding(.vertical, 14)
                .padding(.horizontal)
                
                if title != "Help & Support" && title != "Privacy" {
                    Divider()
                        .background(AppTheme.divider)
                        .padding(.leading, 64)
                }
            }
        }
    }
}

// MARK: - 2. Notification Preferences
public struct NotificationPreferencesScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    // ... (rest of states)
    @State private var pushEnabled = true
    @State private var emailEnabled = true
    @State private var smsEnabled = false
    @State private var newBookings = true
    @State private var dailyReports = true
    @State private var paymentConfirmations = true
    @State private var marketingEnabled = false
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Notifications")

            ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Channels
                VStack(alignment: .leading, spacing: 12) {
                    Text("Channels".uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        ToggleRowRedesign(title: "Push Notifications", isOn: $pushEnabled)
                        ToggleRowRedesign(title: "Email Updates", isOn: $emailEnabled)
                        ToggleRowRedesign(title: "SMS Alerts", isOn: $smsEnabled, showDivider: false)
                    }
                    .background(AppTheme.cardBackground)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                }
                .padding(.horizontal)
                
                // Alert Types
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alert Types".uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        ToggleRowRedesign(title: "New Bookings", isOn: $newBookings)
                        ToggleRowRedesign(title: "Daily Reports", isOn: $dailyReports)
                        ToggleRowRedesign(title: "Payment Confirmations", isOn: $paymentConfirmations)
                        ToggleRowRedesign(title: "Marketing & Tips", isOn: $marketingEnabled, showDivider: false)
                    }
                    .background(AppTheme.cardBackground)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                }
                .padding(.horizontal)
            }
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ToggleRowRedesign: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var isOn: Bool
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(themeManager.primaryColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
            
            if showDivider {
                Divider()
                    .background(AppTheme.divider)
                    .padding(.leading)
            }
        }
    }
}

// MARK: - 3. Privacy & Data
public struct PrivacyAndDataScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingDownloadAlert = false
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Privacy & Data")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // App Information Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App Transparency".uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.leading, 8)
                            
                        VStack(spacing: 0) {
                            NavigationLink(destination: AppPrivacyScreen()) {
                                SupportRow(title: "App Privacy & Data", icon: "shield.lefthalf.filled")
                            }
                            
                            Button(action: { showingDownloadAlert = true }) {
                                SupportRow(title: "Download My Data", icon: "arrow.down.circle", showDivider: false)
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Data Security")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("ChildCare AI uses industry-standard encryption to protect your sensitive information. We only store data necessary for the operation of the childcare services you use.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(themeManager.primaryColor.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Data Request", isPresented: $showingDownloadAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your data report is being prepared. You will receive an export of your profile, bookings, and messaging history via your registered email address shortly.")
        }
    }
}

public struct AppPrivacyScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "App Privacy")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    PrivacySection(title: "Data Collection", content: "We collect only essential information such as your name, contact details, and child profiles to facilitate childcare bookings and communication.")
                    
                    PrivacySection(title: "Communication", content: "Messages sent through the app are stored securely to provide you with a history of your conversations with providers.")
                    
                    PrivacySection(title: "Location Data", content: "We use location data only to help you find childcare providers near you. This data is not shared with third parties.")
                    
                    PrivacySection(title: "Third-Party Sharing", content: "ChildCare AI does not sell your personal data. Data is only shared with childcare providers you explicitly choose to book with.")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Version Information")
                            .font(.headline)
                        Text("App Version: 1.0.0 (Build 2026.03.14)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(6)
            
            Divider()
                .padding(.top, 8)
        }
    }
}

struct ToggleRowWithSubtitle: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(themeManager.primaryColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
            
            if showDivider {
                Divider()
                    .background(AppTheme.divider)
                    .padding(.leading)
            }
        }
    }
}

struct SettingsActionRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.divider, lineWidth: 1))
        .padding(.horizontal)
    }
}

// MARK: - 4. Help & Support
public struct SupportScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Help & Support")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Contact Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Us".uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.leading, 8)
                        
                        Button(action: {
                            if let url = URL(string: "mailto:jeevankiran14341@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(themeManager.primaryColor)
                                    .font(.system(size: 18))
                                
                                Text("jeevankiran14341@gmail.com")
                                    .font(.body)
                                    .foregroundColor(Color(hex: "#00C853"))
                                
                                Spacer()
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FAQ".uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            FAQRow(question: "How do I find a verified childcare?", answer: "Use the 'World Childcares' or 'Verified Users' filter in AI Recommendations to find centers that meet our quality standards.")
                            FAQRow(question: "Is my data safe?", answer: "Yes, ChildCare AI utilizes industry-standard end-to-end encryption for all your sensitive information and real-time storage.")
                            FAQRow(question: "How do real-time updates work?", answer: "Providers send daily reports containing activities, meals, and photos that appear instantly on your home screen.")
                            FAQRow(question: "What is the 'Go' button for?", answer: "The 'Go' button in recommendations opens the childcare's location directly in your maps app for easy navigation.", showDivider: false)
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    var showDivider: Bool = true
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
            }
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if showDivider {
                Divider()
                    .background(AppTheme.divider)
                    .padding(.leading)
            }
        }
    }
}

struct SupportRow: View {
    let title: String
    let icon: String
    var showDivider: Bool = true
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(themeManager.primaryColor)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding()
            
            if showDivider {
                Divider()
                    .background(AppTheme.divider)
                    .padding(.leading, 56)
            }
        }
    }
}

// MARK: - 5. Delete Account Confirmation
public struct DeleteAccountConfirmationScreen: View {
    @EnvironmentObject var appRouter: AppRouter
    @Environment(\.presentationMode) var presentationMode
    @State private var textInput = ""
    
    public var body: some View {
        VStack(spacing: 24) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Warning Card
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(Color(hex: "#FF4D4C"))
                        }
                        
                        VStack(spacing: 12) {
                            Text("Are you sure?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#8B0000"))
                            
                            Text("This action cannot be undone. All your\ndata, bookings, and history will be\npermanently deleted.")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#FF4D4C"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFF1F1"))
                    .cornerRadius(32)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Type")
                            Text("DELETE").fontWeight(.black)
                            Text("to confirm")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                        TextField("DELETE", text: $textInput)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                            .autocapitalization(.allCharacters)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            if textInput == "DELETE" {
                                appRouter.logout()
                            }
                        }) {
                            Text("Delete My Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(textInput == "DELETE" ? Color(hex: "#FF8A8A") : Color(hex: "#FF8A8A").opacity(0.3))
                                .cornerRadius(16)
                                .shadow(color: textInput == "DELETE" ? Color(hex: "#FF8A8A").opacity(0.3) : Color.clear, radius: 10, y: 5)
                        }
                        .disabled(textInput != "DELETE")
                        
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .background(AppTheme.background.opacity(0.1))
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Profile Details Screen
public struct ProfileDetailsScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var certifications = ""
    @State private var yearsExperience = ""
    @State private var openingTime = "08:00 AM"
    @State private var closingTime = "05:00 PM"
    @State private var dateOfBirth = Date()
    @State private var hasDateOfBirth = false
    @State private var isLoading = false
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    @State private var certificationsList: [Certification] = []
    @State private var newCertName = ""
    @State private var showingFilePicker = false
    @State private var isUploadingCert = false
    
    // Profile Image State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploadingImage = false
    
    public init() {}
    
    private var isProvider: Bool {
        appRouter.currentRole == .daycare || appRouter.currentRole == .preschool
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Profile Details")

            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.primaryColor))
                Text("Loading profile...")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 8)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header Visual
                        ZStack {
                            themeManager.primaryGradient
                                .frame(height: 120)
                                .opacity(0.1)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            VStack(spacing: 12) {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    ZStack(alignment: .bottomTrailing) {
                                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .shadow(color: themeManager.primaryColor.opacity(0.2), radius: 15)
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(themeManager.primaryColor)
                                                .padding(4)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: themeManager.primaryColor.opacity(0.2), radius: 15)
                                        }
                                        
                                        Circle()
                                            .fill(themeManager.primaryColor)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14))
                                            )
                                    }
                                }
                                .onChange(of: selectedItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            await MainActor.run {
                                                selectedImageData = data
                                                uploadProfileImage(data: data)
                                            }
                                        }
                                    }
                                }
                                
                                Text(name.isEmpty ? (isProvider ? "Center Name" : "Your Profile") : name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .offset(y: 40)
                        }
                        .padding(.bottom, 40)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            SectionHeader(title: "Identity")
                            
                            VStack(spacing: 1) {
                                PremiumInputField(label: isProvider ? "Center Name" : "Full Name", text: $name, icon: "person.fill")
                                Divider().padding(.leading, 50)
                                PremiumInputField(label: "Email Address", text: $email, icon: "envelope.fill")
                                Divider().padding(.leading, 50)
                                PremiumDatePickerField(label: "Date of Birth", date: $dateOfBirth, icon: "calendar")
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                            
                            SectionHeader(title: "Contact & Online")
                            
                            VStack(spacing: 1) {
                                PremiumInputField(label: "Phone Number", text: $phone, icon: "phone.fill")
                                Divider().padding(.leading, 50)
                                PremiumInputField(label: "Address", text: $address, icon: "mappin.and.ellipse")
                                Divider().padding(.leading, 50)
                                PremiumInputField(label: "Website", text: $website, icon: "globe")
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                            
                            SectionHeader(title: "About")
                            
                            PremiumTextEditor(label: "Biography", text: $bio)
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                            
                            if isProvider {
                                SectionHeader(title: "Professional Details")
                                
                                VStack(spacing: 1) {
                                    PremiumInputField(label: "Years of Experience", text: $yearsExperience, icon: "briefcase.fill")
                                    Divider().padding(.leading, 50)
                                    PremiumInputField(label: "Certifications", text: $certifications, icon: "checkmark.seal.fill")
                                }
                                .background(AppTheme.surface)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                                
                                SectionHeader(title: "Operating Hours")
                                
                                VStack(spacing: 1) {
                                    PremiumInputField(label: "Opening Time", text: $openingTime, icon: "clock.fill")
                                    Divider().padding(.leading, 50)
                                    PremiumInputField(label: "Closing Time", text: $closingTime, icon: "clock.badge.checkmark.fill")
                                }
                                .background(AppTheme.surface)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                            }
                            
                            // Certifications Section (For all users)
                            SectionHeader(title: "Certifications")
                            
                            VStack(spacing: 16) {
                                if certificationsList.isEmpty {
                                    Text("No certifications added yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(certificationsList) { cert in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(cert.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                Text("Uploaded on \(cert.created_at.prefix(10))")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            
                                            Button(action: { deleteCert(cert) }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red.opacity(0.7))
                                                    .font(.subheadline)
                                            }
                                        }
                                        .padding()
                                        .background(AppTheme.background.opacity(0.5))
                                        .cornerRadius(12)
                                    }
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Add New Certification")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.primaryColor)
                                    
                                    HStack(spacing: 12) {
                                        TextField("Certification Name", text: $newCertName)
                                            .padding(10)
                                            .background(Color.gray.opacity(0.05))
                                            .cornerRadius(8)
                                        
                                        Button(action: { showingFilePicker = true }) {
                                            HStack {
                                                if isUploadingCert {
                                                    ProgressView()
                                                        .scaleEffect(0.8)
                                                } else {
                                                    Image(systemName: "doc.badge.plus")
                                                    Text("Upload")
                                                }
                                            }
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(newCertName.isEmpty ? Color.gray : themeManager.primaryColor)
                                            .cornerRadius(8)
                                        }
                                        .disabled(newCertName.isEmpty || isUploadingCert)
                                    }
                                }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                            .fileImporter(
                                isPresented: $showingFilePicker,
                                allowedContentTypes: [.pdf, .image, .plainText],
                                allowsMultipleSelection: false
                            ) { result in
                                handleFilePicker(result: result)
                            }
                        }
                        .padding(.horizontal)
                        
                        PrimaryButton(title: "Save Changes") {
                            saveChanges()
                        }
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.6 : 1.0)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        .overlay(
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                        .alert("Profile Update", isPresented: $showSaveAlert) {
                            Button("OK", role: .cancel) { 
                                if alertMessage.contains("successfully") {
                                    dismiss()
                                }
                            }
                        } message: {
                            Text(alertMessage)
                        }
                    }
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear(perform: loadProfile)
    }
    
    private func loadProfile() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        
        Task {
            do {
                let data = try await ProfileService.shared.getProfile(userId: userId)
                DispatchQueue.main.async {
                    self.email = data["email"] as? String ?? ""
                    
                    if isProvider {
                        self.name = data["center_name"] as? String ?? ""
                        self.address = data["address"] as? String ?? ""
                    } else {
                        self.name = data["full_name"] as? String ?? ""
                        self.address = data["address"] as? String ?? "No address set"
                    }
                    self.phone = data["phone"] as? String ?? ""
                    self.bio = data["bio"] as? String ?? ""
                    self.website = data["website"] as? String ?? ""
                    self.certifications = data["certifications"] as? String ?? ""
                    if let years = data["years_experience"] as? Int {
                        self.yearsExperience = "\(years)"
                    } else {
                        self.yearsExperience = data["years_experience"] as? String ?? ""
                    }
                    self.openingTime = data["opening_time"] as? String ?? "08:00 AM"
                    self.closingTime = data["closing_time"] as? String ?? "05:00 PM"
                    
                    if let dobString = data["date_of_birth"] as? String, !dobString.isEmpty {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        if let pdob = formatter.date(from: dobString) {
                            self.dateOfBirth = pdob
                            self.hasDateOfBirth = true
                        }
                    }
                    
                    // Load certifications separately
                    Task {
                        do {
                            let certs = try await ProfileService.shared.getCertifications(userId: userId)
                            DispatchQueue.main.async {
                                self.certificationsList = certs
                            }
                        } catch {
                        }
                    }
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dobString = formatter.string(from: dateOfBirth)
        
        let updateData = ProfileUpdateData(
            full_name: isProvider ? nil : name,
            center_name: isProvider ? name : nil,
            phone: phone,
            address: address,
            bio: bio,
            website: website,
            certifications: isProvider ? certifications : nil,
            years_experience: isProvider ? Int(yearsExperience) : nil,
            opening_time: isProvider ? openingTime : nil,
            closing_time: isProvider ? closingTime : nil,
            profile_image: nil,
            date_of_birth: dobString
        )
        
        Task {
            do {
                let success = try await ProfileService.shared.updateProfile(userId: userId, updateData: updateData)
                DispatchQueue.main.async {
                    self.isLoading = false
                    if success {
                        AuthService.shared.updateUserRecord(fullName: self.name)
                        self.alertMessage = "Your profile has been updated successfully."
                    } else {
                        self.alertMessage = "Failed to update profile. Please try again."
                    }
                    self.showSaveAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        }
    }
    
    private func handleFilePicker(result: Result<[URL], Error>) {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let fileData = try Data(contentsOf: url)
                let fileName = url.lastPathComponent
                let name = newCertName
                
                isUploadingCert = true
                
                Task {
                    do {
                        if let newCert = try await ProfileService.shared.uploadCertification(
                            userId: userId, 
                            name: name, 
                            fileData: fileData, 
                            fileName: fileName
                        ) {
                            DispatchQueue.main.async {
                                self.certificationsList.append(newCert)
                                self.newCertName = ""
                                self.isUploadingCert = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.isUploadingCert = false
                                self.alertMessage = "Failed to upload certification."
                                self.showSaveAlert = true
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.isUploadingCert = false
                            self.alertMessage = "Error: \(error.localizedDescription)"
                            self.showSaveAlert = true
                        }
                    }
                }
            } catch {
                self.alertMessage = "Could not read file: \(error.localizedDescription)"
                self.showSaveAlert = true
            }
            
        case .failure(let error):
            self.alertMessage = "File selection failed: \(error.localizedDescription)"
            self.showSaveAlert = true
        }
    }
    
    private func deleteCert(_ cert: Certification) {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        Task {
            do {
                let success = try await ProfileService.shared.deleteCertification(userId: userId, certId: cert.id)
                if success {
                    DispatchQueue.main.async {
                        self.certificationsList.removeAll { $0.id == cert.id }
                    }
                }
            } catch {
            }
        }
    }
    private func uploadProfileImage(data: Data) {
        isUploadingImage = true
        Task {
            do {
                let userId = AuthService.shared.currentUser?.id ?? -1
                let boundary = "Boundary-\(UUID().uuidString)"
                let url = URL(string: "\(AuthService.shared.baseURL)/upload/profile-photo/\(userId)")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.httpBody = body
                
                let (_, response) = try await URLSession.shared.data(for: request)
                let http = response as? HTTPURLResponse
                
                await MainActor.run {
                    isUploadingImage = false
                    if http?.statusCode == 200 || http?.statusCode == 201 {
                        AuthService.shared.triggerProfileImageReload()
                    }
                }
            } catch {
                await MainActor.run { isUploadingImage = false }
            }
        }
    }
}

struct PremiumInputField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1)
                
                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct PremiumDatePickerField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    @Binding var date: Date
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// Legacy compatibility
struct CustomInputField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
            
            TextField("", text: $text)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.vertical, 4)
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Premium Text Editor
struct PremiumTextEditor: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            TextEditor(text: $text)
                .frame(height: 100)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

// MARK: - Terms & Conditions Screen
public struct TermsAndConditionsScreen: View {
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Terms & Conditions")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Terms & Conditions")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Last updated: March 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Welcome to ChildCare AI. By using this application, you agree to the following terms:")
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    TermSection(number: "1", title: "Service Purpose", content: "ChildCare AI is a platform connecting parents with childcare providers. We facilitate bookings, communication, and real-time updates but do not provide childcare services directly.")
                    
                    TermSection(number: "2", title: "User Responsibilities", content: "Users must provide accurate information. Parents are responsible for verifying provider credentials, although we provide verification badges for convenience.")
                    
                    TermSection(number: "3", title: "Real-time Data", content: "Daily reports and activities are provided by childcare centers. We ensure the transmission of this data but are not responsible for the accuracy of content submitted by providers.")
                    
                    TermSection(number: "4", title: "Privacy", content: "Your data is handled according to our Privacy Policy. We use encrypted storage to protect all sensitive child and parent information.")
                    
                    TermSection(number: "5", title: "Usage", content: "Use this app responsibly for managing childcare needs. Commercial use for purposes other than those intended is prohibited.")
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct TermSection: View {
    let number: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(number). \(title)")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(6)
        }
    }
}

// MARK: - Privacy Policy Screen
public struct PrivacyPolicyScreen: View {
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Privacy Policy")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Last updated: March 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("At ChildCare AI, we take your privacy 100% seriously. Your data safely stored and industry-standard encrypted.")
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    PrivacySectionItem(title: "Data We Collect", points: [
                        "Personal information (name, email, phone)",
                        "Child profiles (names, birthdays, allergies)",
                        "Real-time activity logs and photos",
                        "Booking history and payment records"
                    ])
                    
                    PrivacySectionItem(title: "How We Use Data", points: [
                        "Facilitate bookings with providers",
                        "Deliver real-time daily updates to parents",
                        "Provide AI-powered childcare recommendations",
                        "Improve safety through verification processes"
                    ])
                    
                    PrivacySectionItem(title: "Data Protection", points: [
                        "100% Secure Real-time Storage",
                        "End-to-end data encryption",
                        "Compliant with data protection regulations",
                        "Regular security audits and updates"
                    ])
                    
                    Text("We do not sell your personal information. Your data is only shared with childcare providers you explicitly choose to interact with.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .italic()
                        .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct PrivacySectionItem: View {
    let title: String
    let points: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)
                        Text(point)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }
}
