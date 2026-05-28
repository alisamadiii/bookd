import SwiftUI

struct WorkingHoursView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    @State private var hours: [DayHours] = []
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private static let shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(hours.enumerated()), id: \.element.dayOfWeek) { idx, _ in
                            dayRow(index: idx)
                            if idx < hours.count - 1 {
                                Divider().padding(.leading, 76)
                            }
                        }
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Working hours")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Save") { Task { await save() } }
                        .fontWeight(.bold)
                }
            }
        }
        .task { await loadHours() }
        .errorAlert($errorMessage)
    }

    // MARK: - Day Row

    private func dayRow(index: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text(Self.shortDayNames[hours[index].dayOfWeek])
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 40, alignment: .leading)

                Toggle("", isOn: $hours[index].isOpen)
                    .labelsHidden()
                    .tint(.bookdProAccent)

                if hours[index].isOpen {
                    Text("\(hours[index].openTime) — \(hours[index].closeTime)")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                } else {
                    Text("Closed")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }

            if hours[index].isOpen {
                HStack(spacing: 12) {
                    timePicker(label: "From", time: $hours[index].openTime)
                    timePicker(label: "To", time: $hours[index].closeTime)
                }
                .padding(.leading, 52)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .animation(.spring(duration: 0.25), value: hours[index].isOpen)
    }

    private func timePicker(label: String, time: Binding<String>) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            DatePicker(
                "",
                selection: Binding(
                    get: { timeStringToDate(time.wrappedValue) },
                    set: { time.wrappedValue = dateToTimeString($0) }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
        }
    }

    // MARK: - Data

    private func loadHours() async {
        guard let proId = authManager.proProfile?.id else {
            isLoading = false
            return
        }

        do {
            let dbHours = try await dataService.loadWorkingHours(proId: proId)
            if dbHours.isEmpty {
                hours = Self.defaultHours()
            } else {
                hours = dbHours.sorted(by: { $0.dayOfWeek < $1.dayOfWeek }).map {
                    DayHours(id: $0.id, dayOfWeek: $0.dayOfWeek, isOpen: $0.isOpen, openTime: $0.openTime, closeTime: $0.closeTime)
                }
            }
        } catch {
            hours = Self.defaultHours()
            errorMessage = "Failed to load hours: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func save() async {
        guard let proId = authManager.proProfile?.id else { return }
        isSaving = true

        do {
            let dbHours = hours.map { h in
                DBWorkingHours(
                    id: h.id,
                    proId: proId,
                    dayOfWeek: h.dayOfWeek,
                    isOpen: h.isOpen,
                    openTime: h.openTime,
                    closeTime: h.closeTime
                )
            }
            try await dataService.upsertWorkingHours(dbHours)
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
        isSaving = false
    }

    // MARK: - Helpers

    private func timeStringToDate(_ str: String) -> Date {
        let parts = str.split(separator: ":").compactMap { Int($0) }
        let hour = parts.count > 0 ? parts[0] : 9
        let minute = parts.count > 1 ? parts[1] : 0
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func dateToTimeString(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", comps.hour ?? 9, comps.minute ?? 0)
    }

    private static func defaultHours() -> [DayHours] {
        (0...6).map { day in
            DayHours(
                id: UUID(),
                dayOfWeek: day,
                isOpen: day >= 1 && day <= 6, // Mon-Sat open, Sun closed
                openTime: "10:00",
                closeTime: "19:00"
            )
        }
    }
}

// MARK: - Local Model

private struct DayHours: Identifiable {
    let id: UUID
    let dayOfWeek: Int
    var isOpen: Bool
    var openTime: String
    var closeTime: String
}
