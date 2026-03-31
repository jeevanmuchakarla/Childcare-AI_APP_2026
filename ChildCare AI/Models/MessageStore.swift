import SwiftUI
import Combine

// MARK: - Live Message (Used in UI Chat)
public struct LiveMessage: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let backendId: Int?
    public let text: String
    public let imageUrl: String? // Added for image support
    public let isFromMe: Bool
    public let timestamp: Date
    public let senderName: String
    public let senderRole: String?
    public let receiverRole: String?
    
    nonisolated public init(id: UUID = UUID(), backendId: Int? = nil, text: String, imageUrl: String? = nil, isFromMe: Bool, timestamp: Date, senderName: String = "", senderRole: String? = nil, receiverRole: String? = nil) {
        self.id = id
        self.backendId = backendId
        self.text = text
        self.imageUrl = imageUrl
        self.isFromMe = isFromMe
        self.timestamp = timestamp
        self.senderName = senderName
        self.senderRole = senderRole
        self.receiverRole = receiverRole
    }
    
    public static func == (lhs: LiveMessage, rhs: LiveMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - MessageStore
@MainActor
public class MessageStore: ObservableObject {
    @Published public var messages: [LiveMessage] = []
    @Published public var unreadByRole: [String: Int] = [:]
    @Published public var totalUnread: Int = 0
    @Published public var isSending: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var inbox: [InboxItem] = []
    @Published public var isLoadingInbox: Bool = false
    @Published public var unreadNotificationCount: Int = 0
    
    private var pollingTask: Task<Void, Never>?
    private var inboxPollingTask: Task<Void, Never>?
    private var badgePollingTask: Task<Void, Never>?
    private var lastMessageId: Int = 0
    
    public static let shared = MessageStore()
    public init() {}
    
    // MARK: - Start Polling a Conversation
    public func startPolling(myId: Int, otherId: Int, contactName: String) {
        stopPolling()
        clearMessages() // Clear stale messages when starting new conversation
        
        pollingTask = Task {
            while !Task.isCancelled {
                await fetchMessages(myId: myId, otherId: otherId, contactName: contactName)
                try? await Task.sleep(nanoseconds: 5_000_000_000) // Increase to 5 seconds to reduce UI load
            }
        }
    }
    
    public func clearMessages() {
        self.messages = []
    }
    
    public func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    // Removed nonisolated formatters as they aren't thread-safe
    
    private static let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss"
    ]
    
    // Made static and nonisolated to be safe for background threads
    nonisolated private static func parseDate(_ dateString: String) -> Date {
        var cleanString = dateString.replacingOccurrences(of: " ", with: "T")
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        // Try standard ISO8601 with fractional seconds first
        if let date = isoFormatter.date(from: cleanString) {
            return date
        }
        // Try fallback without fractional seconds
        if let date = fallbackFormatter.date(from: cleanString) {
            return date
        }
        
        // Manual fallbacks for common SQL/FastAPI formats missing the 'Z'
        if !cleanString.hasSuffix("Z") && !cleanString.contains("+") {
            cleanString += "Z"
        }
        
        if let date = isoFormatter.date(from: cleanString) {
            return date
        }
        
        if let date = fallbackFormatter.date(from: cleanString) {
            return date
        }

        print("DEBUG: Failed to parse date string: \(dateString)")
        return Date() 
    }

    // MARK: - Fetch Conversation Messages
    public func fetchMessages(myId: Int, otherId: Int, contactName: String) async {
        do {
            let models = try await MessageService.shared.getConversation(user1: myId, user2: otherId)
            
            // Capture current messages to process in background
            let currentMessages = self.messages
            
            // Offload mapping and merging to a background task
            let (updatedMessages, nextLastId) = await Task.detached(priority: .userInitiated) { () -> ([LiveMessage], Int?) in
                
                let newMessages = models.map { model -> LiveMessage in
                    let date = Self.parseDate(model.created_at)
                    let fromMe = (model.sender_id == myId)
                    return LiveMessage(
                        backendId: model.id,
                        text: model.content,
                        imageUrl: model.image_url,
                        isFromMe: fromMe,
                        timestamp: date,
                        senderName: fromMe ? "Me" : contactName,
                        senderRole: model.sender_role,
                        receiverRole: model.receiver_role
                    )
                }
                
                let currentBackendMsgs = currentMessages.filter { $0.backendId != nil }
                let hasChanges = newMessages.count != currentBackendMsgs.count || 
                                (newMessages.last?.backendId != currentBackendMsgs.last?.backendId)
                
                if hasChanges {
                    let remainingOptimistic = currentMessages.filter { opt in
                        let isOptimistic = opt.backendId == nil
                        let alreadyInBackend = newMessages.contains { confirmed in
                            confirmed.text == opt.text && abs(confirmed.timestamp.timeIntervalSince(opt.timestamp)) < 60
                        }
                        return isOptimistic && !alreadyInBackend
                    }
                    
                    var allMessages = newMessages + remainingOptimistic
                    allMessages.sort { $0.timestamp < $1.timestamp }
                    
                    let maxId = newMessages.compactMap({ $0.backendId }).max()
                    return (allMessages, maxId)
                }
                
                return (currentMessages, nil)
            }.value
            
            // Update the published property on the MainActor
            if updatedMessages != self.messages {
                self.messages = updatedMessages
            }
            if let nextId = nextLastId {
                self.lastMessageId = nextId
            }
        } catch {
            print("DEBUG ERROR fetchMessages: \(error)")
        }
    }
    
    // MARK: - Send Message
    public func sendMessage(myId: Int, otherId: Int, text: String, imageUrl: String? = nil) async throws {
        guard !text.isEmpty || imageUrl != nil else { return }
        isSending = true
        
        // Optimistic update
        let optimistic = LiveMessage(text: text, imageUrl: imageUrl, isFromMe: true, timestamp: Date(), senderName: "Me")
        messages.append(optimistic)
        
        do {
            let sent = try await MessageService.shared.sendMessage(senderId: myId, receiverId: otherId, content: text, imageUrl: imageUrl)
            // Replace optimistic with real data from backend
            await MainActor.run {
                if let idx = self.messages.firstIndex(where: { $0.id == optimistic.id }) {
                    self.messages[idx] = LiveMessage(
                        backendId: sent.id,
                        text: sent.content,
                        imageUrl: sent.image_url,
                        isFromMe: true,
                        timestamp: Self.parseDate(sent.created_at),
                        senderName: "Me",
                        senderRole: sent.sender_role,
                        receiverRole: sent.receiver_role
                    )
                }
            }
        } catch {
            print("DEBUG ERROR sendMessage: \(error)")
            // Remove the stuck optimistic message on failure
            await MainActor.run {
                self.messages.removeAll(where: { $0.id == optimistic.id })
            }
            throw error
        }
        await MainActor.run { isSending = false }
    }
    
    // MARK: - Fetch Inbox (Live Contact List)
    public func fetchInbox(userId: Int) async {
        isLoadingInbox = true
        do {
            self.inbox = try await MessageService.shared.getInbox(userId: userId)
        } catch {
        }
        isLoadingInbox = false
    }
    
    // MARK: - Start Polling Inbox
    public func startInboxPolling(userId: Int) {
        inboxPollingTask?.cancel()
        inboxPollingTask = Task {
            while !Task.isCancelled {
                await fetchInbox(userId: userId)
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            }
        }
    }
    
    // MARK: - Fetch Unread Counts for Badge Updates
    public func refreshUnreadCounts(userId: Int) async {
        do {
            let response = try await MessageService.shared.getUnreadCounts(userId: userId)
            unreadByRole = response.unread_by_role
            totalUnread = response.total_unread
        } catch {
        }
    }
    
    // MARK: - Start Polling Unread Counts (for home/chat tab badges)
    public func startBadgePolling(userId: Int) {
        badgePollingTask?.cancel()
        badgePollingTask = Task {
            while !Task.isCancelled {
                await refreshUnreadCounts(userId: userId)
                await refreshNotificationCount(userId: userId)
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            }
        }
    }
    
    // MARK: - Fetch Notification Count
    public func refreshNotificationCount(userId: Int) async {
        do {
            let notices = try await NotificationService.shared.fetchNotifications(userId: userId)
            let unread = notices.filter { !$0.is_read }.count
            self.unreadNotificationCount = unread
        } catch {
        }
    }
    
    
    public func clearBackendConversation(myId: Int, otherId: Int) async {
        do {
            try await MessageService.shared.clearConversation(user1: myId, user2: otherId)
            self.messages = []
        } catch {
        }
    }
}
