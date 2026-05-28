import SwiftUI
import MapKit

struct ProDetailView: View {
    let proId: String
    let onBook: (String, String?) -> Void
    let onMessage: (String) -> Void

    @State private var selectedTab = "portfolio"
    @State private var following = false
    @Environment(\.dismiss) private var dismiss

    private var pro: Professional? { SampleData.pro(for: proId) }

    var body: some View {
        guard let pro else { return AnyView(EmptyView()) }

        return AnyView(
            ScrollView {
                VStack(spacing: 0) {
                    // Hero cover
                    heroSection(pro: pro)

                    // Profile card
                    profileCard(pro: pro)
                        .padding(.horizontal, 16)
                        .offset(y: -40)

                    // Tabs
                    tabsSection(pro: pro)
                        .offset(y: -20)
                }
                .padding(.bottom, 130)
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button { } label: { Image(systemName: "square.and.arrow.up") }
                        Button { } label: { Image(systemName: "ellipsis") }
                    }
                }
            }
        )
    }

    // MARK: - Hero

    @ViewBuilder
    private func heroSection(pro: Professional) -> some View {
        MeshGradientImage(palette: pro.palette, seed: 3)
            .frame(height: 280)
    }

    // MARK: - Profile Card

    @ViewBuilder
    private func profileCard(pro: Professional) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Avatar + badges
            HStack(alignment: .bottom, spacing: 14) {
                AvatarView(palette: pro.palette.reversed(), size: 86, name: pro.name, showRing: true)
                    .offset(y: -18)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(pro.badges, id: \.self) { badge in
                        Text(badge.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.7)
                            .foregroundStyle(Color.bookdAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.bookdAccentSoft, in: Capsule())
                    }
                }
            }

            // Name + role
            HStack(spacing: 6) {
                Text(pro.name)
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.5)
                if pro.verified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.bookdAccent)
                }
            }
            .padding(.top, 4)

            Text(pro.role)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "mappin")
                    .font(.system(size: 12))
                Text(pro.city)
            }
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .padding(.top, 6)

            // Stats
            HStack(spacing: 18) {
                statItem(label: "Rating", value: "★ \(String(format: "%.2f", pro.rating))", sub: "\(pro.reviews) reviews")
                statItem(label: "Followers", value: pro.followers)
                statItem(label: "Posts", value: "\(pro.posts)")
                statItem(label: "Reply", value: "2h", sub: "avg")
            }
            .padding(.top, 14)

            // Bio
            Text(pro.bio)
                .font(.system(size: 14))
                .lineSpacing(3)
                .padding(.top, 14)

            // Action buttons
            HStack(spacing: 8) {
                Button {
                    onBook(pro.id, nil)
                } label: {
                    Text("Book appointment")
                        .frame(maxWidth: .infinity)
                }
                .tint(.bookdAccent)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    onMessage(pro.id)
                } label: {
                    Image(systemName: "bubble.right")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    following.toggle()
                } label: {
                    Image(systemName: following ? "heart.fill" : "heart")
                        .foregroundStyle(following ? .red : .primary)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .sensoryFeedback(.impact(flexibility: .soft), trigger: following)
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    private func statItem(label: String, value: String, sub: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .tracking(-0.3)
            Text(sub.map { "\(label) \($0)" } ?? label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tabs

    @ViewBuilder
    private func tabsSection(pro: Professional) -> some View {
        // Tab picker
        Picker("Tab", selection: $selectedTab) {
            Text("Portfolio").tag("portfolio")
            Text("Services").tag("services")
            Text("Reviews").tag("reviews")
            Text("About").tag("about")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)

        // Content
        Group {
            switch selectedTab {
            case "portfolio":
                portfolioGrid(pro: pro)
            case "services":
                servicesTab(pro: pro)
            case "reviews":
                reviewsTab(pro: pro)
            case "about":
                aboutTab(pro: pro)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    // MARK: - Portfolio

    @ViewBuilder
    private func portfolioGrid(pro: Professional) -> some View {
        let portfolio = SampleData.makePortfolio(for: pro)
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 4), count: 3), spacing: 4) {
            ForEach(portfolio) { post in
                ZStack(alignment: .bottomLeading) {
                    MeshGradientImage(palette: pro.palette, seed: post.seed)
                        .aspectRatio(1, contentMode: .fill)
                    Text("♥ \(post.likes)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                        .padding(.leading, 6)
                        .padding(.bottom, 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: BookdRadius.xs))
            }
        }
    }

    // MARK: - Services

    @ViewBuilder
    private func servicesTab(pro: Professional) -> some View {
        VStack(spacing: 10) {
            ForEach(pro.services) { service in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.bookdAccent)
                        .frame(width: 4, height: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(service.name)
                            .font(.system(size: 15, weight: .bold))
                        Text(service.formattedDuration)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(service.formattedPrice)
                            .font(.system(size: 16, weight: .heavy))
                        Button("Book") {
                            onBook(pro.id, service.id)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(.bookdAccent)
                    }
                }
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }
        }
    }

    // MARK: - Reviews

    @ViewBuilder
    private func reviewsTab(pro: Professional) -> some View {
        VStack(spacing: 12) {
            // Summary
            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    Text(String(format: "%.2f", pro.rating))
                        .font(.system(size: 36, weight: .heavy))
                        .tracking(-0.5)
                    StarRatingView(value: pro.rating, size: 14)
                    Text("\(pro.reviews) reviews")
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
                            let pct: CGFloat = n == 5 ? 0.86 : n == 4 ? 0.11 : 0.02
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

            // Individual reviews
            ForEach(SampleData.reviews) { review in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        AvatarView(palette: review.avatarPalette, size: 36, name: review.author)
                        VStack(alignment: .leading) {
                            Text(review.author)
                                .font(.system(size: 13, weight: .bold))
                            Text(review.when)
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        StarRatingView(value: Double(review.rating), size: 12)
                    }
                    Text(review.text)
                        .font(.system(size: 13.5))
                        .lineSpacing(3)
                }
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }
        }
    }

    // MARK: - About

    @ViewBuilder
    private func aboutTab(pro: Professional) -> some View {
        VStack(spacing: 10) {
            // Bio
            GroupBox("About") {
                Text("\(pro.bio) I focus on what feels uniquely you — quiet, intentional, never overdone.")
                    .font(.system(size: 14))
                    .lineSpacing(3)
            }

            // Hours
            GroupBox("Working hours") {
                VStack(spacing: 4) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        HStack {
                            Text(day)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(day == "Sun" ? "Closed" : (day == "Thu" ? "12:00 — 9:00 PM" : "10:00 — 7:00 PM"))
                                .fontWeight(.semibold)
                                .foregroundStyle(day == "Sun" ? .tertiary : .primary)
                        }
                        .font(.system(size: 14))
                    }
                }
            }

            // Location
            GroupBox("Location") {
                VStack(alignment: .leading, spacing: 8) {
                    Map {
                        Marker(pro.name, coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006))
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false)

                    Text("247 Wilson Ave, Brooklyn")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Apt 3B · Buzzer 12")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
