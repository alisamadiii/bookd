import SwiftUI

struct AppointmentsView: View {
    @Binding var selectedProId: String?
    @State private var selectedTab: AppointmentStatus = .upcoming

    private var filteredAppointments: [Appointment] {
        SampleData.appointments.filter { $0.status == selectedTab }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Segment control
                Picker("Status", selection: $selectedTab) {
                    Text("Upcoming").tag(AppointmentStatus.upcoming)
                    Text("Past").tag(AppointmentStatus.past)
                    Text("Cancelled").tag(AppointmentStatus.cancelled)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                // Appointment cards
                if filteredAppointments.isEmpty {
                    ContentUnavailableView("Nothing here yet",
                                           systemImage: "calendar",
                                           description: Text("Browse pros on Home."))
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAppointments) { appointment in
                            appointmentCard(appointment)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Bookings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: { Image(systemName: "calendar") }
            }
        }
    }

    @ViewBuilder
    private func appointmentCard(_ appt: Appointment) -> some View {
        let pro = SampleData.pro(for: appt.proId)

        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Date badge
                VStack(spacing: 2) {
                    Text(appt.datePrefix)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .textCase(.uppercase)
                        .opacity(0.7)
                    Text(appt.dateSuffix)
                        .font(.system(size: 20, weight: .heavy))
                        .tracking(-0.3)
                }
                .frame(minWidth: 56)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .foregroundStyle(appt.status == .upcoming ? .white : .primary)
                .background(
                    appt.status == .upcoming ? AnyShapeStyle(Color.bookdAccent) : AnyShapeStyle(.quaternary),
                    in: RoundedRectangle(cornerRadius: 12)
                )

                // Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(appt.service)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    if let pro {
                        HStack(spacing: 4) {
                            Text(pro.name)
                                .font(.system(size: 15, weight: .bold))
                            if pro.verified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.bookdAccent)
                            }
                        }
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("\(appt.time) · \(ProService(id: "", name: "", price: 0, duration: appt.duration).formattedDuration) · $\(appt.price)")
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
                Spacer()

                if let pro {
                    AvatarView(palette: pro.palette, size: 42, name: pro.name)
                }
            }

            Divider()
                .padding(.vertical, 14)

            // Actions
            HStack(spacing: 6) {
                switch appt.status {
                case .upcoming:
                    Button { } label: {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button { } label: {
                        Label("Message", systemImage: "bubble.right")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Spacer()

                    Button("Cancel", role: .destructive) { }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                case .past:
                    Button {
                        selectedProId = appt.proId
                    } label: {
                        Text("Book again")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.bookdAccent)

                    Button { } label: {
                        Label("Leave review", systemImage: "star")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                case .cancelled:
                    StickerView(text: "Cancelled", color: Color(hex: "FFCED0"), rotation: 0)
                    Spacer()
                    Button {
                        selectedProId = appt.proId
                    } label: {
                        Text("Rebook")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }
}
