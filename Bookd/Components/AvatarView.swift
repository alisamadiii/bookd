import SwiftUI

/// Circular mesh-gradient avatar with initials overlay.
/// Always shows gradient — never a gray circle. Falls back to brand palette.
struct AvatarView: View {
    let palette: [String]
    var size: CGFloat = 44
    var name: String = ""
    var showRing: Bool = false

    /// Brand default palette — used when palette is nil or empty
    private static let defaultPalette = ["#6C5CE7", "#FFB259", "#FF6FA0"]

    private var safePalette: [String] {
        palette.isEmpty ? Self.defaultPalette : palette
    }

    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var body: some View {
        ZStack {
            MeshGradientImage(palette: safePalette, seed: max(name.count, 1))
                .frame(width: size, height: size)
                .clipShape(Circle())

            if !initials.isEmpty {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
            }
        }
        .frame(width: size, height: size)
        .overlay {
            if showRing {
                Circle()
                    .strokeBorder(Color.bookdAccent, lineWidth: 2)
                    .padding(-2)
            }
        }
    }
}
