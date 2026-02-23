import Foundation

public enum UserRole: String, CaseIterable, Identifiable {
    case parent = "Parent"
    case preschool = "Preschool"
    case daycare = "Daycare Center"
    case babysitter = "Babysitter"
    case admin = "Admin"
    
    public var id: String { self.rawValue }
    
    public var description: String {
        switch self {
        case .parent: return "Find & Book Childcare"
        case .preschool: return "Manage Early Education"
        case .daycare: return "Manage Daily Operations"
        case .babysitter: return "Offer Personal Care"
        case .admin: return "Platform Administration"
        }
    }
}
