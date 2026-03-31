import SwiftUI

public struct GamesAndPlayView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var location = "Indoor"
    @State private var selectedActivity = "Blocks"
    @State private var activityDetails = ""
    @State private var showAlert = false
    
    let activityTags = ["Puzzle", "Blocks", "Tag", "Drawing", "Music", "Reading"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Games & Play")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Log New Activity
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Log New Activity")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        // Location Picker
                        HStack(spacing: 0) {
                            Button(action: { location = "Indoor" }) {
                                Text("Indoor")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(location == "Indoor" ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(location == "Indoor" ? themeManager.primaryColor : Color.white)
                                    .cornerRadius(10)
                            }
                            Button(action: { location = "Outdoor" }) {
                                Text("Outdoor")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(location == "Outdoor" ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(location == "Outdoor" ? themeManager.primaryColor : Color.white)
                                    .cornerRadius(10)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ActivityTagView(title: "Puzzle", isSelected: selectedActivity == "Puzzle") { selectedActivity = "Puzzle" }
                                ActivityTagView(title: "Blocks", isSelected: selectedActivity == "Blocks") { selectedActivity = "Blocks" }
                                ActivityTagView(title: "Tag", isSelected: selectedActivity == "Tag") { selectedActivity = "Tag" }
                            }
                            HStack(spacing: 12) {
                                ActivityTagView(title: "Drawing", isSelected: selectedActivity == "Drawing") { selectedActivity = "Drawing" }
                                ActivityTagView(title: "Music", isSelected: selectedActivity == "Music") { selectedActivity = "Music" }
                                ActivityTagView(title: "Reading", isSelected: selectedActivity == "Reading") { selectedActivity = "Reading" }
                            }
                        }
                        
                        // Details
                        TextField("Activity details...", text: $activityDetails)
                            .padding()
                            .frame(height: 100, alignment: .topLeading)
                            .background(Color(hex: "#F1F4F9").opacity(0.3))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        
                        // Add Button
                        Button(action: {
                            if !activityDetails.isEmpty || !selectedActivity.isEmpty {
                                showAlert = true
                                activityDetails = ""
                            }
                        }) {
                            Text("Add Activity")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(themeManager.primaryGradient)
                                .cornerRadius(16)
                                .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Today's Activities
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Activities")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            ActivityItem(title: "Building Blocks", time: "09:30 AM", type: "Indoor", icon: "gamecontroller.fill", iconColor: .green)
                            ActivityItem(title: "Hide and Seek", time: "11:00 AM", type: "Outdoor", icon: "gamecontroller.fill", iconColor: .green)
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
        .alert("Activity Added", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The activity has been successfully logged for today.")
        }
    }
}

struct ActivityItem: View {
    let title: String
    let time: String
    let type: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                HStack(spacing: 8) {
                    Text(time)
                    Text("•")
                    Text(type)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.01), radius: 5)
    }
}

struct ActivityTagView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSelected ? themeManager.primaryColor : Color.white)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : Color(hex: "#F1F4F9"), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}
