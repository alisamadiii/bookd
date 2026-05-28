import SwiftUI

enum ProSetupStep: Int, CaseIterable {
    case basics, category, services, hours, gallery

    var label: String {
        switch self {
        case .basics: "Basics"
        case .category: "Category"
        case .services: "Services"
        case .hours: "Hours"
        case .gallery: "Gallery"
        }
    }
}

struct ProSetupView: View {
    let onDone: () -> Void
    let onClose: () -> Void

    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    @State private var step: ProSetupStep = .basics
    @State private var businessName = ""
    @State private var city = ""
    @State private var bio = ""
    @State private var selectedCategory: String?
    @State private var services: [ProService] = [
        ProService(id: "s1", name: "Signature cut", price: 120, duration: 45)
    ]
    @State private var openDays = [true, true, true, true, true, true, false]
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Progress segments
                    HStack(spacing: 4) {
                        ForEach(ProSetupStep.allCases, id: \.rawValue) { s in
                            Capsule()
                                .fill(s.rawValue <= step.rawValue ? AnyShapeStyle(Color.bookdProAccent) : AnyShapeStyle(.quaternary))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .animation(.spring(duration: 0.3), value: step)

                    // Body
                    ScrollView {
                        VStack(alignment: .leading) {
                            stepContent
                        }
                        .padding(16)
                        .padding(.bottom, 80)
                    }

                    // Footer
                    VStack {
                        Button {
                            if step == .gallery {
                                Task { await publishProfile() }
                            } else {
                                withAnimation(.spring(duration: 0.3)) {
                                    if let next = ProSetupStep(rawValue: step.rawValue + 1) {
                                        step = next
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(step == .gallery ? "Publish profile" : "Continue")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.bookdProAccent)
                        .disabled(isSaving || !canContinue)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                }
                .navigationTitle("Build your Bookd")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if step.rawValue > 0 {
                            Button {
                                if let prev = ProSetupStep(rawValue: step.rawValue - 1) {
                                    withAnimation { step = prev }
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                        } else {
                            Button("Cancel") { onClose() }
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }

                if isSaving {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Publishing...")
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                }
            }
        }
        .interactiveDismissDisabled(isSaving)
        .errorAlert($errorMessage)
    }

    private var canContinue: Bool {
        switch step {
        case .basics: !businessName.isEmpty
        case .category: selectedCategory != nil
        case .services: !services.isEmpty && services.contains { !$0.name.isEmpty }
        case .hours: true
        case .gallery: true
        }
    }

    // MARK: - Publish

    private func publishProfile() async {
        isSaving = true

        do {
            // 1. Create pro profile + set role
            try await authManager.createProProfile(
                businessName: businessName,
                category: selectedCategory ?? "hair",
                city: city,
                bio: bio
            )

            guard let proProfile = authManager.proProfile else {
                errorMessage = "Failed to create profile. Please try again."
                isSaving = false
                return
            }

            // 2. Insert services
            for (idx, service) in services.enumerated() where !service.name.isEmpty {
                var record: [String: String] = [
                    "pro_id": proProfile.id.uuidString,
                    "name": service.name,
                    "price": "\(service.price * 100)", // convert to cents
                    "duration": "\(service.duration)",
                    "sort_order": "\(idx)",
                    "is_active": "true",
                ]
                try await AppSupabase.client
                    .from("services")
                    .insert(record)
                    .execute()
            }

            // 3. Insert working hours (Mon=1..Sun=0 mapping: openDays[0]=Mon..openDays[6]=Sun)
            let dayMapping = [1, 2, 3, 4, 5, 6, 0] // Mon-Sun → DB day_of_week
            for (idx, isOpen) in openDays.enumerated() {
                let record: [String: String] = [
                    "pro_id": proProfile.id.uuidString,
                    "day_of_week": "\(dayMapping[idx])",
                    "is_open": "\(isOpen)",
                    "open_time": "10:00",
                    "close_time": "19:00",
                ]
                try await AppSupabase.client
                    .from("working_hours")
                    .insert(record)
                    .execute()
            }

            // 4. Reload profile state
            await authManager.reloadProfile()

            onDone()
        } catch {
            errorMessage = "Failed to publish: \(error.localizedDescription)"
        }

        isSaving = false
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .basics:
            basicsStep
        case .category:
            categoryStep
        case .services:
            servicesStep
        case .hours:
            hoursStep
        case .gallery:
            galleryStep
        }
    }

    // MARK: - Basics

    private var basicsStep: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Let's start with\nthe basics.")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
            Text("This is what clients see first.")
                .foregroundStyle(.secondary)

            // Cover + avatar
            ZStack(alignment: .bottomLeading) {
                MeshGradientImage(palette: ["#FF7A59", "#FFB259", "#FFE0C4", "#7E5BFF"], seed: 2)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: BookdRadius.lg))
                    .overlay(alignment: .topTrailing) {
                        Button { } label: {
                            Image(systemName: "camera")
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .padding(12)
                    }

                ZStack {
                    MeshGradientImage(palette: ["#7E5BFF", "#FF7A59"], seed: 3)
                        .frame(width: 84, height: 84)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.background, lineWidth: 4))

                    Button { } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.bookdProAccent, in: Circle())
                            .overlay(Circle().strokeBorder(.background, lineWidth: 3))
                    }
                    .offset(x: 28, y: 28)
                }
                .offset(x: 16, y: 42)
            }
            .padding(.top, 22)

            VStack(spacing: 12) {
                formField(label: "Business name", text: $businessName, placeholder: "Mira Cuts · Editorial color")
                formField(label: "Location", text: $city, icon: "mappin")
                formField(label: "Short bio", text: $bio, placeholder: "What makes your work unique?", multiline: true)
            }
            .padding(.top, 50)
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String = "", icon: String? = nil, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.tertiary)

            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                if multiline {
                    TextEditor(text: text)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.sm))
        }
    }

    // MARK: - Category

    private var categoryStep: some View {
        let cats = ProCategory.all.filter { $0.id != "all" }
        let palettes: [[String]] = [
            ["#FF7A59", "#FFB259"], ["#0B1538", "#B385FF"], ["#7AE582", "#0BBFA2"],
            ["#FFCED0", "#A93665"], ["#C7E4C2", "#384E2B"], ["#1A1A1F", "#FF5A5F"],
            ["#6C5CE7", "#FFD86B"],
        ]

        return VStack(alignment: .leading, spacing: 6) {
            Text("What's your craft?")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
            Text("Helps clients find you in the right feed.")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible())], spacing: 10) {
                ForEach(Array(cats.enumerated()), id: \.element.id) { idx, cat in
                    let isSelected = selectedCategory == cat.id
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedCategory = cat.id
                        }
                    } label: {
                        ZStack(alignment: .bottomLeading) {
                            MeshGradientImage(palette: palettes[idx % palettes.count], seed: idx + 1)

                            LinearGradient(colors: [.clear, .black.opacity(0.4)],
                                           startPoint: .top, endPoint: .bottom)

                            VStack(alignment: .leading) {
                                Text(cat.emoji)
                                    .font(.system(size: 28))
                                    .padding(.leading, 14)
                                    .padding(.top, 12)
                                Spacer()
                                Text(cat.label)
                                    .font(.system(size: 18, weight: .heavy))
                                    .tracking(-0.3)
                                    .foregroundStyle(.white)
                                    .padding(.leading, 14)
                                    .padding(.bottom, 12)
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: BookdRadius.md)
                                .strokeBorder(isSelected ? Color.bookdProAccent : .clear, lineWidth: 2.5)
                        )
                        .scaleEffect(isSelected ? 1.02 : 1)
                        .shadow(color: isSelected ? .bookdProAccent.opacity(0.2) : .clear, radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 18)
        }
    }

    // MARK: - Services

    private var servicesStep: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Build your menu.")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
            Text("Add services with clear prices. You can refine later.")
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach($services) { $s in
                    VStack(spacing: 8) {
                        HStack {
                            TextField("Service name", text: $s.name)
                                .font(.system(size: 15, weight: .bold))
                            Button { services.removeAll { $0.id == s.id } } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .frame(width: 28, height: 28)
                                    .background(.quaternary, in: Circle())
                            }
                        }
                        HStack(spacing: 8) {
                            HStack {
                                Text("$").foregroundStyle(.secondary)
                                TextField("0", value: $s.price, format: .number)
                                    .keyboardType(.numberPad)
                                    .fontWeight(.bold)
                            }
                            .padding(8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.secondary)
                                TextField("0", value: $s.duration, format: .number)
                                    .keyboardType(.numberPad)
                                    .fontWeight(.bold)
                                Text("min").foregroundStyle(.tertiary).font(.system(size: 12))
                            }
                            .padding(8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(14)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                }

                Button {
                    services.append(ProService(id: "s\(Date.now.timeIntervalSince1970)", name: "New service", price: 0, duration: 30))
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add service")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: BookdRadius.sm)
                            .strokeBorder(.tertiary, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                }
            }
            .padding(.top, 18)
        }
    }

    // MARK: - Hours

    private var hoursStep: some View {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return VStack(alignment: .leading, spacing: 6) {
            Text("Set your hours.")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
            Text("Block off times you're unavailable.")
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
                    HStack(spacing: 12) {
                        Text(day)
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 60, alignment: .leading)

                        Toggle("", isOn: $openDays[idx])
                            .labelsHidden()
                            .tint(.bookdProAccent)

                        Text(openDays[idx] ? "10:00 AM — 7:00 PM" : "Closed")
                            .font(.system(size: 14))
                            .foregroundStyle(openDays[idx] ? .primary : .tertiary)

                        Spacer()

                        if openDays[idx] {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if idx < days.count - 1 {
                        Divider().padding(.leading, 76)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.top, 18)
        }
    }

    // MARK: - Gallery

    private var galleryStep: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Show your work.")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
            Text("Drop at least 6 photos so your profile feels alive.")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 6), count: 3), spacing: 6) {
                ForEach(0..<9, id: \.self) { i in
                    if i < 5 {
                        ZStack(alignment: .topTrailing) {
                            MeshGradientImage(palette: ["#FF7A59", "#FFB259", "#FFE0C4", "#7E5BFF"], seed: i + 1)
                                .aspectRatio(1, contentMode: .fill)

                            Button { } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                                    .frame(width: 22, height: 22)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(4)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.xs))
                    } else {
                        Button { } label: {
                            RoundedRectangle(cornerRadius: BookdRadius.xs)
                                .strokeBorder(.tertiary, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .aspectRatio(1, contentMode: .fill)
                                .overlay {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.tertiary)
                                }
                        }
                    }
                }
            }
            .padding(.top, 18)

            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.bookdProAccent)
                Text("**Tip:** Bookd pros with 9+ portfolio posts get 3× more bookings.")
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.bookdProAccent)
            .padding(14)
            .background(Color.bookdProAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.md))
            .padding(.top, 16)
        }
    }
}
