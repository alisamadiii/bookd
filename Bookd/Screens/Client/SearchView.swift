import SwiftUI
import MapKit

struct SearchView: View {
    @Binding var selectedProId: String?
    @State private var searchText = ""
    @State private var showMap = false
    @State private var filterToday = false
    @State private var filterTop = false
    @State private var filterNear = true

    private var results: [Professional] {
        if searchText.isEmpty { return SampleData.pros }
        let q = searchText.lowercased()
        return SampleData.pros.filter {
            $0.name.lowercased().contains(q) ||
            $0.role.lowercased().contains(q) ||
            $0.category.contains(q)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Filter chips
                filterStrip

                // View toggle + count
                HStack {
                    Text("\(results.count) pros")
                        .fontWeight(.bold)
                    + Text(" · sorted by fit")
                    Spacer()

                    Picker("View", selection: $showMap) {
                        Image(systemName: "square.grid.2x2").tag(false)
                        Image(systemName: "map").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if showMap {
                    mapView
                } else {
                    gridView
                }
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Search hair, tattoo, fitness...")
    }

    // MARK: - Filters

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("Today", icon: "clock", active: $filterToday)
                filterChip("Top rated", icon: "star", active: $filterTop)
                filterChip("< 5 mi", icon: "mappin", active: $filterNear)
                Button { } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 12))
                        Text("Price")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
                }
                Button { } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 12))
                        Text("More")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private func filterChip(_ label: String, icon: String, active: Binding<Bool>) -> some View {
        Button {
            withAnimation { active.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(active.wrappedValue ? AnyShapeStyle(.primary) : AnyShapeStyle(.regularMaterial))
            .foregroundStyle(active.wrappedValue ? Color(.systemBackground) : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grid

    private var gridView: some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 12), .init(.flexible())], spacing: 12) {
            ForEach(Array(results.enumerated()), id: \.element.id) { idx, pro in
                Button { selectedProId = pro.id } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            MeshGradientImage(palette: pro.palette, seed: idx + 2)
                                .aspectRatio(3.0/4.0, contentMode: .fill)

                            // Overlay icons
                            VStack {
                                HStack {
                                    if pro.verified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.bookdAccent)
                                    }
                                    Spacer()
                                    Image(systemName: "heart")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                        .padding(7)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                                .padding(8)
                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pro.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .lineLimit(1)
                                Text("★ \(pro.rating, specifier: "%.2f") (\(pro.reviews))")
                                    .font(.system(size: 11))
                                    .opacity(0.85)
                            }
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(
                                LinearGradient(colors: [.clear, .black.opacity(0.55)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.md))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(pro.role.components(separatedBy: "·").first ?? "")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text(pro.priceRange)
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Map

    private var mapView: some View {
        VStack(spacing: 0) {
            Map {
                ForEach(results) { pro in
                    Annotation(pro.name, coordinate: randomCoordinate(for: pro)) {
                        Button { selectedProId = pro.id } label: {
                            Text(pro.priceRange.components(separatedBy: "–").first ?? "")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedProId == pro.id ? Color.bookdAccent : .primary,
                                            in: Capsule())
                        }
                    }
                }
            }
            .frame(height: 460)
            .clipShape(RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.horizontal, 16)
        }
    }

    private func randomCoordinate(for pro: Professional) -> CLLocationCoordinate2D {
        let hash = pro.id.hashValue
        let lat = 40.7128 + Double(hash % 100) * 0.001
        let lng = -74.0060 + Double((hash / 100) % 100) * 0.001
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
