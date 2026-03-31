import Foundation

public struct PlatformStats: Codable {
    public let users: UserStats
    public let bookings: BookingSummary
    public let revenue: RevenueStats
    public let metrics: MetricSummary
    
    public struct UserStats: Codable {
        public let total: Int
        public let parents: Int
        public let centers: Int
    }
    
    public struct BookingSummary: Codable {
        public let total: Int
        public let confirmed: Int
        public let live_today: Int
    }
    
    public struct RevenueStats: Codable {
        public let total_usd: Double
    }
    
    public struct MetricSummary: Codable {
        public let active_capacity: String
        public let match_success: String
        public let pending_verification: Int
    }
}

public struct CapacityStats: Codable {
    public let total_capacity: Int
    public let occupied_seats: Int
    public let availability_percentage: String
    public let trend: String
}

public struct AdminLiveBooking: Codable, Identifiable {
    public let id: Int
    public let child_name: String
    public let center_name: String
    public let time: String?
    public let booking_date: String?
    public let status: String
}

public struct PendingProvider: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let type: String
    public let status: String
}

public struct AdminUser: Codable, Identifiable {
    public let id: Int
    public let email: String
    public let role: String
    public let created_at: String?
    public let is_approved: Bool?
}

public struct AdminUserDetails: Codable {
    public let id: Int
    public let email: String
    public let role: String
    public let is_approved: Bool
    public let created_at: String
    // Parent fields
    public let full_name: String?
    public let phone: String?
    public let bio: String?
    // Center fields
    public let center_name: String?
    public let contact_person: String?
    public let license_number: String?
    public let capacity: String?
    public let address: String?
    public let opening_time: String?
    public let closing_time: String?
    public let certifications: String?
    public let years_experience: Int?
    public let rating: Double?
}

public class AdminService: BaseService {
    public static let shared = AdminService()
    
    public func fetchStats() async throws -> PlatformStats {
        return try await performRequest(endpoint: "/admin/stats")
    }
    
    public func fetchPendingProviders() async throws -> [PendingProvider] {
        return try await performRequest(endpoint: "/admin/providers/pending")
    }
    
    public func approveProvider(providerId: Int) async throws -> Bool {
        let _: [String: String] = try await performRequest(
            endpoint: "/admin/users/\(providerId)/approve",
            method: "POST"
        )
        return true
    }
    
    public func rejectProvider(providerId: Int) async throws -> Bool {
        let _: [String: String] = try await performRequest(
            endpoint: "/admin/users/\(providerId)/reject",
            method: "PUT"
        )
        return true
    }
    
    public func fetchAllUsers() async throws -> [AdminUser] {
        return try await performRequest(endpoint: "/admin/users")
    }
    
    public func fetchUserDetails(userId: Int) async throws -> AdminUserDetails {
        return try await performRequest(endpoint: "/admin/users/\(userId)/details")
    }
    
    public func approveUser(userId: Int) async throws -> Bool {
        let _: [String: String] = try await performRequest(
            endpoint: "/admin/users/\(userId)/approve",
            method: "POST"
        )
        return true
    }
    
    public func fetchCapacityMetrics() async throws -> CapacityStats {
        return try await performRequest(endpoint: "/admin/metrics/capacity")
    }
    
    public func fetchLiveBookings() async throws -> [AdminLiveBooking] {
        return try await performRequest(endpoint: "/admin/metrics/live-bookings")
    }
    
    public func fetchAllBookings() async throws -> [AdminLiveBooking] {
        return try await performRequest(endpoint: "/admin/bookings")
    }
}
