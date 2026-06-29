import SwiftUI

// MARK: - Article Detail (read full content, save)
struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var saved: Bool = false
    @State private var progress: Double = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    navBar
                    header
                    intro
                    sections
                    takeaways
                    related
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .id("BOTTOM")
            }
            .background(AppColors.background.ignoresSafeArea())
            .background(
                GeometryReader { bgProxy in
                    Color.clear.preference(key: ScrollOffsetKey.self, value: -bgProxy.frame(in: .named("articleScroll")).minY)
                }
            )
            .coordinateSpace(name: "articleScroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                let p = max(0, min(1, value / 400))
                if abs(progress - p) > 0.02 { progress = p }
            }
            .onAppear {
                if ProcessInfo.processInfo.arguments.contains("--scroll-bottom") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
        }
    }

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.cardBackground))
            }
            Spacer()
            // progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColors.primaryUltraSoft)
                    Capsule()
                        .fill(AppGradients.primaryButton)
                        .frame(width: max(8, proxy.size.width * progress))
                }
            }
            .frame(height: 4)
            .frame(maxWidth: 120)
            Spacer()
            Button(action: { saved.toggle() }) {
                Image(systemName: saved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(saved ? AppColors.primary : AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.cardBackground))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(article.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(article.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(article.tint.opacity(0.15)))
                Text("\(article.readMinutes) min read")
                    .font(AppFonts.micro(10))
                    .foregroundStyle(AppColors.textTertiary)
            }
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(article.tint.opacity(0.18))
                        .frame(width: 64, height: 64)
                    Image(systemName: article.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(article.tint)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(AppFonts.display(26))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(article.subtitle)
                        .font(AppFonts.body(14))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var intro: some View {
        Text(article.intro)
            .font(AppFonts.body(15))
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(article.sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.heading)
                        .font(AppFonts.title(18))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(section.body)
                        .font(AppFonts.body(14))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    if !section.bullets.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(section.bullets, id: \.self) { bullet in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(article.tint)
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 7)
                                    Text(bullet)
                                        .font(AppFonts.body(14))
                                        .foregroundStyle(AppColors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    private var takeaways: some View {
        SoftCard(corner: 22) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AppColors.accentPeach)
                    Text("Key takeaways")
                        .font(AppFonts.headline(14))
                }
                ForEach(article.takeaways, id: \.self) { t in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.accentGreen)
                            .padding(.top, 3)
                        Text(t)
                            .font(AppFonts.body(14))
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var related: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Related reading", trailing: nil)
            ForEach(relatedArticles) { r in
                RelatedRow(article: r)
            }
        }
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [AppColors.background.opacity(0), AppColors.background],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 24)
            HStack(spacing: 12) {
                Button(action: { saved.toggle() }) {
                    Image(systemName: saved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(saved ? AppColors.primary : AppColors.textPrimary)
                        .frame(width: 50, height: 50)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AppColors.cardBackground))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.border, lineWidth: 0.6))
                }
                .buttonStyle(ScaleButtonStyle())
                PrimaryButton(saved ? "Saved" : "Save for later",
                             systemImage: saved ? "checkmark" : "bookmark.fill",
                             action: { saved.toggle() })
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.bottom, 28)
        }
        .background(AppColors.background.opacity(0.98))
    }

    private var relatedArticles: [Article] {
        ArticleLibrary.all.filter { $0.id != article.id && $0.tag == article.tag }.prefix(2).map { $0 }
    }
}

struct RelatedRow: View {
    let article: Article
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle().fill(article.tint.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: article.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(article.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(article.title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(article.readMinutes) min read")
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
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
        )
    }
}

// MARK: - Scroll offset
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
