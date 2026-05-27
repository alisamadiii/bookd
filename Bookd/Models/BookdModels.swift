import Foundation

// MARK: - Category

struct ProCategory: Identifiable, Hashable {
    let id: String
    let label: String
    let emoji: String
    let systemImage: String

    static let all: [ProCategory] = [
        .init(id: "all", label: "For you", emoji: "✦", systemImage: "sparkles"),
        .init(id: "hair", label: "Hair", emoji: "✂", systemImage: "scissors"),
        .init(id: "tattoo", label: "Tattoo", emoji: "✶", systemImage: "paintbrush.pointed"),
        .init(id: "fitness", label: "Fitness", emoji: "◐", systemImage: "figure.run"),
        .init(id: "beauty", label: "Beauty", emoji: "✿", systemImage: "sparkle"),
        .init(id: "wellness", label: "Wellness", emoji: "◌", systemImage: "leaf"),
        .init(id: "photo", label: "Photo", emoji: "◉", systemImage: "camera"),
        .init(id: "coach", label: "Coaching", emoji: "◇", systemImage: "person.2"),
    ]
}

// MARK: - Service

struct ProService: Identifiable, Hashable {
    let id: String
    var name: String
    var price: Int
    var duration: Int // minutes

    var formattedPrice: String {
        price == 0 ? "Free" : "$\(price)"
    }

    var formattedDuration: String {
        if duration < 60 { return "\(duration)m" }
        let h = duration / 60
        let m = duration % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

// MARK: - Professional

struct Professional: Identifiable, Hashable {
    let id: String
    let name: String
    let handle: String
    let category: String
    let role: String
    let city: String
    let verified: Bool
    let rating: Double
    let reviews: Int
    let followers: String
    let palette: [String] // hex colors for gradient
    let bio: String
    let badges: [String]
    let nextSlot: String
    let priceRange: String
    let services: [ProService]
    let posts: Int

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }

    var cityShort: String {
        city.components(separatedBy: ",").first ?? city
    }
}

// MARK: - Review

struct ProReview: Identifiable {
    let id: String
    let author: String
    let rating: Int
    let when: String
    let text: String
    let avatarPalette: [String]
}

// MARK: - Appointment

enum AppointmentStatus: String, CaseIterable {
    case upcoming, past, cancelled
}

struct Appointment: Identifiable {
    let id: String
    let proId: String
    let service: String
    let date: String
    let time: String
    let duration: Int
    let price: Int
    let status: AppointmentStatus
    let location: String

    var datePrefix: String {
        date.components(separatedBy: " ").first ?? date
    }

    var dateSuffix: String {
        let parts = date.components(separatedBy: " ")
        return parts.count > 1 ? parts[1] : "✓"
    }
}

// MARK: - Message Thread

struct MessageThread: Identifiable {
    let id: String
    let proId: String
    let lastMessage: String
    let when: String
    let unread: Int
}

struct ChatMessage: Identifiable {
    let id: String
    let fromMe: Bool
    let text: String
    let when: String
}

// MARK: - Pro Stats

struct ProStats {
    let todayBookings: Int
    let weekEarnings: Int
    let monthEarnings: Int
    let profileViews: Int
    let bookingRate: Double
    let todaySchedule: [ScheduleEntry]
}

struct ScheduleEntry: Identifiable {
    let id = UUID()
    let time: String
    let client: String
    let service: String
    let duration: Int
}

// MARK: - Calendar Block

struct CalendarBlock: Identifiable {
    let id = UUID()
    let hour: Double
    let span: Double
    let name: String
    let service: String
    let color: String // hex
}

// MARK: - Client "Me"

struct ClientProfile {
    let name: String
    let handle: String
    let avatarPalette: [String]
}

// MARK: - Portfolio Post

struct PortfolioPost: Identifiable {
    let id: String
    let caption: String
    let likes: Int
    let seed: Int
}
