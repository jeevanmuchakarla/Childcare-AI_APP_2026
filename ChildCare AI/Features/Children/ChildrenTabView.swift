import SwiftUI

public struct ChildrenTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    let role: UserRole
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if role == .parent {
                        // Parent View: Own Children
                        ChildProfileCard(name: "Oliver", age: "2 Years", careProvider: "Bright Beginnings Preschool")
                        ChildProfileCard(name: "Mia", age: "4 Years", careProvider: "Bright Beginnings Preschool")
                    } else {
                        // Provider View: All enrolled children
                        HStack {
                            CustomTextField(placeholder: "Search child name...", text: .constant(""))
                            Button(action: {}) {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        
                        ChildProfileCard(name: "Emma Watson", age: "3 Years", careProvider: "Room A - Butterflies")
                        ChildProfileCard(name: "Liam Smith", age: "4 Years", careProvider: "Room B - Caterpillars")
                        ChildProfileCard(name: "Noah Johnson", age: "2 Years", careProvider: "Room A - Butterflies")
                    }
                }
                .padding(AppTheme.padding)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(role == .parent ? "My Children" : "Enrolled Children")
            .navigationBarItems(trailing: role != .parent ? Button(action: {}) {
                Image(systemName: "plus")
                    .foregroundColor(AppTheme.primary)
            } : nil)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChildProfileCard: View {
    let name: String
    let age: String
    let careProvider: String // E.g. assigned classroom or provider name
    
    var body: some View {
        NavigationLink(destination: ChildProfileView(name: name, age: age)) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 60, height: 60)
                    Text(String(name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(age) • \(careProvider)")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
