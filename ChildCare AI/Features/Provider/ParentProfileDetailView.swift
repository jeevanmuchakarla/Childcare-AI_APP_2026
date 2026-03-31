import SwiftUI

struct ParentProfileDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let parentId: Int
    let parentName: String
    
    @State private var profileData: [String: Any]? = nil
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Parent Profile")
            
            ScrollView {
                if isLoading {
                    ProgressView().padding(.top, 50)
                } else if let error = errorMessage {
                    Text(error).foregroundColor(.red).padding()
                } else {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Text(String(parentName.prefix(1)).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                            }
                            
                            Text(parentName)
                                .font(.title2).fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        // Contact Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact Information")
                                .font(.headline)
                            
                            if let phone = profileData?["phone"] as? String, !phone.isEmpty {
                                DetailRow(icon: "phone.fill", label: "Phone", value: phone)
                            }
                            
                            if let email = profileData?["email"] as? String {
                                DetailRow(icon: "envelope.fill", label: "Email", value: email)
                            }
                            
                            if let address = profileData?["address"] as? String, !address.isEmpty {
                                DetailRow(icon: "mappin.and.ellipse", label: "Address", value: address)
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Bio
                        if let bio = profileData?["bio"] as? String, !bio.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About Parent")
                                    .font(.headline)
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(AppTheme.background)
        .onAppear { fetchProfile() }
    }
    
    private func fetchProfile() {
        Task {
            do {
                let profile = try await ProfileService.shared.getProfile(userId: parentId)
                await MainActor.run {
                    self.profileData = profile
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load profile"
                    self.isLoading = false
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.gray)
                Text(value).font(.body)
            }
            Spacer()
        }
    }
}
