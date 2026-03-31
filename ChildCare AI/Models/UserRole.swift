import Foundation

public enum UserRole: String, Codable, CaseIterable, Identifiable {
    case parent = "Parent"
    case preschool = "Preschool"
    case daycare = "Daycare"
    case admin = "Admin"
    
    public var id: String { self.rawValue }
    
    public var description: String {
        switch self {
        case .parent: return "Find & Book Childcare"
        case .preschool: return "Early Childhood Education"
        case .daycare: return "Professional Daycare Center"
        case .admin: return "Platform Administration"
        }
    }
}
