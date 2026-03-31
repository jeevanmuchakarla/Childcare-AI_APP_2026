import SwiftUI

public struct ProviderCategoryListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let categoryTitle: String
    
    @State private var navigateToBookingApplication = false
    @State private var selectedProviderForApplication: (name: String, type: String)? = nil
    @State private var liveProviders: [ProviderModel] = []
    @State private var isLoading = false
    
    public init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
    }
    

    // Singularized type for the button label
    private var singularType: String {
        switch categoryTitle {
        case "Preschools": return "Preschool"
        case "Daycares": return "Daycare"
        default: return "Care"
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: categoryTitle)
            
            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 16) {
                        ForEach(liveProviders) { provider in
                            VStack(alignment: .leading, spacing: 0) {
                                // Professional Card Header with Navigation to Details
                                NavigationLink(destination: ProviderDetailView(
                                    name: provider.name,
                                    type: provider.type,
                                    rating: provider.rating,
                                    price: Int(provider.price?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "/mo", with: "").replacingOccurrences(of: "/hr", with: "") ?? "0") ?? 0,
                                    experience: "Verified Provider",
                                    certifications: ["Verified"],
                                    amenities: ["Verified"],
                                    description: provider.bio ?? "No description available.",
                                    providerId: provider.id)) {
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Image Placeholder
                                        ZStack(alignment: .topTrailing) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 160)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .foregroundColor(.gray.opacity(0.3))
                                                        .font(.system(size: 40))
                                                )
                                            
                                            Image(systemName: "heart")
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(Circle().fill(Color.black.opacity(0.2)))
                                                .padding(12)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(provider.name)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Spacer()
                                                
                                                HStack(spacing: 2) {
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(.yellow)
                                                        .font(.caption)
                                                    Text(String(format: "%.1f", provider.rating))
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(AppTheme.textPrimary)
                                                }
                                            }
                                            
                                            HStack {
                                                Text(provider.price ?? "N/A")
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(themeManager.primaryColor)
                                                Text("•")
                                                    .foregroundColor(.gray)
                                                Text("AI Verified")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(16)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Action Buttons Footer
                                HStack(spacing: 12) {
                                    NavigationLink(destination: BookingFormView(providerName: provider.name, providerType: provider.type, isVisit: true, providerId: provider.id)) {
                                        Text("Book Visit")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(themeManager.primaryColor)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .background(themeManager.primaryColor.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    
                                    NavigationLink(destination: BookingFormView(providerName: provider.name, providerType: provider.type, isVisit: false, providerId: provider.id)) {
                                        Text("Book \(provider.type)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .background(themeManager.primaryColor)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            fetchLiveProviders()
        }
    }
    
    private func fetchLiveProviders() {
        isLoading = true
        let roleFilter: String?
        switch categoryTitle {
        case "Preschools": roleFilter = "Preschool"
        case "Daycares": roleFilter = "Daycare"
        default: roleFilter = nil
        }
        
        Task {
            do {
                let fetched = try await DiscoveryService.shared.fetchProviders(role: roleFilter)
                DispatchQueue.main.async {
                    self.liveProviders = fetched
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
}
