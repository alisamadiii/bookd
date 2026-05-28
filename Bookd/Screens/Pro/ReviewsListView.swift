import SwiftUI

struct ReviewsListView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    @State private var reviews: [DBReview] = []
    @State private var reviewerProfiles: [UUID: DBProfile] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var proProfile: DBProProfile? { authManager.proProfile }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(60)
                } else if reviews.isEmpty {
                    emptyState
                } else {
                    ratingSummary
                    reviewsList
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("Reviews & ratings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadReviews() }
        .errorAlert($errorMessage)
    }

    // MARK: - Rating Summary

    private var ratingSummary: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading) {
                Text(String(format: "%.2f", proProfile?.rating ?? 0))
                    .font(.system(size: 36, weight: .heavy))
                    .tracking(-0.5)
                StarRatingView(value: proProfile?.rating ?? 0, size: 14)
                Text("\(proProfile?.reviewsCount ?? 0) reviews")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach([5, 4, 3, 2, 1], id: \.self) { n in
                    HStack(spacing: 8) {
                        Text("\(n)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 8)
                        let count = reviews.filter { $0.rating == n }.count
                        let pct = reviews.isEmpty ? 0 : CGFloat(count) / CGFloat(reviews.count)
                        GeometryReader { geo in
                            Capsule()
                                .fill(.quaternary)
                                .overlay(alignment: .leading) {
                                    Capsule()
                                        .fill(.primary)
                                        .frame(width: geo.size.width * pct)
                                }
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    // MARK: - Reviews List

    private var reviewsList: some View {
        ForEach(reviews) { review in
            let reviewer = reviewerProfiles[review.clientId]
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    ProfileAvatarView(
                        avatarUrl: reviewer?.avatarUrl,
                        palette: reviewer?.palette ?? ["#6C5CE7", "#FFB259"],
                        name: reviewer?.fullName ?? "Client",
                        size: 36
                    )
                    VStack(alignment: .leading) {
                        Text(reviewer?.fullName ?? "Client")
                            .font(.system(size: 13, weight: .bold))
                        if let date = review.createdAt {
                            Text(date.formatted(.dateTime.month(.abbreviated).day().year()))
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Spacer()
                    StarRatingView(value: Double(review.rating), size: 12)
                }

                if let text = review.text, !text.isEmpty {
                    Text(text)
                        .font(.system(size: 13.5))
                        .lineSpacing(3)
                }
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.bubble")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No reviews yet")
                .font(.system(size: 18, weight: .heavy))
            Text("Reviews from your clients will appear here.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - Data

    private func loadReviews() async {
        guard let proId = proProfile?.id else {
            isLoading = false
            return
        }

        do {
            reviews = try await dataService.loadReviews(proId: proId)

            // Load reviewer profiles
            let clientIds = Array(Set(reviews.map(\.clientId)))
            if !clientIds.isEmpty {
                let profiles: [DBProfile] = try await AppSupabase.client
                    .from("profiles")
                    .select()
                    .in("id", values: clientIds.map(\.uuidString))
                    .execute()
                    .value
                reviewerProfiles = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })
            }
        } catch {
            errorMessage = "Failed to load reviews: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
