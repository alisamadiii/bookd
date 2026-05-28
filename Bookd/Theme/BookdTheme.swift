import SwiftUI

// MARK: - Design Tokens

enum BookdRadius {
    static let lg: CGFloat = 24
    static let md: CGFloat = 18
    static let sm: CGFloat = 12
    static let xs: CGFloat = 6
}

extension Color {
    static let bookdAccent = Color(red: 0.424, green: 0.361, blue: 0.906) // #6C5CE7
    static let bookdAccentSoft = Color.bookdAccent.opacity(0.12)
    static let bookdProAccent = Color(red: 0.831, green: 0.659, blue: 0.325) // #D4A853 warm gold
    static let bookdProAccentSoft = Color.bookdProAccent.opacity(0.12)
    static let bookdDanger = Color(red: 1.0, green: 0.35, blue: 0.37)
    static let bookdSuccess = Color(red: 0.48, green: 0.9, blue: 0.51)
    static let bookdWarning = Color(red: 1.0, green: 0.85, blue: 0.42)
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Palette Helpers

extension [String] {
    var swiftUIColors: [Color] {
        map { Color(hex: $0) }
    }
}
