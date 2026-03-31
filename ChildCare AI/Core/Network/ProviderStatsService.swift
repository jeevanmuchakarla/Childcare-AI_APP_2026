import Foundation

public struct AIInsightRecord: Codable {
    public let id: Int
    public let title: String
    public let content: String
    public let type: String
}

public struct CenterStatusRecord: Codable {
    public let current_status: String
    public let status_message: String?
}

public struct ScheduleItemRecord: Codable {
    public let id: Int
    public let time: String
    public let activity: String
    public let is_completed: Bool
}

public struct StaffMemberRecord: Codable {
    public let id: Int
    public let name: String
    public let role: String
    public let status: String
}

public struct ProviderSummaryRecord: Codable {
    public let classes_count: Int
    public let capacity: String
    public let staff_ratio: String
    public let parent_status_count: Int
}

public struct EnrolledParentRecord: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let status: String
    public let last_seen: String
}

public class ProviderStatsService: BaseService {
    public static let shared = ProviderStatsService()
    private override init() {}
    
    public func fetchProviderSummary(providerId: Int) async throws -> ProviderSummaryRecord {
        return try await performRequest(endpoint: "/provider-stats/summary/\(providerId)")
    }
    
    public func fetchSummary(providerId: Int) async throws -> ProviderSummaryRecord {
        return try await fetchProviderSummary(providerId: providerId)
    }
    
    public func fetchInsights(providerId: Int) async throws -> [AIInsightRecord] {
        return try await performRequest(endpoint: "/provider-stats/insights/\(providerId)")
    }
    
    public func fetchCenterStatus(providerId: Int) async throws -> CenterStatusRecord {
        return try await performRequest(endpoint: "/provider-stats/status/\(providerId)")
    }
    
    public func updateCenterStatus(providerId: Int, status: String, message: String?) async throws -> CenterStatusRecord {
        var body: [String: Any] = ["current_status": status]
        if let msg = message { body["status_message"] = msg }
        return try await performRequest(endpoint: "/provider-stats/status/\(providerId)", method: "PATCH", body: body)
    }
    
    public func fetchSchedule(providerId: Int) async throws -> [ScheduleItemRecord] {
        return try await performRequest(endpoint: "/provider-stats/schedule/\(providerId)")
    }
    
    public func fetchStaff(providerId: Int) async throws -> [StaffMemberRecord] {
        return try await performRequest(endpoint: "/provider-stats/staff/\(providerId)")
    }
    
    public func updateStaffStatus(staffId: Int, status: String) async throws -> StaffMemberRecord {
        return try await performRequest(endpoint: "/provider-stats/staff/\(staffId)?status=\(status)", method: "PATCH")
    }
    
    public func fetchEnrolledParents(providerId: Int) async throws -> [EnrolledParentRecord] {
        return try await performRequest(endpoint: "/provider-stats/enrolled-parents/\(providerId)")
    }
}
