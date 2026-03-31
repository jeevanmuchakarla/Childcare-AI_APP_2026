import SwiftUI

public struct ChatContact: Identifiable {
    public let id: UUID
    public let name: String
    public let initial: String
    public let color: Color
    public var lastMessage: String
    public var time: String
    public var unread: Int
    public var userId: Int?
    
    public init(id: UUID = UUID(), name: String, initial: String, color: Color, lastMessage: String, time: String, unread: Int, userId: Int? = nil) {
        self.id = id
        self.name = name
        self.initial = initial
        self.color = color
        self.lastMessage = lastMessage
        self.time = time
        self.unread = unread
        self.userId = userId
    }
}
