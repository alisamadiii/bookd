import Foundation

// MARK: - Database model types (Codable, matching Supabase schema)
// These map 1:1 to database rows. The existing UI models (Professional, etc.)
// are kept for view compatibility; mappers convert between them.

struct DBProfile: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var role: String
    var fullName: String
    var handle: String?
    var avatarUrl: String?
    var palette: [String]?
    var phone: String?
    var email: String?
    var pushToken: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, role, handle, phone, email, palette
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case pushToken = "push_token"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBProProfile: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    var businessName: String
    var bio: String?
    var category: String
    var roleTitle: String?
    var city: String?
    var latitude: Double?
    var longitude: Double?
    var verified: Bool
    var avatarUrl: String?
    var coverUrl: String?
    var badges: [String]?
    var stripeAccountId: String?
    var stripeOnboarded: Bool
    var rating: Double
    var reviewsCount: Int
    var followersCount: Int
    var postsCount: Int
    var avgResponseMinutes: Int?
    var isPublished: Bool
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, bio, category, city, latitude, longitude, verified, badges, rating
        case userId = "user_id"
        case businessName = "business_name"
        case roleTitle = "role_title"
        case avatarUrl = "avatar_url"
        case coverUrl = "cover_url"
        case stripeAccountId = "stripe_account_id"
        case stripeOnboarded = "stripe_onboarded"
        case reviewsCount = "reviews_count"
        case followersCount = "followers_count"
        case postsCount = "posts_count"
        case avgResponseMinutes = "avg_response_minutes"
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBService: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let proId: UUID
    var name: String
    var description: String?
    var price: Int // cents
    var duration: Int // minutes
    var isActive: Bool
    var sortOrder: Int
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, duration
        case proId = "pro_id"
        case isActive = "is_active"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var priceInDollars: Int { price / 100 }
    var formattedPrice: String { price == 0 ? "Free" : "$\(priceInDollars)" }
    var formattedDuration: String {
        if duration < 60 { return "\(duration)m" }
        let h = duration / 60; let m = duration % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

struct DBAppointment: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let proId: UUID
    let clientId: UUID
    let serviceId: UUID
    var serviceName: String
    var servicePrice: Int
    var startsAt: Date
    var duration: Int
    var status: String
    var location: String?
    var notes: String?
    var tipPercent: Int?
    var tipAmount: Int?
    var bookingFee: Int
    var subtotal: Int
    var total: Int
    var stripePaymentIntentId: String?
    var paymentMethod: String?
    var paymentStatus: String?
    var cancelledAt: Date?
    var cancelledBy: UUID?
    var cancellationReason: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, duration, status, location, notes, subtotal, total
        case proId = "pro_id"
        case clientId = "client_id"
        case serviceId = "service_id"
        case serviceName = "service_name"
        case servicePrice = "service_price"
        case startsAt = "starts_at"
        case tipPercent = "tip_percent"
        case tipAmount = "tip_amount"
        case bookingFee = "booking_fee"
        case stripePaymentIntentId = "stripe_payment_intent_id"
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case cancelledAt = "cancelled_at"
        case cancelledBy = "cancelled_by"
        case cancellationReason = "cancellation_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBReview: Codable, Identifiable, Sendable {
    let id: UUID
    let proId: UUID
    let clientId: UUID
    var appointmentId: UUID?
    var rating: Int
    var text: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, rating, text
        case proId = "pro_id"
        case clientId = "client_id"
        case appointmentId = "appointment_id"
        case createdAt = "created_at"
    }
}

struct DBPortfolioPost: Codable, Identifiable, Sendable {
    let id: UUID
    let proId: UUID
    var imageUrl: String
    var caption: String?
    var likesCount: Int
    var sortOrder: Int
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, caption
        case proId = "pro_id"
        case imageUrl = "image_url"
        case likesCount = "likes_count"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
}

struct DBMessageThread: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let proId: UUID
    let clientId: UUID
    var lastMessageText: String?
    var lastMessageAt: Date?
    var clientUnreadCount: Int
    var proUnreadCount: Int
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case proId = "pro_id"
        case clientId = "client_id"
        case lastMessageText = "last_message_text"
        case lastMessageAt = "last_message_at"
        case clientUnreadCount = "client_unread_count"
        case proUnreadCount = "pro_unread_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBMessage: Codable, Identifiable, Sendable {
    let id: UUID
    let threadId: UUID
    let senderId: UUID
    var body: String
    var readAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, body
        case threadId = "thread_id"
        case senderId = "sender_id"
        case readAt = "read_at"
        case createdAt = "created_at"
    }
}

struct DBFavorite: Codable, Identifiable, Sendable {
    let id: UUID
    let clientId: UUID
    let proId: UUID
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case proId = "pro_id"
        case createdAt = "created_at"
    }
}

struct DBWorkingHours: Codable, Identifiable, Sendable {
    let id: UUID
    let proId: UUID
    var dayOfWeek: Int
    var isOpen: Bool
    var openTime: String
    var closeTime: String

    enum CodingKeys: String, CodingKey {
        case id
        case proId = "pro_id"
        case dayOfWeek = "day_of_week"
        case isOpen = "is_open"
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}

struct DBNotification: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var type: String
    var title: String
    var body: String?
    var data: [String: String]?
    var readAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, type, title, body, data
        case userId = "user_id"
        case readAt = "read_at"
        case createdAt = "created_at"
    }
}

struct DBProfileView: Codable, Identifiable, Sendable {
    let id: UUID
    let proId: UUID
    let viewerId: UUID?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case proId = "pro_id"
        case viewerId = "viewer_id"
        case createdAt = "created_at"
    }
}

// MARK: - Insert types (for creating new rows)

struct NewAppointment: Codable {
    let proId: UUID
    let clientId: UUID
    let serviceId: UUID
    let serviceName: String
    let servicePrice: Int
    let startsAt: Date
    let duration: Int
    let location: String?
    let notes: String?
    let tipPercent: Int
    let tipAmount: Int
    let bookingFee: Int
    let subtotal: Int
    let total: Int
    let paymentMethod: String

    enum CodingKeys: String, CodingKey {
        case duration, location, notes, subtotal, total
        case proId = "pro_id"
        case clientId = "client_id"
        case serviceId = "service_id"
        case serviceName = "service_name"
        case servicePrice = "service_price"
        case startsAt = "starts_at"
        case tipPercent = "tip_percent"
        case tipAmount = "tip_amount"
        case bookingFee = "booking_fee"
        case paymentMethod = "payment_method"
    }
}

struct NewMessage: Codable {
    let threadId: UUID
    let senderId: UUID
    let body: String

    enum CodingKeys: String, CodingKey {
        case body
        case threadId = "thread_id"
        case senderId = "sender_id"
    }
}
