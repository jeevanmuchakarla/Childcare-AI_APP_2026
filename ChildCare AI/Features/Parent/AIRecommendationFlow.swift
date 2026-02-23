import SwiftUI

enum AIRecommendationStep: Int, CaseIterable {
    case type = 1
    case age = 2
    case budget = 3
    case distance = 4
    case timing = 5
    case ratings = 6
    case results = 7
    case booking = 8
}

public struct AIRecommendationFlow: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep: AIRecommendationStep = .type
    
    // State variables
    @State private var selectedType = ""
    @State private var selectedAge = "1-2 years"
    @State private var selectedBudget = "Standard"
    @State private var distanceValue: Double = 5.0
    @State private var dropoffTime = "08:00 AM"
    @State private var pickupTime = "05:00 PM"
    @State private var selectedRating = 4
    
    @State private var isAnalyzing = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if currentStep != .results && currentStep != .booking && !isAnalyzing {
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
                                    .foregroundColor(AppTheme.primary)
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
                                    .fill(AppTheme.primary)
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
                            case .distance: distanceSelectionView
                            case .timing: timingSelectionView
                            case .ratings: ratingsSelectionView
                            case .results: resultsView
                            case .booking: bookingConfirmationView
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 40)
                }
                
                if currentStep != .results && currentStep != .booking && !isAnalyzing {
                    VStack(spacing: 16) {
                        PrimaryButton(title: currentStep == .ratings ? "Find Matches" : "Continue") {
                            withAnimation {
                                if currentStep == .ratings {
                                    startAnalysis()
                                } else {
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
        }
    }
    
    private func startAnalysis() {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                isAnalyzing = false
                currentStep = .results
            }
        }
    }
    
    // MARK: - Step Views
    
    private var typeSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "What type of care are you looking for?")
            
            VStack(spacing: 16) {
                SelectionCard(title: "Preschool", sub: "Early education focus", icon: "book.fill", isSelected: selectedType == "Preschool") { selectedType = "Preschool" }
                SelectionCard(title: "Daycare Center", sub: "Structured daily care", icon: "building.2.fill", isSelected: selectedType == "Daycare Center") { selectedType = "Daycare Center" }
                SelectionCard(title: "Babysitter", sub: "Flexible, personal care", icon: "person.2.fill", isSelected: selectedType == "Babysitter") { selectedType = "Babysitter" }
            }
        }
        .padding(.top, 30)
    }
    
    private var ageSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "How old is your child?")
            
            let ages = ["0-12 months", "1-2 years", "2-3 years", "3-4 years", "4-5 years", "5+ years"]
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ages, id: \.self) { age in
                    Button(action: { selectedAge = age }) {
                        Text(age)
                            .font(.body)
                            .fontWeight(selectedAge == age ? .bold : .medium)
                            .foregroundColor(selectedAge == age ? AppTheme.primary : AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedAge == age ? AppTheme.primary : Color.gray.opacity(0.2), lineWidth: selectedAge == age ? 2 : 1)
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
    
    private var distanceSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Preferred distance?")
            
            VStack(spacing: 40) {
                Text("\(Int(distanceValue)) km")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                
                Slider(value: $distanceValue, in: 1...20, step: 1)
                    .accentColor(AppTheme.primary)
                
                HStack {
                    Text("1 km")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("20 km")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, 40)
        }
        .padding(.top, 30)
    }
    
    private var timingSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Timing preference?")
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drop-off Time")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppTheme.textSecondary)
                        Text(dropoffTime)
                            .foregroundColor(AppTheme.textPrimary)
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
                    Text("Pick-up Time")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppTheme.textSecondary)
                        Text(pickupTime)
                            .foregroundColor(AppTheme.textPrimary)
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
            }
        }
        .padding(.top, 30)
    }
    
    private var ratingsSelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeaderView(title: "Minimum Rating?")
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(star <= selectedRating ? .yellow : Color.gray.opacity(0.3))
                            .onTapGesture {
                                withAnimation {
                                    selectedRating = star
                                }
                            }
                    }
                }
                .padding(.top, 40)
                
                Text("\(selectedRating) Stars & Above")
                    .font(.headline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 30)
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
                        .foregroundColor(AppTheme.primary)
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Based on your preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack {
                    ZStack {
                        Capsule()
                            .fill(Color(hex: "#20C997").opacity(0.2))
                        Text("95% Match")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#20C997"))
                    }
                    .frame(width: 90, height: 28)
                    Spacer()
                }
            }
            
            // Result Card
            VStack(alignment: .leading, spacing: 0) {
                // Image Placeholder
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                    
                    Image(systemName: "heart")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                        .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bright Beginnings \(selectedType)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("4.9")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(Int(distanceValue)) km", systemImage: "location")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Label(selectedBudget == "Standard" ? "$950/mo" : selectedBudget == "Premium" ? "$1250/mo" : "$700/mo", systemImage: "dollarsign.circle")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    PrimaryButton(title: "Book Visit") {
                        currentStep = .booking
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            
        }
    }
    
    private var bookingConfirmationView: some View {
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
            
            Text("Booking Confirmed!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Your visit has been successfully scheduled.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer().frame(height: 40)
            
            PrimaryButton(title: "Return to Home") {
                presentationMode.wrappedValue.dismiss()
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
    let title: String
    let sub: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppTheme.primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? AppTheme.primary : AppTheme.primary.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textPrimary)
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.title3)
                }
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct AnalyzingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer().frame(height: 120)
            
            ZStack {
                Circle()
                    .stroke(AppTheme.primary.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(spacing: 12) {
                Text("Analyzing Profiles...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Matching your requirements against verified providers.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
