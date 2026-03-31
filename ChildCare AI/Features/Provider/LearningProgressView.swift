import SwiftUI

public struct LearningProgressView: View {
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Learning Progress")
            
            ScrollView {
                VStack(spacing: 24) {
                    LearningCategorySection(title: "Letters & Phonics", icon: "book.fill", color: .blue, entries: [
                        "Recognized letter 'A'",
                        "Counted to 10" // Example from Figma image matches content
                    ])
                    
                    LearningCategorySection(title: "Numbers & Counting", icon: "clock.fill", color: .green, entries: [
                        "Recognized letter 'A'",
                        "Counted to 10"
                    ])
                    
                    LearningCategorySection(title: "Colors & Shapes", icon: "face.smiling.fill", color: .purple, entries: [
                        "Recognized letter 'A'",
                        "Counted to 10"
                    ])
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct LearningCategorySection: View {
    let title: String
    let icon: String
    let color: Color
    let entries: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.body)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Button(action: {}) {
                    Text("Add Entry")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.divider))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(entries, id: \.self) { entry in
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(color)
                            .frame(width: 3, height: 32)
                            .cornerRadius(2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Today, 10:30 AM")
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardSecondary)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.01), radius: 5)
    }
}
