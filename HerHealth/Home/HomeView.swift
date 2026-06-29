import SwiftUI

struct HomeView: View {
    @State private var monthlyReminderOn: Bool = true
    @State private var showQuiz: Bool = false
    @State private var showJournal: Bool = false
    @State private var showBodyCheck: Bool = false
    @State private var showSaved: Bool = false
    @State private var showStats: Bool = false

    var onSelectTab: ((AppTab) -> Void)? = nil

    private let features: [HomeFeature] = [
        .init(title: "Risk Awareness Quiz", subtitle: "Learn, reflect and know your risk.", symbol: "list.bullet.clipboard.fill", tint: AppColors.primary, route: .riskQuiz),
        .init(title: "AI Companion", subtitle: "24/7 empathetic support and guidance.", symbol: "bubble.left.and.bubble.right.fill", tint: AppColors.primary, route: .aiCompanion),
        .init(title: "Education Cards", subtitle: "Practical knowledge in bite-sized steps.", symbol: "book.fill", tint: AppColors.accentPurple, route: .education),
        .init(title: "Anxiety Relief", subtitle: "Tools and exercises to calm your mind.", symbol: "leaf.fill", tint: AppColors.accentGreen, route: .anxietyRelief)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header
                hero
                therapyPills
                featuresGrid
                quickActions
                monthlyReminder
                reassurance
                cta
                disclaimer
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showQuiz) {
            QuizIntroView(
                onClose: { showQuiz = false },
                onOpenChat: {
                    showQuiz = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        onSelectTab?(.chat)
                    }
                }
            )
        }
        .sheet(isPresented: $showJournal) { JournalView() }
        .sheet(isPresented: $showBodyCheck) { BodyCheckView() }
        .sheet(isPresented: $showSaved) { SavedLibraryView() }
        .sheet(isPresented: $showStats) { StatsView() }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--open-quiz") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showQuiz = true
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .center) {
            HerHealthLogo()
            Spacer()
            IconRoundButton(systemImage: "bell.fill", badge: true)
        }
    }

    // MARK: - Hero
    private var hero: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                Text("You are\nsupported,\nstep by step")
                    .font(AppFonts.display(32))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Psychological support, education,\nand gentle guidance for\nbreast health concerns.")
                    .font(AppFonts.body(14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            PersonIllustration(size: 150)
                .padding(.trailing, -4)
        }
        .padding(.top, 4)
    }

    // MARK: - ACT / MBCT pills
    private var therapyPills: some View {
        HStack(spacing: 12) {
            TherapyPill(symbol: "shield.checkered", title: "ACT", subtitle: "Acceptance &\nCommitment Therapy")
            TherapyPill(symbol: "leaf.circle.fill", title: "MBCT", subtitle: "Mindfulness-Based\nCognitive Therapy")
        }
    }

    // MARK: - 2x2 Feature grid
    private var featuresGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(features) { f in
                FeatureCard(feature: f) { handleRoute(f.route) }
            }
        }
    }

    // MARK: - Quick action strip (Journal, Self-Check, Saved, Insights)
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Your tools", trailing: nil)
            HStack(spacing: 8) {
                QuickActionChip(symbol: "book.closed.fill", title: "Journal", tint: AppColors.primary) { showJournal = true }
                QuickActionChip(symbol: "hand.raised.fill", title: "Self-Check", tint: AppColors.accentPeach) { showBodyCheck = true }
                QuickActionChip(symbol: "bookmark.fill", title: "Saved", tint: AppColors.accentPurple) { showSaved = true }
                QuickActionChip(symbol: "chart.line.uptrend.xyaxis", title: "Insights", tint: AppColors.accentGreen) { showStats = true }
            }
        }
    }

    private func handleRoute(_ route: HomeRoute) {
        switch route {
        case .riskQuiz: showQuiz = true
        case .aiCompanion: onSelectTab?(.chat)
        case .education, .anxietyRelief: onSelectTab?(.learn)
        case .calmGround: onSelectTab?(.calm)
        default: break
        }
    }

    // MARK: - Monthly reminder
    private var monthlyReminder: some View {
        ReminderRow(
            icon: "calendar.badge.clock",
            tint: AppColors.primary,
            title: "Monthly Reminder",
            subtitle: "Gentle check-in and self-care\nprompts just for you.",
            isOn: $monthlyReminderOn
        )
    }

    // MARK: - Reassurance
    private var reassurance: some View {
        SoftCard(corner: 22) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.primarySoft)
                        .frame(width: 52, height: 52)
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Finding a lump does not\nalways mean cancer.")
                        .font(AppFonts.headline(14))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("It is okay to feel worried.")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - CTA
    private var cta: some View {
        PrimaryButton("Talk to AI Companion", systemImage: "bubble.left.and.bubble.right.fill") {
            onSelectTab?(.chat)
        }
        .padding(.top, 4)
    }

    // MARK: - Disclaimer
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

// MARK: - Therapy pill
struct TherapyPill: View {
    let symbol: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppColors.primarySoft)
                    .frame(width: 36, height: 36)
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFonts.headline(13))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border.opacity(0.7), lineWidth: 0.6)
        )
    }
}

// MARK: - Feature card
struct FeatureCard: View {
    let feature: HomeFeature
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                IllustrationChip(tint: feature.tint, symbol: {
                    Image(systemName: feature.symbol)
                }, size: 52)
                VStack(alignment: .leading, spacing: 3) {
                    Text(feature.title)
                        .font(AppFonts.headline(14))
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(feature.subtitle)
                        .font(AppFonts.caption(11))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
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

// MARK: - Quick action chip
struct QuickActionChip: View {
    let symbol: String
    let title: String
    let tint: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(tint.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(AppFonts.micro(10))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
