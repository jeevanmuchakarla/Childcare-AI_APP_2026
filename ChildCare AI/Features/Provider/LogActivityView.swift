import SwiftUI

public struct LogActivityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var availableChildren: [(id: Int, name: String)] = []
    @State private var selectedChildrenIds: Set<Int> = []
    @State private var isLoading = false
    @State private var selectedActivity: String? = "Outdoor Play"
    @State private var notes = ""
    
    let preselectedChildId: Int?
    
    private let activityTypes: [(String, String, Color)] = [
        ("Outdoor Play", "sun.max.fill", .orange),
        ("Art & Craft", "paintbrush.fill", .pink),
        ("Story Time", "book.fill", .blue),
        ("Music", "music.note", .purple),
        ("Nap Time", "moon.fill", Color(hex: "#7B61FF")),
        ("Learning", "graduationcap.fill", .green)
    ]
    
    public init(preselectedChildId: Int? = nil) {
        self.preselectedChildId = preselectedChildId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Log Activity")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Select Activity Type
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Activity Type")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(activityTypes, id: \.0) { activity in
                                ActivityTypeCard(
                                    title: activity.0,
                                    icon: activity.1,
                                    color: activity.2,
                                    isSelected: selectedActivity == activity.0
                                ) {
                                    selectedActivity = activity.0
                                }
                            }
                        }
                    }
                    
                    // Select Children
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Children")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if isLoading {
                            ProgressView().padding()
                        } else if availableChildren.isEmpty {
                            Text("No active bookings found.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(spacing: 0) {
                                ForEach(availableChildren, id: \.id) { child in
                                    ChildSelectionRow(
                                        name: child.name,
                                        isSelected: selectedChildrenIds.contains(child.id)
                                    ) {
                                        if selectedChildrenIds.contains(child.id) {
                                            selectedChildrenIds.remove(child.id)
                                        } else {
                                            selectedChildrenIds.insert(child.id)
                                        }
                                    }
                                    if child.id != availableChildren.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Details")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Add notes about the activity...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(hex: "#F1F4F9"))
                                .cornerRadius(12)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera")
                                Text("Add Photo")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(themeManager.primaryColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            logActivity()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text(isLoading ? "Logging..." : "Log Activity")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryGradient)
                            .cornerRadius(16)
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .onAppear {
            loadChildren()
        }
    }
    
    private func loadChildren() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                let bookings = try await BookingService.shared.fetchProviderBookings(providerId: providerId)
                var childMap: [Int: String] = [:]
                for booking in bookings {
                    if let cid = booking.child_id, let cname = booking.child_name {
                        childMap[cid] = cname
                    }
                }
                let sorted = childMap.map { (id: $0.key, name: $0.value) }.sorted { $0.name < $1.name }
                await MainActor.run {
                    self.availableChildren = sorted
                    self.isLoading = false
                    if let pre = self.preselectedChildId {
                        self.selectedChildrenIds = [pre]
                    }
                }
            } catch {
                DispatchQueue.main.async { 
                    self.availableChildren = [(1, "Leo Johnson"), (2, "Emma Davis")]
                    self.isLoading = false 
                }
            }
        }
    }
    
    private func logActivity() {
        guard let providerId = AuthService.shared.currentUser?.id, let activity = selectedActivity, !selectedChildrenIds.isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                for childId in selectedChildrenIds {
                    _ = try await ActivityService.shared.createActivityRecord(
                        childId: childId,
                        providerId: providerId,
                        type: activity,
                        notes: notes
                    )
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
}

struct ActivityTypeCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeManager.primaryColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.01), radius: 5)
        }
    }
}

struct ChildSelectionRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F1F4F9"))
                        .frame(width: 40, height: 40)
                    Text(String(name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? themeManager.primaryColor : .gray.opacity(0.3))
            }
            .padding()
        }
    }
}
