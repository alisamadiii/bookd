import SwiftUI
import PassKit

enum BookingStep: Int, CaseIterable {
    case service, date, time, notes, review, pay

    var label: String {
        switch self {
        case .service: "Service"
        case .date: "Date"
        case .time: "Time"
        case .notes: "Notes"
        case .review: "Review"
        case .pay: "Pay"
        }
    }
}

struct BookingFlowView: View {
    let proId: String
    var initialServiceId: String? = nil
    let onDismiss: () -> Void

    @State private var step: BookingStep = .service
    @State private var selectedServiceId: String?
    @State private var selectedDate: Date?
    @State private var selectedTime: String?
    @State private var notes = ""
    @State private var tip: Int = 15
    @State private var payMethod = "apple"
    @State private var confirmed = false

    private var pro: Professional? { SampleData.pro(for: proId) }
    private var service: ProService? {
        pro?.services.first { $0.id == selectedServiceId }
    }

    var body: some View {
        guard let pro else { return AnyView(EmptyView()) }

        if confirmed {
            return AnyView(
                BookingConfirmationView(
                    pro: pro,
                    service: service!,
                    date: selectedDate,
                    time: selectedTime,
                    onDismiss: onDismiss
                )
            )
        }

        return AnyView(
            NavigationStack {
                VStack(spacing: 0) {
                    // Progress bar
                    progressBar

                    // Body
                    ScrollView {
                        VStack(alignment: .leading) {
                            stepContent(pro: pro)
                        }
                        .padding(16)
                        .padding(.bottom, 80)
                    }

                    // Footer
                    footerButton(pro: pro)
                }
                .navigationTitle("\(pro.firstName) · Step \(step.rawValue + 1) of \(BookingStep.allCases.count)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { goBack() } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { onDismiss() } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
            .onAppear {
                if let sid = initialServiceId {
                    selectedServiceId = sid
                    step = .date
                } else {
                    selectedServiceId = pro.services.first?.id
                }
            }
        )
    }

    // MARK: - Progress

    private var progressBar: some View {
        GeometryReader { geo in
            let pct = CGFloat(step.rawValue + 1) / CGFloat(BookingStep.allCases.count)
            ZStack(alignment: .leading) {
                Rectangle().fill(.quaternary)
                Rectangle().fill(Color.bookdAccent)
                    .frame(width: geo.size.width * pct)
                    .animation(.spring(duration: 0.3), value: step)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Step Content

    @ViewBuilder
    private func stepContent(pro: Professional) -> some View {
        switch step {
        case .service:
            serviceStep(pro: pro)
        case .date:
            dateStep
        case .time:
            timeStep
        case .notes:
            notesStep
        case .review:
            reviewStep(pro: pro)
        case .pay:
            payStep(pro: pro)
        }
    }

    // MARK: - Service Selection

    @ViewBuilder
    private func serviceStep(pro: Professional) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What are we\nbooking today?")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
            Text("Choose a service to see \(pro.firstName)'s open times.")
                .foregroundStyle(.secondary)
        }

        VStack(spacing: 10) {
            ForEach(pro.services) { s in
                let isSelected = s.id == selectedServiceId

                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedServiceId = s.id
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.bookdAccent : .clear)
                                .overlay(
                                    Circle().strokeBorder(isSelected ? AnyShapeStyle(.clear) : AnyShapeStyle(.tertiary), lineWidth: 1.5)
                                )
                                .frame(width: 22, height: 22)
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.name)
                                .font(.system(size: 15.5, weight: .bold))
                            HStack(spacing: 10) {
                                Label(s.formattedDuration, systemImage: "clock")
                                Text("·")
                                Text("In studio")
                            }
                            .font(.system(size: 12.5))
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(s.formattedPrice)
                            .font(.system(size: 18, weight: .heavy))
                            .tracking(-0.3)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: BookdRadius.lg)
                            .strokeBorder(isSelected ? Color.bookdAccent : .clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? .bookdAccent.opacity(0.18) : .clear, radius: 9, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 18)
    }

    // MARK: - Date

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pick a day.")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
            Text("Sundays are blocked. Slots may fill quickly.")
                .foregroundStyle(.secondary)

            DatePicker("Select date",
                       selection: Binding(
                        get: { selectedDate ?? Date() },
                        set: { selectedDate = $0 }
                       ),
                       in: Date()...,
                       displayedComponents: .date)
            .datePickerStyle(.graphical)
            .tint(.bookdAccent)
            .padding(.top, 18)

            if let date = selectedDate {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.bookdAccent)
                    Text("Selected · \(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.bookdAccent)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.bookdAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.md))
                .padding(.top, 14)
            }
        }
    }

