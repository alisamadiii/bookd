import SwiftUI

/// Display star rating — filled stars up to the rounded value.
struct StarRatingView: View {
    let value: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < Int(value.rounded()) ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i < Int(value.rounded()) ? .primary : .quaternary)
            }
        }
    }
}
