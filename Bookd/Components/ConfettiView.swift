import SwiftUI

/// Burst of colorful dots that fall with rotation — booking confirmation celebration.
struct ConfettiView: View {
    @State private var animate = false

    private let confettiColors: [Color] = [
        Color(hex: "FFE082"),
        .bookdAccent,
        Color(hex: "FF7A59"),
        .bookdSuccess,
        Color(hex: "FF6FA0"),
    ]

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(confettiColors[i % confettiColors.count])
                    .frame(width: CGFloat.random(in: 6...10),
                           height: CGFloat.random(in: 6...10))
                    .offset(
                        x: animate ? CGFloat.random(in: -180...180) : 0,
                        y: animate ? CGFloat.random(in: 200...500) : -50
                    )
                    .opacity(animate ? 0 : 0.8)
                    .rotationEffect(.degrees(animate ? Double.random(in: 180...540) : 0))
                    .animation(
                        .easeOut(duration: Double.random(in: 2...3.5))
                        .delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
