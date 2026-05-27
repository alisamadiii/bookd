import SwiftUI

@main
struct BookdApp: App {
    @State private var appState = AppState()
    @State private var authManager = AuthManager()
    @State private var dataService = DataService()
    @State private var realtimeManager = RealtimeManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    // Splash
                    ZStack {
                        Color(.systemBackground).ignoresSafeArea()
                        VStack(spacing: 8) {
                            Text("Bookd")
                                .font(.system(size: 32, weight: .heavy))
                                .tracking(-1)
                            Text(".")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundStyle(Color.bookdAccent)
                                .offset(x: 0, y: -8)
                        }
                    }
                } else if !authManager.isSignedIn || !appState.hasCompletedOnboarding {
                    OnboardingView {
                        appState.hasCompletedOnboarding = true
                    }
                } else {
                    MainTabView()
                        .environment(appState)
                        .environment(authManager)
                        .environment(dataService)
                        .environment(realtimeManager)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isSignedIn)
            .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
            .tint(.bookdAccent)
            .environment(authManager)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
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

            Tab("Bookings", systemImage: "calendar.badge.clock", value: .bookings) {
                NavigationStack {
                    AppointmentsView(selectedProId: $state.selectedProId)
                }
            }

            Tab(value: .messages) {
                NavigationStack {
                    MessagesView(selectedThread: $state.selectedThread)
                        .navigationDestination(item: $state.selectedThread) { thread in
                            ChatView(thread: thread)
                        }
                }
            } label: {
                Label("Messages", systemImage: "bubble.right.fill")
            }

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
        .sheet(isPresented: $state.showProSetup) {
            ProSetupView {
                appState.showProSetup = false
            } onClose: {
                appState.showProSetup = false
            }
        }
        .task {
            // Load feed on launch
            await dataService.loadFeed()
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
