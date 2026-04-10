import SwiftUI

public struct AdminSystemEfficiencyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.primaryColor)
                }
                Text("System Efficiency")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(AppTheme.surface)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Match Accuracy Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "bolt.shield")
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Match Accuracy")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Based on user acceptance")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .bottom, spacing: 12) {
                            Text("94%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("2.4%")
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(24)
                    .background(LinearGradient(colors: [Color(hex: "#6B60F1"), Color(hex: "#A061CF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(24)
                    .shadow(color: Color(hex: "#6B60F1").opacity(0.3), radius: 15, y: 10)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        PerformanceQuickStat(title: "Avg Response", value: "1.2s")
                        PerformanceQuickStat(title: "Queries/Day", value: "15.4k")
                    }
                    .padding(.horizontal)
                    
                    // Logic Optimization Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(themeManager.primaryColor)
                                .font(.title3)
                            Text("Logic Optimization")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Text("Update the matching engine using newly verified provider data and parent preference patterns to improve match accuracy.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Button(action: {
                            // Mock training action
                        }) {
                            HStack {
                                Text("Optimize Matching Engine")
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(themeManager.primaryColor)
                            .cornerRadius(12)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Optimized")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("Today, 10:45 AM")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Dataset Size")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("1,248 Verified Points")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                    .padding(.horizontal)

                    // Top Matching Factors
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Top Matching Factors")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 20) {
                            FactorProgressRow(title: "Location / Distance", percentage: 0.85)
                            FactorProgressRow(title: "Budget Constraints", percentage: 0.72)
                            FactorProgressRow(title: "Curriculum Type", percentage: 0.64)
                            FactorProgressRow(title: "Safety Ratings", percentage: 0.58)
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.opacity(0.1).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct PerformanceQuickStat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}

struct FactorProgressRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(Int(percentage * 100)) %")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#F1F4F9"))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.primaryColor)
                        .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Compact Dashboard Preview
extension AdminSystemEfficiencyView {
    public struct CompactInsightCard: View {
        @EnvironmentObject var themeManager: ThemeManager
        
        public init() {}
        
        public var body: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#6B60F1").opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "bolt.shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#6B60F1"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Match Accuracy")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("94%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#A061CF").opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#A061CF"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Efficiency")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("+12%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
            }
        }
    }
}
