import SwiftUI

public struct MoodTrackerRedesign: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMood = "Happy"
    @State private var notes = ""
    
    let moods = [
        ("Happy", "😊", Color(hex: "#FFF9C4")),
        ("Sad", "😢", Color(hex: "#E3F2FD")),
        ("Tired", "😴", Color(hex: "#F3E5F5")),
        ("Energetic", "⚡️", Color(hex: "#FFF3E0")),
        ("Calm", "😌", Color(hex: "#E8F5E9"))
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Mood Tracker")
            
            ScrollView {
                VStack(spacing: 32) {
                    // Mood Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(moods, id: \.0) { mood in
                            MoodGridItem(
                                title: mood.0,
                                emoji: mood.1,
                                bgColor: mood.2,
                                isSelected: selectedMood == mood.0
                            ) {
                                selectedMood = mood.0
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Add Note Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add Note")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        TextEditor(text: $notes)
                            .frame(height: 150)
                            .padding(12)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.divider, lineWidth: 1))
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("Describe the child's mood...")
                                            .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    // Log Mood Button
                    Button(action: { dismiss() }) {
                        Text("Log Mood")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.top, 16)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct MoodGridItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let emoji: String
    let bgColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(bgColor.opacity(0.3).background(AppTheme.cardBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeManager.primaryColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.01), radius: 5)
        }
    }
}
