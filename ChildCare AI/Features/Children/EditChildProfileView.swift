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
    
    // Age Picker state
    @State private var showingAgePicker = false
    let ageOptions = ["0-1 year", "1-2 years", "2-3 years", "3-4 years", "4-5 years", "5-6 years", "6-7 years", "7-8 years", "8-9 years", "9-10 years", "10-11 years", "11-12 years", "12+ years"]
    
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
                    
                    Button(action: { showingAgePicker = true }) {
                        HStack {
                            Text("Age / Group")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text(ageGroup.isEmpty ? "Select Age" : ageGroup)
                                .foregroundColor(ageGroup.isEmpty ? .gray : .blue)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
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
            .sheet(isPresented: $showingAgePicker) {
                AgePickerSheet(title: "Select Child's Age", selection: $ageGroup, options: ageOptions) {
                    showingAgePicker = false
                }
            }
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

// Since we already have AgePickerSheet in CreateAccountView, 
// if they are in different modules we might need a shared one.
// But for now, we'll keep it simple or check if it's already available.
// I'll add a duplicate here to avoid link errors if the files are compiled separately.
struct AgePickerSheet: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            Picker(title, selection: $selection) {
                if selection.isEmpty {
                    Text("Select Age").tag("")
                }
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Button(action: onDone) {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.height(350)])
        .onAppear {
            if selection.isEmpty {
                selection = options[0]
            }
        }
    }
}
