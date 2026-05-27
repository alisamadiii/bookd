import SwiftUI

@main
struct BookdApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.hasCompletedOnboarding {
                    OnboardingView {
                        withAnimation(.spring(duration: 0.4)) {
                            appState.hasCompletedOnboarding = true
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainTabView()
                        .environment(appState)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
            .tint(.bookdAccent)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            // Tab 1: Home / Dashboard
            Tab(appState.isPro ? "Dashboard" : "Home",
                systemImage: appState.isPro ? "chart.bar.fill" : "house.fill",
                value: .home)
            {
                NavigationStack {
                    if appState.isPro {
                        ProDashboardView {
                            appState.showProSetup = true
                        }
                    } else {
                        HomeFeedView(
                            selectedProId: $state.selectedProId,
                            showBooking: $state.showBooking,
                            bookingProId: $state.bookingProId
                        )
                        .navigationDestination(item: $state.selectedProId) { proId in
                            PublicProfileView(proId: proId) { pId, sId in
                                appState.startBooking(proId: pId, serviceId: sId)
                            } onMessage: { pId in
                                if let thread = SampleData.threads.first(where: { $0.proId == pId }) {
                                    appState.selectedThread = thread
                                    appState.selectedTab = .messages
                                }
                            }
                        }
                    }
                }
            }

            // Tab 2: Search / Calendar
            Tab(appState.isPro ? "Calendar" : "Search",
                systemImage: appState.isPro ? "calendar" : "magnifyingglass",
                value: .search)
            {
                NavigationStack {
                    if appState.isPro {
                        ProCalendarView()
                    } else {
                        SearchView(selectedProId: $state.selectedProId)
                    }
                }
            }

            // Tab 3: Bookings
            Tab("Bookings", systemImage: "calendar.badge.clock", value: .bookings) {
                NavigationStack {
                    AppointmentsView(selectedProId: $state.selectedProId)
                }
            }

            // Tab 4: Messages
            Tab(value: .messages) {
                NavigationStack {
                    MessagesView(selectedThread: $state.selectedThread)
                        .navigationDestination(item: $state.selectedThread) { thread in
                            ChatView(thread: thread)
                        }
                }
            } label: {
                Label {
                    Text("Messages")
                } icon: {
                    Image(systemName: "bubble.right.fill")
                }
            }

            // Tab 5: Profile
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                NavigationStack {
                    if appState.isPro {
                        ProProfileView {
                            appState.togglePerspective()
                        }
                    } else {
                        ProfileSettingsView {
                            appState.togglePerspective()
                        }
                    }
                }
            }
        }
        // Booking flow sheet
        .sheet(isPresented: $state.showBooking) {
            if let proId = appState.bookingProId {
                BookingFlowView(
                    proId: proId,
                    initialServiceId: appState.bookingServiceId
                ) {
                    appState.showBooking = false
                    appState.bookingProId = nil
                    appState.bookingServiceId = nil
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
            }
        }
        // Pro setup sheet
        .sheet(isPresented: $state.showProSetup) {
            ProSetupView {
                appState.showProSetup = false
            } onClose: {
                appState.showProSetup = false
            }
        }
    }
}

// Make MessageThread conform to Hashable for navigation
extension MessageThread: Hashable {
    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
