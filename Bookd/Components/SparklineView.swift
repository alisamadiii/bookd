import SwiftUI

/// Simple SVG-style sparkline for the Pro dashboard earnings chart.
struct SparklineView: View {
    var color: Color = .bookdSuccess
    let data: [Double] = [35, 30, 32, 22, 26, 14, 18, 8, 12]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxVal = data.max() ?? 1
            let minVal = data.min() ?? 0
            let range = maxVal - minVal

            let points: [CGPoint] = data.enumerated().map { i, val in
                let x = w * CGFloat(i) / CGFloat(data.count - 1)
                let y = h - (h * CGFloat((val - minVal) / range))
                return CGPoint(x: x, y: y)
            }

            // Fill
            Path { path in
                guard let first = points.first else { return }
                path.move(to: CGPoint(x: first.x, y: h))
                path.addLine(to: first)
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }
                path.addLine(to: CGPoint(x: points.last!.x, y: h))
                path.closeSubpath()
            }
            .fill(color.opacity(0.15))

            // Line
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

            // End dot
            if let last = points.last {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .position(last)
            }
        }
    }
}
