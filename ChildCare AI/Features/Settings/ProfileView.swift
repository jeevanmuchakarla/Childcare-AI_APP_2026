import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthService.shared
    
    @State private var detailedProfile: [String: Any]? = nil
    @State private var isLoadingPage = false
    @State private var showingEditProfile = false
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header Profile Info
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(themeManager.primaryColor.opacity(0.1))
                            .frame(width: 110, height: 110)
                        AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))/static/uploads/profile_\(AuthService.shared.currentUser?.id ?? 0).jpg?t=\(AuthService.shared.profileImageUpdateTrigger.uuidString)")) { phase in
                            switch phase {
                            case .empty:
                                Image(systemName: profileIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(themeManager.primaryColor.opacity(0.3))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                Image(systemName: profileIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(themeManager.primaryColor.opacity(0.3))
                            @unknown default:
                                Image(systemName: profileIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(themeManager.primaryColor.opacity(0.3))
                            }
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                        .id(AuthService.shared.profileImageUpdateTrigger)
                    }
                    
                    VStack(spacing: 4) {
                        Text(profileName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(roleDescription)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    if appRouter.currentRole != .admin {
                        HStack(spacing: 12) {
                            BadgeView(text: "4.9", icon: "star.fill", color: .orange)
                            BadgeView(text: "Verified", icon: "checkmark.seal.fill", color: Color(hex: "#00C853"))
                        }
                    }
                }
                .padding(.top, 20)
                
                // Content Sections
                VStack(spacing: 24) {
                    // Achievements Section
                    ProfileSection(title: "Achievements", icon: "trophy.fill") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(achievements, id: \.title) { achievement in
                                AchievementBadge(title: achievement.title, icon: achievement.icon, color: achievement.color)
                            }
                        }
                    }
                    
                    // Certificates Section
                    ProfileSection(title: "Certificates & Safety", icon: "checkmark.shield.fill") {
                        VStack(spacing: 12) {
                            ForEach(certificates, id: \.title) { cert in
                                CertificateRow(title: cert.title, issuer: cert.issuer, date: cert.date)
                            }
                        }
                    }
                    
                    // Available Timings Section
                    ProfileSection(title: "Available Timings", icon: "calendar.badge.clock") {
                        VStack(spacing: 10) {
                            ForEach(timings, id: \.day) { timing in
                                TimingRow(day: timing.day, time: timing.time, isClosed: timing.isClosed)
                            }
                        }
                    }
                    
                    // Identity & Contact Section
                    ProfileSection(title: "Contact & Info", icon: "person.text.rectangle.fill") {
                        VStack(spacing: 16) {
                            if let phone = detailedProfile?["phone"] as? String, !phone.isEmpty {
                                ContactInfoRow(icon: "phone.fill", label: "Phone", value: phone)
                            }
                            if let dob = detailedProfile?["date_of_birth"] as? String, !dob.isEmpty {
                                ContactInfoRow(icon: "birthday.cake.fill", label: "Date of Birth", value: dob)
                            }
                            if let address = detailedProfile?["address"] as? String, !address.isEmpty {
                                ContactInfoRow(icon: "mappin.and.ellipse", label: "Address", value: address)
                            }
                            if let website = detailedProfile?["website"] as? String, !website.isEmpty {
                                ContactInfoRow(icon: "globe", label: "Website", value: website)
                            }
                            if (detailedProfile?["phone"] as? String ?? "").isEmpty &&
                               (detailedProfile?["address"] as? String ?? "").isEmpty &&
                               (detailedProfile?["website"] as? String ?? "").isEmpty &&
                               (detailedProfile?["date_of_birth"] as? String ?? "").isEmpty {
                                Text("No contact information added yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .italic()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditProfile = true }) {
                    Text("Edit")
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryColor)
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditProfile, onDismiss: {
            fetchDetailedProfile()
        }) {
            ProfileDetailsScreen()
        }
        .onAppear {
            fetchDetailedProfile()
        }
    }
    
    private func fetchDetailedProfile() {
        guard let user = AuthService.shared.currentUser else { return }
        isLoadingPage = true
        
        Task {
            do {
                let profile = try await ProfileService.shared.getProfile(userId: user.id)
                DispatchQueue.main.async {
                    self.detailedProfile = profile
                    self.isLoadingPage = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoadingPage = false
                }
            }
        }
    }
    
    // MARK: - Data Logic
    
    private var profileName: String {
        if let detailed = detailedProfile {
            if let fullName = detailed["full_name"] as? String { return fullName }
            if let centerName = detailed["center_name"] as? String { return centerName }
        }
        
        if let user = AuthService.shared.currentUser {
            if user.email == "demo@childcare.ai" {
                switch appRouter.currentRole {
                case .parent: return "Jeevan Muchakarla"
                case .daycare: return "Sunshine Daycare"
                case .preschool: return "Happy Hearts Preschool"
                case .admin: return "Platform Admin"
                case .none: return "User Profile"
                }
            } else if user.email.lowercased().contains("jeevan") {
                return "Jeevan Muchakarla"
            }
            
            let emailUsername = user.email.components(separatedBy: "@").first ?? ""
            let cleanedName = emailUsername.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression)
            return cleanedName.isEmpty ? "User Profile" : cleanedName.capitalized
        }
        return "Guest User"
    }
    
    private var profileIcon: String {
        switch appRouter.currentRole {
        case .parent, .admin: return "person.circle.fill"
        case .daycare, .preschool: return "building.2.crop.circle.fill"
        case .none: return "person.circle.fill"
        }
    }
    
    private var roleDescription: String {
        if let detailed = detailedProfile {
            if let bioSnippet = detailed["bio"] as? String, !bioSnippet.isEmpty {
                let shortBio = bioSnippet.count > 30 ? String(bioSnippet.prefix(30)) + "..." : bioSnippet
                return "\(appRouter.currentRole?.rawValue ?? "User") • \(shortBio)"
            }
        }
        
        switch appRouter.currentRole {
        case .parent: return "Parent • 2 Children"
        case .daycare, .preschool:
            if let exp = detailedProfile?["years_experience"] as? String, !exp.isEmpty {
                return "\(appRouter.currentRole == .preschool ? "Preschool" : "Daycare") • \(exp) Experience"
            }
            return appRouter.currentRole == .preschool ? "Montessori Preschool" : "Certified Daycare Center"
        case .admin: return "System Administrator"
        case .none: return ""
        }
    }
    
    private struct RoleData {
        let title: String
        let icon: String
        let color: Color
    }
    
    private var achievements: [RoleData] {
        switch appRouter.currentRole {
        case .parent:
            return [
                RoleData(title: "Early Bird", icon: "sun.max.fill", color: .orange),
                RoleData(title: "Top Parent", icon: "heart.fill", color: .red),
                RoleData(title: "Responsive", icon: "message.fill", color: .blue)
            ]
        case .daycare, .preschool:
            return [
                RoleData(title: "Top Rated", icon: "crown.fill", color: .orange),
                RoleData(title: "Safe Space", icon: "shield.checkered", color: .blue),
                RoleData(title: "5 Star", icon: "star.stack.fill", color: .yellow)
            ]
        default:
            return [RoleData(title: "Elite", icon: "medal.fill", color: .gray)]
        }
    }
    
    private struct CertData {
        let title: String
        let issuer: String
        let date: String
    }
    
    private var certificates: [CertData] {
        if let certsString = detailedProfile?["certifications"] as? String, !certsString.isEmpty {
            return [CertData(title: certsString, issuer: "Verified", date: "Active")]
        }
        
        switch appRouter.currentRole {
        case .parent:
            return [
                CertData(title: "First Aid & CPR", issuer: "Red Cross", date: "Jan 2026"),
                CertData(title: "Verified Identity", issuer: "SafePass", date: "Mar 2024")
            ]
        case .daycare, .preschool:
            return [
                CertData(title: "State Operating License", issuer: "DHFS", date: "Expires 2027"),
                CertData(title: "NAEYC Accreditation", issuer: "NAEYC", date: "Since 2020")
            ]
        default:
            return [CertData(title: "Professional Badge", issuer: "Platform", date: "Active")]
        }
    }
    
    private struct TimeData {
        let day: String
        let time: String
        var isClosed: Bool = false
    }
    
    private var timings: [TimeData] {
        if let opening = detailedProfile?["opening_time"] as? String,
           let closing = detailedProfile?["closing_time"] as? String {
            return [TimeData(day: "Operating Hours", time: "\(opening) - \(closing)")]
        }
        
        switch appRouter.currentRole {
        case .parent:
            return [
                TimeData(day: "Typical Drop-off", time: "08:15 AM"),
                TimeData(day: "Typical Pick-up", time: "05:30 PM")
            ]
        case .daycare, .preschool:
            return [
                TimeData(day: "Mon - Fri", time: "07:00 AM - 06:30 PM"),
                TimeData(day: "Saturday", time: "09:00 AM - 01:00 PM"),
                TimeData(day: "Sunday", time: "Closed", isClosed: true)
            ]
        default:
            return [TimeData(day: "System Status", time: "Online 24/7")]
        }
    }
}

// Sub-components
struct BadgeView: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.05), lineWidth: 1))
        }
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CertificateRow: View {
    let title: String
    let issuer: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Text("\(issuer) • \(date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.blue)
                .font(.caption)
        }
    }
}

struct TimingRow: View {
    let day: String
    let time: String
    var isClosed: Bool = false
    
    var body: some View {
        HStack {
            Text(day)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Text(time)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isClosed ? .red.opacity(0.8) : .gray)
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.textSecondary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(AppTheme.textSecondary)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
        }
    }
}
