import SwiftUI

public struct AdminPaymentsView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Revenue Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Total Platform Revenue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("$124,500.00")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This Month")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                HStack {
                                    Text("+$12.4k")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pending")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("$3.2k")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.primaryGradient)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    HStack {
                        Text("Recent Transactions")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(themeManager.primaryColor)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TransactionRow(title: "Payout to Provider", id: "#TRX-8393", amount: "- $180.00", isIncome: false)
                        TransactionRow(title: "Commission Received", id: "#TRX-8394", amount: "+ $45.00", isIncome: true)
                        TransactionRow(title: "Payout to Provider", id: "#TRX-8395", amount: "- $180.00", isIncome: false)
                        TransactionRow(title: "Commission Received", id: "#TRX-8396", amount: "+ $45.00", isIncome: true)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(AppTheme.background.opacity(0.3))
    }
}

struct TransactionRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let id: String
    let amount: String
    let isIncome: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isIncome ? Color.green.opacity(0.1) : themeManager.primaryColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: isIncome ? "arrow.down.left" : "arrow.up.right")
                    .foregroundColor(isIncome ? .green : themeManager.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                HStack(spacing: 4) {
                    Text("Oct 24, 2023")
                    Text("•")
                    Text(id)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isIncome ? .green : AppTheme.textPrimary)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}
