import SwiftUI

// MARK: - 1. Profile Screen (NEW)
public struct ProfileScreen: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var showingSignOutAlert = false
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Avatar & Info
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 90, height: 90)
                        
                        Text("SJ")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Sarah Johnson")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("sarah@example.com")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 20)
                
                // Menu Items
                VStack(spacing: 0) {
                    ProfileMenuRow(title: "My Children", icon: "person.2", color: AppTheme.primary)
                    ProfileMenuRow(title: "Payment Methods", icon: "creditcard", color: AppTheme.primary)
                    ProfileMenuRow(title: "Notifications", icon: "bell", color: AppTheme.primary)
                    ProfileMenuRow(title: "Settings", icon: "gearshape", color: AppTheme.primary)
                    ProfileMenuRow(title: "Help & Support", icon: "questionmark.circle", color: AppTheme.primary)
                }
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                .shadow(color: Color.black.opacity(0.03), radius: 3)
                
                // Sign Out
                Button(action: { showingSignOutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(.horizontal, AppTheme.padding)
                .alert(isPresented: $showingSignOutAlert) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            appRouter.logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Text("Version 1.0 • Build 2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ProfileMenuRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        
        Divider().padding(.leading, 56)
    }
}

// MARK: - Profile Details (kept for backward compatibility)
public struct ProfileDetailsScreen: View {
    @State private var name = "Sarah Johnson"
    @State private var phone = "555-0199"
    @State private var email = "sarah@example.com"
    @State private var address = "123 Main St, Springfield, IL"
    
    public var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Full Name", text: $name)
                TextField("Phone Number", text: $phone).keyboardType(.phonePad)
                TextField("Email Address", text: $email).keyboardType(.emailAddress)
            }
            
            Section(header: Text("Location")) {
                TextField("Address", text: $address)
            }
            
            Section {
                Button("Save Changes") { }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 2. Notification Preferences
public struct NotificationPreferencesScreen: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = true
    @State private var smsEnabled = false
    @State private var newBookings = true
    @State private var dailyReports = true
    @State private var paymentConfirmations = true
    @State private var marketingEnabled = false
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Channels
                VStack(alignment: .leading, spacing: 12) {
                    Text("Channels")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.padding)
                    
                    VStack(spacing: 0) {
                        ToggleRow(title: "Push Notifications", isOn: $pushEnabled)
                        ToggleRow(title: "Email Updates", isOn: $emailEnabled)
                        ToggleRow(title: "SMS Alerts", isOn: $smsEnabled)
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .shadow(color: Color.black.opacity(0.03), radius: 3)
                }
                
                // Alert Types
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alert Types")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.padding)
                    
                    VStack(spacing: 0) {
                        ToggleRow(title: "New Bookings", isOn: $newBookings)
                        ToggleRow(title: "Daily Reports", isOn: $dailyReports)
                        ToggleRow(title: "Payment Confirmations", isOn: $paymentConfirmations)
                        ToggleRow(title: "Marketing & Tips", isOn: $marketingEnabled)
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .shadow(color: Color.black.opacity(0.03), radius: 3)
                }
            }
            .padding(.top, 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(AppTheme.primary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            
            Divider().padding(.leading, 16)
        }
    }
}

// MARK: - 3. Privacy & Data
public struct PrivacyAndDataScreen: View {
    @State private var profileVisibility = true
    @State private var dataSharing = false
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Toggles
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Profile Visibility")
                                    .font(.body)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Visible to verified providers only")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $profileVisibility)
                                .labelsHidden()
                                .tint(AppTheme.primary)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        
                        Divider().padding(.leading, 16)
                    }
                    
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data Sharing")
                                    .font(.body)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Share usage data for improvements")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $dataSharing)
                                .labelsHidden()
                                .tint(AppTheme.primary)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                    }
                }
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                .shadow(color: Color.black.opacity(0.03), radius: 3)
                
                // Action Rows
                VStack(spacing: 0) {
                    HStack {
                        Text("Download My Data")
                            .font(.body)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                .shadow(color: Color.black.opacity(0.03), radius: 3)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.body)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                .shadow(color: Color.black.opacity(0.03), radius: 3)
            }
            .padding(.top, 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 4. Help & Support
public struct SupportScreen: View {
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(width: 70, height: 70)
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    Text("How can we help?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Our team is available 24/7 to assist you\nwith any questions.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {}) {
                        Text("Contact Support")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                .shadow(color: Color.black.opacity(0.03), radius: 3)
                
                // Contact Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Contact Options")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.padding)
                    
                    VStack(spacing: 0) {
                        ContactRow(title: "Email Us", icon: "envelope")
                        ContactRow(title: "Call Us", icon: "phone")
                        ContactRow(title: "Live Chat", icon: "message")
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .shadow(color: Color.black.opacity(0.03), radius: 3)
                }
            }
            .padding(.top, 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            
            Divider().padding(.leading, 56)
        }
    }
}

// MARK: - 5. Delete Account Confirmation
public struct DeleteAccountConfirmationScreen: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var textInput = ""
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Warning Banner
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 60, height: 60)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    
                    Text("Are you sure?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("This action cannot be undone. All your\ndata, bookings, and history will be\npermanently deleted.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.05))
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal, AppTheme.padding)
                
                // Confirmation Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Type")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("DELETE")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("to confirm")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    TextField("DELETE", text: $textInput)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, AppTheme.padding)
                
                // Delete Button
                Button(action: {
                    if textInput == "DELETE" {
                        appRouter.navigate(to: .roleSelection)
                    }
                }) {
                    Text("Delete My Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(textInput == "DELETE" ? Color.red : Color.red.opacity(0.4))
                        .cornerRadius(12)
                }
                .disabled(textInput != "DELETE")
                .padding(.horizontal, AppTheme.padding)
                
                // Cancel
                Button(action: {}) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                }
                .padding(.horizontal, AppTheme.padding)
            }
            .padding(.top, 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

