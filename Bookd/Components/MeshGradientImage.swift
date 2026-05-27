import SwiftUI

/// Seeded mesh-gradient placeholder for professional imagery.
/// Combines radial gradients in fixed positions per seed for variety.
struct MeshGradientImage: View {
    let palette: [String]
    var seed: Int = 1

    private var colors: [Color] {
        palette.map { Color(hex: $0) }
    }

    // Five "mood" layouts — seed picks one
    private var points: [(Float, Float)] {
        let moods: [[(Float, Float)]] = [
            [(0.1, 0.2), (0.85, 0.1), (0.5, 0.85), (0.5, 0.5)],
            [(0.9, 0.25), (0.2, 0.75), (0.7, 0.95), (0.5, 0.5)],
            [(0.5, 0.0), (0.0, 1.0), (1.0, 0.6), (0.5, 0.5)],
            [(0.15, 0.9), (0.9, 0.8), (0.6, 0.1), (0.5, 0.5)],
            [(0.7, 0.3), (0.1, 0.6), (0.95, 0.95), (0.5, 0.5)],
        ]
        return moods[seed % moods.count]
    }

    var body: some View {
        let c = colors
        let c0 = c.indices.contains(0) ? c[0] : .gray
        let c1 = c.indices.contains(1) ? c[1] : .gray
        let c2 = c.indices.contains(2) ? c[2] : .gray
        let c3 = c.indices.contains(3) ? c[3] : c0

        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(points[3].0, points[3].1), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1),
            ],
            colors: [
                c3, c0, c1,
                c0, c2, c1,
                c2, c3, c0,
            ]
        )
        .overlay {
            // Subtle vignette
            RadialGradient(
                colors: [.clear, .black.opacity(0.15)],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
        }
    }
}

/// Square aspect ratio version
struct MeshGradientSquare: View {
    let palette: [String]
    var seed: Int = 1

    var body: some View {
        MeshGradientImage(palette: palette, seed: seed)
            .aspectRatio(1, contentMode: .fill)
    }
}
