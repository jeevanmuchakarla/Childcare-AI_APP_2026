import SwiftUI

struct ParentStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var parents: [EnrolledParentRecord] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Parent Status")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if parents.isEmpty {
                            Text("No enrolled parents found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(parents) { parent in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(themeManager.primaryColor.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Text(String(parent.name.prefix(1)))
                                                .fontWeight(.bold)
                                                .foregroundColor(themeManager.primaryColor)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(parent.name)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text("Last seen: \(parent.last_seen)")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(parent.status)
                                        .font(.caption.bold())
                                        .foregroundColor(statusColor(for: parent.status))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(statusColor(for: parent.status).opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadParents() }
    }
    
    private func loadParents() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                let data = try await ProviderStatsService.shared.fetchEnrolledParents(providerId: providerId)
                let mappedData = data
                await MainActor.run {
                    self.parents = mappedData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Active": return .green
        case "On the way": return .blue
        case "Away": return .orange
        default: return .gray
        }
    }
}
