import SwiftUI

/// Displays user avatar: remote image if available, gradient + initials fallback.
/// Use this everywhere a user avatar is shown. Enforces the CLAUDE.md rule:
/// "Never show a generic placeholder icon or gray circle."
struct ProfileAvatarView: View {
    var avatarUrl: String?
    var palette: [String]
    var name: String
    var size: CGFloat = 44
    var showRing: Bool = false

    var body: some View {
        if let url = avatarUrl, !url.isEmpty, let imageUrl = URL(string: url) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    // Loading or failure → show gradient
                    AvatarView(palette: palette, size: size, name: name, showRing: showRing)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            AvatarView(palette: palette, size: size, name: name, showRing: showRing)
        }
    }
}
