import SwiftUI

// MARK: - Calm tab content (new)
struct CalmView: View {
    @State private var showBreathing: ExerciseKind? = nil
    @State private var showGrounding: Bool = false
    @State private var showBodyScan: Bool = false

    private let exercises: [ExerciseItem] = [
        .init(title: "4-4-6 Breath", subtitle: "Inhale 4 · Hold 4 · Exhale 6",
              symbol: "lungs.fill", tint: AppColors.primary, durationMin: 3, kind: .breath448),
        .init(title: "4-7-8 Breath", subtitle: "Inhale 4 · Hold 7 · Exhale 8",
              symbol: "wind", tint: AppColors.accentPurple, durationMin: 3, kind: .breath478),
        .init(title: "Box Breathing", subtitle: "4 sides, 4 counts each",
              symbol: "square", tint: AppColors.accentGreen, durationMin: 4, kind: .box),
        .init(title: "5-4-3-2-1 Grounding", subtitle: "5 sight · 4 touch · 3 sound · 2 smell · 1 taste",
              symbol: "leaf.fill", tint: AppColors.accentPeach, durationMin: 3, kind: .grounding),
        .init(title: "Body Scan", subtitle: "A gentle tour of your body",
              symbol: "figure.stand", tint: AppColors.accentYellow, durationMin: 6, kind: .bodyScan),
        .init(title: "Loving-Kindness", subtitle: "Soft words toward yourself",
              symbol: "heart.fill", tint: AppColors.primaryDeep, durationMin: 5, kind: .lovingKindness)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                hero
                quickStart
                exercisesGrid
                affirmationCard
                disclaimer
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(item: $showBreathing) { kind in
            BreathSessionView(kind: kind)
        }
        .fullScreenCover(isPresented: $showGrounding) {
            GroundingSessionView()
        }
        .fullScreenCover(isPresented: $showBodyScan) {
            BodyScanSessionView()
        }
    }

    private var header: some View {
        HStack {
            HerHealthLogo()
            Spacer()
            IconRoundButton(systemImage: "bell.fill", badge: true)
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Calm\n& Ground")
                    .font(AppFonts.display(30))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)
                Text("ACT + MBCT tools for difficult moments")
                    .font(AppFonts.body(14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
            PersonIllustration(size: 130)
        }
    }

    private var quickStart: some View {
        SoftCard(corner: 22) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Quick start")
                        .font(AppFonts.headline(14))
                    Spacer()
                    Text("3 min")
                        .font(AppFonts.caption(12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                HStack(spacing: 10) {
                    QuickStartButton(title: "Breathe", symbol: "lungs.fill", color: AppColors.primary) {
                        showBreathing = .breath448
                    }
                    QuickStartButton(title: "Ground", symbol: "leaf.fill", color: AppColors.accentGreen) {
                        showGrounding = true
                    }
                    QuickStartButton(title: "Body Scan", symbol: "figure.stand", color: AppColors.accentPeach) {
                        showBodyScan = true
                    }
                }
            }
        }
    }

    private var exercisesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "All exercises", trailing: "\(exercises.count) practices")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(exercises) { ex in
                    ExerciseCard(exercise: ex) {
                        if ex.kind == .grounding {
                            showGrounding = true
                        } else if ex.kind == .bodyScan {
                            showBodyScan = true
                        } else {
                            showBreathing = ex.kind
                        }
                    }
                }
            }
        }
    }

    private var affirmationCard: some View {
        SoftCard(corner: 22) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppColors.primaryUltraSoft)
                        .frame(width: 40, height: 40)
                    Image(systemName: "heart.fill")
                        .foregroundStyle(AppColors.primary)
                }
                Text("You can notice fear without\nletting it control this moment.")
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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

struct QuickStartButton: View {
    let title: String
    let symbol: String
    let color: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(color.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: symbol)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.cardSoft)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ExerciseCard: View {
    let exercise: ExerciseItem
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle().fill(exercise.tint.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: exercise.symbol)
                            .font(.system(size: 16))
                            .foregroundStyle(exercise.tint)
                    }
                    Spacer()
                    Text("\(exercise.durationMin) min")
                        .font(AppFonts.micro(10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(exercise.tint.opacity(0.15)))
                        .foregroundStyle(exercise.tint)
                }
                Text(exercise.title)
                    .font(AppFonts.headline(14))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(exercise.subtitle)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
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
