import SwiftUI

public struct ChildProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var childStore: ChildStore
    @State private var showingEditProfile = false
    @State private var childPhoto: UIImage? = nil
    
    let childId: Int
    let name: String
    let age: String
    let role: UserRole
    
    public init(childId: Int, name: String, age: String, role: UserRole) {
        self.childId = childId
        self.name = name
        self.age = age
        self.role = role
    }
    
    // Dynamically retrieve the child model from the store if parent
    private var childModel: Child? {
        if role == .parent {
            return childStore.children.first { $0.id == childId }
        }
        return nil
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // New Premium Header
            ZStack(alignment: .top) {
                // Background Gradient
                LinearGradient(colors: [themeManager.primaryColor, themeManager.primaryColor.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 220)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Spacer()
                        
                        if role == .parent {
                            Button(action: { showingEditProfile = true }) {
                                Text("Edit")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Centered Profile Image & Name
                    VStack(spacing: 12) {
                        ZStack {
                            if let photo = childPhoto {
                                Image(uiImage: photo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(String(name.prefix(1)))
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(childModel?.name ?? name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack {
                                Image(systemName: "calendar")
                                Text(childModel?.age ?? age)
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.top, 5)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Medical & Emergency Info
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(title: "Important Information", icon: "exclamationmark.shield.fill", color: .red)
                        
                        VStack(spacing: 12) {
                            InfoRow(
                                icon: "heart.text.square.fill", 
                                title: "Food Allergies", 
                                value: (childModel?.allergies?.isEmpty == false) ? childModel!.allergies! : "None specified", 
                                color: .red
                            )
                        }
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    
                    // Personal Details
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(title: "Medical & Health Notes", icon: "cross.case.fill", color: .blue)
                        
                        VStack(spacing: 12) {
                            InfoRow(
                                icon: "doc.text.fill", 
                                title: "Notes", 
                                value: (childModel?.medicalNotes?.isEmpty == false) ? childModel!.medicalNotes! : "No medical notes", 
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    
                    // Emergency Info
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(title: "Emergency Info", icon: "phone.circle.fill", color: .green)
                        
                        VStack(spacing: 12) {
                            InfoRow(
                                icon: "phone.fill", 
                                title: "Emergency Contact", 
                                value: (childModel?.emergencyContact?.isEmpty == false) ? childModel!.emergencyContact! : "Not provided", 
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.top, 24)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { 
            fetchChildPhoto()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditChildProfileView(
                childId: childId, 
                name: childModel?.name ?? name, 
                age: childModel?.age ?? age,
                medicalNotes: childModel?.medicalNotes,
                foodAllergies: childModel?.allergies,
                emergencyContact: childModel?.emergencyContact
            )
        }
    }
    
    private func fetchChildPhoto() {
        Task {
            do {
                let url = URL(string: "\(AuthService.shared.baseURL)/profile/child/\(childId)/photo")!
                let (data, response) = try await URLSession.shared.data(from: url)
                if let http = response as? HTTPURLResponse, http.statusCode == 200, let image = UIImage(data: data) {
                    await MainActor.run {
                        self.childPhoto = image
                    }
                }
            } catch {
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
        }
    }
}

