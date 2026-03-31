import SwiftUI

public struct BabySymbol: View {
    @EnvironmentObject var themeManager: ThemeManager
    var size: CGFloat = 40
    var overrideColor: Color? = nil
    
    public init(size: CGFloat = 40, color: Color? = nil) {
        self.size = size
        self.overrideColor = color
    }
    
    private var symbolColor: Color {
        overrideColor ?? themeManager.primaryColor
    }
    
    public var body: some View {
        ZStack {
            // Face
            Circle()
                .fill(Color(hex: "#FFD5B4"))
                .frame(width: size, height: size)
            
            // Eyes
            HStack(spacing: size * 0.2) {
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.1, height: size * 0.1)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.1, height: size * 0.1)
            }
            .offset(y: -size * 0.05)
            
            // Smile
            Path { path in
                path.addArc(center: CGPoint(x: size * 0.5, y: size * 0.58), 
                            radius: size * 0.16, 
                            startAngle: .degrees(0), 
                            endAngle: .degrees(180), 
                            clockwise: false)
            }
            .stroke(symbolColor.opacity(0.6), lineWidth: size * 0.03)
            .frame(width: size, height: size)
        }
    }
}
