import SwiftUI

struct OnboardingSlide {
    let eyebrow: String
    let title: String
    let body: String
    let palette: [String]
    let stickerText: String
    let stickerColor: Color
    let stickerRotation: Double
}

private let slides: [OnboardingSlide] = [
    OnboardingSlide(
        eyebrow: "For pros",
        title: "Showcase\nyour craft.",
        body: "Build a profile that does the selling — your work, your hours, your price.",
        palette: ["#FF7A59", "#FFB259", "#FFE0C4", "#7E5BFF"],
        stickerText: "⚡ BOOKD",
        stickerColor: Color(hex: "FFE082"),
        stickerRotation: -8
    ),
    OnboardingSlide(
        eyebrow: "For clients",
        title: "Get discovered.",
        body: "Scroll a feed of pros near you. Tap to book — no DMs, no back and forth.",
        palette: ["#0B1538", "#3B2F87", "#B385FF", "#6C5CE7"],
        stickerText: "TRENDING",
        stickerColor: Color(hex: "B385FF"),
        stickerRotation: 6
    ),
    OnboardingSlide(
        eyebrow: "For everyone",
        title: "Book in\nseconds.",
        body: "Apple Pay, calendar sync, smart reminders. Done.",
        palette: ["#7AE582", "#0BBFA2", "#FFD86B", "#0F4D3F"],
        stickerText: "< 30 sec",
        stickerColor: Color(hex: "7AE582"),
        stickerRotation: -3
    ),
]

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentIndex = 0

    var body: some View {
        let slide = slides[currentIndex]

        ZStack {
            // Full-bleed gradient background
            MeshGradientImage(palette: slide.palette, seed: currentIndex + 2)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentIndex)

            VStack {
                // Top bar
                HStack {
                    Text("Bookd")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(.white)
                    Text(".")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color(hex: "FFE082"))
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Sticker
                HStack {
                    Spacer()
                    StickerView(text: slide.stickerText, color: slide.stickerColor, rotation: slide.stickerRotation)
                        .padding(.trailing, 28)
                }

                // Floating glass card
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .frame(width: 220, height: 280)
                    .overlay {
                        VStack {
                            MeshGradientImage(palette: slide.palette.reversed(), seed: currentIndex + 4)
                                .frame(maxHeight: .infinity)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("NEXT SLOT")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.7))
                                Text("Tomorrow, 11:00")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .rotationEffect(.degrees(-4))
                    .shadow(color: .black.opacity(0.2), radius: 40, y: 30)

                Spacer()

                // Bottom content card
                VStack(alignment: .leading, spacing: 0) {
                    Text(slide.eyebrow)
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.7)
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.85))

                    Text(slide.title)
                        .font(.system(size: 44, weight: .heavy))
                        .tracking(-1.3)
                        .lineSpacing(-4)
                        .foregroundStyle(.white)
                        .padding(.top, 10)

                    Text(slide.body)
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(2)
                        .padding(.top, 12)
                        .frame(maxWidth: 320, alignment: .leading)

                    // Dots + CTA
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<slides.count, id: \.self) { i in
                                Capsule()
                                    .fill(.white.opacity(i == currentIndex ? 1 : 0.4))
                                    .frame(width: i == currentIndex ? 22 : 6, height: 6)
                                    .animation(.spring(duration: 0.3), value: currentIndex)
                            }
                        }

                        Spacer()

                        Button {
                            withAnimation(.spring(duration: 0.4)) {
                                if currentIndex < slides.count - 1 {
                                    currentIndex += 1
                                } else {
                                    onComplete()
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(currentIndex == slides.count - 1 ? "Get started" : "Continue")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(.white, in: Capsule())
                        }
                    }
                    .padding(.top, 28)

                    // Sign in link
                    HStack {
                        Spacer()
                        Text("Already have an account? ")
                            .foregroundStyle(.white.opacity(0.8))
                        + Text("Sign in")
                            .foregroundStyle(.white)
                            .bold()
                            .underline()
                        Spacer()
                    }
                    .font(.system(size: 13))
                    .padding(.top, 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        .padding(.top, -60)
                )
            }
        }
    }
}
