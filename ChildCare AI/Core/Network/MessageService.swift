import Foundation

public struct MessageResponse: Codable {
    public let id: Int
    public let sender_id: Int
    public let receiver_id: Int
    public let content: String
}

public struct MessageModel: Codable, Identifiable, Equatable {
    public let id: Int
    public let sender_id: Int
    public let sender_role: String?
    public let receiver_id: Int
    public let receiver_role: String?
    public let content: String
    public let image_url: String? // Added for image support
    public let is_read: Bool
    public let created_at: String
    
    public static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        lhs.id == rhs.id
    }
}

public struct InboxItem: Codable, Identifiable {
    public var id: Int { user_id }
    public let user_id: Int
    public let email: String
    public let last_message: String
    public let timestamp: String
    public let is_read: Bool
    public let image_url: String? // Added for image support in inbox
    public let full_name: String?
    public let center_name: String?
}

public struct UnreadCountResponse: Codable {
    public let unread_by_role: [String: Int]
    public let total_unread: Int
}

public struct SendMessageResponse: Codable {
    public let message: String
    public let data: MessageModel
}

public class MessageService: BaseService {
    public static let shared = MessageService()
    
    /// Send a message from senderId to receiverId
    public func sendMessage(senderId: Int, receiverId: Int, content: String, imageUrl: String? = nil) async throws -> MessageModel {
        var body: [String: Any] = ["receiver_id": receiverId, "content": content]
        if let url = imageUrl { body["image_url"] = url }
        
        let response: SendMessageResponse = try await performRequest(
            endpoint: "/messages/send-message",
            method: "POST",
            body: body
        )
        return response.data
    }
    
    /// Fetch all messages between two users
    public func getConversation(user1: Int, user2: Int) async throws -> [MessageModel] {
        return try await performRequest(endpoint: "/messages/conversation/\(user2)")
    }
    
    /// Fetch inbox summary (all recent conversations)
    public func getInbox(userId: Int) async throws -> [InboxItem] {
        return try await performRequest(endpoint: "/messages/inbox")
    }
    
    /// Fetch unread count by role for badge updates
    public func getUnreadCounts(userId: Int) async throws -> UnreadCountResponse {
        return try await performRequest(endpoint: "/messages/unread_count")
    }
    
    /// Mark all messages from sender as read
    public func markRead(userId: Int, senderId: Int) async throws {
        let _: [String: String] = try await performRequest(
            endpoint: "/messages/mark_read/\(senderId)",
            method: "POST"
        )
    }
    
    /// Check if two users are allowed to chat (admin or confirmed booking)
    public func checkChatPermission(user1: Int, user2: Int) async throws -> Bool {
        struct ChatPermissionResponse: Codable {
            let can_chat: Bool
        }
        let response: ChatPermissionResponse = try await performRequest(
            endpoint: "/bookings/can_chat/\(user1)/\(user2)",
            method: "GET"
        )
        return response.can_chat
    }
    
    /// Delete all messages between two users
    public func clearConversation(user1: Int, user2: Int) async throws {
        let _: [String: String] = try await performRequest(
            endpoint: "/messages/conversation/\(user2)",
            method: "DELETE"
        )
    }
}
