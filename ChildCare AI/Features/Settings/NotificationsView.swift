import SwiftUI

public struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var notifications: [NotificationModel] = []
    @State private var isLoading = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "Notifications",
                trailingAction: AnyView(
                    Menu {
                        Button(action: {
                            markAllAsRead()
                        }) {
                            Label("Mark all as read", systemImage: "checkmark.circle")
                        }
                        
                        Button(role: .destructive, action: {
                            deleteAll()
                        }) {
                            Label("Delete all", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 22))
                            .foregroundColor(themeManager.primaryColor)
                    }
                )
            )
            
            if isLoading && notifications.isEmpty {
                ProgressView().padding(.top, 40)
            } else if notifications.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No notifications yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(notifications) { notification in
                            NavigationLink(destination: NotificationDetailView(notification: notification)) {
                                NotificationRow(notification: notification)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                let fetched = try await NotificationService.shared.fetchNotifications(userId: userId)
                DispatchQueue.main.async {
                    self.notifications = fetched
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    private func markAllAsRead() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task {
            _ = try? await NotificationService.shared.markAllAsRead(userId: userId)
            loadNotifications()
        }
    }
    
    private func deleteAll() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task {
            _ = try? await NotificationService.shared.deleteNotifications(userId: userId)
            loadNotifications()
        }
    }
}

struct NotificationDetailView: View {
    let notification: NotificationModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Notification Details", showBackButton: true, onBack: { dismiss() })
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(colorForType(notification.type).opacity(0.1))
                                .frame(width: 60, height: 60)
                            Image(systemName: iconForType(notification.type))
                                .foregroundColor(colorForType(notification.type))
                                .font(.title)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(notification.created_at)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, 10)
                    
                    if let childId = notification.child_id, notification.title.contains("Daily Report") {
                        NavigationLink(destination: DailyReportOverviewView(childId: childId, childName: notification.message.components(separatedBy: "for ").last?.components(separatedBy: " has").first ?? "Child")) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("View Detailed Report")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.primaryGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 5)
                        }
                        .padding(.top, 20)
                    }
                    
                    Divider().padding(.vertical, 10)
                }
                .padding(20)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func iconForType(_ type: String) -> String {
        switch type {
        case "success": return "checkmark.circle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "alert": return "bell.fill"
        default: return "info.circle.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "success": return .green
        case "warning": return .orange
        case "alert": return .red
        default: return .blue
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(colorForType(notification.type).opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: iconForType(notification.type))
                    .foregroundColor(colorForType(notification.type))
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text("Now") 
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if !notification.is_read {
                Circle()
                    .fill(themeManager.primaryColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "success": return "checkmark.circle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "alert": return "bell.fill"
        default: return "info.circle.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "success": return .green
        case "warning": return .orange
        case "alert": return .red
        default: return .blue
        }
    }
}
