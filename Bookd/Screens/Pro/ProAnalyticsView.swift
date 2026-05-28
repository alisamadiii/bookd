import SwiftUI

struct ProAnalyticsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    @State private var period = "week"
    @State private var profileViews = 0
    @State private var earnings: (week: Int, month: Int, total: Int)?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var proProfile: DBProProfile? { authManager.proProfile }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                periodPicker

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(60)
                } else {
                    statsGrid
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
        .onChange(of: period) { _, _ in Task { await loadData() } }
        .errorAlert($errorMessage)
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Period", selection: $period) {
            Text("Week").tag("week")
            Text("Month").tag("month")
            Text("All time").tag("all")
        }
        .pickerStyle(.segmented)
        .padding(.top, 8)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible())], spacing: 10) {
            statCard(
                icon: "eye",
                label: "Profile views",
                value: "\(profileViews)"
            )

            statCard(
                icon: "star.fill",
                label: "Rating",
                value: String(format: "%.2f", proProfile?.rating ?? 0)
            )

            statCard(
                icon: "person.2.fill",
                label: "Followers",
                value: formatCount(proProfile?.followersCount ?? 0)
            )

            statCard(
                icon: "dollarsign",
                label: "Earnings",
                value: earningsForPeriod()
            )

            statCard(
                icon: "text.bubble.fill",
                label: "Reviews",
                value: "\(proProfile?.reviewsCount ?? 0)"
            )

            statCard(
                icon: "photo.stack.fill",
                label: "Posts",
                value: "\(proProfile?.postsCount ?? 0)"
            )
        }
    }

    private func statCard(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.bookdProAccent)

            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .tracking(-0.5)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    // MARK: - Data

    private func loadData() async {
        guard let proId = proProfile?.id else {
            isLoading = false
            return
        }

        isLoading = true

        do {
            let since: Date
            switch period {
            case "week":
                since = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            case "month":
                since = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            default:
                since = Date.distantPast
            }

            async let viewsTask = dataService.loadProfileViewsCount(proId: proId, since: since)
            async let earningsTask = dataService.loadEarningsSummary(proId: proId)

            let (views, earningsResult) = try await (viewsTask, earningsTask)
            profileViews = views
            earnings = earningsResult
        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func earningsForPeriod() -> String {
        guard let earnings else { return "$0" }
        let cents: Int
        switch period {
        case "week": cents = earnings.week
        case "month": cents = earnings.month
        default: cents = earnings.total
        }
        return "$\(cents / 100)"
    }

    private func formatCount(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000) }
        return "\(n)"
    }
}
