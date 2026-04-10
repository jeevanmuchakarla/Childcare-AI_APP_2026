import SwiftUI

public struct AIRecommendationDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let recommendation: AIRecommendation
    
    public init(recommendation: AIRecommendation) {
        self.recommendation = recommendation
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image & Gradient
                ZStack(alignment: .topLeading) {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(LinearGradient(colors: [themeManager.primaryColor.opacity(0.8), themeManager.primaryColor], startPoint: .top, endPoint: .bottom))
                            .frame(height: geometry.size.width * 0.75 + geometry.safeAreaInsets.top)
                            .ignoresSafeArea()
                    }
                    .frame(height: (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.screen.bounds.width ?? 393) * 0.75)
                    
                    VStack {
                        HStack {
                            Button(action: { dismiss() }) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.left")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .bold))
                                    )
                            }
                            Spacer()
                            
                            // Match Badge
                            ZStack {
                                Capsule()
                                    .fill(Color.white)
                                Text("\(recommendation.match_score)% Match")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                            }
                            .frame(width: 100, height: 32)
                        }
                        .padding(.horizontal, 20)
                        
                        // Fake Provider Image Icon (since we don't have images in JSON)
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: recommendation.provider_type.lowercased().contains("daycare") ? "building.2.fill" : "book.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: .black.opacity(0.2), radius: 10)
                            .padding(.bottom, 30)
                    }
                }
                
                // Content Body
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Title and Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recommendation.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack {
                            Text(recommendation.provider_type)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.primaryColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(themeManager.primaryColor.opacity(0.1))
                                .cornerRadius(12)
                                
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", recommendation.rating))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("(Verified)")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    
                    // Key Details Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AIDetailItem(icon: "dollarsign.circle.fill", title: "Price", value: "$\(recommendation.monthly_price)/mo", color: .green)
                        AIDetailItem(icon: "location.fill", title: "Distance", value: "\(String(format: "%.1f", recommendation.distance_km)) km", color: .blue)
                        AIDetailItem(icon: "clock.fill", title: "Timing", value: recommendation.timing ?? "Standard", color: .orange)
                        AIDetailItem(icon: "person.2.fill", title: "Age Group", value: recommendation.age_range ?? "1-6 years", color: themeManager.primaryColor)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    
                    // Address Section
                    if let address = recommendation.address, !address.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineSpacing(4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 8)
                        }
                    }
                    
                    // Experience / Why it's a match
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Insights")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            
                        VStack(alignment: .leading, spacing: 12) {
                            Label("High match score based on your search filters.", systemImage: "sparkles")
                            if let exp = recommendation.experience {
                                Label("Established provider with \(exp) experience.", systemImage: "calendar.badge.clock")
                            }
                            Label("Ranked favorably for safety and quality of care.", systemImage: "shield.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(themeManager.primaryColor.opacity(0.05))
                        .cornerRadius(16)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
                .background(AppTheme.background)
                .aiCornerRadius(32, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay(
            // Sticky Action Bar at the absolute bottom
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    Button(action: {
                        if let phone = recommendation.phone, !phone.isEmpty {
                            let cleanedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if let url = URL(string: "tel://\(cleanedPhone)") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call \(recommendation.phone ?? "Provider")")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Button(action: {
                        let query = "\(recommendation.name) \(recommendation.address ?? "")"
                        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            let appleMapsURL = URL(string: "http://maps.apple.com/?q=\(encodedQuery)")!
                            UIApplication.shared.open(appleMapsURL)
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Get Directions")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.primaryColor)
                        .cornerRadius(16)
                        .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 20)
                .background(AppTheme.background.edgesIgnoringSafeArea(.bottom))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
            }
        )
    }
}

struct AIDetailItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
        }
    }
}

// Extension to round specific corners
extension View {
    func aiCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( AIRoundedCorner(radius: radius, corners: corners) )
    }
}

struct AIRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
