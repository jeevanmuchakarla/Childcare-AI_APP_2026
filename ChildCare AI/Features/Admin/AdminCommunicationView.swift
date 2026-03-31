import SwiftUI

public struct AdminCommunicationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var broadcastTitle = ""
    @State private var broadcastMessage = ""
    @State private var selectedAudience = 0
    let audiences = ["All Users", "Parents", "Providers", "Admins"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.primaryColor)
                }
                Text("Platform Broadcast")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(AppTheme.surface)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Info Row
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Broadcasts will be sent as push notifications and in-app alerts.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Audience Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Audience")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<audiences.count, id: \.self) { index in
                                    Button(action: { selectedAudience = index }) {
                                        Text(audiences[index])
                                            .font(.caption)
                                            .foregroundColor(selectedAudience == index ? .white : AppTheme.textPrimary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(selectedAudience == index ? themeManager.primaryColor : AppTheme.surface)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Inputs
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alert Title")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            TextField("e.g. Scheduled Maintenance", text: $broadcastTitle)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message Content")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            TextEditor(text: $broadcastMessage)
                                .frame(height: 120)
                                .padding(8)
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Send Button
                    Button(action: {
                        // Action to send broadcast
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Broadcast")
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(broadcastTitle.isEmpty || broadcastMessage.isEmpty ? Color.gray : themeManager.primaryColor)
                        .cornerRadius(16)
                    }
                    .disabled(broadcastTitle.isEmpty || broadcastMessage.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Recent Broadcasts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Broadcasts")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            BroadcastRow(title: "New Feature: AI Matching", date: "2 days ago", audience: "All Users")
                            BroadcastRow(title: "Maintenance Notice", date: "1 week ago", audience: "All Users")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.opacity(0.1).ignoresSafeArea())
    }
}

struct BroadcastRow: View {
    let title: String
    let date: String
    let audience: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("\(audience) • \(date)")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
    }
}
