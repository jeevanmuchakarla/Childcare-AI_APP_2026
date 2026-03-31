import SwiftUI

public struct PaymentsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    // Mock user transactions
    let transactions: [(provider: String, type: String, amount: Double, date: String)] = [
        ("Bright Futures Preschool", "Preschool", 1200.0, "Mar 1, 2026"),
        ("Happy Days Daycare", "Daycare", 850.0, "Feb 15, 2026"),

        ("Green Valley Basecamp", "Preschool", 1200.0, "Feb 1, 2026"),
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Payments")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Subscription Banner
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                            Text("ChildCare AI Premium")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("ACTIVE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        
                        Text("Yearly Subscription")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack {
                            Text("$1499.00")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("/ year")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 4)
                        
                        Text("Next billing date: Jan 15, 2027")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [themeManager.primaryColor, Color(hex: "#20C997")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 20)
                    
                    // Transactions Header
                    Text("Payment History")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 10)
                    
                    // Transactions List
                    VStack(spacing: 16) {
                        ForEach(transactions.indices, id: \.self) { index in
                            let transaction = transactions[index]
                            
                            HStack(spacing: 16) {
                                // Icon based on type
                                ZStack {
                                    Circle()
                                        .fill(
                                            transaction.type == "Preschool" ? Color.purple.opacity(0.1) :
                                            transaction.type == "Daycare" ? Color.blue.opacity(0.1) : Color.green.opacity(0.1)
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: 
                                        transaction.type == "Preschool" ? "book.fill" :
                                        transaction.type == "Daycare" ? "building.2.fill" : "person.2.fill"
                                    )
                                    .font(.title3)
                                    .foregroundColor(
                                        transaction.type == "Preschool" ? .purple :
                                        transaction.type == "Daycare" ? .blue : .green
                                    )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.provider)
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(transaction.type)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(String(format: "-$%.2f", transaction.amount))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(transaction.date)
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 40)
                    
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
