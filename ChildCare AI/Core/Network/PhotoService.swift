import Foundation

public struct PhotoModel: Codable, Identifiable {
    public let id: Int
    public let child_id: Int?
    public let center_id: Int?
    public let url: String
    public let caption: String?
    public let created_at: String
}

public class PhotoService: BaseService {
    public static let shared = PhotoService()
    
    public func fetchChildPhotos(childId: Int) async throws -> [PhotoModel] {
        return try await performRequest(endpoint: "/upload/child/\(childId)")
    }
}
