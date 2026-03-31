import Foundation

public struct ProfileUpdateData: Encodable {
    public let full_name: String?
    public let center_name: String?
    public let phone: String?
    public let address: String?
    public let bio: String?
    public let website: String?
    public let certifications: String?
    public let years_experience: Int?
    public let opening_time: String?
    public let closing_time: String?
    public let profile_image: String?
    public let date_of_birth: String?
    
    public init(
        full_name: String? = nil,
        center_name: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        bio: String? = nil,
        website: String? = nil,
        certifications: String? = nil,
        years_experience: Int? = nil,
        opening_time: String? = nil,
        closing_time: String? = nil,
        profile_image: String? = nil,
        date_of_birth: String? = nil
    ) {
        self.full_name = full_name
        self.center_name = center_name
        self.phone = phone
        self.address = address
        self.bio = bio
        self.website = website
        self.certifications = certifications
        self.years_experience = years_experience
        self.opening_time = opening_time
        self.closing_time = closing_time
        self.profile_image = profile_image
        self.date_of_birth = date_of_birth
    }
}

public struct Certification: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let file_url: String
    public let created_at: String
}

public struct RemoteUser: Codable, Identifiable {
    public let id: Int
    public let email: String
    public let full_name: String
    public let role: String
}

public class ProfileService: BaseService {
    public static let shared = ProfileService()
    private var serviceURL: String { "\(AuthService.shared.baseURL)/profile" }
    
    private override init() {}
    
    public func getCertifications(userId: Int) async throws -> [Certification] {
        let json = try await performRawRequest(endpoint: "/profile/\(userId)", method: "GET")
        
        guard let certsData = json["certifications_list"] as? [[String: Any]] else {
            return []
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: certsData)
        return try JSONDecoder().decode([Certification].self, from: jsonData)
    }

    public func getProfile(userId: Int) async throws -> [String: Any] {
        return try await performRawRequest(endpoint: "/profile/\(userId)", method: "GET")
    }
    
    public func updateProfile(userId: Int, updateData: ProfileUpdateData) async throws -> Bool {
        let body = try JSONSerialization.jsonObject(with: JSONEncoder().encode(updateData)) as? [String: Any]
        let _: BaseResponse = try await performRequest(endpoint: "/profile/\(userId)", method: "PUT", body: body)
        return true
    }
    
    public func uploadCertification(userId: Int, name: String, fileData: Data, fileName: String) async throws -> Certification? {
        // Multi-part remains custom but we should use the shared session if possible, 
        // however performRequest is tailored for JSON. We'll keep it custom but it's used less often.
        // For now, standardize it to at least check status code properly.
        guard let url = URL(string: "\(serviceURL)/\(userId)/certifications?name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await BaseService.sharedServiceSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let certData = result["certification"] as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: certData),
           let cert = try? decoder.decode(Certification.self, from: jsonData) {
            return cert
        }
        return nil
    }
    
    public func deleteCertification(userId: Int, certId: Int) async throws -> Bool {
        let _: BaseResponse = try await performRequest(endpoint: "/profile/\(userId)/certifications/\(certId)", method: "DELETE")
        return true
    }

    public func fetchUsersByRole(role: String) async throws -> [RemoteUser] {
        return try await performRequest(endpoint: "/profile/users-by-role/\(role)", method: "GET")
    }
    
    public func fetchPendingUsers() async throws -> [RemoteUser] {
        return try await performRequest(
            endpoint: "/profile/pending-users",
            method: "GET"
        )
    }
    
    public func approveUser(userId: Int) async throws -> Bool {
        let _: [String: String] = try await performRequest(
            endpoint: "/profile/approve-user/\(userId)",
            method: "POST"
        )
        return true
    }
    
    public func rejectUser(userId: Int) async throws -> Bool {
        let _: [String: String] = try await performRequest(
            endpoint: "/profile/reject-user/\(userId)",
            method: "POST"
        )
        return true
    }
}
