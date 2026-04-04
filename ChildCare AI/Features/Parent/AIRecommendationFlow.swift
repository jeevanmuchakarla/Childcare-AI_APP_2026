import SwiftUI

enum AIRecommendationStep: Int, CaseIterable {
    case type = 1
    case age = 2
    case budget = 3
    case location = 4
    case timing = 5
    case ratings = 6
    case results = 7
}



public struct AIRecommendationFlow: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep: AIRecommendationStep = .type
    
    // State variables
    @State private var selectedType = ""
    @State private var selectedAge = "1-2 years"
    @State private var selectedBudget = "Standard"
    @State private var selectedLocation = "Anywhere in Chennai"
    @State private var dropoffTime = "08:00 AM"
    @State private var pickupTime = "05:00 PM"
    @State private var selectedRating = 4
    
    @State private var showingInlineDropoff = false
    @State private var showingInlinePickup = false
    @State private var tempDropoffDate = Date()
    @State private var tempPickupDate = Date()
    
    @State private var isAnalyzing = false
    @State private var recommendations: [AIRecommendation] = []
    @State private var errorMessage: String? = nil

    // AI Consent
    @StateObject private var consentManager = AIConsentManager.shared
    @State private var showConsentSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if currentStep != .results && !isAnalyzing {
                    // Progress Bar Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Button(action: {
                                if currentStep.rawValue > 1 {
                                    withAnimation {
                                        currentStep = AIRecommendationStep(rawValue: currentStep.rawValue - 1) ?? .type
                                    }
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundColor(themeManager.primaryColor)
                            }
                            
                            Spacer()
                            
                            Text("Step \(currentStep.rawValue) of 6")
                                .font(.headline)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                            
                            // Invisible spacer for balance
                            Image(systemName: "chevron.left")
                                .opacity(0)
                        }
                        
                        // Progress Bar Indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(themeManager.primaryColor)
                                    .frame(width: geometry.size.width * CGFloat(currentStep.rawValue) / 6.0, height: 8)
                                    .cornerRadius(4)
                                    .animation(.easeInOut, value: currentStep.rawValue)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        if isAnalyzing {
                            AnalyzingView()
                        } else {
                            switch currentStep {
                            case .type: typeSelectionView
                            case .age: ageSelectionView
                            case .budget: budgetSelectionView
                            case .location: locationSelectionView
                            case .timing: timingSelectionView
                            case .ratings: ratingsSelectionView
                            case .results: resultsView
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 40)
                }
                
                if currentStep != .results && !isAnalyzing {
                    VStack(spacing: 16) {
                        PrimaryButton(title: currentStep == .ratings ? "Find Matches" : "Continue") {
                            if currentStep == .ratings {
                                if consentManager.hasConsent {
                                    Task { await startAnalysis() }
                                } else {
                                    showConsentSheet = true
                                }
                            } else {
                                withAnimation {
                                    currentStep = AIRecommendationStep(rawValue: currentStep.rawValue + 1) ?? .results
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 20)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showConsentSheet) {
                AIConsentPopupView(
                    onAllow: {
                        showConsentSheet = false
                        consentManager.grantConsent()
                        Task { await startAnalysis() }
                    },
                    onDeny: {
                        showConsentSheet = false
                    }
                )
                .environmentObject(themeManager)
            }
        }
    }
    
    @MainActor
    private func startAnalysis() async {
        isAnalyzing = true
        errorMessage = nil
        recommendations = []
        
        let typeVal = selectedType.isEmpty ? "Preschool" : selectedType
        let timingVal = "\(dropoffTime)-\(pickupTime)"
        do {
            let results = try await AIService.shared.fetchRecommendations(
                type: typeVal,
                budget: selectedBudget,
                location: selectedLocation == "Anywhere in Chennai" ? nil : selectedLocation,
                age: selectedAge,
                timing: timingVal
            )
            
            if !results.isEmpty {
                self.recommendations = results
                self.isAnalyzing = false
                withAnimation {
                    self.currentStep = .results
                }
            } else {
                self.errorMessage = "No recommendations found. Try adjusting your preferences."
                self.isAnalyzing = false
            }
        } catch {
            self.errorMessage = "Failed to fetch AI recommendations: \(error.localizedDescription)"
            self.isAnalyzing = false
        }
    }
    
    
    private func useMockData() {
        let typeVal = selectedType.isEmpty ? "Preschools" : selectedType
        
        let mockData: [AIRecommendation]
        if typeVal.contains("Daycare") {
            mockData = [
                AIRecommendation(id: 1, name: "Happy Tots Daycare Center", provider_type: "Daycare", rating: 4.9, distance_km: 1.2, monthly_price: 850, match_score: 98, experience: "10 years", address: "123 Main St, Chennai", phone: "9840123456", timing: "08:00 AM-05:00 PM", age_range: "1-5", latitude: 13.0405, longitude: 80.2337),
                AIRecommendation(id: 2, name: "Safe Haven Childcare", provider_type: "Daycare", rating: 4.7, distance_km: 3.1, monthly_price: 700, match_score: 92, experience: "8 years", address: "456 Side Rd, Chennai", phone: "9840654321", timing: "07:30 AM-06:00 PM", age_range: "1-6", latitude: 13.0489, longitude: 80.1114),
            ]
        } else {
            mockData = [
                AIRecommendation(id: 3, name: "Bright Futures Preschool", provider_type: "Preschool", rating: 4.9, distance_km: 1.2, monthly_price: 1200, match_score: 98, experience: "12 years", address: "321 Education St, Chennai", phone: "9840111222", timing: "09:00 AM-03:00 PM", age_range: "2-5", latitude: 13.0405, longitude: 80.2337),
                AIRecommendation(id: 4, name: "Little Learners Prep", provider_type: "Preschool", rating: 4.7, distance_km: 2.5, monthly_price: 950, match_score: 92, experience: "7 years", address: "654 School Ln, Chennai", phone: "9840333444", timing: "08:30 AM-01:30 PM", age_range: "3-5", latitude: 13.0850, longitude: 80.2189),
            ]
        }
        
        self.recommendations = mockData
        self.isAnalyzing = false
        self.currentStep = .results
    }
    
    // MARK: - Step Views
    
    
    private var typeSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // App Description Txt Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(themeManager.primaryColor)
                        .font(.headline)
                    Text("About ChildCare AI")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Text("ChildCare AI leverages advanced algorithms to match your family with the highest-rated preschools and daycares. Our platform simplifies the search process, providing real-time data and personalized recommendations centered on your child's developmental needs and your family's preferences.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    Label("Verified Providers", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.primaryColor)
                    
                    Label("Real-time Data", systemImage: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(themeManager.primaryColor.opacity(0.05))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(themeManager.primaryColor.opacity(0.1), lineWidth: 1)
            )
            .padding(.bottom, 8)

            HeaderView(title: "What type of care are you looking for?")
            
            VStack(spacing: 20) {
                SelectionCard(title: "Preschools", sub: "Early education focus", icon: "book.fill", isSelected: selectedType == "Preschools") { 
                    withAnimation(.spring()) {
                        selectedType = "Preschools"
                    }
                }
                SelectionCard(title: "Daycares", sub: "Structured daily care", icon: "building.2.fill", isSelected: selectedType == "Daycares") { 
                    withAnimation(.spring()) {
                        selectedType = "Daycares"
                    }
                }
            }
        }
        .padding(.top, 30)
    }
    
    private var ageSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "How old is your child?")
            
            let ages = ["Infant (0-12m)", "Toddler (1-2y)", "Preschooler (3-4y)", "Pre-K (4-5y)", "Explorer (5-6y)", "Student (6y+)"]
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(ages, id: \.self) { age in
                    Button(action: { 
                        withAnimation(.spring()) {
                            selectedAge = age 
                        }
                    }) {
                        Text(age)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedAge == age ? .white : AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(selectedAge == age ? themeManager.primaryColor : AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: selectedAge == age ? themeManager.primaryColor.opacity(0.3) : Color.black.opacity(0.05), radius: 10, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedAge == age ? Color.white.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(.top, 30)
    }
    
    private var budgetSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "What's your budget?")
            
            VStack(spacing: 16) {
                SegmentedSelectionCard(
                    title: "Budget Friendly",
                    description: "Basic quality care options",
                    priceText: "$500 - $800 / mo",
                    isSelected: selectedBudget == "Budget Friendly"
                ) { selectedBudget = "Budget Friendly" }
                
                SegmentedSelectionCard(
                    title: "Standard",
                    description: "Balanced quality and value",
                    priceText: "$800 - $1200 / mo",
                    isSelected: selectedBudget == "Standard"
                ) { selectedBudget = "Standard" }
                
                SegmentedSelectionCard(
                    title: "Premium",
                    description: "Top-tier facilities and programs",
                    priceText: "$1200+ / mo",
                    isSelected: selectedBudget == "Premium"
                ) { selectedBudget = "Premium" }
            }
        }
        .padding(.top, 30)
    }
    
    private var locationSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Preferred location?")
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    let locations = ["Anywhere in Chennai", "Anna Nagar", "T Nagar", "Adyar", "Velachery", "Porur", "Tambaram", "Sholinganallur", "Medavakkam", "OMR"]
                    
                    ForEach(locations, id: \.self) { location in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedLocation = location
                            }
                        }) {
                            HStack {
                                Text(location)
                                    .font(.headline)
                                    .foregroundColor(selectedLocation == location ? .white : AppTheme.textPrimary)
                                Spacer()
                                if selectedLocation == location {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(selectedLocation == location ? themeManager.primaryColor : AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedLocation == location ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.top, 30)
    }
    
    private var timingSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Timing preference?")
            
            VStack(spacing: 24) {
                // Drop-off
                VStack(alignment: .leading, spacing: 12) {
                    Text("Drop-off Time")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Button(action: { 
                        withAnimation { 
                            showingInlineDropoff.toggle()
                            showingInlinePickup = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.primaryColor)
                            Text(dropoffTime)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(showingInlineDropoff ? 180 : 0))
                        }
                        .padding(20)
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    }
                    
                    if showingInlineDropoff {
                        DatePicker("", selection: $tempDropoffDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .onChange(of: tempDropoffDate) { oldValue, newValue in
                                dropoffTime = newValue.formatted(date: .omitted, time: .shortened)
                            }
                    }
                }
                
                // Pick-up
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pick-up Time")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Button(action: { 
                        withAnimation { 
                            showingInlinePickup.toggle()
                            showingInlineDropoff = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.primaryColor)
                            Text(pickupTime)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(showingInlinePickup ? 180 : 0))
                        }
                        .padding(20)
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    }
                    
                    if showingInlinePickup {
                        DatePicker("", selection: $tempPickupDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .onChange(of: tempPickupDate) { oldValue, newValue in
                                pickupTime = newValue.formatted(date: .omitted, time: .shortened)
                            }
                    }
                }
            }
        }
    }
    private var ratingsSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Minimum Rating?")
            
            VStack(spacing: 30) {
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                selectedRating = star
                            }
                        }) {
                            Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(star <= selectedRating ? .yellow : Color.gray.opacity(0.3))
                                .scaleEffect(star <= selectedRating ? 1.1 : 1.0)
                        }
                    }
                }
                .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("\(selectedRating) Stars & Above")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(ratingDescription(for: selectedRating))
                        .font(.subheadline)
                        .foregroundColor(themeManager.primaryColor)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(themeManager.primaryColor.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 30)
    }
    
    private func ratingDescription(for rating: Int) -> String {
        switch rating {
        case 1: return "All Verified Providers"
        case 2: return "Consistent Quality"
        case 3: return "High Quality Standards"
        case 4: return "Top Tier Experience"
        case 5: return "Premium Excellence Only"
        default: return ""
        }
    }
    
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header Top Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("AI Recommendations")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.top, 20)
            
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if recommendations.isEmpty {
                Text("No recommendations found.")
                    .foregroundColor(AppTheme.textSecondary)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedType.isEmpty ? "Top Matches" : "Best \(selectedType)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("AI-optimized matches for your family")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                ForEach(recommendations) { rec in
                    // Result Card with Deep Navigation
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink(destination: AIRecommendationDetailView(recommendation: rec)) {
                            VStack(alignment: .leading, spacing: 0) {
                                // Image Placeholder
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 140)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray.opacity(0.3))
                                        )
                                    
                                    HStack {
                                        ZStack {
                                            Capsule()
                                                .fill(themeManager.primaryColor.opacity(0.9))
                                            Text("\(rec.match_score)% Match")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 90, height: 28)
                                        .padding(8)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "heart")
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(Circle().fill(Color.black.opacity(0.2)))
                                            .padding(8)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(rec.name)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.textPrimary)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text(String(format: "%.1f", rec.rating))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                    }
                                    
                                    HStack(spacing: 16) {
                                        Label("\(String(format: "%.1f", rec.distance_km)) km", systemImage: "location")
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        Label("$\(rec.monthly_price)/mo", systemImage: "dollarsign.circle")
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .padding(16)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Action Buttons Footer
                        HStack(spacing: 12) {
                            Button(action: {
                                if let phone = rec.phone, !phone.isEmpty {
                                    let cleanedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                                    if let url = URL(string: "tel://\(cleanedPhone)") {
                                        if UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url)
                                        } else {
                                            print("Error: Cannot open tel URL for \(cleanedPhone)")
                                        }
                                    }
                                }
                            }) {
                                Text("Call")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(themeManager.primaryColor.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .buttonStyle(BounceButtonStyle())
                            
                            Button(action: {
                                if let lat = rec.latitude, let lon = rec.longitude {
                                    // Use exact coordinates
                                    let urlString = "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(rec.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                                    if let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } else if let address = rec.address, let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                    // Fallback to address search
                                    let appleMapsURL = URL(string: "http://maps.apple.com/?q=\(encodedAddress)")!
                                    UIApplication.shared.open(appleMapsURL)
                                }
                            }) {
                                Text("Go")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(themeManager.primaryColor)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(BounceButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
}

// MARK: - Helper Views

struct HeaderView: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(AppTheme.textPrimary)
    }
}

struct SelectionCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let sub: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? themeManager.primaryColor : themeManager.primaryColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(isSelected ? .white : themeManager.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(isSelected ? themeManager.primaryColor : AppTheme.textPrimary)
                    Text(sub)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(themeManager.primaryColor)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
            .background(AppTheme.surface)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? themeManager.primaryColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? themeManager.primaryColor.opacity(0.1) : Color.black.opacity(0.05), radius: 15, y: 5)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

struct AnalyzingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer().frame(height: 80)
            
            ZStack {
                // Outer Pulsing Circle
                Circle()
                    .stroke(themeManager.primaryColor.opacity(0.1), lineWidth: 20)
                    .frame(width: 160, height: 160)
                    .scaleEffect(scale)
                
                // Rotating Progress
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(themeManager.primaryColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                
                // Brain Icon with pulse
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(themeManager.primaryColor)
                    .scaleEffect(scale)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
            
            VStack(spacing: 16) {
                Text("Analyzing Profiles...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Matching your requirements against\nverified providers in your area.")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct AIFormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isLarge: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            if isLarge {
                TextEditor(text: $text)
                    .frame(height: 80)
                    .padding(12)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
            }
        }
    }
}
