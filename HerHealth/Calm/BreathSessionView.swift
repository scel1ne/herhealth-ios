import SwiftUI

// MARK: - Breath Session (full screen guided)
struct BreathSessionView: View {
    let kind: ExerciseKind
    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .inhale
    @State private var cycleIndex: Int = 0
    @State private var scale: CGFloat = 0.7
    @State private var progress: Double = 0
    @State private var counter: Int = 0
    @State private var timer: Timer?
    @State private var paused: Bool = false

    enum Phase { case inhale, hold1, exhale, hold2 }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            Spacer()
            phaseCircle
            Spacer()
            controls
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.cardBackground))
            }
            Spacer()
            VStack(spacing: 2) {
                Text(kind.title)
                    .font(AppFonts.headline(15))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Cycle \(min(cycleIndex + 1, kind.cycles)) of \(kind.cycles)")
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var phaseCircle: some View {
        ZStack {
            // ring
            Circle()
                .fill(AppColors.primaryUltraSoft)
                .frame(width: 280, height: 280)
            // animated inner
            Circle()
                .fill(LinearGradient(
                    colors: [AppColors.primary.opacity(0.95), AppColors.accentPeach.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: 200 * scale, height: 200 * scale)
                .animation(.easeInOut(duration: phaseDuration(phase)), value: scale)
            VStack(spacing: 4) {
                Text(phaseLabel)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text("\(counter)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<kind.cycles, id: \.self) { i in
                    Capsule()
                        .fill(i < cycleIndex ? AppColors.primary : (i == cycleIndex ? AppColors.accentPeach : AppColors.primaryUltraSoft))
                        .frame(width: 24, height: 6)
                }
            }
            HStack(spacing: 16) {
                Button(action: { paused.toggle() }) {
                    Image(systemName: paused ? "play.fill" : "pause.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(AppColors.cardBackground))
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 0.6))
                }
                .buttonStyle(ScaleButtonStyle())
                Button(action: { stop(); start() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(AppColors.cardBackground))
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 0.6))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.bottom, 100)
    }

    // MARK: - Logic
    private var phaseLabel: String {
        switch phase {
        case .inhale: return "Breathe in"
        case .hold1: return "Hold"
        case .exhale: return "Breathe out"
        case .hold2: return "Hold"
        }
    }

    private func phaseDuration(_ p: Phase) -> TimeInterval {
        switch p {
        case .inhale: return Double(kind.inhale)
        case .hold1:  return Double(kind.hold1)
        case .exhale: return Double(kind.exhale)
        case .hold2:  return Double(kind.hold2)
        }
    }

    private func nextPhase(_ p: Phase) -> Phase {
        switch p {
        case .inhale: return kind.hold1 > 0 ? .hold1 : .exhale
        case .hold1:  return .exhale
        case .exhale: return kind.hold2 > 0 ? .hold2 : .inhale
        case .hold2:  return .inhale
        }
    }

    private func start() {
        runPhase(.inhale)
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func runPhase(_ p: Phase) {
        phase = p
        counter = counterForPhase(p)
        // animate scale
        switch p {
        case .inhale: scale = 1.0
        case .hold1, .hold2: scale = 1.0
        case .exhale: scale = 0.7
        }
        stop()
        if paused { return }
        // count-down timer
        var remaining = Int(phaseDuration(p))
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            remaining -= 1
            counter = max(0, remaining)
            if remaining <= 0 {
                t.invalidate()
                if phase == .exhale && kind.hold2 == 0 ||
                   phase == .hold1 && kind.hold1 == 0 ||
                   phase == .hold2 {
                    advanceCycle()
                }
                if phase == .exhale && kind.hold2 == 0 {
                    advanceCycle()
                }
                runPhase(nextPhase(p))
            }
        }
    }

    private func counterForPhase(_ p: Phase) -> Int {
        switch p {
        case .inhale: return kind.inhale
        case .hold1: return kind.hold1
        case .exhale: return kind.exhale
        case .hold2: return kind.hold2
        }
    }

    private func advanceCycle() {
        cycleIndex += 1
        if cycleIndex >= kind.cycles {
            cycleIndex = kind.cycles - 1
            stop()
        }
    }
}

// MARK: - Grounding 5-4-3-2-1
struct GroundingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Int = 0

    private let steps: [(String, String, String, String)] = [
        ("5", "things you can see", "eye.fill", "Look around slowly. Name 5 things you see."),
        ("4", "things you can touch", "hand.raised.fill", "Notice 4 textures around you. The chair, your sleeve, the air."),
        ("3", "things you can hear", "ear.fill", "Pause. Listen for 3 sounds — near and far."),
        ("2", "things you can smell", "nose.fill", "Breathe in. Name 2 scents, even subtle ones."),
        ("1", "thing you can taste", "drop.fill", "Notice one taste — even just the inside of your mouth.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(AppColors.cardBackground))
                }
                Spacer()
                Text("5-4-3-2-1 Grounding")
                    .font(AppFonts.headline(15))
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
            ZStack {
                Circle().fill(AppColors.accentGreen.opacity(0.18)).frame(width: 280, height: 280)
                Circle().fill(AppColors.accentGreen).frame(width: 220, height: 220)
                VStack(spacing: 4) {
                    Text(steps[step].0)
                        .font(.system(size: 96, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text(steps[step].1)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                }
            }
            .id(step)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)

            Text(steps[step].3)
                .font(AppFonts.caption(13))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 14)

            Spacer()
            HStack(spacing: 16) {
                if step > 0 {
                    SecondaryButton(title: "Back") {
                        withAnimation { step -= 1 }
                    }
                    .frame(maxWidth: 140)
                }
                if step < steps.count - 1 {
                    PrimaryButton("Next", systemImage: "arrow.right", action: {
                        withAnimation { step += 1 }
                    })
                } else {
                    PrimaryButton("Done", systemImage: "checkmark.seal.fill", action: { dismiss() })
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - Body Scan (gentle 6-step)
struct BodyScanSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Int = 0
    private let steps: [(String, String, String)] = [
        ("Crown", "Soften your forehead, your jaw, your eyes.", "brain.head.profile"),
        ("Throat", "Notice your throat. Let any words unspoken dissolve.", "wind"),
        ("Heart", "Place a hand on your chest. Feel it rise and fall.", "heart.fill"),
        ("Belly", "Soften your belly. Allow your breath to land there.", "circle.dotted"),
        ("Hands", "Open and close your fists. Notice the warmth.", "hand.raised.fill"),
        ("Feet", "Press your feet into the floor. You are here, supported.", "figure.walk")
    ]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(AppColors.cardBackground))
                }
                Spacer()
                Text("Body Scan")
                    .font(AppFonts.headline(15))
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
            ZStack {
                Circle().fill(AppColors.accentYellow.opacity(0.18)).frame(width: 280, height: 280)
                Circle().fill(LinearGradient(
                    colors: [AppColors.accentYellow, AppColors.accentPeach],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )).frame(width: 220, height: 220)
                VStack(spacing: 12) {
                    Image(systemName: steps[step].2)
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                    Text(steps[step].0)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }
            }
            .id(step)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)

            Text(steps[step].1)
                .font(AppFonts.caption(13))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 14)

            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? AppColors.accentYellow : AppColors.primaryUltraSoft)
                        .frame(width: 22, height: 5)
                }
            }
            .padding(.top, 16)

            Spacer()
            HStack(spacing: 16) {
                if step > 0 {
                    SecondaryButton(title: "Back") {
                        withAnimation { step -= 1 }
                    }
                    .frame(maxWidth: 140)
                }
                if step < steps.count - 1 {
                    PrimaryButton("Next", systemImage: "arrow.right", action: {
                        withAnimation { step += 1 }
                    })
                } else {
                    PrimaryButton("Done", systemImage: "checkmark.seal.fill", action: { dismiss() })
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
