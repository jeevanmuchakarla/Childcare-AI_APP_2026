import SwiftUI

struct ParentingInsightDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("Insight Details")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "heart")
                    .font(.title3)
                    .foregroundColor(themeManager.primaryColor)
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.vertical, 16)
            .background(AppTheme.surface)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(color.opacity(0.1))
                            .frame(height: 200)
                        
                        Image(systemName: icon)
                            .font(.system(size: 80))
                            .foregroundColor(color)
                            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack {
                            Label("5 min read", systemImage: "clock")
                            Spacer()
                            Label("Expert Verified", systemImage: "checkmark.seal.fill")
                        }
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Divider()
                    
                    Text(content)
                        .font(.body)
                        .lineSpacing(8)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    // Call to Action
                    VStack(spacing: 16) {
                        Text("Was this helpful?")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            Button(action: {}) {
                                Label("Yes", systemImage: "hand.thumbsup.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(themeManager.primaryColor.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                Label("No", systemImage: "hand.thumbsdown.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                }
                .padding(AppTheme.padding)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
