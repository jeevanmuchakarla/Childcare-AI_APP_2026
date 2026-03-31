import SwiftUI

public struct CenterProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showProfileMenu = false
    @State private var showShareSheet = false
    @State private var showEditProfile = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryColor)
                    }
                    
                    Spacer()
                    
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    // Top-right menu button
                    Menu {
                        Button(action: { showEditProfile = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        Button(action: { showShareSheet = true }) {
                            Label("Share Profile", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.primaryColor)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(.gray.opacity(0.2)), alignment: .bottom)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Header Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.roleProvider.opacity(0.12))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.roleProvider)
                            }
                            
                            VStack(spacing: 8) {
                                Text(centerDisplayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption)
                                    Text("Verified Center")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(Color(hex: "#008A3D"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#E8FFF4"))
                                .clipShape(Capsule())
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text("4.9  •  126 reviews")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        // Stats Row
                        HStack(spacing: 0) {
                            CenterStatBox(value: "48", label: "Children")
                            Divider().frame(height: 40)
                            CenterStatBox(value: "12", label: "Staff")
                            Divider().frame(height: 40)
                            CenterStatBox(value: "5yr", label: "Experience")
                        }
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Menu Items
                        VStack(spacing: 0) {
                            CenterProfileMenuRow(icon: "person", title: "Center Profile", color: .blue, action: { showEditProfile = true })
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: MyRatingsView()) {
                                CenterProfileMenuRowContent(icon: "star", title: "My Ratings", color: .orange)
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: AchievementsView()) {
                                CenterProfileMenuRowContent(icon: "trophy", title: "Achievements", color: .indigo)
                            }
                            
                            if appRouter.currentRole == .preschool {
                                Divider().padding(.leading, 56)
                                NavigationLink(destination: CurriculumOfferingsView()) {
                                    CenterProfileMenuRowContent(icon: "book.fill", title: "Curriculum Offerings", color: .green)
                                }
                                Divider().padding(.leading, 56)
                                NavigationLink(destination: ClassSchedulesView()) {
                                    CenterProfileMenuRowContent(icon: "calendar", title: "Class Schedules", color: .blue)
                                }
                            }
                        }
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfile) {
            CenterProfileEditView(centerName: centerDisplayName)
        }
    }
    
    private var centerDisplayName: String {
        switch appRouter.currentRole {
        case .preschool: return "Happy Minds Preschool"
        default: return "Sunshine Daycare"
        }
    }
}

struct CenterProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State var centerName: String
    @State private var email = "contact@center.com"
    @State private var phone = "(555) 123-4567"
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roleProvider.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.roleProvider)
                        
                        Circle()
                            .fill(themeManager.primaryColor)
                            .frame(width: 32, height: 32)
                            .overlay(Image(systemName: "camera.fill").foregroundColor(.white).font(.caption))
                            .offset(x: 35, y: 35)
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ProfileEditField(label: "Center Name", text: $centerName)
                        ProfileEditField(label: "Email Address", text: $email)
                        ProfileEditField(label: "Phone Number", text: $phone)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Button(action: { showSuccess = true }) {
                        Text("Save Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Center profile updated successfully.")
            }
        }
    }
}

struct ProfileEditField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .padding()
                .background(AppTheme.background.opacity(0.3))
                .cornerRadius(12)
        }
    }
}

struct CenterStatBox: View {
    let value: String
    // ... rest of implementation (re-adding from existing code as I replaced it)
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct CenterProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CenterProfileMenuRowContent(icon: icon, title: title, color: color)
        }
    }
}

struct CenterProfileMenuRowContent: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
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
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
