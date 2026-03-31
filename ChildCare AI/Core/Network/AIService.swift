import Foundation

public struct AIRecommendation: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let provider_type: String
    public let rating: Double
    public let distance_km: Double
    public let monthly_price: Int
    public let match_score: Int
    public let experience: String?
    public let address: String?
    public let phone: String?
    public let timing: String?
    public let age_range: String?
    public let latitude: Double?
    public let longitude: Double?
    
    public init(id: Int, name: String, provider_type: String, rating: Double, distance_km: Double, monthly_price: Int, match_score: Int, experience: String? = nil, address: String? = nil, phone: String? = nil, timing: String? = nil, age_range: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.name = name
        self.provider_type = provider_type
        self.rating = rating
        self.distance_km = distance_km
        self.monthly_price = monthly_price
        self.match_score = match_score
        self.experience = experience
        self.address = address
        self.phone = phone
        self.timing = timing
        self.age_range = age_range
        self.latitude = latitude
        self.longitude = longitude
    }
}

public class AIService: BaseService {
    public static let shared = AIService()
    
    private override init() {}
    
    public func fetchRecommendations(
        type: String,
        budget: String,
        location: String?,
        age: String?,
        timing: String?,
        lat: Double? = nil,
        lon: Double? = nil
    ) async throws -> [AIRecommendation] {
        var queryItems = [
            URLQueryItem(name: "provider_type", value: type),
            URLQueryItem(name: "budget", value: budget)
        ]
        
        if let loc = location {
            queryItems.append(URLQueryItem(name: "location", value: loc))
        }
        
        if let age = age {
            queryItems.append(URLQueryItem(name: "age", value: age))
        }
        if let timing = timing {
            queryItems.append(URLQueryItem(name: "timing", value: timing))
        }
        
        return try await performRequest(
            endpoint: "/ai/recommendations",
            method: "GET",
            queryItems: queryItems
        )
    }
}

