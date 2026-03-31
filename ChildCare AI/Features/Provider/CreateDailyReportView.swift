import SwiftUI

public struct CreateDailyReportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedChild = "Select Child"
    @State private var selectedChildId: Int? = nil
    @State private var selectedChildModel: ChildModel? = nil
    @State private var childrenModels: [ChildModel] = []
    
    @State private var selectedMood = "Happy"
    @State private var breakfast = "All"
    @State private var lunch = "Some"
    @State private var snack = "All"
    @State private var checkInTime = "08:30 AM"
    @State private var duration = "9 Hours"
    @State private var isSending = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("Create Report")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                if isSending {
                    ProgressView().padding(.trailing)
                } else {
                    Color.clear.frame(width: 30)
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Child Selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Child")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(childrenModels) { child in
                                Button(child.name) {
                                    selectedChild = child.name
                                    selectedChildId = child.id
                                    selectedChildModel = child
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedChild)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                    }
                    
                    // Check-In & Duration Section
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Check-In Time")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            TextField("08:30 AM", text: $checkInTime)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            TextField("9 Hours", text: $duration)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                    }
                    
                    // Mood Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("😊")
                                .font(.title3)
                            Text("Mood")
                                .font(.body)
                                .fontWeight(.bold)
                        }
                        
                        HStack(spacing: 8) {
                            MoodButton(title: "Happy", emoji: "😊", bgColor: Color(hex: "#FFF9C4"), isSelected: selectedMood == "Happy") { selectedMood = "Happy" }
                            MoodButton(title: "Sad", emoji: "😢", bgColor: Color(hex: "#E3F2FD"), isSelected: selectedMood == "Sad") { selectedMood = "Sad" }
                            MoodButton(title: "Tired", emoji: "😴", bgColor: Color(hex: "#F3E5F5"), isSelected: selectedMood == "Tired") { selectedMood = "Tired" }
                            MoodButton(title: "Energetic", emoji: "⚡️", bgColor: Color(hex: "#FFF3E0"), isSelected: selectedMood == "Energetic") { selectedMood = "Energetic" }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    
                    // Meals Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                            Text("Meals")
                                .font(.body)
                                .fontWeight(.bold)
                        }
                        
                        VStack(spacing: 12) {
                            CreateReportMealRow(label: "Breakfast", selection: $breakfast)
                            CreateReportMealRow(label: "Lunch", selection: $lunch)
                            CreateReportMealRow(label: "Snack", selection: $snack)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    
                    // Send Button
                    Button(action: { sendReport() }) {
                        HStack(spacing: 12) {
                            if isSending {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                            }
                            Text(isSending ? "Sending..." : "Send Report")
                                .font(.body)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.primaryGradient)
                        .cornerRadius(16)
                        .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(isSending || selectedChildId == nil)
                    .padding(.bottom, 40)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .onAppear {
            fetchChildren()
        }
    }
    
    private func fetchChildren() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        Task {
            do {
                let fetched = try await BookingService.shared.fetchProviderChildren(providerId: providerId)
                await MainActor.run {
                    self.childrenModels = fetched
                    if let first = fetched.first {
                        self.selectedChild = first.name
                        self.selectedChildId = first.id
                        self.selectedChildModel = first
                    }
                }
            } catch {
                print("Error fetching children: \(error)")
            }
        }
    }
    
    private func sendReport() {
        guard let childId = selectedChildId, let providerId = AuthService.shared.currentUser?.id else { return }
        isSending = true
        
        Task {
            do {
                // 1. Clear previous data
                try await ActivityService.shared.clearChildRecords(childId: childId)
                
                // 2. Save Attendance & Duration
                _ = try await ActivityService.shared.createActivityRecord(
                    childId: childId,
                    providerId: providerId,
                    type: "Attendance",
                    notes: "Check-In: \(checkInTime)"
                )
                
                _ = try await ActivityService.shared.createActivityRecord(
                    childId: childId,
                    providerId: providerId,
                    type: "Duration",
                    notes: "Stay Duration: \(duration)"
                )
                
                // 3. Save Mood
                _ = try await ActivityService.shared.createActivityRecord(
                    childId: childId,
                    providerId: providerId,
                    type: "Mood",
                    notes: "Today's mood: \(selectedMood)"
                )
                
                // 4. Save Meals
                _ = try await MealService.shared.createMealRecord(
                    childId: childId,
                    providerId: providerId,
                    mealType: "Breakfast",
                    foodItem: "Preschool Meal",
                    amountEaten: breakfast
                )
                _ = try await MealService.shared.createMealRecord(
                    childId: childId,
                    providerId: providerId,
                    mealType: "Lunch",
                    foodItem: "Preschool Meal",
                    amountEaten: lunch
                )
                _ = try await MealService.shared.createMealRecord(
                    childId: childId,
                    providerId: providerId,
                    mealType: "Snack",
                    foodItem: "Preschool Meal",
                    amountEaten: snack
                )
                
                _ = try await ActivityService.shared.createActivityRecord(
                    childId: childId,
                    providerId: providerId,
                    type: "Report",
                    notes: "Finalized daily report with mood: \(selectedMood)"
                )
                
                // 4. Send Notification to Parent
                if let parentId = selectedChildModel?.parent_id {
                    do {
                        let url = URL(string: "\(AuthService.shared.baseURL)/notifications/")!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let body: [String: Any] = [
                            "user_id": parentId,
                            "title": "📑 Daily Report Ready",
                            "message": "\(selectedChild) is \(selectedMood.lowercased()) today! Click to view the full report.",
                            "type": "success",
                            "child_id": childId
                        ]
                        request.httpBody = try JSONSerialization.data(withJSONObject: body)
                        _ = try await URLSession.shared.data(for: request)
                    } catch {
                        print("Could not send report notification: \(error)")
                    }
                }
                
                await MainActor.run {
                    isSending = false
                    dismiss()
                }
            } catch {
                print("Error sending report: \(error)")
                await MainActor.run { isSending = false }
            }
        }
    }
}

struct MoodButton: View {
    let title: String
    let emoji: String
    let bgColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? bgColor : Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.clear : Color(hex: "#F1F4F9"), lineWidth: 1))
        }
    }
}

struct CreateReportMealRow: View {
    let label: String
    @Binding var selection: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
            HStack(spacing: 4) {
                MealToggle(title: "None", isSelected: selection == "None") { selection = "None" }
                MealToggle(title: "Some", isSelected: selection == "Some") { selection = "Some" }
                MealToggle(title: "All", isSelected: selection == "All") { selection = "All" }
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

struct MealToggle: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(6)
        }
    }
}
