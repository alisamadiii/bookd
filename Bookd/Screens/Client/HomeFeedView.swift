import SwiftUI

struct HomeFeedView: View {
    @Binding var selectedProId: String?
    @Binding var showBooking: Bool
    @Binding var bookingProId: String?
    @State private var selectedCategory = "all"
    @State private var searchText = ""

    private var filteredPros: [Professional] {
        if selectedCategory == "all" { return SampleData.pros }
        return SampleData.pros.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Category strip
                categoryStrip

                // Trending carousel
                trendingSection

                // Feed posts
                feedSection
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Bookd")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search hair, tattoo, fitness near you")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { } label: {
                    Image(systemName: "bell")
                }
                Button { } label: {
                    Image(systemName: "tray")
                }
            }
        }
    }

    // MARK: - Category Strip

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProCategory.all) { cat in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedCategory = cat.id
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.systemImage)
                                .font(.system(size: 12))
                            Text(cat.label)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == cat.id
                                ? AnyShapeStyle(Color.bookdAccent)
                                : AnyShapeStyle(.regularMaterial)
                        )
                        .foregroundStyle(selectedCategory == cat.id ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Trending Carousel

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Trending near you")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.4)
                Spacer()
                Button("See all") { }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.bookdAccent)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(SampleData.pros.prefix(4).enumerated()), id: \.element.id) { idx, pro in
                        Button { selectedProId = pro.id } label: {
                            trendingCard(pro: pro, index: idx)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 6)
    }

    private func trendingCard(pro: Professional, index: Int) -> some View {
        ZStack(alignment: .bottom) {
            MeshGradientImage(palette: pro.palette, seed: index + 1)

            // Sticker
            VStack {
                HStack {
                    StickerView(
                        text: index == 0 ? "🔥 Hot" : "#\(index + 1)",
                        color: index == 0 ? Color(hex: "FFE082") : .white,
                        rotation: -5
                    )
                    Spacer()
                }
                .padding(8)
                Spacer()
            }

            // Bottom info
            VStack(alignment: .leading, spacing: 2) {
                Text(pro.name)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                Text("★ \(pro.rating, specifier: "%.2f") · \(pro.cityShort)")
                    .font(.system(size: 11))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.6)],
                               startPoint: .top, endPoint: .bottom)
            )
        }
        .frame(width: 160, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.md))
    }

    // MARK: - Feed Posts

    private var feedSection: some View {
        LazyVStack(spacing: 24) {
            ForEach(Array(filteredPros.enumerated()), id: \.element.id) { idx, pro in
                FeedPostView(pro: pro, seed: idx + 3) {
                    selectedProId = pro.id
                } onBookNow: {
                    bookingProId = pro.id
                    showBooking = true
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

// MARK: - Feed Post

struct FeedPostView: View {
    let pro: Professional
    let seed: Int
    let onTapPro: () -> Void
    let onBookNow: () -> Void

    @State private var liked = false
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: onTapPro) {
                HStack(spacing: 10) {
                    AvatarView(palette: pro.palette, size: 42, name: pro.name)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(pro.name)
                                .font(.system(size: 14.5, weight: .bold))
                            if pro.verified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.bookdAccent)
                            }
                        }
                        Text("\(pro.role) · \(pro.cityShort)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)

            // Image with overlays
            ZStack(alignment: .bottom) {
                MeshGradientImage(palette: pro.palette, seed: seed)
                    .aspectRatio(4.0/5.0, contentMode: .fill)

                // Badge sticker
                if let badge = pro.badges.first {
                    VStack {
                        HStack {
                            StickerView(text: badge, color: .white, rotation: -4)
                                .padding(14)
                            Spacer()
                        }
                        Spacer()
                    }
                }

                // "Book now" overlay
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NEXT SLOT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .opacity(0.85)
                        Text(pro.nextSlot)
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.white)

                    Spacer()

                    Button("Book now", action: onBookNow)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.white, in: Capsule())
                }
                .padding(16)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.55)],
                                   startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: BookdRadius.lg))

            // Action row
            HStack(spacing: 14) {
                Button { liked.toggle() } label: {
                    Image(systemName: liked ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundStyle(liked ? .red : .primary)
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: liked)

                Button { } label: {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 24))
                }
                Button { } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                }
                Spacer()
                Button { saved.toggle() } label: {
                    Image(systemName: saved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22))
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)

            // Stats
            HStack(spacing: 0) {
                Text("\((1200 + seed * 73).formatted()) likes")
                    .fontWeight(.bold)
                Text(" · \(pro.priceRange) · \(pro.posts) portfolio posts")
            }
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
        }
    }
}
