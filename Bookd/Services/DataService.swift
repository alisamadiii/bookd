import Foundation
import Observation
import Supabase

@Observable
@MainActor
final class DataService {
    // MARK: - Feed / Discovery

    var feedPros: [DBProProfile] = []
    var feedProUsers: [UUID: DBProfile] = [:] // user_id -> profile
    var feedProServices: [UUID: [DBService]] = [:] // pro_profile.id -> services

    func loadFeed(category: String? = nil) async {
        do {
            var query = AppSupabase.client
                .from("pro_profiles")
                .select()
                .eq("is_published", value: true)

            if let category, category != "all" {
                query = query.eq("category", value: category)
            }

            let pros: [DBProProfile] = try await query
                .order("rating", ascending: false)
                .limit(20)
                .execute()
                .value

            feedPros = pros

            // Load user profiles for each pro
            let userIds = pros.map(\.userId)
            if !userIds.isEmpty {
                let profiles: [DBProfile] = try await AppSupabase.client
                    .from("profiles")
                    .select()
                    .in("id", values: userIds.map(\.uuidString))
                    .execute()
                    .value
                feedProUsers = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })
            }

            // Load services for each pro
            let proIds = pros.map(\.id)
            if !proIds.isEmpty {
                let services: [DBService] = try await AppSupabase.client
                    .from("services")
                    .select()
                    .in("pro_id", values: proIds.map(\.uuidString))
                    .eq("is_active", value: true)
                    .order("sort_order")
                    .execute()
                    .value
                feedProServices = Dictionary(grouping: services, by: \.proId)
            }
        } catch {
            print("Failed to load feed: \(error)")
        }
    }

    // MARK: - Pro Profile Detail

    func loadProDetail(proId: UUID) async -> (DBProProfile, DBProfile, [DBService], [DBReview], [DBPortfolioPost])? {
        do {
            let pros: [DBProProfile] = try await AppSupabase.client
                .from("pro_profiles")
                .select()
                .eq("id", value: proId.uuidString)
                .execute()
                .value

            guard let pro = pros.first else { return nil }

            let profiles: [DBProfile] = try await AppSupabase.client
                .from("profiles")
                .select()
                .eq("id", value: pro.userId.uuidString)
                .execute()
                .value

            guard let profile = profiles.first else { return nil }

            async let servicesTask: [DBService] = AppSupabase.client
                .from("services")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .eq("is_active", value: true)
                .order("sort_order")
                .execute()
                .value

            async let reviewsTask: [DBReview] = AppSupabase.client
                .from("reviews")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value

            async let postsTask: [DBPortfolioPost] = AppSupabase.client
                .from("portfolio_posts")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .order("sort_order")
                .execute()
                .value

            let (services, reviews, posts) = try await (servicesTask, reviewsTask, postsTask)
            return (pro, profile, services, reviews, posts)
        } catch {
            print("Failed to load pro detail: \(error)")
            return nil
        }
    }

    // MARK: - Appointments

    var appointments: [DBAppointment] = []

    func loadAppointments(userId: UUID) async {
        do {
            appointments = try await AppSupabase.client
                .from("appointments")
                .select()
                .eq("client_id", value: userId.uuidString)
                .order("starts_at", ascending: false)
                .execute()
                .value
        } catch {
            print("Failed to load appointments: \(error)")
        }
    }

    func loadProAppointments(proId: UUID) async {
        do {
            appointments = try await AppSupabase.client
                .from("appointments")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .order("starts_at", ascending: false)
                .execute()
                .value
        } catch {
            print("Failed to load pro appointments: \(error)")
        }
    }

    func createAppointment(_ appointment: NewAppointment) async throws -> DBAppointment {
        let result: [DBAppointment] = try await AppSupabase.client
            .from("appointments")
            .insert(appointment)
            .select()
            .execute()
            .value
        return result[0]
    }

    func cancelAppointment(id: UUID, userId: UUID) async throws {
        try await AppSupabase.client
            .from("appointments")
            .update([
                "status": "cancelled",
                "cancelled_at": ISO8601DateFormatter().string(from: Date()),
                "cancelled_by": userId.uuidString,
            ])
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Messages

    var threads: [DBMessageThread] = []
    var currentMessages: [DBMessage] = []

    func loadThreads(userId: UUID, isPro: Bool, proId: UUID?) async {
        do {
            if isPro, let proId {
                threads = try await AppSupabase.client
                    .from("message_threads")
                    .select()
                    .eq("pro_id", value: proId.uuidString)
                    .order("last_message_at", ascending: false)
                    .execute()
                    .value
            } else {
                threads = try await AppSupabase.client
                    .from("message_threads")
                    .select()
                    .eq("client_id", value: userId.uuidString)
                    .order("last_message_at", ascending: false)
                    .execute()
                    .value
            }
        } catch {
            print("Failed to load threads: \(error)")
        }
    }

    func loadMessages(threadId: UUID) async {
        do {
            currentMessages = try await AppSupabase.client
                .from("messages")
                .select()
                .eq("thread_id", value: threadId.uuidString)
                .order("created_at")
                .limit(100)
                .execute()
                .value
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    func sendMessage(_ message: NewMessage) async throws {
        try await AppSupabase.client
            .from("messages")
            .insert(message)
            .execute()
    }

    func getOrCreateThread(proId: UUID, clientId: UUID) async throws -> DBMessageThread {
        // Check existing
        let existing: [DBMessageThread] = try await AppSupabase.client
            .from("message_threads")
            .select()
            .eq("pro_id", value: proId.uuidString)
            .eq("client_id", value: clientId.uuidString)
            .execute()
            .value

        if let thread = existing.first { return thread }

        // Create new
        let newThreads: [DBMessageThread] = try await AppSupabase.client
            .from("message_threads")
            .insert(["pro_id": proId.uuidString, "client_id": clientId.uuidString])
            .select()
            .execute()
            .value

        return newThreads[0]
    }

    // MARK: - Favorites

    func toggleFavorite(proId: UUID, clientId: UUID) async throws -> Bool {
        let existing: [DBFavorite] = try await AppSupabase.client
            .from("favorites")
            .select()
            .eq("pro_id", value: proId.uuidString)
            .eq("client_id", value: clientId.uuidString)
            .execute()
            .value

        if let fav = existing.first {
            try await AppSupabase.client
                .from("favorites")
                .delete()
                .eq("id", value: fav.id.uuidString)
                .execute()
            return false
        } else {
            try await AppSupabase.client
                .from("favorites")
                .insert(["pro_id": proId.uuidString, "client_id": clientId.uuidString])
                .execute()
            return true
        }
    }

    func isFavorited(proId: UUID, clientId: UUID) async -> Bool {
        do {
            let result: [DBFavorite] = try await AppSupabase.client
                .from("favorites")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .eq("client_id", value: clientId.uuidString)
                .execute()
                .value
            return !result.isEmpty
        } catch { return false }
    }

    // MARK: - Profile Views (analytics)

    func logProfileView(proId: UUID, viewerId: UUID?) async {
        do {
            var record: [String: String] = ["pro_id": proId.uuidString]
            if let viewerId { record["viewer_id"] = viewerId.uuidString }
            try await AppSupabase.client
                .from("profile_views")
                .insert(record)
                .execute()
        } catch {
            print("Failed to log profile view: \(error)")
        }
    }

    // MARK: - Pro Dashboard Stats

    func loadProStats(proId: UUID) async -> (todayCount: Int, weekEarnings: Int, monthViews: Int)? {
        do {
            let today = Calendar.current.startOfDay(for: Date())
            let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: today)!
            let monthStart = Calendar.current.date(byAdding: .month, value: -1, to: today)!

            let todayIso = ISO8601DateFormatter().string(from: today)
            let weekIso = ISO8601DateFormatter().string(from: weekStart)
            let monthIso = ISO8601DateFormatter().string(from: monthStart)

            async let todayAppts: [DBAppointment] = AppSupabase.client
                .from("appointments")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .gte("starts_at", value: todayIso)
                .in("status", values: ["confirmed", "completed"])
                .execute()
                .value

            async let weekAppts: [DBAppointment] = AppSupabase.client
                .from("appointments")
                .select()
                .eq("pro_id", value: proId.uuidString)
                .gte("starts_at", value: weekIso)
                .eq("status", value: "completed")
                .execute()
                .value

            let (todayResults, weekResults) = try await (todayAppts, weekAppts)
            let weekEarnings = weekResults.reduce(0) { $0 + $1.subtotal + ($1.tipAmount ?? 0) }

            return (todayResults.count, weekEarnings / 100, 0) // views would need separate query
        } catch {
            print("Failed to load pro stats: \(error)")
            return nil
        }
    }

    // MARK: - Storage

    func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString.lowercased())/avatar.jpg"
        try await AppSupabase.client.storage
            .from("avatars")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
        return try AppSupabase.client.storage.from("avatars").getPublicURL(path: path).absoluteString
    }

    func uploadCover(userId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString.lowercased())/cover.jpg"
        try await AppSupabase.client.storage
            .from("covers")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
        return try AppSupabase.client.storage.from("covers").getPublicURL(path: path).absoluteString
    }

    func uploadPortfolioImage(userId: UUID, postId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString.lowercased())/\(postId.uuidString.lowercased()).jpg"
        try await AppSupabase.client.storage
            .from("portfolio")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
        return try AppSupabase.client.storage.from("portfolio").getPublicURL(path: path).absoluteString
    }
}
