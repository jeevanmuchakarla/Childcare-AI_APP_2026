import SwiftUI

public struct GamesPeriodView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var children: [ProviderChild] = []
    @State private var selectedChildIds: Set<Int> = []
    @State private var gameName = ""
    @State private var selectedMood = "Happy"
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var saveSuccess = false
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Games Period")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Child Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Children")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.gray)
                        
                        if children.isEmpty && !isLoading {
                            Text("No children found in care.")
                                .foregroundColor(.gray).italic()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(children) { child in
                                        ChildSelectionBadge(
                                            child: child,
                                            isSelected: selectedChildIds.contains(child.id),
                                            action: {
                                                if selectedChildIds.contains(child.id) {
                                                    selectedChildIds.remove(child.id)
                                                } else {
                                                    selectedChildIds.insert(child.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Game Details
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Game / Activity Name")
                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            TextField("e.g. Hide and Seek, Blocks, Painting", text: $gameName)
                                .padding(14)
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mood During Game").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            Picker("Mood", selection: $selectedMood) {
                                ForEach(["Happy", "Energetic", "Calm", "Focused", "Fussy"], id: \.self) { Text($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(12)
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        Text(error).font(.caption).foregroundColor(.red).padding(.horizontal)
                    }
                    
                    if saveSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Games recorded successfully!").foregroundColor(.green).fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Button(action: saveGames) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("Record Games Period") }
                        }
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(selectedChildIds.isEmpty || gameName.isEmpty ? Color.gray : themeManager.primaryColor)
                        .cornerRadius(16)
                    }
                    .disabled(isLoading || selectedChildIds.isEmpty || gameName.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical, 24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
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
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load children."
                isLoading = false
            }
        }
    }
    
    private func saveGames() {
        guard providerId != -1 else { return }
        isLoading = true
        errorMessage = nil
        saveSuccess = false
        
        Task {
            var allSucceeded = true
            for childId in selectedChildIds {
                do {
                    let url = URL(string: "\(AuthService.shared.baseURL)/activities/")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "child_id": childId,
                        "provider_id": providerId,
                        "activity_type": "Game",
                        "notes": "Game: \(gameName). Mood: \(selectedMood). \(notes)"
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    if let http = response as? HTTPURLResponse, http.statusCode != 200 && http.statusCode != 201 {
                        allSucceeded = false
                    }
                } catch {
                    allSucceeded = false
                }
            }
            
            await MainActor.run {
                isLoading = false
                if allSucceeded {
                    saveSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
                } else {
                    errorMessage = "Failed to save some records."
                }
            }
        }
    }
}

struct ChildSelectionBadge: View {
    let child: ProviderChild
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? themeManager.primaryColor : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Text(String(child.name.prefix(1)))
                        .font(.headline).fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : themeManager.primaryColor)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.green))
                            .offset(x: 18, y: -18)
                            .font(.system(size: 14))
                    }
                }
                Text(child.name)
                    .font(.caption2).fontWeight(.medium)
                    .foregroundColor(isSelected ? themeManager.primaryColor : AppTheme.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 70)
        }
    }
}

