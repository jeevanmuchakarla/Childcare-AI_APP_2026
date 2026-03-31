import SwiftUI
import PhotosUI

public struct EditChildProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var childName: String
    @State private var ageGroup: String
    @State private var medicalNotes: String
    @State private var foodAllergies: String
    @State private var emergencyContact: String
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var childStore: ChildStore
    let childId: Int

    public init(childId: Int, name: String, age: String, medicalNotes: String? = nil, foodAllergies: String? = nil, emergencyContact: String? = nil) {
        self.childId = childId
        _childName = State(initialValue: name)
        _ageGroup = State(initialValue: age)
        _medicalNotes = State(initialValue: medicalNotes ?? "")
        _foodAllergies = State(initialValue: foodAllergies ?? "")
        _emergencyContact = State(initialValue: emergencyContact ?? "")
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Child Name", text: $childName)
                    TextField("Age / Group", text: $ageGroup)
                }
                
                Section(header: Text("Medical & Emergency")) {
                    TextField("Food Allergies", text: $foodAllergies)
                    TextField("Medical Notes", text: $medicalNotes)
                    TextField("Emergency Contact", text: $emergencyContact)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveChanges) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save").fontWeight(.bold)
                        }
                    }
                    .disabled(isSaving || childName.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await ChildService.shared.updateChild(
                    userId: userId,
                    childId: childId,
                    name: childName,
                    age: ageGroup,
                    allergies: foodAllergies,
                    medicalNotes: medicalNotes,
                    emergencyContact: emergencyContact
                )
                
                // Refresh child store
                await childStore.loadChildren(parentId: userId)
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to update profile. Please try again."
                }
            }
        }
    }
}
