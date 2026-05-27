import SwiftUI

struct ProCalendarView: View {
    @State private var viewMode = "day"

    private let hourHeight: CGFloat = 64
    private let hours = Array(9...18)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // View toggle
                Picker("View", selection: $viewMode) {
                    Text("Day").tag("day")
                    Text("Week").tag("week")
                    Text("Month").tag("month")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                // Day header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tuesday · May 27")
                            .font(.system(size: 24, weight: .heavy))
                            .tracking(-0.4)
                        Text("4 bookings · 4.5 hours scheduled")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button { } label: {
                            Image(systemName: "chevron.left")
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button { } label: {
                            Image(systemName: "chevron.right")
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Timeline
                timelineView
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 130)
        }
        .navigationTitle("Calendar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: {
                    Image(systemName: "plus")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.primary)
            }
        }
    }

    // MARK: - Timeline

    private var timelineView: some View {
        ZStack(alignment: .topLeading) {
            // Hour rows
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text(formatHour(hour))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .frame(width: 60, alignment: .leading)

                        Rectangle()
                            .fill(.separator)
                            .frame(height: 0.5)
                    }
                    .frame(height: hourHeight)
                }
            }

            // Booking blocks
            ForEach(SampleData.calendarBlocks) { block in
                let top = CGFloat(block.hour - 9) * hourHeight
                let height = CGFloat(block.span) * hourHeight - 4

                VStack(alignment: .leading, spacing: 2) {
                    Text(block.service)
                        .font(.system(size: 13, weight: .heavy))
                    Text("\(block.name) · \(formatHour(block.hour))")
                        .font(.system(size: 11))
                        .opacity(0.7)

                    if block.span >= 2 {
                        Spacer()
                        HStack(spacing: 6) {
                            AvatarView(palette: ["#FF7A59", "#7E5BFF"], size: 20, name: block.name)
                            Text("Confirmed · paid")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
                .foregroundStyle(Color(hex: "141416"))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: height)
                .background(Color(hex: block.color), in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                .offset(x: 64, y: top + 2)
                .padding(.trailing, 12)
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    private func formatHour(_ h: Double) -> String {
        let hh = Int(h)
        let mm = Int((h - Double(hh)) * 60)
        let period = hh >= 12 ? "PM" : "AM"
        let displayH = hh > 12 ? hh - 12 : hh
        return "\(displayH):\(String(format: "%02d", mm)) \(period)"
    }

    private func formatHour(_ h: Int) -> String {
        let period = h >= 12 ? "PM" : "AM"
        let displayH = h > 12 ? h - 12 : h
        return "\(displayH):00 \(period)"
    }
}
