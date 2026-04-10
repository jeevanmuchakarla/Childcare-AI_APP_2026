import SwiftUI

public struct AdminAnalyticsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Revenue Analytics Card
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Revenue (YTD)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("$124,500.00")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This Month")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("$12.4k")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Growth")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("+18%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Revenue Breakdown")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            RevenueProgressRow(label: "Commission Fees", percentage: 0.65, color: themeManager.primaryColor)
                            RevenueProgressRow(label: "Subscription Plans", percentage: 0.25, color: Color(hex: "#7D61FF"))
                            RevenueProgressRow(label: "Featured Listings", percentage: 0.10, color: Color(hex: "#FF7D29"))
                        }
                    }
                    .padding(24)
                    .background(LinearGradient(colors: [Color(hex: "#00C853"), Color(hex: "#009624")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Usage Analytics
                    HStack(spacing: 16) {
                        UsageBox(title: "DAU", value: "1,240", change: "+12% vs last week", color: themeManager.primaryColor)
                        UsageBox(title: "MAU", value: "8,500", change: "+5% vs last month", color: Color(hex: "#00BC8C"))
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Feature Usage")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            FeatureUsageRow(title: "Advanced Selection", count: "45k", status: "Active")
                            FeatureUsageRow(title: "Direct Booking", count: "12k", status: "Active")
                            FeatureUsageRow(title: "Chat", count: "85k", status: "Active")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .background { AppTheme.background.opacity(0.3) }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RevenueProgressRow: View {
    let label: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage))
                }
            }
            .frame(height: 4)
        }
    }
}

struct UsageBox: View {
    let title: String
    let value: String
    let change: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(color)
                    .font(.caption)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(change)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.green)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}

struct FeatureUsageRow: View {
    let title: String
    let count: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(status)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(count)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("use")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}
