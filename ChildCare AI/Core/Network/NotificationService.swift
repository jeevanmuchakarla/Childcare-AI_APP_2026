import Foundation

public struct NotificationModel: Codable, Identifiable {
    public let id: Int
    public let user_id: Int
    public let title: String
    public let message: String
    public let type: String // info, success, warning, alert
    public let child_id: Int?
    public let is_read: Bool
    public let created_at: String
}

public class NotificationService: BaseService {
    public static let shared = NotificationService()
    
    public func fetchNotifications(userId: Int) async throws -> [NotificationModel] {
        return try await performRequest(endpoint: "/notifications/\(userId)")
    }
    
    public func markAllAsRead(userId: Int) async throws -> [String: String] {
        return try await performRequest(
            endpoint: "/notifications/read-all/\(userId)",
            method: "PATCH"
        )
    }
    
    public func deleteNotifications(userId: Int) async throws -> [String: String] {
        return try await performRequest(
            endpoint: "/notifications/\(userId)",
            method: "DELETE"
        )
    }
    
    public func sendEmergencyAlert(providerId: Int, message: String) async throws -> [String: String] {
        return try await performRequest(
            endpoint: "/notifications/emergency?provider_id=\(providerId)&message=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            method: "POST"
        )
    }
}
