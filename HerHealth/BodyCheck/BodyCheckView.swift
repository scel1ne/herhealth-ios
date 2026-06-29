import SwiftUI

// MARK: - Body Check (Monthly self-check log)
struct BodyCheckView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [BodyCheckEntry] = BodyCheckStore.seed
    @State private var showNew: Bool = false
    @State private var showGuide: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    navHeader
                    hero
                    summaryCard
                    guideButton
                    historyList
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 140)
            }
            newEntryButton
        }
        .sheet(isPresented: $showNew) {
            NewBodyCheckSheet(entries: $entries)
        }
        .sheet(isPresented: $showGuide) {
            BodyCheckGuideSheet()
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
            Text("Self-Check")
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Monthly\nSelf-Check")
                .font(AppFonts.display(30))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
            Text("Two minutes. Know your normal.")
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var summaryCard: some View {
        SoftCard(corner: 22) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(AppColors.primaryUltraSoft)
                        .frame(width: 56, height: 56)
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last check: \(lastCheckLabel)")
                        .font(AppFonts.headline(14))
                    Text("Next reminder in \(daysUntilNext) days")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        }
    }

    private var guideButton: some View {
        Button(action: { showGuide = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppColors.accentPeach.opacity(0.25))
                        .frame(width: 40, height: 40)
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(AppColors.accentPeach)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("How to do a self-check")
                        .font(AppFonts.headline(14))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("A gentle 2-minute walk-through")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(14)
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

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your history", trailing: "\(entries.count) entries")
            ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                BodyCheckRow(entry: entry)
            }
        }
    }

    private var newEntryButton: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [AppColors.background.opacity(0), AppColors.background],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 30)
            PrimaryButton("Log Today's Check", systemImage: "plus.circle.fill") {
                showNew = true
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.bottom, 100)
        }
    }

    private var lastCheckLabel: String {
        guard let last = entries.sorted(by: { $0.date > $1.date }).first else { return "—" }
        let f = DateFormatter()
        if Calendar.current.isDateInToday(last.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(last.date) {
            return "Yesterday"
        } else {
            f.dateFormat = "MMM d"
            return f.string(from: last.date)
        }
    }

    private var daysUntilNext: Int {
        let cal = Calendar.current
        guard let last = entries.sorted(by: { $0.date > $1.date }).first else { return 30 }
        let next = cal.date(byAdding: .day, value: 30, to: last.date) ?? Date()
        let comps = cal.dateComponents([.day], from: Date(), to: next)
        return max(0, comps.day ?? 0)
    }
}

// MARK: - Body check row
struct BodyCheckRow: View {
    let entry: BodyCheckEntry
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(entry.finding == .noChange ? AppColors.accentGreen.opacity(0.2) : AppColors.accentPeach.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.finding.symbol)
                    .foregroundStyle(entry.finding == .noChange ? AppColors.accentGreen : AppColors.accentPeach)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(formattedDate)
                        .font(AppFonts.headline(13))
                    Spacer()
                    Text(entry.finding.rawValue)
                        .font(AppFonts.micro(10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(
                                entry.finding == .noChange
                                ? AppColors.accentGreen.opacity(0.18)
                                : AppColors.accentPeach.opacity(0.18)
                            )
                        )
                        .foregroundStyle(entry.finding == .noChange ? AppColors.accentGreen : AppColors.accentPeach)
                }
                Text(entry.note)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if entry.side != .none {
                    Text("Side: \(entry.side.rawValue)")
                        .font(AppFonts.micro(10))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
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

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: entry.date)
    }
}

// MARK: - New entry sheet
struct NewBodyCheckSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [BodyCheckEntry]
    @State private var side: BodyCheckEntry.Side = .none
    @State private var finding: BodyCheckEntry.Finding = .noChange
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today's check")
                                .font(AppFonts.display(28))
                                .foregroundStyle(AppColors.textPrimary)
                            Text("A simple log, not a diagnosis.")
                                .font(AppFonts.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        chipPicker(title: "Side", options: BodyCheckEntry.Side.allCases, selection: $side) { $0.rawValue }
                        chipPicker(title: "What did you notice?", options: BodyCheckEntry.Finding.allCases, selection: $finding) { $0.rawValue }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes (optional)")
                                .font(AppFonts.headline(13))
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
                                    )
                                if note.isEmpty {
                                    Text("Any observations to remember?")
                                        .font(AppFonts.body(14))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .padding(14)
                                }
                                TextEditor(text: $note)
                                    .font(AppFonts.body(14))
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .frame(minHeight: 100)
                            }
                        }

                        SoftCard {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(AppColors.primary)
                                Text("This log is private. If you notice anything new or concerning, please consult a clinician.")
                                    .font(AppFonts.caption(11))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }

                        PrimaryButton("Save Log", systemImage: "checkmark") { save() }
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func chipPicker<T: Identifiable & Hashable>(title: String, options: [T], selection: Binding<T>, label: @escaping (T) -> String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.headline(13))
                .foregroundStyle(AppColors.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options) { opt in
                        let isSelected = selection.wrappedValue == opt
                        Button {
                            withAnimation(.spring()) { selection.wrappedValue = opt }
                        } label: {
                            Text(label(opt))
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
                }
            }
        }
    }

    private func save() {
        let new = BodyCheckEntry(date: Date(), side: side, finding: finding, note: note.isEmpty ? defaultNote : note)
        entries.insert(new, at: 0)
        dismiss()
    }

    private var defaultNote: String {
        finding == .noChange ? "No new changes noticed." : "Noted \(finding.rawValue.lowercased())."
    }
}

// MARK: - Self-check guide sheet
struct BodyCheckGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let steps: [(String, String, String)] = [
        ("Look", "Stand in front of a mirror with shoulders straight, arms on hips. Look for changes in shape, dimpling, or skin.", "eye.fill"),
        ("Raise", "Raise your arms overhead and look again for the same changes, including the underside.", "arrow.up.circle.fill"),
        ("Lie down", "Use your right hand to feel your left breast in small circles. Then switch. Use light, medium, and firm pressure.", "hand.raised.fill"),
        ("Stand up", "Repeat the same small circles while standing or in the shower. Many people find this easier.", "drop.fill"),
        ("Note", "Notice any lump, thickening, or change. Note size, location, and whether it moves. Don't panic — most are not cancer.", "square.and.pencil"),
        ("Schedule", "If you find anything new or concerning, schedule a clinical breast exam within 1–2 weeks.", "calendar")
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("How to do\na self-check")
                                .font(AppFonts.display(30))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(2)
                            Text("Two minutes, once a month. After your period is a good time.")
                                .font(AppFonts.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle().fill(AppColors.primarySoft)
                                        .frame(width: 36, height: 36)
                                    Text("\(idx + 1)")
                                        .font(.system(size: 14, weight: .bold, design: .serif))
                                        .foregroundStyle(AppColors.primary)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.0)
                                        .font(AppFonts.headline(15))
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(step.1)
                                        .font(AppFonts.caption(12))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
                            )
                        }
                        SoftCard {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(AppColors.primary)
                                Text("Most breast changes are not cancer. Knowing your normal is the goal — not finding problems.")
                                    .font(AppFonts.caption(12))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
