import SwiftUI

public struct ChildProfileView: View {
    let name: String
    let age: String
    
    public init(name: String, age: String) {
        self.name = name
        self.age = age
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Profile Info
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                        Text(String(name.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(age) Old • Joined Sep 2023")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    NavigationLink(destination: DailyReportOverviewView(childName: name)) {
                        VStack(spacing: 8) {
                            Image(systemName: "list.clipboard.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Daily Report")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.primary)
                            Text("Message Provider")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.primary, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.padding)
                
                // Medical & Emergency Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("Important Information")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    InfoRow(icon: "cross.case.fill", title: "Allergies", value: "Peanuts, Penicillin", color: .red)
                    InfoRow(icon: "pills.fill", title: "Medications", value: "None", color: .blue)
                    InfoRow(icon: "phone.circle.fill", title: "Emergency Contact", value: "Mom: 555-0192", color: .green)
                    InfoRow(icon: "person.crop.circle.badge.plus", title: "Authorized Pickups", value: "Mom, Dad, Grandma", color: .purple)
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, AppTheme.padding)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("\(name)'s Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
        }
    }
}
