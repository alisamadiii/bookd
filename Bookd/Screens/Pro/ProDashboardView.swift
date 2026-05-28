import SwiftUI

struct ProDashboardView: View {
    let onOpenSetup: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero header
                heroHeader

                // Stat cards
                statCards
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                // Today's schedule
                todaySchedule
                    .padding(.top, 22)

                // Monthly analytics
                monthlyStats
                    .padding(.top, 22)

                // Refresh profile CTA
                refreshProfileCard
                    .padding(.top, 22)
                    .padding(.horizontal, 16)

                // Activity feed
                activityFeed
                    .padding(.top, 22)
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Dashboard")
    }

    // MARK: - Hero

    private var heroHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Tuesday, May 27")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text("Hey, Mira")
                        .font(.system(size: 28, weight: .heavy))
                        .tracking(-0.5)
                    Text("PRO")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.bookdProAccent, in: Capsule())
                }
            }
            Spacer()
            AvatarView(palette: SampleData.mePro.palette, size: 42, name: SampleData.mePro.name)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .background(
            LinearGradient(colors: [Color.bookdProAccent.opacity(0.16), .clear],
                           startPoint: .top, endPoint: .bottom)
            .frame(height: 220)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        )
    }

    // MARK: - Stats

    private var statCards: some View {
        HStack(spacing: 10) {
            // Earnings
            VStack(alignment: .leading, spacing: 6) {
                Text("THIS WEEK")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .opacity(0.6)
                Text("$2,840")
                    .font(.system(size: 36, weight: .heavy))
                    .tracking(-1)
                HStack(spacing: 4) {
                    Text("+18%")
                        .foregroundStyle(.green)
                        .fontWeight(.bold)
                    Text("vs last week")
                        .opacity(0.65)
                }
                .font(.system(size: 12))

                SparklineView(color: .green)
                    .frame(height: 40)
                    .padding(.top, 6)
            }
            .foregroundStyle(.white)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.primary, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .shadow(color: .black.opacity(0.18), radius: 20, y: 7)

            // Today count
            VStack(alignment: .leading, spacing: 6) {
                Text("TODAY")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.tertiary)
                Text("\(SampleData.proStats.todayBookings)")
                    .font(.system(size: 36, weight: .heavy))
                    .tracking(-1)
                Text("bookings · 4.5h")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(1...4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.bookdProAccent.opacity(0.4 + Double(i) * 0.15))
                            .frame(height: 26)
                    }
                }
                .padding(.top, 6)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
    }

    // MARK: - Today's Schedule

    private var todaySchedule: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's schedule")
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(-0.4)
                Spacer()
                Button("Open hours") { }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.bookdProAccent)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(SampleData.proStats.todaySchedule.enumerated()), id: \.element.id) { idx, entry in
                    HStack(spacing: 14) {
                        VStack(alignment: .leading) {
                            Text(entry.time.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 14, weight: .heavy))
                                .tracking(-0.2)
                            Text(entry.time.components(separatedBy: " ").last ?? "")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(width: 60, alignment: .leading)

                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.bookdProAccent)
                            .frame(width: 2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.service)
                                .font(.system(size: 14.5, weight: .bold))
                            Text("\(entry.client) · \(ProService(id: "", name: "", price: 0, duration: entry.duration).formattedDuration)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button { } label: {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 14))
                                .frame(width: 32, height: 32)
                                .background(.quaternary, in: Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if idx < SampleData.proStats.todaySchedule.count - 1 {
                        Divider().padding(.leading, 76)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Monthly

    private var monthlyStats: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This month")
                .font(.system(size: 20, weight: .heavy))
                .tracking(-0.4)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible())], spacing: 10) {
                miniStat(icon: "eye", label: "Profile views", value: "1,284", delta: "+12%")
                miniStat(icon: "chart.line.uptrend.xyaxis", label: "Conversion", value: "18.4%", delta: "+2.3%")
                miniStat(icon: "dollarsign", label: "Earnings", value: "$11.2k", delta: "+24%")
                miniStat(icon: "person", label: "New followers", value: "312", delta: "+45")
            }
            .padding(.horizontal, 16)
        }
    }

    private func miniStat(icon: String, label: String, value: String, delta: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.4)
            Text(delta)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.bookdSuccess)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    // MARK: - Refresh Profile

    private var refreshProfileCard: some View {
        Button(action: onOpenSetup) {
            HStack(spacing: 12) {
                Image(systemName: "pencil")
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.bookdProAccent, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Refresh your profile")
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(Color.bookdProAccent)
                    Text("3 new portfolio slots open · add to boost discovery")
                        .font(.system(size: 12.5))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.bookdProAccent)
            }
            .padding(16)
            .background(Color.bookdProAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Activity

    private var activityFeed: some View {
        let activities: [(icon: String, text: String, time: String, color: Color)] = [
            ("dollarsign", "Sasha M. booked Color refresh", "Just now", .bookdSuccess),
            ("star", "New 5★ review from Devon K.", "12m", .bookdWarning),
            ("person", "You gained 8 new followers", "1h", .bookdProAccent),
            ("calendar", "Mae L. rescheduled to 1pm", "2h", .secondary),
        ]

        return VStack(alignment: .leading, spacing: 10) {
            Text("Activity")
                .font(.system(size: 20, weight: .heavy))
                .tracking(-0.4)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(activities.enumerated()), id: \.offset) { idx, activity in
                    HStack(spacing: 12) {
                        Image(systemName: activity.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(activity.color)
                            .frame(width: 32, height: 32)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                        Text(activity.text)
                            .font(.system(size: 14))

                        Spacer()

                        Text(activity.time)
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if idx < activities.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            .padding(.horizontal, 16)
        }
    }
}
