import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

public struct OnboardingView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Smarter Childcare, Powered by AI", description: "Our AI analyzes your preferences to find the perfect childcare match for your child.", iconName: "sparkles", color: AppTheme.primary),
        OnboardingPage(title: "Discover, Book & Monitor", description: "Find trusted childcare, book instantly, and get real-time updates — all in one app.", iconName: "magnifyingglass", color: AppTheme.secondary),
        OnboardingPage(title: "Safety & Peace of Mind", description: "Daily updates, verified centers, and transparent communication for complete peace of mind.", iconName: "checkmark.shield.fill", color: AppTheme.roleAdmin)
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Skip
            HStack {
                Spacer()
                Button("Skip") {
                    appRouter.navigate(to: .roleSelection)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.primary)
                .padding()
            }
            
            // Simulated TabView without swipe (Fixed Screens)
            VStack {
                Spacer()
                
                let page = pages[currentPage]
                
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(page.color)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: page.iconName)
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 12)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
                
                Spacer()
            }
            .id(currentPage)
            .transition(.opacity)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? AppTheme.accentBlack : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                }
            }
            .padding(.bottom, 40)
            
            // Fixed Navigation Buttons
            VStack(spacing: 16) {
                if currentPage < pages.count - 1 {
                    DarkNavyButton(title: "Continue") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                } else {
                    DarkNavyButton(title: "Get Started") {
                        appRouter.navigate(to: .roleSelection)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
