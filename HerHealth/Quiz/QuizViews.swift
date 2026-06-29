import SwiftUI

// MARK: - Quiz intro
struct QuizIntroView: View {
    var onClose: () -> Void = {}
    var onOpenChat: () -> Void = {}
    @State private var started: Bool = ProcessInfo.processInfo.arguments.contains("--start-quiz")

    var body: some View {
        if started {
            QuizContainerView(
                onClose: { started = false },
                onFinishClose: onClose,
                onOpenChat: onOpenChat
            )
        } else {
            QuizLandingView(
                onStart: { started = true },
                onClose: onClose
            )
        }
    }
}

// MARK: - Quiz landing
struct QuizLandingView: View {
    var onStart: () -> Void
    var onClose: () -> Void
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Top nav bar with close button so user can leave before starting
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppColors.cardBackground))
                    }
                }
                .padding(.top, 4)

                HerHealthLogo()

                SoftCard(corner: 22) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Risk Awareness\nCheck-In")
                                .font(AppFonts.display(28))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(2)
                            Text("A gentle 10-question awareness tool")
                                .font(AppFonts.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12, weight: .medium))
                                Text("5 min")
                                    .font(AppFonts.caption(12))
                            }
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(AppColors.primarySoft)
                            )
                        }
                        Spacer(minLength: 0)
                        PersonIllustration(size: 130)
                    }
                }

                SoftCard {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primarySoft)
                                .frame(width: 36, height: 36)
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(AppColors.primary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("For awareness only —\nnot a medical diagnosis.")
                                .font(AppFonts.headline(13))
                                .foregroundStyle(AppColors.textPrimary)
                            Text("Your answers stay private and are used only to give gentle guidance.")
                                .font(AppFonts.caption(12))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }

                PrimaryButton("Begin Check-In", systemImage: "arrow.right.circle.fill", action: onStart)
                    .padding(.top, 6)

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
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.bottom, 130)
        }
    }
}

// MARK: - Quiz container (manages 10 questions and finish)
struct QuizContainerView: View {
    // Close during questions — goes back to landing (in-modal)
    var onClose: () -> Void
    // Close after finishing — fully dismisses the quiz
    var onFinishClose: () -> Void
    // Switch to AI companion tab and dismiss
    var onOpenChat: () -> Void

    @State private var index: Int = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResult: Bool = ProcessInfo.processInfo.arguments.contains("--show-result")

    private let questions: [QuizQuestion] = QuizData.questions

    var body: some View {
        if showResult {
            QuizResultView(
                score: totalScore,
                onClose: onFinishClose,
                onOpenChat: onOpenChat,
                onRetake: retake
            )
        } else {
            QuizQuestionView(
                question: questions[index],
                progress: Double(index + 1) / Double(questions.count),
                selected: answers[index],
                onSelect: { answers[index] = $0 },
                onNext: goNext,
                onBack: goBack,
                isLast: index == questions.count - 1,
                onClose: onFinishClose
            )
        }
    }

    private var totalScore: Int {
        answers.values.reduce(0, +)
    }

    private func goNext() {
        if index < questions.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { index += 1 }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showResult = true }
        }
    }

    private func goBack() {
        if index > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { index -= 1 }
        } else {
            onClose()
        }
    }

    private func retake() {
        index = 0
        answers = [:]
        withAnimation(.spring()) { showResult = false }
    }
}

