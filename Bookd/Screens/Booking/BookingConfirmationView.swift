import SwiftUI

struct BookingConfirmationView: View {
    let pro: Professional
    let service: ProService
    let date: Date?
    let time: String?
    let onDismiss: () -> Void

    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Background gradient (top half)
            VStack {
                GeometryReader { geo in
                    MeshGradientImage(palette: pro.palette, seed: 4)
                        .frame(height: geo.size.height * 0.45)
                        .overlay(
                            LinearGradient(colors: [.clear, Color(.systemBackground)],
                                           startPoint: .init(x: 0.5, y: 0.3), endPoint: .bottom)
                        )
                }
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                Spacer()
                    .frame(height: 60)

                // Check badge
                ZStack {
                    Circle()
                        .fill(.background)
                        .frame(width: 96, height: 96)
                        .shadow(color: .black.opacity(0.18), radius: 25, y: 10)

                    Circle()
                        .fill(Color.bookdAccent)
                        .frame(width: 72, height: 72)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showConfetti ? 1 : 0.5)
                .opacity(showConfetti ? 1 : 0)
                .animation(.spring(duration: 0.5, bounce: 0.3), value: showConfetti)
                .sensoryFeedback(.success, trigger: showConfetti)

                // "You're bookd"
                Text("YOU'RE BOOKD")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(1.7)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .padding(.top, 28)

                // Day + time
                VStack(spacing: 4) {
                    if let date {
                        Text("See you \(date.formatted(.dateTime.weekday(.wide)))")
                            .font(.system(size: 36, weight: .heavy))
                            .tracking(-1)
                    }
                    if let time {
                        Text("at \(time).")
                            .font(.system(size: 36, weight: .heavy))
                            .tracking(-1)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()
                    .frame(height: 20)

                // Details card
                HStack(spacing: 12) {
                    AvatarView(palette: pro.palette, size: 48, name: pro.name)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(pro.name).font(.system(size: 15, weight: .bold))
                            if pro.verified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.bookdAccent)
                            }
                        }
                        Text("\(service.name) · \(service.formattedPrice)")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                        if let date {
                            Text("\(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())) · \(time ?? "")")
                                .font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button { } label: {
                        Label("Chat", systemImage: "bubble.right")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
                .padding(.horizontal, 16)

                // Action buttons
                HStack(spacing: 8) {
                    Button { } label: {
                        Label("Add to Calendar", systemImage: "calendar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button { } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Button {
                    onDismiss()
                } label: {
                    Text("View my bookings")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.bookdAccent)
                .padding(.horizontal, 16)
                .padding(.top, 10)

                Button("Back home") {
                    onDismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 14)

                Spacer()
            }

            // Confetti
            if showConfetti {
                ConfettiView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}
