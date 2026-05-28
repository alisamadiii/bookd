import SwiftUI

struct PayoutsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    @State private var earnings: (week: Int, month: Int, total: Int)?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var proProfile: DBProProfile? { authManager.proProfile }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if proProfile?.stripeOnboarded == true {
                    connectedContent
                } else {
                    connectStripeCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("Payouts")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadEarnings() }
        .errorAlert($errorMessage)
    }

    // MARK: - Not Connected

    private var connectStripeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "banknote")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("Connect with Stripe")
                .font(.system(size: 20, weight: .heavy))
                .tracking(-0.3)

            Text("Accept payments and receive payouts directly to your bank account.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                // Stripe Connect onboarding — not yet wired
            } label: {
                Text("Set up payouts")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.bookdProAccent)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        .padding(.top, 16)
    }

    // MARK: - Connected

    private var connectedContent: some View {
        VStack(spacing: 12) {
            // Payout schedule
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payout schedule")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("Daily")
                        .font(.system(size: 16, weight: .heavy))
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 20))
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))

            // Earnings
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(40)
            } else if let earnings {
                VStack(spacing: 0) {
                    earningsRow(label: "This week", amount: earnings.week)
                    Divider().padding(.leading, 16)
                    earningsRow(label: "This month", amount: earnings.month)
                    Divider().padding(.leading, 16)
                    earningsRow(label: "All time", amount: earnings.total)
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }

            // Payout history placeholder
            VStack(alignment: .leading, spacing: 8) {
                Text("PAYOUT HISTORY")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)

                HStack {
                    Text("Coming soon")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
    }

    private func earningsRow(label: String, amount: Int) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14.5, weight: .medium))
            Spacer()
            Text("$\(amount / 100)")
                .font(.system(size: 16, weight: .heavy))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Data

    private func loadEarnings() async {
        guard let proId = proProfile?.id else {
            isLoading = false
            return
        }

        do {
            earnings = try await dataService.loadEarningsSummary(proId: proId)
        } catch {
            errorMessage = "Failed to load earnings: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
