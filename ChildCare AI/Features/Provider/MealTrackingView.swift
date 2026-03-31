import SwiftUI

public struct MealTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var children: [ProviderChild] = []
    @State private var selectedChildIds: Set<Int> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var breakfastItem = ""
    @State private var breakfastAmount = "All"
    @State private var lunchItem = ""
    @State private var lunchAmount = "Some"
    @State private var snackItem = ""
    @State private var snackAmount = "All"
    @State private var dinnerItem = ""
    @State private var dinnerAmount = "All"
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init(preselectedChildId: Int? = nil) {
        if let id = preselectedChildId {
            _selectedChildIds = State(initialValue: [id])
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // New Header
            HStack {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                        )
                }
                Spacer()
                Text("Meal Tracking")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 36)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Child Selector (Menu replacement)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Child")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(children) { child in
                                Button(child.name) {
                                    selectedChildIds = [child.id]
                                }
                            }
                        } label: {
                            HStack {
                                Text(children.first(where: { selectedChildIds.contains($0.id) })?.name ?? "Select Child")
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
                    .padding(.horizontal)
                    
                    // Meal Sections
                    MealDetailSection(
                        title: "Breakfast",
                        icon: "fork.knife",
                        color: Color(hex: "#FF7D29"),
                        foodItem: $breakfastItem,
                        amountEaten: $breakfastAmount
                    )
                    
                    MealDetailSection(
                        title: "Lunch",
                        icon: "fork.knife",
                        color: Color(hex: "#FF7D29"),
                        foodItem: $lunchItem,
                        amountEaten: $lunchAmount
                    )
                    
                    MealDetailSection(
                        title: "Snack",
                        icon: "applelogo",
                        color: Color(hex: "#FF4757"),
                        foodItem: $snackItem,
                        amountEaten: $snackAmount
                    )
                    
                    MealDetailSection(
                        title: "Dinner",
                        icon: "fork.knife",
                        color: Color(hex: "#4D4D4D"),
                        foodItem: $dinnerItem,
                        amountEaten: $dinnerAmount
                    )
                    
                    // Save Button
                    Button(action: { saveMealRecord() }) {
                        Text(isLoading ? "Saving..." : "Save Meal Record")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#FF5E62"), Color(hex: "#FF9966")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "#FF5E62").opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(isLoading || selectedChildIds.isEmpty)
                    .padding(.top, 16)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.vertical, 12)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { Task { await loadChildren() } }
    }
    
    private func loadChildren() async {
        guard providerId != -1 else { return }
        isLoading = true
        do {
            let url = URL(string: "\(AuthService.shared.baseURL)/bookings/provider/\(providerId)/children")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ProviderChild].self, from: data)
            await MainActor.run {
                children = decoded
                // Auto-select if there's only one child
                if children.count == 1 {
                    selectedChildIds = [children[0].id]
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load children."
                isLoading = false
            }
        }
    }
    
    private func saveMealRecord() {
        guard !selectedChildIds.isEmpty else { return }
        isLoading = true
        
        Task {
            for childId in selectedChildIds {
                do {
                    // Save Breakfast
                    if !breakfastItem.isEmpty {
                        _ = try await MealService.shared.createMealRecord(
                            childId: childId,
                            providerId: providerId,
                            mealType: "Breakfast",
                            foodItem: breakfastItem,
                            amountEaten: breakfastAmount
                        )
                    }
                    
                    // Save Lunch
                    if !lunchItem.isEmpty {
                        _ = try await MealService.shared.createMealRecord(
                            childId: childId,
                            providerId: providerId,
                            mealType: "Lunch",
                            foodItem: lunchItem,
                            amountEaten: lunchAmount
                        )
                    }
                    
                    // Save Snack
                    if !snackItem.isEmpty {
                        _ = try await MealService.shared.createMealRecord(
                            childId: childId,
                            providerId: providerId,
                            mealType: "Snack",
                            foodItem: snackItem,
                            amountEaten: snackAmount
                        )
                    }
                    
                    // Save Dinner
                    if !dinnerItem.isEmpty {
                        _ = try await MealService.shared.createMealRecord(
                            childId: childId,
                            providerId: providerId,
                            mealType: "Dinner",
                            foodItem: dinnerItem,
                            amountEaten: dinnerAmount
                        )
                    }
                } catch {
                }
            }
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

struct MealDetailSection: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var foodItem: String
    @Binding var amountEaten: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#FFF4EF")) // Peach/Light Orange background
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "#FF7D29"))
                        .font(.title3)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Food Item")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                TextField("What was for \(title.lowercased())?", text: $foodItem)
                    .padding()
                    .background(Color(hex: "#F8F9FB"))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount Eaten")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                HStack(spacing: 8) {
                    AmountButton(title: "None", isSelected: amountEaten == "None") { amountEaten = "None" }
                    AmountButton(title: "Some", isSelected: amountEaten == "Some") { amountEaten = "Some" }
                    AmountButton(title: "Most", isSelected: amountEaten == "Most") { amountEaten = "Most" }
                    AmountButton(title: "All", isSelected: amountEaten == "All") { amountEaten = "All" }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal)
    }
}

struct AmountButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05), lineWidth: 1))
        }
    }
}
