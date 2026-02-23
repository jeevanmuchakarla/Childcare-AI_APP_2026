import SwiftUI

public struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.darkNavyGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Futuristic Logo representation
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppTheme.primary)
                        .frame(width: 90, height: 90)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white)
                }
                
                Text("ChildCare AI™")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.accentBlack) // Black text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white) // White box background
                
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
            
            // Navigate to onboarding after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                appRouter.navigate(to: .onboarding)
            }
        }
    }
}
