import SwiftUI

public struct BookingFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var childStore: ChildStore
    
    let providerName: String
    let providerType: String
    let isVisit: Bool
    let providerId: Int?
    
    @State private var selectedDate = Date()
    @State private var selectedTime = "09:00 AM"
    @State private var selectedChildId: Int?
    @State private var notes = ""
    @State private var parentName = ""
    @State private var parentPhone = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var bookingError = ""
    
    public init(providerName: String, providerType: String, isVisit: Bool, providerId: Int? = nil) {
        self.providerName = providerName
        self.providerType = providerType
        self.isVisit = isVisit
        self.providerId = providerId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: isVisit ? "Book Visit" : "Book Childcare")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(providerName)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(providerType)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date")
                            .font(.headline)
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accentColor(themeManager.primaryColor)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                    }
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Time")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM"], id: \.self) { time in
                                    Button(action: { selectedTime = time }) {
                                        Text(time)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedTime == time ? .white : AppTheme.textPrimary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(selectedTime == time ? themeManager.primaryColor : AppTheme.surface)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedTime == time ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Child Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Child")
                            .font(.headline)
                        
                        if childStore.children.isEmpty {
                            VStack(spacing: 12) {
                                Text("No children found in your profile.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Button(action: { /* Navigate to add child or show alert */ }) {
                                    Text("Add Child Profile First")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.primaryColor)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(childStore.children) { child in
                                        Button(action: { selectedChildId = child.id }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: "person.circle.fill")
                                                    .font(.system(size: 24))
                                                Text(child.name)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(selectedChildId == child.id ? .white : AppTheme.textPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedChildId == child.id ? themeManager.primaryColor : AppTheme.surface)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedChildId == child.id ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Information")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            FormField(label: "Full Name", text: $parentName)
                            FormField(label: "Phone Number", text: $parentPhone)
                            FormField(label: "Special Requirements / Notes", text: $notes, isLarge: true)
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    PrimaryButton(title: bookingStore.isLoading ? "Confirming..." : "Confirm Booking") {
                        confirmBooking()
                    }
                    .disabled(bookingStore.isLoading)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, AppTheme.padding)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay(
            Group {
                if showingSuccess {
                    SuccessOverlay {
                        dismiss()
                    }
                }
            }
        )
        .alert("Booking Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(bookingError)
        }
        .task {
            if let user = AuthService.shared.currentUser {
                let userId = user.id
                // Set initial name from auth service
                if let fullName = user.full_name, !fullName.isEmpty {
                    self.parentName = fullName
                }
                
                await childStore.loadChildren(parentId: userId)
                if selectedChildId == nil, let firstChild = childStore.children.first {
                    selectedChildId = firstChild.id
                }
                
                // Fetch full profile to get phone and confirm name
                do {
                    let data = try await ProfileService.shared.getProfile(userId: userId)
                    if let name = data["full_name"] as? String, !name.isEmpty {
                        self.parentName = name
                    }
                    if let phone = data["phone"] as? String, !phone.isEmpty {
                        self.parentPhone = phone
                    }
                } catch {
                    // Fallback for phone if not set
                    if parentPhone.isEmpty {
                        parentPhone = "Not set in profile"
                    }
                }
            }
        }
    }
    
    private func confirmBooking() {
        guard let parentId = AuthService.shared.currentUser?.id else {
            return
        }
        
        guard let providerId = providerId else {
            return
        }
        
        Task {
            do {
                try await bookingStore.createBooking(
                    parentId: parentId,
                    providerId: providerId,
                    childId: selectedChildId,
                    date: selectedDate,
                    startTime: selectedTime,
                    amount: Double(1200), // Placeholder or from provider
                    parentName: parentName,
                    parentPhone: parentPhone,
                    notes: notes
                )
                
                DispatchQueue.main.async {
                    withAnimation {
                        showingSuccess = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.bookingError = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    var isLarge: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            if isLarge {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .padding(12)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            } else {
                TextField("", text: $text)
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
}

struct SuccessOverlay: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Booking Request Sent!")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Thank you for your booking! You will receive an email update once the provider accepts your request.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: onDismiss) {
                    Text("Great!")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(themeManager.primaryColor)
                        .cornerRadius(16)
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(32)
            .padding(.horizontal, 40)
        }
    }
}
