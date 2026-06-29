import SwiftUI

struct LearnView: View {
    @State private var selectedArticle: Article? = nil
    @State private var selectedTag: LearnTag? = nil
    @State private var showSaved: Bool = false

    private let insights: [LearnInsight] = [
        .init(value: "32", unit: "%", label: "awareness\nanxiety", symbol: "lightbulb.fill"),
        .init(value: "1.25", unit: "%", label: "fear\nrecurrence", symbol: "heart.text.square.fill"),
        .init(value: "38", unit: "%", label: "depression", symbol: "cloud.rain.fill")
    ]

    private var allArticles: [Article] {
        ArticleLibrary.all
    }

    private var filteredArticles: [Article] {
        if let t = selectedTag {
            return allArticles.filter { $0.tag == t }
        }
        return allArticles
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                hero
                featured
                categoryStrip
                articlesList
                insightsSection
                aiRecommendation
                startCTA
                disclaimer
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
        .sheet(isPresented: $showSaved) {
            SavedLibraryView()
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--open-article") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedArticle = allArticles.first
                }
            }
        }
    }

    private var header: some View {
        HStack {
            HerHealthLogo()
            Spacer()
            Button(action: { showSaved = true }) {
                ZStack {
                    Circle().fill(AppColors.cardBackground)
                        .frame(width: 38, height: 38)
                        .shadow(color: AppColors.primaryDeep.opacity(0.08), radius: 6, x: 0, y: 2)
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            IconRoundButton(systemImage: "bell.fill", badge: true)
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Learn\n& Reassure")
                    .font(AppFonts.display(30))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)
                Text("Trusted breast-health\neducation in small steps")
                    .font(AppFonts.body(14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
            PersonIllustration(size: 140)
        }
    }

    private var featured: some View {
        Button(action: { selectedArticle = allArticles.first }) {
            SoftCard(corner: 22) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FEATURED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppColors.primaryUltraSoft))
                        Text("3-Minute\nBreast Cancer Basics")
                            .font(AppFonts.title(18))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                        Text("Understand the essentials\nin just a few minutes.")
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                        HStack(spacing: 6) {
                            Text("Start Now")
                                .font(AppFonts.caption(12))
                            Image(systemName: "play.fill")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColors.primary))
                    }
                    Spacer(minLength: 0)
                    ZStack {
                        Circle()
                            .stroke(AppColors.primaryUltraSoft, lineWidth: 4)
                            .frame(width: 90, height: 90)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.primary)
                    }
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var categoryStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "All articles", trailing: "\(allArticles.count) reads")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TagPill(title: "All", symbol: "square.grid.2x2.fill",
                            tint: AppColors.primary, isOn: selectedTag == nil) {
                        withAnimation { selectedTag = nil }
                    }
                    ForEach(LearnTag.allCases) { t in
                        TagPill(title: t.label, symbol: t.symbol,
                                tint: AppColors.primary, isOn: selectedTag == t) {
                            withAnimation { selectedTag = (selectedTag == t) ? nil : t }
                        }
                    }
                }
            }
        }
    }

    private var articlesList: some View {
        VStack(spacing: 10) {
            ForEach(filteredArticles) { article in
                Button(action: { selectedArticle = article }) {
                    ArticleListRow(article: article)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Key Insights", trailing: nil)
            HStack(spacing: 12) {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }

    private var aiRecommendation: some View {
        SoftCard {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle().fill(AppColors.primarySoft)
                        .frame(width: 44, height: 44)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Digital support is increasingly recommended for psychological distress.")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private var startCTA: some View {
        PrimaryButton("Start Learning", systemImage: "book.fill") {
            selectedArticle = allArticles.first
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

struct TagPill: View {
    let title: String
    let symbol: String
    let tint: Color
    let isOn: Bool
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .semibold))
                Text(title)
                    .font(AppFonts.caption(12))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(isOn ? tint : AppColors.cardBackground)
            )
            .foregroundStyle(isOn ? .white : AppColors.textPrimary)
            .overlay(
                Capsule().stroke(isOn ? Color.clear : AppColors.border, lineWidth: 0.6)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ArticleListRow: View {
    let article: Article
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(article.tint.opacity(0.18))
                    .frame(width: 50, height: 50)
                Image(systemName: article.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(article.tint)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(article.subtitle)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Text(article.tag.label)
                        .font(AppFonts.micro(9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(AppColors.primaryUltraSoft))
                        .foregroundStyle(AppColors.primary)
                    Text("\(article.readMinutes) min")
                        .font(AppFonts.micro(9))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
        )
    }
}

struct InsightCard: View {
    let insight: LearnInsight
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle().fill(AppColors.primaryUltraSoft)
                        .frame(width: 30, height: 30)
                    Image(systemName: insight.symbol)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.primary)
                }
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(insight.value)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                Text(insight.unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
            }
            Text(insight.label)
                .font(AppFonts.caption(10))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
        )
    }
}
