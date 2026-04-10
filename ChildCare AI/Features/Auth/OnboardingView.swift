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
        OnboardingPage(title: "Intelligent Matching", description: "Finding the perfect childcare is easier than ever with smart-matched recommendations tailored to your child's needs.", iconName: "baby.symbol", color: .blue),
        OnboardingPage(title: "Comprehensive Care", description: "Whether you're a parent seeking education or a center managing growth, ChildCare AI streamlines every interaction.", iconName: "person.2.fill", color: .green),
        OnboardingPage(title: "Safety & Peace of Mind", description: "Verified providers, real-time updates, and secure communication ensure peace of mind for every family.", iconName: "checkmark.shield.fill", color: .purple)
    ]
    
    @EnvironmentObject var themeManager: ThemeManager
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Skip
            HStack {
                Spacer()
                Button("Skip") {
                    withAnimation(.spring()) {
                        AuthService.shared.hasSeenOnboarding = true
                        appRouter.navigate(to: .roleSelection)
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.primaryColor.opacity(0.8))
                .padding()
            }
            .buttonStyle(BounceButtonStyle())
            
            // Simulated TabView without swipe (Fixed Screens)
            VStack {
                Spacer()
                
                // Safety check: Ensure currentPage doesn't exceed bounds
                let safeIndex = max(0, min(currentPage, pages.count - 1))
                let page = pages[safeIndex]
                
                AnimatedRoleIcon(iconName: page.iconName, color: page.color)
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
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)).combined(with: .scale(scale: 0.95)),
                removal: .opacity.combined(with: .move(edge: .leading)).combined(with: .scale(scale: 1.05))
            ))
            .animation(.easeInOut(duration: 0.4), value: currentPage)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? themeManager.primaryColor : AppTheme.textSecondary.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                }
            }
            .padding(.bottom, 40)
            
            // Fixed Navigation Buttons
            VStack(spacing: 16) {
                if currentPage < pages.count - 1 {
                    DarkNavyButton(title: "Continue") {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            }
                        }
                    }
                } else {
                    DarkNavyButton(title: "Get Started") {
                        withAnimation(.spring()) {
                            AuthService.shared.hasSeenOnboarding = true
                            appRouter.navigate(to: .roleSelection)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 24)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}

struct AnimatedRoleIcon: View {
    let iconName: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(color.opacity(isAnimating ? 0.8 : 1.0))
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .shadow(color: color.opacity(0.4), radius: isAnimating ? 15 : 5, x: 0, y: isAnimating ? 10 : 5)
            
            if iconName == "baby.symbol" {
                BabySymbol(size: 40, color: .white)
                    .scaleEffect(isAnimating ? 1.15 : 1.0)
                    .offset(y: isAnimating ? -5 : 0)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.15 : 1.0)
                    .offset(y: isAnimating ? -5 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
