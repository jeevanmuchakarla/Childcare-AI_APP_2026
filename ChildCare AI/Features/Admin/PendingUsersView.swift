import SwiftUI

struct PendingUsersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var pendingUsers: [RemoteUser] = []
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Pending Approvals")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if pendingUsers.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No Pending Approvals")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("All users have been processed.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(pendingUsers) { user in
                            PendingUserCard(user: user, onApprove: {
                                approveUser(user)
                            }, onReject: {
                                rejectUser(user)
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadPendingUsers()
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadPendingUsers() {
        isLoading = true
        Task {
            do {
                let fetched = try await ProfileService.shared.fetchPendingUsers()
                await MainActor.run {
                    self.pendingUsers = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func approveUser(_ user: RemoteUser) {
        Task {
            do {
                let success = try await ProfileService.shared.approveUser(userId: user.id)
                if success {
                    await MainActor.run {
                        self.pendingUsers.removeAll { $0.id == user.id }
                        self.alertMessage = "User \(user.full_name) has been approved."
                        self.showSuccessAlert = true
                    }
                }
            } catch {
            }
        }
    }
    
    private func rejectUser(_ user: RemoteUser) {
        Task {
            do {
                let success = try await ProfileService.shared.rejectUser(userId: user.id)
                if success {
                    await MainActor.run {
                        self.pendingUsers.removeAll { $0.id == user.id }
                        self.alertMessage = "User \(user.full_name) has been rejected."
                        self.showSuccessAlert = true
                    }
                }
            } catch {
            }
        }
    }
}

struct PendingUserCard: View {
    let user: RemoteUser
    let onApprove: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.full_name)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Text(user.role.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Reject")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: onApprove) {
                    Text("Approve")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
