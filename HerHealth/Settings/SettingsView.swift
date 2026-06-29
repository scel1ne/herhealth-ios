import SwiftUI

// MARK: - Settings screen
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = true
    @AppStorage("reminderDay") private var reminderDay: Int = 1
    @AppStorage("gentleNudges") private var gentleNudges: Bool = true
    @AppStorage("weeklyDigest") private var weeklyDigest: Bool = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("reduceMotion") private var reduceMotion: Bool = false
    @State private var showAbout: Bool = false
    @State private var showPrivacy: Bool = false
    @State private var showHelp: Bool = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    navHeader
                    hero
                    notificationsSection
                    preferencesSection
                    supportSection
                    aboutSection
                    disclaimer
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showAbout) { AboutSheet() }
        .sheet(isPresented: $showPrivacy) { PrivacySheet() }
        .sheet(isPresented: $showHelp) { HelpSheet() }
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
            Text("Settings")
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Make HerHealth\nyours")
                .font(AppFonts.display(30))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
            Text("Tune your gentle nudges and comfort.")
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var notificationsSection: some View {
        SettingsGroup(title: "Reminders") {
            SettingsToggleRow(icon: "calendar.badge.clock", tint: AppColors.primary,
                              title: "Monthly reminder",
                              subtitle: "A gentle nudge on the day you choose.",
                              isOn: $reminderEnabled)
            if reminderEnabled {
                DayPickerRow(day: $reminderDay)
            }
            SettingsToggleRow(icon: "leaf.fill", tint: AppColors.accentGreen,
                              title: "Gentle nudges",
                              subtitle: "Soft prompts to breathe or reflect.",
                              isOn: $gentleNudges)
            SettingsToggleRow(icon: "envelope.badge.fill", tint: AppColors.accentPeach,
                              title: "Weekly digest",
                              subtitle: "A Sunday summary of your insights.",
                              isOn: $weeklyDigest)
        }
    }

    private var preferencesSection: some View {
        SettingsGroup(title: "App preferences") {
            SettingsToggleRow(icon: "iphone.radiowaves.left.and.right", tint: AppColors.accentPurple,
                              title: "Haptics",
                              subtitle: "Soft taps on important moments.",
                              isOn: $hapticsEnabled)
            SettingsToggleRow(icon: "tortoise.fill", tint: AppColors.accentYellow,
                              title: "Reduce motion",
                              subtitle: "Calmer transitions and animations.",
                              isOn: $reduceMotion)
        }
    }

    private var supportSection: some View {
        SettingsGroup(title: "Support") {
            SettingsNavRow(icon: "questionmark.circle.fill", tint: AppColors.primary,
                           title: "Help & FAQ", action: { showHelp = true })
            SettingsNavRow(icon: "lock.shield.fill", tint: AppColors.accentGreen,
                           title: "Privacy & data", action: { showPrivacy = true })
        }
    }

    private var aboutSection: some View {
        SettingsGroup(title: "About") {
            SettingsNavRow(icon: "heart.text.square.fill", tint: AppColors.primary,
                           title: "About HerHealth", action: { showAbout = true })
            SettingsRow(icon: "number", tint: AppColors.textTertiary,
                        title: "Version", trailing: "1.0.0")
        }
    }

    private var disclaimer: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
            Text("HerHealth is supportive only — not a medical diagnosis or emergency service.")
                .font(AppFonts.micro(11))
        }
        .foregroundStyle(AppColors.textTertiary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, 8)
    }
}

// MARK: - Settings helpers
struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
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
}

struct SettingsToggleRow: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(AppColors.primary)
                .labelsHidden()
        }
        .padding(12)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 0.5)
                .padding(.horizontal, 12),
            alignment: .bottom
        )
    }
}

struct SettingsNavRow: View {
    let icon: String
    let tint: Color
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
        }
        .buttonStyle(ScaleButtonStyle())
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 0.5)
                .padding(.horizontal, 12),
            alignment: .bottom
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let tint: Color
    let title: String
    let trailing: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(AppFonts.headline(14))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(trailing)
                .font(AppFonts.caption(12))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(12)
    }
}

struct DayPickerRow: View {
    @Binding var day: Int
    private let days = Array(1...28)
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Day of month")
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("\(day)")
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.primary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(days, id: \.self) { d in
                        let isSelected = d == day
                        Button {
                            withAnimation(.spring()) { day = d }
                        } label: {
                            Text("\(d)")
                                .font(.system(size: 11, weight: .medium))
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle().fill(isSelected ? AppColors.primary : AppColors.primaryUltraSoft)
                                )
                                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 0.5)
                .padding(.horizontal, 12),
            alignment: .bottom
        )
    }
}

// MARK: - About sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("About HerHealth")
                            .font(AppFonts.display(30))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(2)
                        Text("HerHealth is a gentle companion app for women navigating breast-health concerns. We blend evidence-based psychology (ACT and MBCT) with practical education to make the hard days a little softer.")
                            .font(AppFonts.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack(alignment: .leading, spacing: 10) {
                            BulletLine("Built on ACT & MBCT", color: AppColors.primary)
                            BulletLine("Evidence-based education", color: AppColors.accentPeach)
                            BulletLine("No account required", color: AppColors.accentGreen)
                            BulletLine("Private & on-device", color: AppColors.accentPurple)
                        }
                        SoftCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("A gentle reminder")
                                    .font(AppFonts.headline(14))
                                Text("This app is supportive, not a diagnosis. Always consult a clinician for medical decisions.")
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
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}

struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy & data")
                            .font(AppFonts.display(30))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(2)
                        VStack(alignment: .leading, spacing: 10) {
                            BulletLine("No account, no sign-up", color: AppColors.primary)
                            BulletLine("Your journal entries stay on this device", color: AppColors.accentPeach)
                            BulletLine("We never sell your data", color: AppColors.accentGreen)
                            BulletLine("Anonymous, psychologist-moderated community", color: AppColors.accentPurple)
                        }
                        Text("You can clear all on-device data anytime from Settings → Privacy → Clear data.")
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let faqs: [(String, String)] = [
        ("Is this a medical diagnosis?",
         "No. HerHealth is a supportive tool only. It does not replace medical advice, screening, or emergency care."),
        ("Where is my data stored?",
         "All journal entries, body-check logs, and saved items stay on your device. We do not sync to a server."),
        ("Can I export my data?",
         "Yes. Settings → Privacy → Export creates a readable copy you can share with your clinician."),
        ("How often should I do a self-check?",
         "Monthly is a gentle rhythm. The app will gently remind you on the day you choose."),
        ("I'm in crisis. What should I do?",
         "If you are in immediate danger, please contact your local emergency number or a crisis line. HerHealth is not an emergency service.")
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Help & FAQ")
                            .font(AppFonts.display(30))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(2)
                        ForEach(Array(faqs.enumerated()), id: \.offset) { _, pair in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(pair.0)
                                    .font(AppFonts.headline(15))
                                Text(pair.1)
                                    .font(AppFonts.caption(12))
                                    .foregroundStyle(AppColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppColors.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
                            )
                        }
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}

struct BulletLine: View {
    let text: String
    let color: Color
    init(_ text: String, color: Color) { self.text = text; self.color = color }
    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(AppFonts.body(14))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
