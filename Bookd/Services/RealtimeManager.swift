import Foundation
import Observation
import Supabase
import Realtime

@Observable
@MainActor
final class RealtimeManager {
    private var messageChannel: RealtimeChannelV2?
    var onNewMessage: ((DBMessage) -> Void)?

    func subscribeToThread(threadId: UUID) async {
        // Unsubscribe from previous
        await unsubscribe()

        let channel = AppSupabase.client.realtimeV2.channel("messages:\(threadId.uuidString)")

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: "thread_id=eq.\(threadId.uuidString)"
        )

        await channel.subscribe()
        messageChannel = channel

        Task {
            for await change in changes {
                if let message = try? change.decodeRecord(as: DBMessage.self, decoder: JSONDecoder.supabaseDecoder) {
                    await MainActor.run {
                        self.onNewMessage?(message)
                    }
                }
            }
        }
    }

    func unsubscribe() async {
        if let channel = messageChannel {
            await channel.unsubscribe()
            messageChannel = nil
        }
    }
}

extension JSONDecoder {
    static let supabaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatters: [ISO8601DateFormatter] = {
                let f1 = ISO8601DateFormatter()
                f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let f2 = ISO8601DateFormatter()
                f2.formatOptions = [.withInternetDateTime]
                return [f1, f2]
            }()

            for formatter in formatters {
                if let date = formatter.date(from: dateString) { return date }
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()
}
