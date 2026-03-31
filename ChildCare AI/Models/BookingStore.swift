import SwiftUI
import Combine

public struct Booking: Identifiable, Codable {
    public let id: String
    public let name: String
    public let type: String
    public let date: Date
    public let time: String
    public let address: String
    public var status: String
    public let providerId: Int?
    
    public init(id: String = UUID().uuidString, name: String, type: String, date: Date, time: String, address: String, status: String = "Confirmed", providerId: Int? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
        self.time = time
        self.address = address
        self.status = status
        self.providerId = providerId
    }
}

public class BookingStore: ObservableObject {
    @Published public var upcomingBookings: [Booking] = []
    @Published public var pastBookings: [Booking] = []
    @Published public var hasNewBooking: Bool = false
    @Published public var isLoading: Bool = false
    
    public init() {}
    
    // Reuse formatters — creating DateFormatter is expensive
    private static let bookingDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    @MainActor
    public func loadBookings(parentId: Int) async {
        isLoading = true
        do {
            let models = try await BookingService.shared.fetchBookings(parentId: parentId)
            let allBookings = models.map { model -> Booking in
                let date = Self.bookingDateFormatter.date(from: model.booking_date) ?? Date()
                return Booking(
                    id: "\(model.id)",
                    name: model.provider_name ?? "Provider #\(model.provider_id)",
                    type: model.provider_type ?? "Service",
                    date: date,
                    time: model.start_time ?? "N/A",
                    address: "Verified Location",
                    status: model.status.capitalized,
                    providerId: model.provider_id
                )
            }

            let today = Calendar.current.startOfDay(for: Date())
            self.upcomingBookings = allBookings.filter {
                let isPastDate = Calendar.current.startOfDay(for: $0.date) < today
                return ($0.status != "Completed" && $0.status != "Cancelled") && !isPastDate
            }
            self.pastBookings = allBookings.filter {
                let isPastDate = Calendar.current.startOfDay(for: $0.date) < today
                return ($0.status == "Completed" || $0.status == "Cancelled") || isPastDate
            }

        } catch {}
        isLoading = false
    }
    
    @MainActor
    public func createBooking(
        parentId: Int,
        providerId: Int,
        childId: Int?,
        date: Date,
        startTime: String,
        amount: Double? = nil,
        parentName: String? = nil,
        parentPhone: String? = nil,
        childAgeOrName: String? = nil,
        notes: String? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        _ = try await BookingService.shared.createBooking(
            parentId: parentId,
            providerId: providerId,
            childId: childId,
            date: dateString,
            startTime: startTime,
            endTime: nil,
            amount: amount,
            parentName: parentName,
            parentPhone: parentPhone,
            childAgeOrName: childAgeOrName,
            notes: notes
        )
        
        // Refresh the list after successful creation
        await loadBookings(parentId: parentId)
        hasNewBooking = true
    }
    
    public func addBooking(_ booking: Booking) {
        upcomingBookings.insert(booking, at: 0)
        hasNewBooking = true
    }
}
