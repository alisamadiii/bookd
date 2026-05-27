import SwiftUI
import Observation

@Observable
final class AppState {
    var hasCompletedOnboarding = false
    var isPro = false // client vs pro perspective
    var selectedTab: AppTab = .home
    var selectedProId: String?
    var showBooking = false
    var bookingProId: String?
    var bookingServiceId: String?
    var selectedThread: MessageThread?
    var showProSetup = false
    var showSignIn = false

    func openProfile(_ proId: String) {
        selectedProId = proId
    }

    func startBooking(proId: String, serviceId: String? = nil) {
        bookingProId = proId
        bookingServiceId = serviceId
        showBooking = true
    }

    func togglePerspective() {
        withAnimation(.spring(duration: 0.3)) {
            isPro.toggle()
            selectedTab = .home
        }
    }
}

enum AppTab: String, CaseIterable {
    case home, search, bookings, messages, profile

    var label: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .bookings: "Bookings"
        case .messages: "Messages"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .bookings: "calendar"
        case .messages: "bubble.right"
        case .profile: "person"
        }
    }

    var iconFilled: String {
        switch self {
        case .home: "house.fill"
        case .search: "magnifyingglass"
        case .bookings: "calendar"
        case .messages: "bubble.right.fill"
        case .profile: "person.fill"
        }
    }

    // Pro mode has different tabs
    var proLabel: String {
        switch self {
        case .home: "Dashboard"
        case .search: "Calendar"
        case .bookings: "Bookings"
        case .messages: "Messages"
        case .profile: "Profile"
        }
    }

    var proIcon: String {
        switch self {
        case .home: "chart.bar"
        case .search: "calendar"
        case .bookings: "list.bullet.clipboard"
        case .messages: "bubble.right"
        case .profile: "person"
        }
    }

    var proIconFilled: String {
        switch self {
        case .home: "chart.bar.fill"
        case .search: "calendar"
        case .bookings: "list.bullet.clipboard.fill"
        case .messages: "bubble.right.fill"
        case .profile: "person.fill"
        }
    }
}
