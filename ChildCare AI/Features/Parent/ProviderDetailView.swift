import SwiftUI

public struct ProviderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let name: String
    let type: String
    let rating: Double
    let price: Int
    let experience: String
    let certifications: [String]
    let amenities: [String]
    let description: String
    let providerId: Int?
    
    public init(name: String, 
                type: String, 
                rating: Double, 
                price: Int, 
                experience: String, 
                certifications: [String], 
                amenities: [String],
                description: String,
                providerId: Int? = nil) {
        self.name = name
        self.type = type
        self.rating = rating
        self.price = price
        self.experience = experience
        self.certifications = certifications
        self.amenities = amenities
        self.description = description
        self.providerId = providerId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Provider Details")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Header
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                        
                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .clear]), startPoint: .bottom, endPoint: .top)
                            .frame(height: 100)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text(String(format: "%.1f", rating))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Text("•")
                                    .foregroundColor(.white.opacity(0.6))
                                Text(type)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(20)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Key Info Row
                        HStack(spacing: 40) {
                            InfoItem(title: "Experience", value: experience, icon: "briefcase.fill")
                            InfoItem(title: "Price", value: "$\(price)/mo", icon: "dollarsign.circle.fill")
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(description)
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        
                        // Certifications
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Certifications")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            FlowLayout(items: certifications) { cert in
                                DetailBadge(text: cert, color: themeManager.primaryColor)
                            }
                        }
                        
                        // Amenities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amenities")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            FlowLayout(items: amenities) { amenity in
                                DetailBadge(text: amenity, color: Color.green)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    Spacer().frame(height: 100)
                }
            }
            .background(AppTheme.background)
            
            // Fixed Bottom Buttons
            VStack {
                HStack(spacing: 12) {
                    // Message Button
                    if let pId = providerId {
                        NavigationLink(destination: ChatView(role: .parent, initialCategory: type, autoOpenUserId: pId, autoOpenUserName: name)) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.primaryColor)
                                    .frame(width: 54, height: 54)
                                Image(systemName: "message.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                    }
                    
                    NavigationLink(destination: BookingFormView(providerName: name, providerType: type, isVisit: true, providerId: providerId)) {
                        Text("Book Visit")
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(themeManager.primaryColor.opacity(0.1))
                            .cornerRadius(16)
                    }
                    
                    NavigationLink(destination: BookingFormView(providerName: name, providerType: type, isVisit: false, providerId: providerId)) {
                        Text("Book \(type)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.top, 16)
                .padding(.bottom, 34) // For safe area
                .background(AppTheme.surface.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5))
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct InfoItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(themeManager.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
    }
}

struct DetailBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

// Simple FlowLayout helper
struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading) { d in
                            if (abs(width - d.width) > geo.size.width) {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item == items.last {
                                width = 0
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { d in
                            let result = height
                            if item == items.last {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(minHeight: 100) // Rough height estimate
    }
}
