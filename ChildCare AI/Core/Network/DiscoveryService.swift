import Foundation
import Combine

public struct ProviderModel: Identifiable, Decodable {
    public let id: Int
    public let name: String
    public let type: String
    public let rating: Double
    public let reviewCount: Int
    public let address: String?
    public let price: String?
    public let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case name = "center_name"
        case fullName = "full_name"
        case type
        case rating
        case reviewCount = "review_count"
        case address
        case hourlyRate = "hourly_rate"
        case price = "monthly_price"
        case bio
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Handle Center (center_name)
        if let cName = try? container.decode(String.self, forKey: .name) {
            name = cName
        } else {
            name = "Unknown Center"
        }
        
        type = try container.decode(String.self, forKey: .type)
        rating = (try? container.decode(Double.self, forKey: .rating)) ?? 0.0
        reviewCount = (try? container.decode(Int.self, forKey: .reviewCount)) ?? 0
        address = try? container.decode(String.self, forKey: .address)
        
        // Handle price/rate
        if let hRate = try? container.decode(String.self, forKey: .hourlyRate) {
            price = hRate
        } else if let mPrice = try? container.decode(String.self, forKey: .price) {
            price = mPrice
        } else {
            price = nil
        }
        
        bio = try? container.decode(String.self, forKey: .bio)
    }
}

public class DiscoveryService: BaseService {
    public static let shared = DiscoveryService()
    
    public func fetchProviders(role: String? = nil) async throws -> [ProviderModel] {
        var queryItems = [URLQueryItem]()
        if let role = role {
            queryItems.append(URLQueryItem(name: "role", value: role))
        }
        
        let response: [String: [ProviderModel]] = try await performRequest(
            endpoint: "/providers/",
            method: "GET",
            queryItems: queryItems
        )
        
        return response["providers"] ?? []
    }
    
    public func fetchCounts() async throws -> [String: Int] {
        return try await performRequest(
            endpoint: "/providers/counts",
            method: "GET"
        )
    }
}
