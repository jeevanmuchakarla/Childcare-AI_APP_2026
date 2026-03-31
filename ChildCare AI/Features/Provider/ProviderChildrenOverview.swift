import SwiftUI

// MARK: - Data Model for Provider's Child
struct ProviderChild: Identifiable, Decodable {
    let id: Int
    let name: String
    let age: String
    let allergies: String
    let medical_notes: String
    let parent_name: String
    let parent_id: Int
    let booking_status: String
}

// MARK: - ProviderChildrenOverview
public struct ProviderChildrenOverview: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var children: [ProviderChild] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedChild: ProviderChild?
    @State private var showQuickAction: QuickActionType?
    @State private var showUpdateSuccess = false
    @State private var successChildName = ""
    let role: UserRole
    
    enum QuickActionType: Identifiable {
        case meal(ProviderChild), nap(ProviderChild), play(ProviderChild), note(ProviderChild), game(ProviderChild), photo(ProviderChild), message(ProviderChild), attendance(ProviderChild)
        var id: String {
            switch self {
            case .meal(let c): return "meal_\(c.id)"
            case .nap(let c): return "nap_\(c.id)"
            case .play(let c): return "play_\(c.id)"
            case .note(let c): return "note_\(c.id)"
            case .game(let c): return "game_\(c.id)"
            case .photo(let c): return "photo_\(c.id)"
            case .message(let c): return "message_\(c.id)"
            case .attendance(let c): return "attendance_\(c.id)"
            }
        }
    }
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Classroom Overview Card
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Classroom Overview")
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.caption).foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("\(children.count)")
                            .fontWeight(.bold).foregroundColor(AppTheme.textPrimary)
                        Text("Present")
                            .font(.caption).foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(10)
                }
                .padding(16)
                .background(AppTheme.surface)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.08), lineWidth: 1))
                .padding(.horizontal)
                
                
                // Currently in Care
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Currently in Care")
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button(action: { Task { await loadChildren() } }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(themeManager.primaryColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView("Loading children...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error).font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                            Button("Retry") { Task { await loadChildren() } }
                                .foregroundColor(themeManager.primaryColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if children.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No children enrolled yet")
                                .foregroundColor(.gray)
                            Text("Children appear here when a booking is confirmed.")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        VStack(spacing: 14) {
                            ForEach(children) { child in
                                    LiveChildCareCard(
                                        child: child,
                                        role: role,
                                        onMeal: { showQuickAction = .meal(child) },
                                        onNap: { showQuickAction = .nap(child) },
                                        onPlay: { showQuickAction = .game(child) },
                                        onNote: { showQuickAction = .note(child) },
                                        onGame: { showQuickAction = .game(child) },
                                        onPhoto: { showQuickAction = .photo(child) },
                                        onMessage: { showQuickAction = .message(child) },
                                        onAttendance: { showQuickAction = .attendance(child) },
                                        onSendUpdate: { sendDailyUpdate(for: child) }
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .padding(.top, 8)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Children")
        .navigationBarTitleDisplayMode(.large)
        .task { await loadChildren() }
        .sheet(item: $showQuickAction) { action in
            QuickActionSheet(action: action, providerId: providerId) {
                Task { await loadChildren() }
            }
        }
        .alert("Daily Update Sent", isPresented: $showUpdateSuccess) {
            Button("Nice!", role: .cancel) { }
        } message: {
            Text("The daily report for \(successChildName) has been sent to their parents successfully.")
        }
    }
    
    private func loadChildren() async {
        guard providerId != -1 else { return }
        isLoading = true
        errorMessage = nil
        do {
            let url = URL(string: "\(AuthService.shared.baseURL)/bookings/provider/\(providerId)/children")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ProviderChild].self, from: data)
            await MainActor.run {
                children = decoded
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Could not load children. Make sure the server is running."
                isLoading = false
            }
        }
    }

    private func sendDailyUpdate(for child: ProviderChild) {
        Task {
            do {
                // 1. Fetch latest activity for a descriptive message before clearing
                let activities = try await ActivityService.shared.fetchChildActivities(childId: child.id)
                let latestMood = activities.filter { $0.activity_type == "Mood" }.last
                let moodNote = latestMood?.notes?.replacingOccurrences(of: "Today's mood: ", with: "") ?? "Happy"
                
                // 2. Log a "Report" activity so it survives the "clear past" (which only clears records from strictly before today/now)
                // Actually, clearPastChildRecords clears everything before "Today" UTC.
                _ = try await ActivityService.shared.createActivityRecord(
                    childId: child.id,
                    providerId: providerId,
                    type: "Report",
                    notes: "\(child.name) is \(moodNote.lowercased()) today! Everything is going great."
                )
                
                // 3. Clear past data (optional, but requested in original code)
                try await ActivityService.shared.clearPastChildRecords(childId: child.id)
                
                // 4. Send the notification with descriptive message
                let url = URL(string: "\(AuthService.shared.baseURL)/notifications/")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "user_id": child.parent_id,
                    "title": "📑 Daily Report Ready",
                    "message": "\(child.name) is \(moodNote.lowercased()) today! Click to view the full report.",
                    "type": "success",
                    "child_id": child.id
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                _ = try await URLSession.shared.data(for: request)
                
                await MainActor.run {
                    self.successChildName = child.name
                    self.showUpdateSuccess = true
                }
            } catch {
                print("Failed to send daily update: \(error)")
            }
        }
    }
}

// MARK: - Live Child Care Card
struct LiveChildCareCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let child: ProviderChild
    let role: UserRole
    let onMeal: () -> Void
    let onNap: () -> Void
    let onPlay: () -> Void
    let onNote: () -> Void
    let onGame: () -> Void
    let onPhoto: () -> Void
    let onMessage: () -> Void
    let onAttendance: () -> Void
    let onSendUpdate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(hex: "#F1F4F9"))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(child.name.prefix(1)))
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(child.name)
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 6) {
                        if !child.age.isEmpty { Text(child.age) }
                        if !child.age.isEmpty { Text("•") }
                        Text(child.parent_name)
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    if !child.allergies.isEmpty {
                        Text("⚠️ \(child.allergies)")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    }
                }
                Spacer()
            }
            
            NavigationLink(destination: ChildProfileView(childId: child.id, name: child.name, age: child.age, role: role)) {
                HStack(spacing: 8) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 16))
                    Text("Child Profile")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [themeManager.primaryColor, themeManager.primaryColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: themeManager.primaryColor.opacity(0.2), radius: 8, y: 4)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // 2x3 Quick Action Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                CardActivityButton(title: "Attendance", icon: "checkmark.seal.fill", color: themeManager.primaryColor)
                    .onTapGesture { onAttendance() }
                
                CardActivityButton(title: "Meals", icon: "fork.knife", color: Color(hex: "#EEA63A"))
                    .onTapGesture { onMeal() }
                
                CardActivityButton(title: "Nap Time", icon: "moon.fill", color: Color(hex: "#A061CF"))
                    .onTapGesture { onNap() }
                
                CardActivityButton(title: "Games Period", icon: "gamecontroller.fill", color: Color(hex: "#FF4757"))
                    .onTapGesture { onGame() }
                
                CardActivityButton(title: "Add Photo", icon: "camera.fill", color: Color.blue)
                    .onTapGesture { onPhoto() }
                
                CardActivityButton(title: "Add Note", icon: "doc.text.fill", color: Color.purple)
                    .onTapGesture { onNote() }
            }
            .padding(.top, 4)
            
            Button(action: onSendUpdate) {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                    Text("Send Daily Update to Parent")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .foregroundColor(themeManager.primaryColor)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.primaryColor.opacity(0.2), lineWidth: 1.5))
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(AppTheme.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.06), lineWidth: 1))
    }
}

