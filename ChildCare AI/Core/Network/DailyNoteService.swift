import Foundation

public struct DailyNoteRecord: Codable, Identifiable {
    public let id: Int
    public let provider_id: Int
    public let author_name: String?
    public let content: String
    public let created_at: String
}

public class DailyNoteService: BaseService {
    public static let shared = DailyNoteService()
    private override init() {}
    
    public func fetchDailyNotes(providerId: Int) async throws -> [DailyNoteRecord] {
        return try await performRequest(endpoint: "/provider-stats/daily-notes/\(providerId)")
    }
    
    public func createDailyNote(providerId: Int, content: String, authorName: String? = nil) async throws -> DailyNoteRecord {
        let body: [String: Any] = [
            "content": content,
            "author_name": authorName as Any
        ]
        return try await performRequest(endpoint: "/provider-stats/daily-notes/\(providerId)", method: "POST", body: body)
    }
}
