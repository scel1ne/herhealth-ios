import SwiftUI

// MARK: - Saved Library
struct SavedLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [SavedItem] = SavedStore.seed
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all = "All", articles = "Articles", exercises = "Exercises"
        var id: String { rawValue }
    }

    private var filtered: [SavedItem] {
        switch filter {
        case .all: return items
        case .articles: return items.filter { $0.kind == .article }
        case .exercises: return items.filter { $0.kind == .exercise }
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                navHeader
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        hero
                        filterStrip
                        if filtered.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 10) {
                                ForEach(filtered) { item in
                                    SavedItemRow(item: item) {
                                        remove(item)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                    .padding(.bottom, 130)
                }
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
            Text("Saved")
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AppMetrics.pagePadding)
        .padding(.top, 8)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your\nSaved Library")
                .font(AppFonts.display(30))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
            Text("Articles and exercises you've kept close.")
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var filterStrip: some View {
        HStack(spacing: 8) {
            ForEach(Filter.allCases) { f in
                let isSelected = filter == f
                Button {
                    withAnimation(.spring()) { filter = f }
                } label: {
                    Text(f.rawValue)
                        .font(AppFonts.caption(12))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(isSelected ? AppColors.primary : AppColors.cardBackground)
                        )
                        .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                        .overlay(
                            Capsule().stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 0.6)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        SoftCard {
            VStack(spacing: 8) {
                Image(systemName: "bookmark")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.textTertiary)
                Text("Nothing saved yet")
                    .font(AppFonts.headline(14))
                Text("Tap the bookmark on any article or exercise to keep it close.")
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private func remove(_ item: SavedItem) {
        withAnimation(.spring()) {
            items.removeAll(where: { $0.id == item.id })
        }
    }
}

struct SavedItemRow: View {
    let item: SavedItem
    var onRemove: () -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(item.tint.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: item.symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(item.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(item.subtitle)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(AppColors.primaryUltraSoft))
            }
            .buttonStyle(ScaleButtonStyle())
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
