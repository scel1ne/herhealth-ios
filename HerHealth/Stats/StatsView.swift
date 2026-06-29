import SwiftUI

// MARK: - Stats screen
struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    private let entries: [JournalEntry] = JournalStore.seed
    private let articles: [Article] = ArticleLibrary.all
    private let savedCount: Int = SavedStore.seed.count

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    navHeader
                    hero
                    monthStreak
                    moodSummary
                    learningSummary
                    topMoods
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 130)
            }
        }
    }

    private var navHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.cardBackground))
            }
            Spacer()
            Text("Your Insights")
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your\nGentle Insights")
                .font(AppFonts.display(30))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
            Text("Trends from your last 30 days.")
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var monthStreak: some View {
        SoftCard(corner: 22) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().stroke(AppColors.primaryUltraSoft, lineWidth: 6)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: 0.66)
                        .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 64, height: 64)
                    Text("5")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("5-day streak")
                        .font(AppFonts.headline(15))
                    Text("You've checked in 5 days in a row. Beautiful consistency.")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    private var moodSummary: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mood trend")
                        .font(AppFonts.headline(14))
                    Spacer()
                    Text("7 entries")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                MoodLineChart(entries: entries)
            }
        }
    }

    private var learningSummary: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning")
                    .font(AppFonts.headline(14))
                HStack(spacing: 12) {
                    StatTile(value: "\(articles.count)", label: "articles available", symbol: "book.fill", tint: AppColors.primary)
                    StatTile(value: "\(savedCount)", label: "saved", symbol: "bookmark.fill", tint: AppColors.accentPeach)
                }
            }
        }
    }

    private var topMoods: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Most felt moods")
                    .font(AppFonts.headline(14))
                ForEach(topMoodPairs, id: \.0) { pair in
                    MoodBarRow(mood: pair.0, count: pair.1, total: entries.count)
                }
            }
        }
    }

    private var topMoodPairs: [(WeeklyMood, Int)] {
        let counts = Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
}

struct StatTile: View {
    let value: String
    let label: String
    let symbol: String
    let tint: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle().fill(tint.opacity(0.18))
                        .frame(width: 30, height: 30)
                    Image(systemName: symbol)
                        .font(.system(size: 12))
                        .foregroundStyle(tint)
                }
                Spacer()
            }
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(AppFonts.caption(10))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.cardSoft)
        )
    }
}

struct MoodBarRow: View {
    let mood: WeeklyMood
    let count: Int
    let total: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: mood.symbol)
                    .font(.system(size: 12))
                    .foregroundStyle(mood.color)
                Text(mood.label)
                    .font(AppFonts.caption(12))
                Spacer()
                Text("\(count) of \(total)")
                    .font(AppFonts.micro(10))
                    .foregroundStyle(AppColors.textTertiary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColors.primaryUltraSoft)
                    Capsule().fill(mood.color)
                        .frame(width: max(8, proxy.size.width * (Double(count) / Double(max(total, 1)))))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Mood line chart
struct MoodLineChart: View {
    let entries: [JournalEntry]
    private var points: [CGPoint] {
        let last7 = Array(entries.sorted(by: { $0.date > $1.date }).prefix(7))
        let ordered = last7.sorted(by: { $0.date < $1.date })
        let maxRaw = Double(WeeklyMood.hopeful.rawValue)
        let count = max(ordered.count - 1, 1)
        return ordered.enumerated().map { idx, e in
            let x = Double(idx) / Double(count)
            let y = 1.0 - Double(e.mood.rawValue) / maxRaw
            return CGPoint(x: x, y: y)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack {
                    // baseline
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: proxy.size.height - 1))
                        p.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height - 1))
                    }
                    .stroke(AppColors.primaryUltraSoft, lineWidth: 1)

                    if points.count > 1 {
                        Path { p in
                            p.move(to: denorm(points[0], size: proxy.size))
                            for p2 in points.dropFirst() {
                                p.addLine(to: denorm(p2, size: proxy.size))
                            }
                        }
                        .stroke(AppGradients.primaryButton, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        // dots
                        ForEach(0..<points.count, id: \.self) { i in
                            let pt = denorm(points[i], size: proxy.size)
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 7, height: 7)
                                .position(pt)
                        }
                    }
                }
            }
            .frame(height: 110)

            HStack {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdayLabel(i))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func denorm(_ p: CGPoint, size: CGSize) -> CGPoint {
        CGPoint(x: p.x * size.width, y: max(8, p.y * (size.height - 12)) + 6)
    }

    private func weekdayLabel(_ offset: Int) -> String {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: -(7 - 1 - offset), to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f.string(from: date)
    }
}
