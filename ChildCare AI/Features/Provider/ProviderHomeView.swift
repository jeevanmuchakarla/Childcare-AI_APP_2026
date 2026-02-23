import SwiftUI

public struct ProviderHomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    let role: UserRole
    
    // Navigation Triggers
    @State private var navigateToEarnings = false
    @State private var navigateToAlerts = false
    @State private var navigateToProfile = false
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hidden Navigation Links for fixed screen requirement
                    NavigationLink(destination: Text("Earnings Dashboard").navigationTitle("Earnings"), isActive: $navigateToEarnings) { EmptyView() }
                    NavigationLink(destination: Text("Alerts & Notifications").navigationTitle("Alerts"), isActive: $navigateToAlerts) { EmptyView() }
                    NavigationLink(destination: Text("Provider Profile").navigationTitle("Profile"), isActive: $navigateToProfile) { EmptyView() }
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(role == .babysitter ? "Sarah" : "Bright Beginnings")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 10)
                    
                    // Dashboard KPIs
                    HStack(spacing: 16) {
                        KPICard(title: "Today's Kids", value: role == .babysitter ? "2" : "45", icon: "person.2.fill", color: AppTheme.primary)
                        KPICard(title: "Earnings", value: "$1,250", icon: "dollarsign.circle.fill", color: .green)
                            .onTapGesture { navigateToEarnings = true }
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    // Alerts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Action Required")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Button("View All") { navigateToAlerts = true }
                                .font(.footnote)
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(.horizontal, AppTheme.padding)
                        
                        AlertCard(title: "Missing Immunization Record", description: "Emma Watson's polio vaccination record is due.", icon: "exclamationmark.square.fill", color: .orange)
                            .padding(.horizontal, AppTheme.padding)
                    }
                    
                    // Quick Action Buttons
                    HStack(spacing: 16) {
                        ActionCard(title: "Add Note", iconName: "note.text.badge.plus") {}
                        ActionCard(title: "Log Meal", iconName: "fork.knife") {}
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    // Today's Children
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Roster")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.padding)
                        
                        VStack(spacing: 16) {
                            ChildRosterRow(name: "Emma Watson", age: "3 yrs", status: "Checked In", statusColor: .green)
                            ChildRosterRow(name: "Liam Smith", age: "4 yrs", status: "Checking In Soon", statusColor: .orange)
                            if role != .babysitter {
                                ChildRosterRow(name: "Noah Johnson", age: "2 yrs", status: "Absent", statusColor: .red)
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarItems(trailing:
                Menu {
                    Button(action: { navigateToProfile = true }) {
                        Label("View Profile", systemImage: "building.2.crop.circle")
                    }
                    Button(role: .destructive, action: { appRouter.logout() }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    AvatarButton(action: {})
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(role == .babysitter ? "My Dashboard" : "Center Dashboard")
        }
    }
}

// MARK: - Helper Views
struct KPICard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AlertCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ChildRosterRow: View {
    let name: String
    let age: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(AppTheme.primary.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Text(String(name.prefix(1))).fontWeight(.bold).foregroundColor(AppTheme.primary))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(age)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
