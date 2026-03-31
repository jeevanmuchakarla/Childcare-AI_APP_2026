import SwiftUI

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct AppFeaturesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let features = [
        FeatureItem(title: "ChildCare AI", description: "Smart matching with local preschools and daycares based on your child's unique needs.", icon: "sparkles", color: .purple),
        FeatureItem(title: "Real-time Daily Logs", description: "Stay updated with meals, naps, and activities as they happen throughout the day.", icon: "clock.fill", color: .blue),
        FeatureItem(title: "Direct Messaging", description: "Secure, instant communication with providers and our support team.", icon: "message.fill", color: .green),
        FeatureItem(title: "Expert Advice", description: "Personalized parenting insights and developmental milestone tracking.", icon: "lightbulb.fill", color: .orange),
        FeatureItem(title: "Verified Providers", description: "All centers are background-checked and license-verified for your peace of mind.", icon: "checkmark.shield.fill", color: .red)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            // Background Decorative Elements
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(themeManager.primaryColor.opacity(0.1))
                        .frame(width: 300)
                        .offset(x: -100, y: -100)
                        .blur(radius: 50)
                    
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 250)
                        .offset(x: proxy.size.width - 150, y: proxy.size.height - 200)
                        .blur(radius: 50)
                }
            }
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    Spacer()
                    Text("App Features")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    // Dummy for centering
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Next-Gen ChildCare")
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Experience the future of parenting with our AI-powered ecosystem.")
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            ForEach(features) { feature in
                                FeatureCard(feature: feature)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct FeatureCard: View {
    let feature: FeatureItem
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(feature.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(feature.title)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(20)
        .background(AppTheme.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.divider.opacity(0.5), lineWidth: 1)
        )
    }
}
