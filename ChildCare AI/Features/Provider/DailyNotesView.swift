import SwiftUI

public struct DailyNotesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var newNote = ""
    @State private var showAlert = false
    @State private var notes: [DailyNoteRecord] = []
    @State private var isLoading = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Daily Notes")
            
            ScrollView {
                VStack(spacing: 20) {
                    // New Note Composer
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(themeManager.primaryColor)
                                    .font(.system(size: 14))
                            }
                            Text("New Note")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        TextEditor(text: $newNote)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color(hex: "#F1F4F9").opacity(0.3))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                            .overlay(
                                Group {
                                    if newNote.isEmpty {
                                        Text("Write a note for parents...")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                    }
                                },
                                alignment: .topLeading
                            )
                        
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "camera")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                            }
                            Spacer()
                            Button(action: postNote) {
                                HStack {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Post Note")
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(themeManager.primaryGradient)
                                .cornerRadius(12)
                            }
                            .disabled(newNote.isEmpty || isLoading)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // History
                    VStack(spacing: 16) {
                        if notes.isEmpty {
                            Text("No notes posted yet.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(notes) { note in
                                NoteRow(
                                    author: note.author_name ?? "Provider",
                                    time: formatRelativeDate(note.created_at),
                                    content: note.content
                                )
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert("Note Posted", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your note has been successfully shared with the parents.")
        }
        .onAppear { loadNotes() }
    }
    
    private func loadNotes() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        Task {
            if let data = try? await DailyNoteService.shared.fetchDailyNotes(providerId: providerId) {
                await MainActor.run {
                    self.notes = data
                }
            }
        }
    }
    
    private func postNote() {
        guard let providerId = AuthService.shared.currentUser?.id, !newNote.isEmpty else { return }
        isLoading = true
        Task {
            do {
                _ = try await DailyNoteService.shared.createDailyNote(providerId: providerId, content: newNote)
                await MainActor.run {
                    isLoading = false
                    showAlert = true
                    newNote = ""
                    loadNotes()
                }
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }
    
    private func formatRelativeDate(_ dateString: String) -> String {
        // Simple formatter for time
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let outFormatter = DateFormatter()
            outFormatter.dateFormat = "h:mm a"
            return outFormatter.string(from: date)
        }
        return "Just now"
    }
}

struct NoteRow: View {
    let author: String
    let time: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(author)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
        .padding(.horizontal)
    }
}
