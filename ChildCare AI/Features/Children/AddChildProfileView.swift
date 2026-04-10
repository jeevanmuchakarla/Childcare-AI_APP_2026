import SwiftUI

public struct AddChildProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var fullName = ""
    @State private var dateOfBirth = ""
    @State private var selectedDateOfBirth = Date()
    @State private var gender = "Male"
    @State private var healthStatus = "Healthy"
    @State private var foodAllergies = ""
    @State private var interests = ""
    @State private var medicalNotes = ""
    @EnvironmentObject var childStore: ChildStore
    @State private var isSaving = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Add Child Profile")
            
            ScrollView {
                VStack(spacing: 32) {
                    // Upload Photo
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(width: 120, height: 120)
                            Image(systemName: "camera")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        Button("Upload Photo") { }
                            .font(.subheadline)
                            .foregroundColor(themeManager.primaryColor)
                    }
                    .padding(.top)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            TextField("Child's Name", text: $fullName)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of Birth")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            HStack {
                                DatePicker("Select Date", selection: $selectedDateOfBirth, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 8)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                GenderButton(title: "Male", isSelected: gender == "Male") { gender = "Male" }
                                GenderButton(title: "Female", isSelected: gender == "Female") { gender = "Female" }
                                GenderButton(title: "Other", isSelected: gender == "Other") { gender = "Other" }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Health Status")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                GenderButton(title: "Healthy", isSelected: healthStatus == "Healthy") { healthStatus = "Healthy" }
                                GenderButton(title: "Needs Attention", isSelected: healthStatus == "Needs Attention") { healthStatus = "Needs Attention" }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Food Allergies")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            TextField("e.g. Peanuts, Dairy (or None)", text: $foodAllergies)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Interests / Hobbies")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            TextField("e.g. Dinosaurs, Painting", text: $interests)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Behavioral/Medical Notes")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $medicalNotes)
                                    .frame(height: 120)
                                    .padding(8)
                                if medicalNotes.isEmpty {
                                    Text("List any allergies or special needs...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }
                            }
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                        }
                    }
                }
                .padding(24)
            }
            
            // Save Button
            Button(action: {
                guard !fullName.isEmpty else { return }
                if let userId = AuthService.shared.currentUser?.id {
                    // Task handles adding the child in the background
                    Task {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        let dobString = formatter.string(from: selectedDateOfBirth)
                        await childStore.addChild(parentId: userId, name: fullName, age: dobString)
                    }
                    dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Profile")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(fullName.isEmpty ? Color.gray : themeManager.primaryColor)
                .cornerRadius(16)
                .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(fullName.isEmpty || isSaving)
            .padding(24)
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
    }
}

struct GenderButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(isSelected ? themeManager.primaryColor : AppTheme.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? themeManager.primaryColor : Color.gray.opacity(0.1)))
        }
    }
}
