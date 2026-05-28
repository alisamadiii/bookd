# Bookd — Project Instructions

## Design Rules

- **Default avatar**: When a user has no avatar image, use `AvatarView` with the mesh gradient background + initials. This is the brand's default avatar style — never show a generic placeholder icon or gray circle. The gradient palette comes from `profile.palette` (stored in DB). If palette is empty, fall back to `["#6C5CE7", "#FFB259"]`.

## Tech Stack

- iOS 26+ SwiftUI with Liquid Glass
- Supabase (Postgres + Auth + Realtime + Storage)
- Project ref: `qgxgvrawkorukqxaoneb`
- Stripe Connect for payments (not yet wired)

## Architecture

- `Services/AuthManager.swift` — auth state, sign in/up, profile loading
- `Services/DataService.swift` — all Supabase CRUD operations
- `Services/RealtimeManager.swift` — websocket subscriptions for live chat
- `Models/DBModels.swift` — Codable structs matching DB tables
- `Models/BookdModels.swift` + `SampleData.swift` — UI models (legacy, being replaced)
- `Navigation/AppState.swift` — observable app state, tab selection, navigation

## Error Handling

- **Every async operation must surface errors to the user.** Never silently `print()` or `try?` swallow errors.
- Use `@State private var errorMessage: String?` on any view that does network/async work.
- Attach `.errorAlert($errorMessage)` modifier (from `Components/ErrorAlert.swift`) to the view.
- In catch blocks: `errorMessage = error.localizedDescription` (or a user-friendly message).
- For `ProfileAvatarView` / `AsyncImage`: show `AvatarView` gradient on failure phase, not a gray placeholder.

## Avatar Display

- Use `ProfileAvatarView` for displaying any user avatar. It handles: remote image if URL exists, gradient + initials fallback.
- `AvatarView` has a built-in `safePalette` that falls back to `["#6C5CE7", "#FFB259", "#FF6FA0"]` if palette is empty.

## Swift + Supabase Gotchas

- **UUID case mismatch**: Swift's `UUID.uuidString` returns UPPERCASE (`4E74DAE7-...`) but Supabase `auth.uid()::text` returns lowercase (`4e74dae7-...`). **Always use `.uuidString.lowercased()`** when building storage paths or any string compared against Postgres UUIDs. Without this, RLS policies that compare folder names to `auth.uid()` will reject the request with "new row violates row-level security policy".

## Conventions

- Prices stored in **cents** in DB, converted to dollars for display
- Use `Color.bookdAccent` (not `.bookdAccent`) in ShapeStyle contexts
- Regenerate Xcode project with `xcodegen generate` after changing `project.yml`
- Dev team ID: `3WUS69PJ45`
