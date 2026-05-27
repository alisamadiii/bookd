import SwiftUI

/// Playful rotated badge chip — the "TRENDING", "⚡ BOOKD" stickers.
struct StickerView: View {
    let text: String
    var color: Color = Color(hex: "FFE082")
    var rotation: Double = -4

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .tracking(0.7)
            .textCase(.uppercase)
            .foregroundStyle(Color(hex: "141416"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.18), radius: 6, y: 4)
            .rotationEffect(.degrees(rotation))
    }
}
