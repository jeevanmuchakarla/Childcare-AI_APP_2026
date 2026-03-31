import SwiftUI

public struct PayoutSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var cardNumber = "**** **** **** 4242"
    @State private var expiryDate = "12/26"
    @State private var cardHolder = "Sarah Johnson"
    @State private var showingAddCard = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Payout Settings")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Balance Section
                    VStack(spacing: 8) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("$1,240.50")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Button(action: {}) {
                            Text("Withdraw Funds")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background {
                                    if themeManager.isMulticolor {
                                        LinearGradient(colors: [Color(hex: "#FF4757"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                                    } else {
                                        themeManager.primaryColor
                                    }
                                }
                                .cornerRadius(25)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.top, 24)
                    
                    // Payment Methods
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Payment Methods")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Button(action: { showingAddCard = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(themeManager.primaryColor)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            PaymentMethodRow(icon: "creditcard.fill", title: "Visa Primary", subtitle: cardNumber, color: .blue)
                            PaymentMethodRow(icon: "building.2.fill", title: "Chase Bank", subtitle: "**** 8829", color: .green)
                        }
                    }
                    
                    // Transaction History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Payouts")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            PayoutHistoryRow(title: "Payout to Visa", date: "Oct 24, 2024", amount: "$450.00", status: "Completed")
                            Divider().padding(.leading, 56)
                            PayoutHistoryRow(title: "Payout to Chase", date: "Oct 18, 2024", amount: "$320.00", status: "Completed")
                            Divider().padding(.leading, 56)
                            PayoutHistoryRow(title: "Payout to Visa", date: "Oct 10, 2024", amount: "$470.50", status: "Completed", isLast: true)
                        }
                        .background(AppTheme.surface)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddCard) {
            AddPaymentMethodView()
        }
    }
}

struct PaymentMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary.opacity(0.4))
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.divider, lineWidth: 1))
        .padding(.horizontal)
    }
}

struct PayoutHistoryRow: View {
    let title: String
    let date: String
    let amount: String
    let status: String
    var isLast: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.green)
                    .font(.system(size: 14, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(date)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(status)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 20) {
                    PremiumInputField(label: "Card Number", text: $cardNumber, icon: "creditcard.fill")
                    Divider().padding(.leading, 52)
                    HStack(spacing: 0) {
                        PremiumInputField(label: "Expiry Date", text: $expiry, icon: "calendar")
                        Divider().frame(height: 30)
                        PremiumInputField(label: "CVC", text: $cvc, icon: "lock.fill")
                    }
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                .padding()
                
                Button(action: { dismiss() }) {
                    Text("Add Card")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            if themeManager.isMulticolor {
                                LinearGradient(colors: [Color(hex: "#FF4757"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                            } else {
                                themeManager.primaryColor
                            }
                        }
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