// MARK: - Single question view (fixed top + scroll middle + safeAreaInset CTA bottom)
struct QuizQuestionView: View {
    let question: QuizQuestion
    let progress: Double
    let selected: Int?
    var onSelect: (Int) -> Void
    var onNext: () -> Void
    var onBack: () -> Void
    let isLast: Bool
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Fixed top: nav bar + hero
            VStack(spacing: 12) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppColors.cardBackground))
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppColors.cardBackground))
                    }
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Risk Awareness Check-In")
                            .font(AppFonts.title(20))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("A gentle 10-question awareness tool")
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer(minLength: 0)
                    PersonIllustration(size: 72)
                }

                ProgressBlock(progress: progress,
                              label: "Question \(question.index) of 10",
                              right: "\(Int(progress * 100))%")
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(AppColors.background)

            // Scrollable middle: question + options + affirmation
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SoftCard {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle().fill(AppColors.primarySoft)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColors.primary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("For awareness only —\nnot a medical diagnosis.")
                                    .font(AppFonts.headline(13))
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                        }
                    }

                    Text(question.title)
                        .font(AppFonts.displaySemi(24))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let h = question.helper {
                        Text(h)
                            .font(AppFonts.caption(13))
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 10) {
                        ForEach(question.options) { opt in
                            OptionRow(option: opt, isSelected: selected == opt.value) {
                                onSelect(opt.value)
                            }
                        }
                    }
                    .padding(.top, 2)

                    SoftCard(corner: 18) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Circle().fill(AppColors.primaryUltraSoft)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "hands.sparkles.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColors.primary)
                            }
                            Text(question.affirmation)
                                .font(AppFonts.headline(13))
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.horizontal, AppMetrics.pagePadding)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
        }
        // Floating bottom CTA — using safeAreaInset guarantees the scroll content
        // never gets hidden behind the button.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider().opacity(0.4)
                PrimaryButton(isLast ? "See My Summary" : "Next Question",
                              systemImage: isLast ? "checkmark.seal.fill" : "arrow.right",
                              action: onNext)
                    .opacity(selected == nil ? 0.5 : 1)
                    .disabled(selected == nil)
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
            }
            .background(AppColors.background)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - Progress block
struct ProgressBlock: View {
    let progress: Double
    let label: String
    let right: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text(right)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.primary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColors.primaryUltraSoft)
                    Capsule()
                        .fill(AppGradients.primaryButton)
                        .frame(width: max(8, proxy.size.width * progress))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Option row
struct OptionRow: View {
    let option: QuizOption
    let isSelected: Bool
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryUltraSoft)
                        .frame(width: 40, height: 40)
                    Image(systemName: option.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }
                Text(option.label)
                    .font(AppFonts.bodyMedium(15))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? AppColors.primaryUltraSoft : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? AppColors.primary : AppColors.border.opacity(0.6),
                            lineWidth: isSelected ? 1.4 : 0.6)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Quiz Result
struct QuizResultView: View {
    let score: Int
    var onClose: () -> Void
    var onOpenChat: () -> Void
    var onRetake: () -> Void
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppColors.cardBackground))
                    }
                    Spacer()
                }
                .padding(.top, 8)

                SoftCard(corner: 22) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Awareness Profile")
                            .font(AppFonts.title(18))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Score")
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textSecondary)
                        Text("\(score)/30")
                            .font(AppFonts.display(40))
                            .foregroundStyle(AppColors.primary)
                        Text(scoreLevel.text)
                            .font(AppFonts.headline(13))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(scoreLevel.detail)
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Gentle next steps", trailing: nil)
                    NextStepRow(symbol: "lungs.fill", tint: AppColors.primary,
                                title: "Try 3-Minute Breathing",
                                subtitle: "Calm your nervous system in 3 minutes.")
                    NextStepRow(symbol: "list.bullet.clipboard.fill", tint: AppColors.accentPeach,
                                title: "Plan a self-check",
                                subtitle: "A 2-minute monthly habit for awareness.")
                    NextStepRow(symbol: "bubble.left.and.bubble.right.fill", tint: AppColors.accentPurple,
                                title: "Talk to AI Companion",
                                subtitle: "24/7 supportive, non-judgmental guidance.")
                }

                PrimaryButton("Talk to AI Companion",
                              systemImage: "bubble.left.and.bubble.right.fill",
                              action: onOpenChat)
                SecondaryButton(title: "Retake Quiz", action: onRetake)
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.bottom, 130)
        }
    }

    private var scoreLevel: (text: String, detail: String) {
        switch score {
        case 0...12: return ("You're starting gently",
                             "Every step counts. Try one of the gentle practices to begin your rhythm.")
        case 13...20: return ("Building awareness",
                               "You're learning your patterns. Keep going — small habits add up.")
        case 21...25: return ("A strong rhythm",
                               "You know your body well. Stay consistent and trust your instincts.")
        default: return ("Wonderful self-care",
                         "Your awareness is a gift to your future self. Keep listening inward.")
        }
    }
}

struct NextStepRow: View {
    let symbol: String
    let tint: Color
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: symbol)
                    .font(.system(size: 16))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.headline(13))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
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

