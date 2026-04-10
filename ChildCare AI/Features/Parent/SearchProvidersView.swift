import SwiftUI

public struct SearchProvidersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var selectedFilter = "Distance"
    @State private var providers: [ProviderModel] = []
    @State private var isLoading = false
    let filters = ["Distance", "Price", "Rating", "Type"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Search")
                
            VStack(alignment: .leading, spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by name or location", text: $searchText)
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(title: filter, isSelected: selectedFilter == filter) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
            .background(AppTheme.surface)
            
            // Results List
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(providers.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }) { provider in
                            NavigationLink(destination: ProviderDetailView(
                                name: provider.name,
                                type: provider.type,
                                rating: provider.rating,
                                price: Int(provider.price?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "/mo", with: "").replacingOccurrences(of: "/hr", with: "") ?? "0") ?? 0,
                                experience: "Verified Provider",
                                certifications: ["Background Checked"],
                                amenities: ["Safe", "Nurturing"],
                                description: provider.bio ?? "No description available.",
                                providerId: provider.id
                            )) {
                                ProviderSearchCard(
                                    name: provider.name,
                                    distance: provider.address?.contains("Chennai") == true ? "Local" : "Verified",
                                    rating: String(format: "%.1f", provider.rating),
                                    price: provider.price ?? "N/A",
                                    imageName: provider.type == "Preschool" ? "book" : "building.2"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .onAppear {
                fetchProviders()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func fetchProviders() {
        isLoading = true
        Task {
            do {
                let fetched = try await DiscoveryService.shared.fetchProviders()
                DispatchQueue.main.async {
                    self.providers = fetched
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.clear)
                .foregroundColor(isSelected ? themeManager.primaryColor : .gray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? themeManager.primaryColor.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

struct ProviderSearchCard: View {
    let name: String
    let distance: String
    let rating: String
    let price: String
    let imageName: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: imageName)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(distance)
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Spacer()
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(rating)
                            .fontWeight(.bold)
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    Text(price)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryColor)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
