import SwiftUI

public struct ParentHomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var showingAvatarMenu = false
    @State private var showingAIRecommendation = false
    
    // Navigation triggers
    @State private var navigateToReports = false
    @State private var navigateToProfile = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                // Background Blobs Top Half
                GeometryReader { proxy in
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.15))
                            .frame(width: 250)
                            .blur(radius: 40)
                            .offset(x: proxy.size.width - 100, y: -50)
                        
                        Circle()
                            .fill(Color(hex: "#FFD166").opacity(0.12))
                            .frame(width: 200)
                            .blur(radius: 40)
                            .offset(x: -50, y: 150)
                        
                        Circle()
                            .fill(AppTheme.secondary.opacity(0.1))
                            .frame(width: 300)
                            .blur(radius: 60)
                            .offset(x: 100, y: 250)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hidden Navigation Links for strict fixed-screen guarantee
                        NavigationLink(destination: Text("Profile Settings").navigationTitle("Profile"), isActive: $navigateToProfile) { EmptyView() }
                        NavigationLink(destination: Text("Daily Reports").navigationTitle("Reports"), isActive: $navigateToReports) { EmptyView() }
                        
                        // Welcome Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good morning,")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Sarah Johnson")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            
                            Menu {
                                Button(action: { navigateToProfile = true }) {
                                    Label("View Profile", systemImage: "person.crop.circle")
                                }
                                Button(role: .destructive, action: { appRouter.logout() }) {
                                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            } label: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(AppTheme.primary)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 20)
                        
                        // AI Recommendation CTA (Glassmorphism / Glow style)
                        Button(action: {
                            showingAIRecommendation = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.primary)
                                        .padding(.bottom, 4)
                                    
                                    Text("Start Matching")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("Find perfect childcare today")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.primary)
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(24)
                            .shadow(color: AppTheme.primary.opacity(0.15), radius: 15, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 10)
                        .fullScreenCover(isPresented: $showingAIRecommendation) {
                            AIRecommendationFlow()
                        }
                        
                        // Quick Actions (Horizontal Row)
                        HStack(spacing: 0) {
                            QuickActionItem(title: "Search", icon: "magnifyingglass", color: AppTheme.primary) { showingAIRecommendation = true }
                            QuickActionItem(title: "Reports", icon: "chart.bar.doc.horizontal", color: AppTheme.secondary) { navigateToReports = true }
                            QuickActionItem(title: "Children", icon: "face.smiling", color: AppTheme.roleAdmin) { }
                            QuickActionItem(title: "Emergency", icon: "exclamationmark.triangle", color: Color.red) { }
                        }
                        .padding(.horizontal, 10)
                        
                        // Emergency Alert Banner
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Emergency Alerts")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Check active medical alerts")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, AppTheme.padding)
                        
                        // Nearby Preschools
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Nearby Preschools")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Button("See All") {}
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.primary)
                            }
                            .padding(.horizontal, AppTheme.padding)
                            
                            // Horizontal scrolling cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    NearbyPreschoolCard(
                                        name: "Little Stars Academy",
                                        rating: 4.9,
                                        distance: "0.8 mi",
                                        price: "$1,200/mo"
                                    )
                                    
                                    NearbyPreschoolCard(
                                        name: "Green Valley Basecamp",
                                        rating: 4.8,
                                        distance: "1.2 mi",
                                        price: "$950/mo"
                                    )
                                }
                                .padding(.horizontal, AppTheme.padding)
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct QuickActionItem: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct NearbyPreschoolCard: View {
    let name: String
    let rating: Double
    let distance: String
    let price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Placeholder
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                
                Image(systemName: "heart")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.black.opacity(0.3)))
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                
                HStack(spacing: 12) {
                    Label(distance, systemImage: "location")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Label(price, systemImage: "dollarsign.circle")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(12)
        }
        .frame(width: 240)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
