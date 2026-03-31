import SwiftUI

public struct MyRatingsView: View {
    @Environment(\.dismiss) var dismiss
    
    let ratings = [
        RatingItem(author: "Sarah Johnson", date: "2 days ago", rating: 5, comment: "Jessica was amazing with Leon! Very professional and caring."),
        RatingItem(author: "Michael Brown", date: "1 week ago", rating: 4, comment: "Great experience, very punctual."),
        RatingItem(author: "Emily Davis", date: "2 weeks ago", rating: 5, comment: "Highly recommend! The kids loved her.")
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Ratings")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Summary Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("4.9")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                                
                                Text("Based on 24 reviews")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Visual bar chart simplified
                            VStack(alignment: .trailing, spacing: 4) {
                                RatingBar(stars: 5, percentage: 0.9)
                                RatingBar(stars: 4, percentage: 0.1)
                                RatingBar(stars: 3, percentage: 0.0)
                                RatingBar(stars: 2, percentage: 0.0)
                                RatingBar(stars: 1, percentage: 0.0)
                            }
                            .frame(width: 120)
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 10)
                    .padding(.horizontal)
                    
                    // Reviews List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Reviews")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        ForEach(ratings) { rating in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(rating.author)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(rating.date)
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(index < rating.rating ? .yellow : .gray.opacity(0.3))
                                            .font(.system(size: 10))
                                    }
                                }
                                
                                Text(rating.comment)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
}

struct RatingItem: Identifiable {
    let id = UUID()
    let author: String
    let date: String
    let rating: Int
    let comment: String
}

struct RatingBar: View {
    let stars: Int
    let percentage: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(stars)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 8)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.divider)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.yellow)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 4)
        }
    }
}
