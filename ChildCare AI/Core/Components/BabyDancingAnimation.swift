import SwiftUI

public struct BabyDancingAnimation: View {
    @State private var bounce = false
    @State private var sway = false
    @State private var handWave = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Head
                Circle()
                    .fill(Color(hex: "#FFD5B4"))
                    .frame(width: 60, height: 60)
                    .offset(y: bounce ? -5 : 5)
                
                // Eyes
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(Color.black)
                        .frame(width: 6, height: 6)
                }
                .offset(y: bounce ? -5 : 5)
                
                // Smile
                Path { path in
                    path.addArc(center: CGPoint(x: 30, y: 35), radius: 10, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                }
                .stroke(Color.red.opacity(0.6), lineWidth: 2)
                .frame(width: 60, height: 60)
                .offset(y: bounce ? -5 : 5)
                
                // Diaper/Body
                Capsule()
                    .fill(Color.white)
                    .frame(width: 70, height: 50)
                    .offset(y: 40)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                
                // Arms
                HStack(spacing: 60) {
                    // Left Arm
                    Capsule()
                        .fill(Color(hex: "#FFD5B4"))
                        .frame(width: 25, height: 10)
                        .rotationEffect(.degrees(handWave ? -30 : 10))
                    
                    // Right Arm
                    Capsule()
                        .fill(Color(hex: "#FFD5B4"))
                        .frame(width: 25, height: 10)
                        .rotationEffect(.degrees(handWave ? 30 : -10))
                }
                .offset(y: 20)
                
                // Happy Sparkles
                ForEach(0..<3) { i in
                    Image(systemName: "sparkle")
                        .foregroundColor(.yellow)
                        .scaleEffect(bounce ? 1.2 : 0.8)
                        .offset(x: CGFloat(i * 40 - 40), y: bounce ? -50 : -40)
                        .opacity(bounce ? 1 : 0)
                }
            }
            .rotationEffect(.degrees(sway ? -8 : 8))
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                bounce.toggle()
            }
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                sway.toggle()
            }
            withAnimation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                handWave.toggle()
            }
        }
    }
}
