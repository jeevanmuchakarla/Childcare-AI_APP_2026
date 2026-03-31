import SwiftUI

public struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.darkNavyGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Baby Dancing Animation
                BabyDancingAnimation()
                    .frame(width: 240, height: 240)
                    .padding(.bottom, 20)
                
                Text("ChildCare AI™")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary) // Adaptive primary text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.surface) // Adaptive surface background
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                
                Text("AI-Powered Childcare Discovery")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
                
                // Bottom loading indicator
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Initializing AI Core...")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .padding(.bottom, 40)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                self.scale = 1.0
                self.opacity = 1.0
            }
            
            // Navigate after splash animation completes with a professional delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Aligned with requirements: always go to onboarding -> logins
                appRouter.navigate(to: .onboarding)
            }
        }
    }
}
