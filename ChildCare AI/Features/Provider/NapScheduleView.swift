import SwiftUI

public struct NapScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var children: [ProviderChild] = []
    @State private var selectedChildIds: Set<Int> = []
    @State private var startTime = "01:00 PM"
    @State private var endTime = "03:00 PM"
    @State private var sleepQuality = "Normal"
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                AppHeader(title: "Nap Schedule")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Child Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Children")
                                .font(.subheadline).fontWeight(.bold).foregroundColor(.gray)
                            
                            if children.isEmpty && !isLoading {
                                Text("No children found.").foregroundColor(.gray).padding()
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
                        
                        // Time Picker Section
                        VStack(spacing: 16) {
                            NapTimeRow(label: "Start Time", time: $startTime)
                            Divider()
                            NapTimeRow(label: "End Time", time: $endTime)
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        // Quality Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sleep Quality")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            HStack(spacing: 8) {
                                QualityButton(title: "Restless", isSelected: sleepQuality == "Restless") { sleepQuality = "Restless" }
                                QualityButton(title: "Normal", isSelected: sleepQuality == "Normal") { sleepQuality = "Normal" }
                                QualityButton(title: "Deep Sleep", isSelected: sleepQuality == "Deep Sleep") { sleepQuality = "Deep Sleep" }
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                                .overlay(
                                    Group {
                                        if notes.isEmpty {
                                            Text("Notes (e.g. woke up crying, needed toy)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray.opacity(0.5))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 20)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                    
                    // Save Button
                    Button(action: saveNapRecords) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("Save Nap Record") }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedChildIds.isEmpty ? Color.gray : themeManager.primaryColor)
                        .cornerRadius(16)
                        .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(isLoading || selectedChildIds.isEmpty)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
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
                isLoading = false
            }
        }
    }
    
    private func saveNapRecords() {
        guard !selectedChildIds.isEmpty else { return }
        isLoading = true
        
        Task {
            for childId in selectedChildIds {
                do {
                    let url = URL(string: "\(AuthService.shared.baseURL)/activities/")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "child_id": childId,
                        "provider_id": providerId,
                        "activity_type": "Nap",
                        "notes": "Quality: \(sleepQuality). \(notes)",
                        "start_time": startTime,
                        "end_time": endTime
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    _ = try await URLSession.shared.data(for: request)
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

struct QualityButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? AppTheme.textPrimary : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.gray.opacity(0.2) : Color(hex: "#F1F4F9"), lineWidth: 1))
        }
    }
}

struct NapTimeRow: View {
    let label: String
    @Binding var time: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Text(time)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(themeManager.primaryColor.opacity(0.08))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}
