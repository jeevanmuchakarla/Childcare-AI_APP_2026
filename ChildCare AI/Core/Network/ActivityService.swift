import Foundation

public struct ActivityModel: Codable, Identifiable {
    public let id: Int
    public let child_id: Int
    public let provider_id: Int
    public let activity_type: String
    public let notes: String?
    public let created_at: String
}

public class ActivityService: BaseService {
    public static let shared = ActivityService()
    
    public func createActivityRecord(
        childId: Int,
        providerId: Int,
        type: String,
        notes: String?
    ) async throws -> ActivityModel {
        let payload: [String: Any?] = [
            "child_id": childId,
            "provider_id": providerId,
            "activity_type": type,
            "notes": notes
        ]
        
        return try await performRequest(
            endpoint: "/activities/",
            method: "POST",
            body: payload as [String : Any]
        )
    }
    
    public func fetchChildActivities(childId: Int) async throws -> [ActivityModel] {
        return try await performRequest(endpoint: "/activities/child/\(childId)")
    }
    
    public func fetchProviderActivities(providerId: Int) async throws -> [ActivityModel] {
        return try await performRequest(endpoint: "/activities/provider/\(providerId)")
    }
    
    public func clearChildRecords(childId: Int) async throws {
        let _: [String: String] = try await performRequest(
            endpoint: "/activities/child/\(childId)/clear",
            method: "DELETE"
        )
    }
    
    public func clearPastChildRecords(childId: Int) async throws {
        let _: [String: String] = try await performRequest(
            endpoint: "/activities/child/\(childId)/clear_past",
            method: "DELETE"
        )
    }
}