import PhotosUI

// MARK: - Quick Action Sheet (Meal/Nap/Play/Note)
struct QuickActionSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    let action: ProviderChildrenOverview.QuickActionType
    let providerId: Int
    var onSaveSuccess: (() -> Void)? = nil
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var saveError: String?
    
    // Attendance State
    @State private var attendanceDate = Date()
    
    // Meal State
    @State private var mealType = "Breakfast"
    @State private var foodItem = ""
    @State private var amountEaten = "Most"
    
    // Nap State
    @State private var napHours = 0
    @State private var napMinutes = 30
    
    // Game State
    @State private var gameName = ""
    @State private var gameMood = "Happy"
    @State private var howPlayed = ""
    @State private var gamePlace = ""
    
    // Multi-meal State
    @State private var breakfastData = ""
    @State private var lunchData = ""
    @State private var snackData = ""
    @State private var dinnerData = ""
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var childName: String {
        switch action {
        case .meal(let c), .nap(let c), .play(let c), .note(let c), .game(let c), .photo(let c), .message(let c), .attendance(let c): return c.name
        }
    }
    var childId: Int {
        switch action {
        case .meal(let c), .nap(let c), .play(let c), .note(let c), .game(let c), .photo(let c), .message(let c), .attendance(let c): return c.id
        }
    }
    var title: String {
        switch action {
        case .meal: return "Log Meal"
        case .nap: return "Log Nap"
        case .play: return "Log Play"
        case .note: return "Add Note"
        case .game: return "Log Game"
        case .photo: return "Send Photo"
        case .message: return "Send Message"
        case .attendance: return "Mark Attendance"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("For: \(childName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    switch action {
                    case .meal:
                        mealForm
                    case .nap:
                        napForm
                    case .play, .game:
                        gameForm
                    case .note:
                        simpleForm(title: "Notes", placeholder: "e.g. Arrived happy, ate well today", text: $howPlayed)
                    case .photo:
                        photoForm
                    case .message:
                        simpleForm(title: "Message", placeholder: "e.g. I'll be finishing up soon!", text: $howPlayed)
                    case .attendance:
                        attendanceForm
                    }
                    
                    if let error = saveError {
                        Text(error).font(.caption).foregroundColor(.red)
                    }
                    
                    if saveSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Saved successfully!").foregroundColor(.green).fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(12)
                    }
                    
                    Button(action: save) {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(actionID == "photo" ? "Upload & Send" : "Save") }
                        }
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
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
                    .disabled(isSaving || (actionID == "photo" && selectedImageData == nil))
                }
                .padding(24)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                }
            }
        }
    }
    
    private var actionID: String {
        switch action {
        case .photo: return "photo"
        case .meal: return "meal"
        default: return "other"
        }
    }
    
    @ViewBuilder
    private var mealForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            MealInputSection(title: "Breakfast", icon: "sun.and.horizon.fill", text: $breakfastData, color: .orange)
            MealInputSection(title: "Lunch", icon: "sun.max.fill", text: $lunchData, color: .yellow)
            MealInputSection(title: "Snack", icon: "leaf.fill", text: $snackData, color: .green)
            MealInputSection(title: "Dinner", icon: "moon.fill", text: $dinnerData, color: .indigo)
        }
    }
    
    struct MealInputSection: View {
        let title: String
        let icon: String
        @Binding var text: String
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(color)
                    }
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                TextField("What did they have for \(title.lowercased())?", text: $text)
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            }
        }
    }
    
    @ViewBuilder
    private var photoForm: some View {
        VStack(alignment: .center, spacing: 20) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                VStack(spacing: 12) {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(16)
                            .clipped()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: 200, height: 200)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5])))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(themeManager.primaryColor)
                                Text("Select Photo")
                                    .font(.subheadline).fontWeight(.bold)
                                    .foregroundColor(themeManager.primaryColor)
                            }
                        }
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedImageData = data
                        }
                    }
                }
            }
            
            if selectedImageData != nil {
                Button(action: { selectedItem = nil; selectedImageData = nil }) {
                    Text("Change Photo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var attendanceForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.primaryColor)
                    Text("Select Date & Time")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                DatePicker("Time", selection: $attendanceDate)
                    .datePickerStyle(.graphical)
                    .padding(12)
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Notes (Optional)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                TextField("e.g. Arrived on time", text: $howPlayed)
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
        }
    }
    
    @ViewBuilder
    private var napForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(hex: "#A061CF"))
                    Text("Sleep Duration")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text("Hours").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                        Picker("Hours", selection: $napHours) {
                            ForEach(0..<13) { Text("\($0) h") }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Minutes").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                        Picker("Minutes", selection: $napMinutes) {
                            ForEach([0, 5, 10, 15, 20, 30, 45], id: \.self) { Text("\($0) m") }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(AppTheme.surface)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Observation")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                TextField("e.g. Fell asleep quickly", text: $howPlayed)
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
        }
    }
    
    @ViewBuilder
    private var gameForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Where?", systemImage: "mappin.and.ellipse")
                    .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                TextField("e.g. Playground, Playroom", text: $gamePlace)
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Label("What?", systemImage: "gamecontroller.fill")
                    .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                TextField("e.g. Building Blocks, Tag", text: $gameName)
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Mood During Activity").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                HStack(spacing: 8) {
                    ForEach(["Happy", "Energetic", "Calm", "Focused", "Fussy"], id: \.self) { mood in
                        Button(action: { gameMood = mood }) {
                            Text(mood)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(gameMood == mood ? .white : .gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(gameMood == mood ? themeManager.primaryColor : Color.gray.opacity(0.05))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("How they played").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                TextEditor(text: $howPlayed)
                    .frame(height: 100)
                    .padding(12)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
        }
    }
    
    private func simpleForm(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).fontWeight(.bold).foregroundColor(.gray)
            TextEditor(text: text)
                .frame(height: 120)
                .padding(12)
                .background(Color(hex: "#F8F9FB"))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.05)))
                .overlay(
                    Group {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder).foregroundColor(.gray.opacity(0.5)).padding(16)
                        }
                    }, alignment: .topLeading
                )
        }
    }
    
    private func save() {
        // Guard: provider must be authenticated
        guard providerId != -1 else {
            saveError = "Provider session expired. Please log out and log back in."
            return
        }
        
        isSaving = true
        saveError = nil
        saveSuccess = false
        
        Task {
            do {
                // PHOTO UPLOAD (multipart — cannot go through BaseService JSON path)
                if actionID == "photo", let imageData = selectedImageData {
                    let boundary = "Boundary-\(UUID().uuidString)"
                    let url = URL(string: "\(AuthService.shared.baseURL)/upload/child-photo/\(childId)")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    let token = AuthService.shared.storedToken
                    if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
                    
                    var body = Data()
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(imageData)
                    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                    request.httpBody = body
                    
                    print("[iOS-Photo] 🚀 Uploading child photo for child \(childId)")
                    let (_, response) = try await URLSession.shared.data(for: request)
                    let http = response as? HTTPURLResponse
                    print("[iOS-Photo] RESPONSE: \(http?.statusCode ?? -1)")
                    await MainActor.run {
                        isSaving = false
                        if http?.statusCode == 200 || http?.statusCode == 201 {
                            saveSuccess = true; onSaveSuccess?()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                        } else {
                            saveError = "Upload failed. Error code: \(http?.statusCode ?? 0)"
                        }
                    }
                    return
                }

                // MEAL — uses MealService which routes through BaseService (includes auth header)
                if case .meal = action {
                    let mealsToSave = [
                        ("Breakfast", breakfastData),
                        ("Lunch",     lunchData),
                        ("Snack",     snackData),
                        ("Dinner",    dinnerData)
                    ].filter { !$1.isEmpty }
                    
                    guard !mealsToSave.isEmpty else {
                        throw NetworkError.serverError("Please enter at least one meal item.")
                    }
                    
                    for (type, food) in mealsToSave {
                        print("[iOS-Meal] 🚀 Saving \(type) for child \(childId) via MealService")
                        let result = try await MealService.shared.createMealRecord(
                            childId: childId,
                            providerId: providerId,
                            mealType: type,
                            foodItem: food,
                            amountEaten: "Most"
                        )
                        print("[iOS-Meal] ✅ Saved meal id=\(result.id), type=\(result.meal_type)")
                    }
                    await MainActor.run {
                        isSaving = false; saveSuccess = true; onSaveSuccess?()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                    }
                    return
                }

                // ALL ACTIVITY TYPES — use ActivityService (BaseService with auth header)
                let activityType: String
                let notes: String
                
                switch action {
                case .nap:
                    activityType = "Nap"
                    notes = "Duration: \(napHours)h \(napMinutes)m. \(howPlayed)"
                case .play, .game:
                    activityType = "Game"
                    notes = "Place: \(gamePlace). Game: \(gameName). Mood: \(gameMood). \(howPlayed)"
                case .note:
                    activityType = "Note"
                    notes = howPlayed
                case .message:
                    activityType = "Message"
                    notes = howPlayed
                case .attendance:
                    activityType = "Attendance"
                    notes = howPlayed.isEmpty ? "Checked In" : howPlayed
                default:
                    activityType = "Activity"
                    notes = howPlayed
                }
                
                print("[iOS-Activity] 🚀 Saving '\(activityType)' for child \(childId) via ActivityService")
                let result = try await ActivityService.shared.createActivityRecord(
                    childId: childId,
                    providerId: providerId,
                    type: activityType,
                    notes: notes.isEmpty ? nil : notes
                )
                print("[iOS-Activity] ✅ Saved activity id=\(result.id), type=\(result.activity_type)")

                await MainActor.run {
                    isSaving = false
                    saveSuccess = true
                    onSaveSuccess?()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                }

            } catch {
                await MainActor.run {
                    isSaving = false
                    saveError = error.localizedDescription
                    print("[iOS-Save] ❌ Error: \(error)")
                }
            }
        }
    }
}

// MARK: - Activity Grid Item (NavigationLink based)
struct ActivityGridItem: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.surface)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.08), lineWidth: 1))
        }
    }
}

// MARK: - Card Activity Button (used in per-child card)
struct CardActivityButton: View {
    let title: String
    let icon: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .bold))
            }
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.surface)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.gray.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Quick Action Icon (used in card buttons)
struct QuickActionIcon: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Legacy support struct
struct ChildCareCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let age: String
    let parent: String
    let tag: String
    let tagColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(hex: "#F1F4F9"))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.headline).fontWeight(.bold).foregroundColor(.gray)
                    )
                VStack(alignment: .leading, spacing: 5) {
                    Text(name).font(.subheadline).fontWeight(.bold).foregroundColor(AppTheme.textPrimary)
                    HStack(spacing: 6) {
                        Text(age)
                        Text("•")
                        Text(parent)
                    }
                    .font(.caption).foregroundColor(AppTheme.textSecondary)
                    Text(tag)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(tagColor.opacity(0.1))
                        .foregroundColor(tagColor)
                        .cornerRadius(6)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.06), lineWidth: 1))
    }
}
