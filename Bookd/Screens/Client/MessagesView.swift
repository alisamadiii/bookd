import SwiftUI

struct MessagesView: View {
    @Binding var selectedThread: MessageThread?
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(SampleData.threads) { thread in
                let pro = SampleData.pro(for: thread.proId)
                Button {
                    selectedThread = thread
                } label: {
                    HStack(spacing: 12) {
                        if let pro {
                            AvatarView(palette: pro.palette, size: 52, name: pro.name)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                if let pro {
                                    HStack(spacing: 4) {
                                        Text(pro.name)
                                            .font(.system(size: 15, weight: thread.unread > 0 ? .heavy : .bold))
                                        if pro.verified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 11))
                                                .foregroundStyle(Color.bookdAccent)
                                        }
                                    }
                                }
                                Spacer()
                                Text(thread.when)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                            }
                            HStack {
                                Text(thread.lastMessage)
                                    .font(.system(size: 13, weight: thread.unread > 0 ? .semibold : .regular))
                                    .foregroundStyle(thread.unread > 0 ? .primary : .secondary)
                                    .lineLimit(1)
                                Spacer()
                                if thread.unread > 0 {
                                    Text("\(thread.unread)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(minWidth: 18, minHeight: 18)
                                        .background(Color.bookdAccent, in: Circle())
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Messages")
        .searchable(text: $searchText, prompt: "Search messages")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: { Image(systemName: "square.and.pencil") }
            }
        }
    }
}

// MARK: - Chat Screen

struct ChatView: View {
    let thread: MessageThread
    @State private var draft = ""
    @State private var messages: [ChatMessage]
    @Environment(\.dismiss) private var dismiss

    init(thread: MessageThread) {
        self.thread = thread
        self._messages = State(initialValue: SampleData.chatMessages)
    }

    private var pro: Professional? { SampleData.pro(for: thread.proId) }

    var body: some View {
        VStack(spacing: 0) {
            // Booking quick action card
            if let pro {
                bookingCard(pro: pro)
            }

            // Messages
            ScrollView {
                LazyVStack(spacing: 8) {
                    Text("Today")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 8)

                    ForEach(messages) { msg in
                        messageBubble(msg)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            // Composer
            composerBar
        }
        .navigationTitle(pro?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let pro {
                    AvatarView(palette: pro.palette, size: 32, name: pro.name)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: { Image(systemName: "phone") }
            }
        }
    }

    // MARK: - Booking Card

    @ViewBuilder
    private func bookingCard(pro: Professional) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar")
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.bookdAccent, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 1) {
                Text("Tomorrow 11:00 AM")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.bookdAccent)
                Text("Color refresh · $220")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("View") { }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.bookdAccent)
        }
        .padding(12)
        .background(Color.bookdAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    // MARK: - Bubble

    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.fromMe { Spacer() }
            VStack(alignment: msg.fromMe ? .trailing : .leading, spacing: 4) {
                Text(msg.text)
                    .font(.system(size: 15))
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundStyle(msg.fromMe ? .white : .primary)
                    .background(
                        msg.fromMe ? AnyShapeStyle(Color.bookdAccent) : AnyShapeStyle(.regularMaterial),
                        in: BubbleShape(fromMe: msg.fromMe)
                    )
                Text(msg.when)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: 280, alignment: msg.fromMe ? .trailing : .leading)
            if !msg.fromMe { Spacer() }
        }
    }

    // MARK: - Composer

    private var composerBar: some View {
        HStack(spacing: 8) {
            Button { } label: {
                Image(systemName: "plus")
                    .frame(width: 40, height: 40)
            }

            HStack(spacing: 4) {
                TextField("Message…", text: $draft)
                    .textFieldStyle(.plain)
                    .onSubmit { send() }

                Button(action: send) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            draft.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AnyShapeStyle(.tertiary)
                                : AnyShapeStyle(Color.bookdAccent),
                            in: Circle()
                        )
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 6)
            .padding(.vertical, 4)
            .background(.regularMaterial, in: Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func send() {
        guard !draft.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(ChatMessage(id: "m\(messages.count + 1)", fromMe: true, text: draft, when: "just now"))
        draft = ""
    }
}

// MARK: - Bubble Shape

struct BubbleShape: Shape {
    let fromMe: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let smallR: CGFloat = 6
        var path = Path()

        if fromMe {
            path.addRoundedRect(in: rect, cornerRadii: RectangleCornerRadii(
                topLeading: r, bottomLeading: r, bottomTrailing: smallR, topTrailing: r
            ))
        } else {
            path.addRoundedRect(in: rect, cornerRadii: RectangleCornerRadii(
                topLeading: smallR, bottomLeading: r, bottomTrailing: r, topTrailing: r
            ))
        }
        return path
    }
}
