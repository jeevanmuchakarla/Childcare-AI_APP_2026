import Foundation

public struct ChildModel: Codable, Identifiable {
    public let id: Int
    public let parent_id: Int
    public let name: String
    public let age: String?
    public let allergies: String?
    public let medical_notes: String?
    public let emergency_contact: String?
}

public class ChildService: BaseService {
    public static let shared = ChildService()
    
    struct AddChildResponse: Decodable {
        let message: String
        let child: ChildModel
    }
    
    public func fetchChildren(parentId: Int) async throws -> [ChildModel] {
        return try await performRequest(endpoint: "/profile/\(parentId)/children")
    }
    
    public func addChild(parentId: Int, name: String, age: String) async throws -> ChildModel {
        let body: [String: Any] = [
            "name": name,
            "age": age
        ]
        
        let response: AddChildResponse = try await performRequest(
            endpoint: "/profile/\(parentId)/children",
            method: "POST",
            body: body
        )
        return response.child
    }
    
    public func updateChild(userId: Int, childId: Int, name: String, age: String, allergies: String?, medicalNotes: String?, emergencyContact: String?) async throws -> Bool {
        let body: [String: Any] = [
            "name": name,
            "age": age,
            "allergies": allergies ?? "",
            "medical_notes": medicalNotes ?? "",
            "emergency_contact": emergencyContact ?? ""
        ]
        
        let _: BaseResponse = try await performRequest(
            endpoint: "/profile/\(userId)/children/\(childId)",
            method: "PUT",
            body: body
        )
        return true
    }
    
    public func deleteChild(userId: Int, childId: Int) async throws -> Bool {
        let _: BaseResponse = try await performRequest(
            endpoint: "/profile/\(userId)/children/\(childId)",
            method: "DELETE"
        )
        return true
    }
}