    // MARK: - Time

    private var timeStep: some View {
        let slots: [(String, Bool)] = [
            ("9:00 AM", false), ("9:30 AM", true),
            ("10:00 AM", true), ("10:30 AM", false),
            ("11:00 AM", true), ("11:30 AM", true),
            ("12:00 PM", false), ("12:30 PM", false),
            ("1:00 PM", true), ("1:30 PM", true),
            ("2:00 PM", true), ("2:30 PM", false),
            ("3:00 PM", true), ("3:30 PM", true),
            ("4:00 PM", false), ("4:30 PM", true),
            ("5:00 PM", true), ("5:30 PM", true),
        ]

        let periods: [(String, Range<Int>)] = [
            ("Morning", 0..<6),
            ("Afternoon", 6..<14),
            ("Evening", 14..<18),
        ]

        return VStack(alignment: .leading, spacing: 6) {
            Text("What time works?")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)

            if let date = selectedDate {
                Text("\(date.formatted(.dateTime.weekday(.wide).month(.wide).day())) · Times shown in your local zone")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 14) {
                ForEach(periods, id: \.0) { period, range in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(period.uppercased())
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundStyle(.tertiary)

                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 8) {
                            ForEach(Array(slots[range]).indices, id: \.self) { i in
                                let slot = slots[range.lowerBound + i]
                                let isSelected = slot.0 == selectedTime

                                Button {
                                    if slot.1 {
                                        withAnimation(.spring(duration: 0.2)) {
                                            selectedTime = slot.0
                                        }
                                    }
                                } label: {
                                    let fgStyle: AnyShapeStyle = isSelected ? AnyShapeStyle(.white) :
                                        slot.1 ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
                                    let bgStyle: AnyShapeStyle = isSelected ? AnyShapeStyle(Color.bookdAccent) :
                                        slot.1 ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(.clear)
                                    let shadowColor: Color = isSelected ? .bookdAccent.opacity(0.32) : .clear

                                    Text(slot.0)
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(-0.2)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(fgStyle)
                                        .strikethrough(!slot.1)
                                        .background(bgStyle, in: RoundedRectangle(cornerRadius: BookdRadius.sm))
                                        .shadow(color: shadowColor, radius: 8, y: 3)
                                }
                                .disabled(!slot.1)
                            }
                        }
                    }
                }
            }
            .padding(.top, 18)
        }
    }

    // MARK: - Notes

    private var notesStep: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Anything to add?")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
            Text("Optional, but helps your pro prep.")
                .foregroundStyle(.secondary)

            TextEditor(text: $notes)
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                .overlay(alignment: .bottomTrailing) {
                    Text("\(notes.count)/280")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .padding(18)
                }
                .padding(.top, 18)
                .onChange(of: notes) { _, new in
                    if new.count > 280 { notes = String(new.prefix(280)) }
                }

            Text("QUICK ADD")
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundStyle(.tertiary)
                .padding(.top, 14)

            FlowLayout(spacing: 6) {
                ForEach(["First time client", "Bringing inspo pics", "Sensitive scalp", "Time-sensitive"], id: \.self) { preset in
                    Button {
                        notes = notes.isEmpty ? preset : "\(notes), \(preset.lowercased())"
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text(preset)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Review

    @ViewBuilder
    private func reviewStep(pro: Professional) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Quick review.")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
        }

        if let service {
            // Summary card
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    AvatarView(palette: pro.palette, size: 48, name: pro.name)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(pro.name).font(.system(size: 16, weight: .bold))
                            if pro.verified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.bookdAccent)
                            }
                        }
                        Text(pro.role)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }

                Divider().padding(.vertical, 14)

                summaryRow(icon: "sparkles", label: service.name, value: service.formattedPrice)
                summaryRow(icon: "calendar", label: selectedDate?.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()) ?? "—")
                summaryRow(icon: "clock", label: "\(selectedTime ?? "—") · \(service.formattedDuration)")
                summaryRow(icon: "mappin", label: "247 Wilson Ave, Brooklyn")
                if !notes.isEmpty {
                    summaryRow(icon: "pencil", label: notes.count > 50 ? String(notes.prefix(50)) + "…" : notes)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.top, 18)

            // Tip
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Add a tip").font(.system(size: 15, weight: .bold))
                        Text("100% goes to \(pro.firstName)")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("OPTIONAL")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.tertiary)
                }
                HStack(spacing: 8) {
                    ForEach([0, 10, 15, 20], id: \.self) { t in
                        Button {
                            withAnimation { tip = t }
                        } label: {
                            Text(t == 0 ? "No tip" : "\(t)%")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundStyle(tip == t ? .white : .primary)
                                .background(tip == t ? AnyShapeStyle(.primary) : AnyShapeStyle(.quaternary),
                                            in: RoundedRectangle(cornerRadius: BookdRadius.sm))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.top, 12)

            // Price breakdown
            priceBreakdown(service: service)
                .padding(.top, 12)

            Text("Free cancellation up to 24h before. After that, 50% charge.")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .padding(.top, 12)
        }
    }

    private func summaryRow(icon: String, label: String, value: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 24, height: 24)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.secondary)
            Text(label)
                .font(.system(size: 14, weight: .medium))
            Spacer()
            if let value {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Pay

    @ViewBuilder
    private func payStep(pro: Professional) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pay & confirm.")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
            Text("Held until the appointment is complete.")
                .foregroundStyle(.secondary)
        }

        if let service {
            // Payment methods
            VStack(spacing: 10) {
                payOption(id: "apple", icon: "apple.logo", title: "Apple Pay", subtitle: "Touch ID · Default", featured: true)
                payOption(id: "card", icon: "creditcard", title: "Visa •• 4982", subtitle: "Expires 09/27")
                payOption(id: "add", icon: "plus", title: "Add a new card")
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.top, 18)

            priceBreakdown(service: service)
                .padding(.top, 12)

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                Text("Encrypted by Stripe · Bookd never sees your card")
            }
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
        }
    }

    private func payOption(id: String, icon: String, title: String, subtitle: String? = nil, featured: Bool = false) -> some View {
        let isSelected = payMethod == id
        return Button {
            withAnimation { payMethod = id }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 36, height: 36)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(title).font(.system(size: 14.5, weight: .bold))
                        if featured {
                            StickerView(text: "Fast", color: Color(hex: "FFE082"), rotation: 0)
                        }
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.bookdAccent : .clear)
                        .overlay(
                            Circle().strokeBorder(isSelected ? AnyShapeStyle(.clear) : AnyShapeStyle(.tertiary), lineWidth: 1.5)
                        )
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? AnyShapeStyle(Color.bookdAccentSoft) : AnyShapeStyle(.clear),
                        in: RoundedRectangle(cornerRadius: BookdRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: BookdRadius.sm)
                    .strokeBorder(isSelected ? Color.bookdAccent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Price Breakdown

    private func priceBreakdown(service: ProService) -> some View {
        let tipAmount = Double(service.price) * Double(tip) / 100.0
        let total = Double(service.price) + tipAmount + 2

        return VStack(spacing: 0) {
            priceRow(label: "Service", value: "$\(service.price).00")
            priceRow(label: "Tip (\(tip)%)", value: "$\(String(format: "%.2f", tipAmount))")
            priceRow(label: "Booking fee", value: "$2.00")
            Divider().padding(.vertical, 10)
            priceRow(label: "Total", value: "$\(String(format: "%.2f", total))", bold: true)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    private func priceRow(label: String, value: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
        .font(.system(size: bold ? 16 : 14, weight: bold ? .heavy : .medium))
        .foregroundStyle(bold ? .primary : .secondary)
        .padding(.vertical, 4)
    }

    // MARK: - Footer

    @ViewBuilder
    private func footerButton(pro: Professional) -> some View {
        VStack {
            Divider()
            if step == .pay {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        confirmed = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                        if let service {
                            let tipAmt = Double(service.price) * Double(tip) / 100.0
                            let total = Double(service.price) + tipAmt + 2
                            let label = String(format: "%.2f", total)
                            Text("Pay $\(label) with Apple Pay")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.black)
                .sensoryFeedback(.success, trigger: confirmed)
            } else {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        advanceStep()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if step == .service, let service {
                            Text("Continue · \(service.formattedPrice)")
                        } else if step == .review {
                            Text("Continue to payment")
                        } else {
                            Text("Continue")
                        }
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.bookdAccent)
                .disabled(!canContinue)
            }
        }
        .padding(16)
        .background(.regularMaterial)
    }

    // MARK: - Navigation

    private var canContinue: Bool {
        switch step {
        case .service: selectedServiceId != nil
        case .date: selectedDate != nil
        case .time: selectedTime != nil
        case .notes, .review, .pay: true
        }
    }

    private func advanceStep() {
        guard let next = BookingStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    private func goBack() {
        if let prev = BookingStep(rawValue: step.rawValue - 1) {
            step = prev
        } else {
            onDismiss()
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                                  proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (origins, CGSize(width: maxX, height: y + rowHeight))
    }
}
