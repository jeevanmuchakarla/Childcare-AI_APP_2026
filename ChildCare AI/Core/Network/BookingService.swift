import Foundation

public struct BookingModel: Codable, Identifiable {
    public let id: Int
    public let parent_id: Int
    public let provider_id: Int
    public let child_id: Int?
    public let status: String
    public let booking_date: String
    public let start_time: String?
    public let end_time: String?
    public let total_amount: Double?
    public let provider_name: String?
    public let provider_type: String?
    public let child_name: String?
}

public class BookingService: BaseService {
    public static let shared = BookingService()
    
    public func fetchBookings(parentId: Int) async throws -> [BookingModel] {
        return try await performRequest(endpoint: "/bookings/parent/\(parentId)")
    }
    
    public func fetchProviderBookings(providerId: Int) async throws -> [BookingModel] {
        return try await performRequest(endpoint: "/bookings/provider/\(providerId)")
    }
    
    struct BookingResponse: Decodable {
        let message: String
        let booking: BookingModel
    }

    public func createBooking(
        parentId: Int,
        providerId: Int,
        childId: Int?,
        date: String,
        startTime: String,
        endTime: String?,
        amount: Double?,
        parentName: String? = nil,
        parentPhone: String? = nil,
        childAgeOrName: String? = nil,
        notes: String? = nil
    ) async throws -> BookingModel {
        let payload: [String: Any?] = [
            "parent_id": parentId,
            "provider_id": providerId,
            "child_id": childId,
            "booking_date": date,
            "start_time": startTime,
            "end_time": endTime,
            "total_amount": amount,
            "parent_name": parentName,
            "parent_phone": parentPhone,
            "child_age_or_name": childAgeOrName,
            "notes": notes
        ]
        
        let bodyPayload = payload.compactMapValues { $0 }
        
        let response: BookingResponse = try await performRequest(
            endpoint: "/bookings/",
            method: "POST",
            body: bodyPayload
        )
        
        return response.booking
    }
    
    public func fetchProviderChildren(providerId: Int) async throws -> [ChildModel] {
        return try await performRequest(endpoint: "/bookings/provider/\(providerId)/children")
    }
}
