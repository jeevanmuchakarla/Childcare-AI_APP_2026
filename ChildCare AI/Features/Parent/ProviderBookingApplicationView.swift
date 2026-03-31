import SwiftUI

public struct ProviderBookingApplicationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bookingStore: BookingStore
    
    let providerName: String
    let providerType: String
    let providerId: Int
    let price: Int
    
    @State private var parentName: String = ""
    @State private var parentPhone: String = ""
    @State private var childAge: String = ""
    @State private var preferredStartDate: Date = Date()
    @State private var additionalNotes: String = ""
    
    @State private var showSuccess: Bool = false
    
    @State private var isSubmitting = false
    @State private var submitError: String? = nil
    
    public init(providerName: String, providerType: String, providerId: Int, price: Int) {
        self.providerName = providerName
        self.providerType = providerType
        self.providerId = providerId
        self.price = price
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Book \(providerType)")
            
            if showSuccess {
                VStack(spacing: 24) {
                    Spacer().frame(height: 100)
                    
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 100, height: 100)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                    
                    Text("Application Sent!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Your visit application for **\(providerName)** has been submitted for review. They will contact you shortly.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 32)
                    
                    Spacer().frame(height: 40)
                    
                    PrimaryButton(title: "Done") {
                        dismiss()
                    }
                    .padding(.horizontal, AppTheme.padding)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if let error = submitError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Text("Application for **\(providerName)**")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        VStack(spacing: 16) {
                            formField(title: "Your Full Name", placeholder: "e.g. Sarah Johnson", text: $parentName)
                            formField(title: "Phone Number", placeholder: "e.g. 555-0192", text: $parentPhone, keyboardType: .phonePad)
                            formField(title: "Child's Age/Name", placeholder: "e.g. Leon, 3 years", text: $childAge)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preferred Start Date")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                HStack {
                                    DatePicker("Select Date", selection: $preferredStartDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional Notes (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                TextEditor(text: $additionalNotes)
                                    .frame(minHeight: 100)
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Bottom Submit Action
                VStack {
                    PrimaryButton(title: isSubmitting ? "Submitting..." : "Submit Application") {
                        submitApplication()
                    }
                    .disabled(isSubmitting)
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 34)
                }
                .background(AppTheme.surface.ignoresSafeArea())
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func formField(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private func submitApplication() {
        guard let parentId = AuthService.shared.currentUser?.id else {
            submitError = "You must be logged in."
            return
        }
        
        isSubmitting = true
        submitError = nil
        
        Task {
            do {
                try await bookingStore.createBooking(
                    parentId: parentId,
                    providerId: providerId,
                    childId: nil, // AI flow doesn't pick from list yet
                    date: preferredStartDate,
                    startTime: "09:00 AM", // Default or you could add a picker
                    amount: Double(price),
                    parentName: parentName,
                    parentPhone: parentPhone,
                    childAgeOrName: childAge,
                    notes: additionalNotes
                )
                
                DispatchQueue.main.async {
                    withAnimation {
                        isSubmitting = false
                        showSuccess = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isSubmitting = false
                    submitError = error.localizedDescription
                }
            }
        }
    }
}