// MARK: - Data
enum QuizData {
    static let questions: [QuizQuestion] = [
        .init(index: 1, title: "How often do you do\na breast self-check?", helper: nil,
              options: [
                .init(icon: "checkmark.circle.fill", label: "Monthly", value: 1),
                .init(icon: "clock.fill", label: "Sometimes", value: 2),
                .init(icon: "calendar", label: "Rarely", value: 3),
                .init(icon: "heart.slash.fill", label: "I haven't started yet", value: 4)
              ],
              affirmation: "Knowing your habits is\na positive first step."),
        .init(index: 2, title: "Do you know your\nfamily history?", helper: nil,
              options: [
                .init(icon: "person.3.fill", label: "Yes, in detail", value: 1),
                .init(icon: "questionmark.circle", label: "Somewhat", value: 2),
                .init(icon: "xmark.circle", label: "Not really", value: 3)
              ],
              affirmation: "Family history is one of many\nfactors — you are not alone."),
        .init(index: 3, title: "How old were you when\nyou had your first period?", helper: nil,
              options: [
                .init(icon: "sunrise.fill", label: "Under 12", value: 2),
                .init(icon: "circle.fill", label: "12–14", value: 1),
                .init(icon: "moon.fill", label: "15 or later", value: 1)
              ],
              affirmation: "Hormonal milestones are part\nof your unique story."),
        .init(index: 4, title: "How would you describe\nyour current stress level?", helper: nil,
              options: [
                .init(icon: "face.smiling.fill", label: "Low", value: 1),
                .init(icon: "cloud.fill", label: "Moderate", value: 2),
                .init(icon: "cloud.bolt.rain.fill", label: "High", value: 3)
              ],
              affirmation: "Naming your stress is a kind\nact of self-care."),
        .init(index: 5, title: "How often do you\nmove your body weekly?", helper: nil,
              options: [
                .init(icon: "figure.run", label: "5+ times", value: 1),
                .init(icon: "figure.walk", label: "2–4 times", value: 2),
                .init(icon: "bed.double.fill", label: "Rarely", value: 3)
              ],
              affirmation: "Gentle movement counts —\na short walk is wonderful."),
        .init(index: 6, title: "How is your sleep\nmost nights?", helper: nil,
              options: [
                .init(icon: "moon.stars.fill", label: "Restful", value: 1),
                .init(icon: "cloud.moon", label: "Uneven", value: 2),
                .init(icon: "exclamationmark.triangle.fill", label: "Troubled", value: 3)
              ],
              affirmation: "Better sleep is a journey,\nnot a destination."),
        .init(index: 7, title: "Do you know the\nrecommended screening age?", helper: nil,
              options: [
                .init(icon: "checkmark.seal.fill", label: "Yes", value: 1),
                .init(icon: "questionmark.diamond.fill", label: "Not sure", value: 2)
              ],
              affirmation: "Knowing when to screen is\npowerful self-knowledge."),
        .init(index: 8, title: "How comfortable are you\ntalking with a doctor?", helper: nil,
              options: [
                .init(icon: "bubble.left.and.bubble.right.fill", label: "Very", value: 1),
                .init(icon: "text.bubble", label: "Somewhat", value: 2),
                .init(icon: "ellipsis.bubble.fill", label: "Hesitant", value: 3)
              ],
              affirmation: "Practicing what to say can\nhelp when the moment comes."),
        .init(index: 9, title: "How often do you\nlimit alcohol?", helper: nil,
              options: [
                .init(icon: "drop.fill", label: "Always", value: 1),
                .init(icon: "drop.degreesign", label: "Sometimes", value: 2),
                .init(icon: "wineglass.fill", label: "Rarely", value: 3)
              ],
              affirmation: "Small swaps add up — you\nare doing better than you think."),
        .init(index: 10, title: "What's your intention\nfor today?", helper: nil,
              options: [
                .init(icon: "sparkles", label: "To learn", value: 1),
                .init(icon: "heart.fill", label: "To feel calmer", value: 1),
                .init(icon: "questionmark.bubble.fill", label: "To find answers", value: 1)
              ],
              affirmation: "Any intention is a brave\nand beautiful one.")
    ]
}
