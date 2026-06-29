import SwiftUI

struct MeView: View {
    @State private var reminderOn: Bool = true
    @State private var currentMood: WeeklyMood = .hopeful
    @State private var streak: [Bool] = [true, true, true, true, true, false, false]

    @State private var showJournal: Bool = false
    @State private var showBodyCheck: Bool = false
    @State private var showSaved: Bool = false
    @State private var showStats: Bool = false
    @State private var showSettings: Bool = false

    private let planSteps: [PlanStep] = [
        .init(number: 1, title: "Plan", isDone: true, isCurrent: false),
        .init(number: 2, title: "Self Check", isDone: true, isCurrent: false),
        .init(number: 3, title: "Reflect", isDone: false, isCurrent: true),
        .init(number: 4, title: "Stay Consistent", isDone: false, isCurrent: false)
    ]

    private let weekdayInitials: [String] = ["M", "T", "W", "T", "F", "S", "S"]
    private let weekdayLabels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                hero
                planCard
                menuGrid
                reminderRow
                microActions
                moodCheckIn
                peerSupport
                continueButton
                disclaimer
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(isPresented: $showJournal) { JournalView() }
        .sheet(isPresented: $showBodyCheck) { BodyCheckView() }
        .sheet(isPresented: $showSaved) { SavedLibraryView() }
        .sheet(isPresented: $showStats) { StatsView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var header: some View {
        HStack {
            HerHealthLogo()
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(AppColors.cardBackground))
                    .shadow(color: AppColors.primaryDeep.opacity(0.08), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Care\nJourney")
                    .font(AppFonts.display(30))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)
                Text("Small steps build confidence")
                    .font(AppFonts.body(14))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
            PersonIllustration(size: 130)
        }
    }

    private var planCard: some View {
        SoftCard(corner: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundStyle(AppColors.primary)
                        Text("This Month's Plan")
                            .font(AppFonts.headline(14))
                    }
                    Spacer()
                    Button(action: { showBodyCheck = true }) {
                        Text("View Log")
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.primary)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(planSteps) { step in
                        PlanStepView(step: step, total: planSteps.count)
                    }
                }
            }
        }
    }

    private var menuGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            MenuTile(icon: "book.closed.fill", tint: AppColors.primary,
                     title: "Journal", subtitle: "Track your moods",
                     action: { showJournal = true })
            MenuTile(icon: "hand.raised.fill", tint: AppColors.accentPeach,
                     title: "Self-Check", subtitle: "Log a breast check",
                     action: { showBodyCheck = true })
            MenuTile(icon: "bookmark.fill", tint: AppColors.accentPurple,
                     title: "Saved", subtitle: "Your library",
                     action: { showSaved = true })
            MenuTile(icon: "chart.line.uptrend.xyaxis", tint: AppColors.accentGreen,
                     title: "Insights", subtitle: "Your trends",
                     action: { showStats = true })
        }
    }

    private var reminderRow: some View {
        ReminderRow(
            icon: "calendar",
            tint: AppColors.accentPeach,
            title: "Monthly Reminder",
            subtitle: "Gentle check-ins and self-care\nprompts just for you.",
            isOn: $reminderOn
        )
    }

    private var microActions: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle().fill(AppColors.primaryUltraSoft)
                                .frame(width: 36, height: 36)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.primary)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Daily Micro-Actions")
                                .font(AppFonts.headline(14))
                            Text("Small actions, big impact.\nKeep going!")
                                .font(AppFonts.caption(11))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("5")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.primary)
                        Text("Day Streak")
                            .font(AppFonts.caption(11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(0..<7) { i in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(i < streak.filter({ $0 }).count ? AppColors.primary : AppColors.primaryUltraSoft)
                                .frame(width: 14, height: 14)
                            Text(weekdayInitials[i])
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var moodCheckIn: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(AppColors.primaryUltraSoft)
                            .frame(width: 36, height: 36)
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(AppColors.primary)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Weekly Mood Check-in")
                            .font(AppFonts.headline(14))
                        Text("Your feelings matter. Track your\nemotional well-being.")
                            .font(AppFonts.caption(11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                }
                HStack(alignment: .bottom, spacing: 10) {
                    MoodBars()
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Image(systemName: currentMood.symbol)
                            .font(.system(size: 28))
                            .foregroundStyle(currentMood.color)
                        Text(currentMood.label)
                            .font(AppFonts.caption(11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(WeeklyMood.allCases) { mood in
                        Button {
                            withAnimation(.spring()) { currentMood = mood }
                        } label: {
                            Image(systemName: mood.symbol)
                                .font(.system(size: 12))
                                .foregroundStyle(currentMood == mood ? .white : mood.color)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(currentMood == mood ? mood.color : mood.color.opacity(0.15)))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<7) { i in
                            Text(weekdayInitials[i])
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: 120)
                }
            }
        }
    }

    private var peerSupport: some View {
        SoftCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle().fill(AppColors.accentPeach.opacity(0.25))
                                .frame(width: 36, height: 36)
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(AppColors.accentPeach)
                        }
                        Text("Peer Support Community")
                            .font(AppFonts.headline(14))
                    }
                    Text("Share, listen, and support\neach other.")
                        .font(AppFonts.caption(11))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                    Text("Anonymous, safe,\npsychologist-moderated.")
                        .font(AppFonts.micro(10))
                        .multilineTextAlignment(.trailing)
                }
                .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private var continueButton: some View {
        PrimaryButton("Continue My Plan", systemImage: "bubble.left.and.bubble.right.fill") {
            showJournal = true
        }
    }

    private var disclaimer: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
            Text("Supportive tool only — not a medical diagnosis or emergency service.")
                .font(AppFonts.micro(11))
        }
        .foregroundStyle(AppColors.textTertiary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Menu tile
struct MenuTile: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.headline(14))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppFonts.caption(11))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Plan step view
struct PlanStepView: View {
    let step: PlanStep
    let total: Int
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(step.isDone ? AppColors.primary : (step.isCurrent ? AppColors.primaryUltraSoft : AppColors.primaryUltraSoft.opacity(0.5)))
                        .frame(width: 30, height: 30)
                    if step.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.number)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(step.isCurrent ? AppColors.primary : AppColors.textTertiary)
                    }
                }
                Text(step.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(step.isDone || step.isCurrent ? AppColors.textPrimary : AppColors.textTertiary)
            }
            if step.number < total {
                Rectangle()
                    .fill(step.isDone ? AppColors.primary : AppColors.primaryUltraSoft)
                    .frame(height: 2)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mood bars (weekday labels use distinct initials; Monday-Friday + Sat + Sun)
struct MoodBars: View {
    private let heights: [CGFloat] = [12, 18, 14, 22, 28, 24, 30]
    private let labels: [String] = ["M", "T", "W", "T", "F", "S", "S"]
    private let fullLabels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<7) { i in
                    Capsule()
                        .fill(LinearGradient(colors: [AppColors.primary, AppColors.accentPeach], startPoint: .bottom, endPoint: .top))
                        .frame(width: 8, height: heights[i])
                }
            }
            HStack(spacing: 6) {
                ForEach(0..<7) { i in
                    Text(fullLabels[i])
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 8)
                }
            }
        }
    }
}
