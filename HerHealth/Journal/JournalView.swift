import SwiftUI

// MARK: - Journal screen
struct JournalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [JournalEntry] = JournalStore.seed
    @State private var showNew: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    navHeader
                    hero
                    moodTrend
                    todayPrompt
                    entriesList
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 140)
            }
            newEntryButton
        }
        .sheet(isPresented: $showNew) {
            NewJournalEntrySheet(entries: $entries)
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
            Text("Journal")
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button(action: { showNew = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.cardBackground))
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your\nInner Weather")
                .font(AppFonts.display(30))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
            Text("A few words a day can soften a hard week.")
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var moodTrend: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("This week")
                        .font(AppFonts.headline(14))
                    Spacer()
                    Text(weeklyAverageLabel)
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                MoodTrendChart(entries: entries)
            }
        }
    }

    private var todayPrompt: some View {
        SoftCard(corner: 22) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppColors.accentPeach.opacity(0.25))
                        .frame(width: 44, height: 44)
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(AppColors.accentPeach)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's gentle prompt")
                        .font(AppFonts.headline(13))
                    Text("What is one small thing that brought you a moment of ease?")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent entries", trailing: "\(entries.count) total")
            ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                JournalEntryRow(entry: entry)
            }
        }
    }

    private var weeklyAverageLabel: String {
        guard !entries.isEmpty else { return "—" }
        let recent = entries.sorted(by: { $0.date > $1.date }).prefix(7)
        let avg = Double(recent.reduce(0) { $0 + $1.mood.rawValue }) / Double(recent.count)
        let mood = WeeklyMood(rawValue: Int(avg.rounded())) ?? .neutral
        return "Mostly \(mood.label.lowercased())"
    }

    private var newEntryButton: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [AppColors.background.opacity(0), AppColors.background],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 30)
            PrimaryButton("New Entry", systemImage: "square.and.pencil") {
                showNew = true
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Mood trend chart
struct MoodTrendChart: View {
    let entries: [JournalEntry]
    private let dayCount: Int = 7

    private var last7: [JournalEntry] {
        Array(entries.sorted(by: { $0.date > $1.date }).prefix(dayCount))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<dayCount, id: \.self) { i in
                let entry = i < last7.count ? last7[last7.count - 1 - i] : nil
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(entry?.mood.color.opacity(0.18) ?? AppColors.primaryUltraSoft)
                            .frame(width: 32, height: 32)
                        if let e = entry {
                            Image(systemName: e.mood.symbol)
                                .font(.system(size: 14))
                                .foregroundStyle(e.mood.color)
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 10))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }
                    Text(weekdayLabel(i))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekdayLabel(_ offset: Int) -> String {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: -(dayCount - 1 - offset), to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f.string(from: date)
    }
}

// MARK: - Journal entry row
struct JournalEntryRow: View {
    let entry: JournalEntry
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(entry.mood.color.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.mood.symbol)
                    .foregroundStyle(entry.mood.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(formattedDate)
                        .font(AppFonts.headline(13))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Text(entry.mood.label)
                        .font(AppFonts.micro(10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(entry.mood.color.opacity(0.18)))
                        .foregroundStyle(entry.mood.color)
                }
                Text(entry.note)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                if !entry.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                    .padding(.top, 2)
                }
            }
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

    private var formattedDate: String {
        let f = DateFormatter()
        if Calendar.current.isDateInToday(entry.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(entry.date) {
            return "Yesterday"
        } else {
            f.dateFormat = "MMM d"
            return f.string(from: entry.date)
        }
    }
}

// MARK: - New entry sheet
struct NewJournalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [JournalEntry]
    @State private var mood: WeeklyMood = .calm
    @State private var note: String = ""
    @State private var tags: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("How are you\nfeeling right now?")
                                .font(AppFonts.display(28))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(2)
                            Text("Pick the closest match. There is no wrong answer.")
                                .font(AppFonts.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(WeeklyMood.allCases) { m in
                                Button { withAnimation(.spring()) { mood = m } } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: m.symbol)
                                            .font(.system(size: 18))
                                            .foregroundStyle(m.color)
                                            .frame(width: 36)
                                        Text(m.label)
                                            .font(AppFonts.headline(15))
                                            .foregroundStyle(AppColors.textPrimary)
                                        Spacer()
                                        if mood == m {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppColors.primary)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(AppColors.textTertiary)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(mood == m ? m.color.opacity(0.10) : AppColors.cardBackground)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(mood == m ? m.color.opacity(0.6) : AppColors.border.opacity(0.6),
                                                    lineWidth: mood == m ? 1.2 : 0.6)
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("A few words (optional)")
                                .font(AppFonts.headline(13))
                                .foregroundStyle(AppColors.textPrimary)
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
                                    )
                                if note.isEmpty {
                                    Text("What's on your mind?")
                                        .font(AppFonts.body(14))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .padding(14)
                                }
                                TextEditor(text: $note)
                                    .font(AppFonts.body(14))
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .frame(minHeight: 120)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tags (comma separated)")
                                .font(AppFonts.headline(13))
                                .foregroundStyle(AppColors.textPrimary)
                            TextField("e.g. scanxiety, morning, walk", text: $tags)
                                .font(AppFonts.body(14))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppColors.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
                                )
                        }

                        PrimaryButton("Save Entry", systemImage: "checkmark") { save() }
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

    private func save() {
        let new = JournalEntry(
            date: Date(),
            mood: mood,
            note: note.isEmpty ? "Just checking in." : note,
            tags: tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { !$0.isEmpty }
        )
        entries.insert(new, at: 0)
        dismiss()
    }
}
