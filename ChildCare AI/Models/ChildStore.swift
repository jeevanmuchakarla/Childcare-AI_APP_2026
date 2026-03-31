import SwiftUI
import Combine

public struct Child: Identifiable, Codable {
    public let id: Int
    public let parentId: Int
    public let name: String
    public let age: String
    public let allergies: String?
    public let medicalNotes: String?
    public let emergencyContact: String?
    
    public init(id: Int, parentId: Int, name: String, age: String, allergies: String? = nil, medicalNotes: String? = nil, emergencyContact: String? = nil) {
        self.id = id
        self.parentId = parentId
        self.name = name
        self.age = age
        self.allergies = allergies
        self.medicalNotes = medicalNotes
        self.emergencyContact = emergencyContact
    }
}

public class ChildStore: ObservableObject {
    @Published public var children: [Child] = []
    @Published public var isLoading: Bool = false
    
    public init() {}
    
    @MainActor
    public func loadChildren(parentId: Int) async {
        isLoading = true
        do {
            let models = try await ChildService.shared.fetchChildren(parentId: parentId)
            self.children = models.map { Child(id: $0.id, parentId: $0.parent_id, name: $0.name, age: $0.age ?? "", allergies: $0.allergies, medicalNotes: $0.medical_notes, emergencyContact: $0.emergency_contact) }
        } catch {
        }
        isLoading = false
    }
    
    @MainActor
    public func addChild(parentId: Int, name: String, age: String) async {
        // Optimistic Update: Add to local list immediately with a temporary ID
        let tempChild = Child(id: Int.random(in: 1000...9999), parentId: parentId, name: name, age: age)
        self.children.append(tempChild)
        
        do {
            let model = try await ChildService.shared.addChild(parentId: parentId, name: name, age: age)
            // Replace temp child with real one from backend
            if let index = self.children.firstIndex(where: { $0.id == tempChild.id }) {
                self.children[index] = Child(id: model.id, parentId: model.parent_id, name: model.name, age: model.age ?? "", allergies: model.allergies, medicalNotes: model.medical_notes, emergencyContact: model.emergency_contact)
            }
        } catch {
            // Rollback on error
            self.children.removeAll(where: { $0.id == tempChild.id })
        }
    }
    
    @MainActor
    public func updateChild(userId: Int, childId: Int, name: String, age: String, allergies: String?, medicalNotes: String?, emergencyContact: String?) async {
        do {
            let success = try await ChildService.shared.updateChild(
                userId: userId,
                childId: childId,
                name: name,
                age: age,
                allergies: allergies,
                medicalNotes: medicalNotes,
                emergencyContact: emergencyContact
            )
            if success {
                if let index = self.children.firstIndex(where: { $0.id == childId }) {
                    self.children[index] = Child(id: childId, parentId: userId, name: name, age: age)
                }
            }
        } catch {
        }
    }
    
    @MainActor
    public func deleteChild(userId: Int, childId: Int) async {
        do {
            let success = try await ChildService.shared.deleteChild(userId: userId, childId: childId)
            if success {
                self.children.removeAll(where: { $0.id == childId })
            }
        } catch {
        }
    }
}
