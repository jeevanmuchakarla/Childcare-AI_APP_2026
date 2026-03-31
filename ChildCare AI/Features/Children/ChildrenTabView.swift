import SwiftUI

public struct ChildrenTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var childStore: ChildStore
    @State private var enrolledChildren: [(id: Int, name: String, age: String, classroom: String)] = []
    @State private var isLoadingEnrolled = false
    let role: UserRole
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        // Root view for tab content

            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: role == .parent ? "My Children" : "Enrolled Children", showBackButton: false)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if role == .parent {
                            if childStore.isLoading {
                                ProgressView()
                                    .padding(.top, 40)
                            } else if childStore.children.isEmpty {
                                Text("No children registered yet")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(childStore.children) { child in
                                    NavigationLink(destination: ChildProfileView(childId: child.id, name: child.name, age: child.age, role: .parent)) {
                                        ChildProfileCardRedesign(
                                            name: child.name,
                                            age: child.age,
                                            provider: "Daycare Center",
                                            imageName: "person.circle.fill"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            // Add Child Button
                            NavigationLink(destination: AddChildProfileView()) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("Register New Child")
                                        .font(.headline)
                                }
                                .foregroundColor(themeManager.primaryColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.primaryColor, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                                )
                                .background(themeManager.primaryColor.opacity(0.02))
                                .cornerRadius(20)
                            }
                            .padding(.top, 10)
                        } else {
                            // Provider: show enrolled children with proper info
                            if isLoadingEnrolled {
                                ProgressView()
                                    .padding(.top, 40)
                            } else if enrolledChildren.isEmpty {
                                Text("No children currently enrolled.")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(enrolledChildren, id: \.id) { child in
                                    NavigationLink(destination: ChildProfileView(childId: child.id, name: child.name, age: child.age, role: role)) {
                                        ChildProfileCardRedesign(
                                            name: child.name,
                                            age: child.age,
                                            provider: child.classroom,
                                            imageName: "person.circle.fill"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if let userId = AuthService.shared.currentUser?.id {
                    if role == .parent {
                        Task {
                            await childStore.loadChildren(parentId: userId)
                        }
                    } else {
                        fetchEnrolledChildren(providerId: userId)
                    }
                }
            }
    }
    
    private func fetchEnrolledChildren(providerId: Int) {
        isLoadingEnrolled = true
        Task {
            do {
                let bookings = try await BookingService.shared.fetchProviderBookings(providerId: providerId)
                // Filter for Confirmed bookings and get unique children
                var uniqueChildren: [Int: (name: String, age: String, classroom: String)] = [:]
                for booking in bookings where booking.status.lowercased() == "confirmed" {
                    if let cid = booking.child_id, let cname = booking.child_name {
                        // In a real app, age might come from a separate child fetch, but for now we use what's in the booking if available
                        uniqueChildren[cid] = (name: cname, age: "Child", classroom: "Enrolled")
                    }
                }
                
                let mapped = uniqueChildren.map { (id: $0.key, name: $0.value.name, age: $0.value.age, classroom: $0.value.classroom) }
                    .sorted { $0.name < $1.name }
                
                await MainActor.run {
                    self.enrolledChildren = mapped
                    self.isLoadingEnrolled = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingEnrolled = false
                    // Demo fallback if backend fails
                    self.enrolledChildren = [
                        (101, "Leo Johnson", "4 years", "Classroom A"),
                        (102, "Emma Davis", "2 years", "Classroom B")
                    ]
                }
            }
        }
    }
}

struct ChildProfileCardRedesign: View {
    let name: String
    let age: String
    let provider: String
    let imageName: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(themeManager.primaryColor.opacity(0.1))
                        .frame(width: 65, height: 65)
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(themeManager.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 10) {
                        Text(age)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 4, height: 4)
                        
                        Text("Active Update")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(20)
        }
        .background(AppTheme.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

// Deleted ChildActionButton as it's no longer used
