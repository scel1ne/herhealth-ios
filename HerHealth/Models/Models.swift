import Foundation
import SwiftUI

// MARK: - Home feature item
struct HomeFeature: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let route: HomeRoute
}

enum HomeRoute: Hashable {
    case riskQuiz
    case aiCompanion
    case education
    case anxietyRelief
    case calmGround
    case learning
    case mythDetail
    case lumpDetail
    case recurrenceDetail
    case bodyImageDetail
    case breathingDetail
    case namingDetail
    case noticeDetail
    case actionDetail
}

// MARK: - Quiz
struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let title: String
    let helper: String?
    let options: [QuizOption]
    let affirmation: String
}

struct QuizOption: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let label: String
    let value: Int
}

// MARK: - Learn
struct LearnCard: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    let route: HomeRoute
    let readTime: Int
    let body: String
    let bullets: [String]
    let tag: String
}

struct LearnInsight: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let unit: String
    let label: String
    let symbol: String
}

// MARK: - Chat
struct ChatMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
    let timestamp: String
}

// MARK: - Mood / Journey
struct DayProgress: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let isCompleted: Bool
}

struct PlanStep: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let title: String
    let isDone: Bool
    let isCurrent: Bool
}

enum WeeklyMood: Int, CaseIterable, Identifiable {
    case anxious, low, neutral, calm, hopeful
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .anxious: return "Anxious"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .calm: return "Calm"
        case .hopeful: return "Hopeful"
        }
    }
    var symbol: String {
        switch self {
        case .anxious: return "cloud.bolt.rain.fill"
        case .low: return "cloud.rain.fill"
        case .neutral: return "cloud.fill"
        case .calm: return "cloud.sun.fill"
        case .hopeful: return "sun.max.fill"
        }
    }
    var color: Color {
        switch self {
        case .anxious: return Color(red: 0.55, green: 0.62, blue: 0.78)
        case .low: return Color(red: 0.55, green: 0.68, blue: 0.80)
        case .neutral: return Color(red: 0.72, green: 0.72, blue: 0.78)
        case .calm: return Color(red: 0.85, green: 0.78, blue: 0.62)
        case .hopeful: return Color(red: 1.00, green: 0.78, blue: 0.60)
        }
    }
}

// MARK: - Journal entries
struct JournalEntry: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let mood: WeeklyMood
    let note: String
    let tags: [String]
}

enum JournalStore {
    static let seed: [JournalEntry] = [
        .init(date: Calendar.current.date(byAdding: .day, value: -0, to: Date())!,
              mood: .hopeful, note: "Felt lighter after my 3-minute breathing practice this morning.", tags: ["breathing", "morning"]),
        .init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
              mood: .calm, note: "Read the myth-busting article. It really eased my mind.", tags: ["learning", "myths"]),
        .init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
              mood: .anxious, note: "A bit of scanxiety today. Used the 5-4-3-2-1 grounding.", tags: ["scanxiety", "grounding"]),
        .init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
              mood: .neutral, note: "Quiet day. Took a slow walk after dinner.", tags: ["walk"]),
        .init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
              mood: .hopeful, note: "Talked with a friend who really listened.", tags: ["support"]),
        .init(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
              mood: .low, note: "Tired. Reminded myself that rest is also care.", tags: ["rest"])
    ]
}

// MARK: - Body Check
struct BodyCheckEntry: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let side: Side
    let finding: Finding
    let note: String

    enum Side: String, CaseIterable, Identifiable {
        case left = "Left", right = "Right", both = "Both", none = "Nothing noted"
        var id: String { rawValue }
    }
    enum Finding: String, CaseIterable, Identifiable {
        case lump = "Lump"
        case tenderness = "Tenderness"
        case skinChange = "Skin change"
        case nippleChange = "Nipple change"
        case noChange = "No change"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .lump: return "circle.dotted.circle"
            case .tenderness: return "hand.point.up.left.fill"
            case .skinChange: return "rectangle.dashed"
            case .nippleChange: return "drop.fill"
            case .noChange: return "checkmark.circle.fill"
            }
        }
    }
}

enum BodyCheckStore {
    static let seed: [BodyCheckEntry] = [
        .init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
              side: .none, finding: .noChange, note: "Monthly self-check complete. No new changes."),
        .init(date: Calendar.current.date(byAdding: .day, value: -33, to: Date())!,
              side: .left, finding: .tenderness, note: "Mild tenderness, likely cycle-related."),
        .init(date: Calendar.current.date(byAdding: .day, value: -63, to: Date())!,
              side: .none, finding: .noChange, note: "All clear. Keeping monthly habit.")
    ]
}

// MARK: - Saved Library
struct SavedItem: Identifiable, Hashable {
    enum Kind: String { case article, exercise, journal }
    let id = UUID()
    let kind: Kind
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let savedAt: Date
}

enum SavedStore {
    static let seed: [SavedItem] = [
        .init(kind: .article, title: "Coping with Fear of Recurrence",
              subtitle: "5 practices from MBCT therapists", symbol: "heart.slash.fill",
              tint: AppColors.accentPurple, savedAt: Date()),
        .init(kind: .exercise, title: "3-Minute Breathing",
              subtitle: "4-4-6 rhythm", symbol: "lungs.fill",
              tint: AppColors.primary, savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        .init(kind: .article, title: "Common Myths",
              subtitle: "Separate fact from fiction", symbol: "xmark.octagon.fill",
              tint: AppColors.accentPeach, savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        .init(kind: .exercise, title: "5-4-3-2-1 Grounding",
              subtitle: "Use your senses to return", symbol: "leaf.fill",
              tint: AppColors.accentGreen, savedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!)
    ]
}

// MARK: - Exercise / Calm content
struct ExerciseItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let durationMin: Int
    let kind: ExerciseKind
}

enum ExerciseKind: String, CaseIterable, Identifiable {
    case breath448 = "4-4-6"
    case breath478 = "4-7-8"
    case box = "Box"
    case grounding = "5-4-3-2-1"
    case bodyScan = "Body Scan"
    case lovingKindness = "Loving-Kindness"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .breath448: return "4-4-6 Breath"
        case .breath478: return "4-7-8 Breath"
        case .box: return "Box Breathing"
        case .grounding: return "5-4-3-2-1 Grounding"
        case .bodyScan: return "Body Scan"
        case .lovingKindness: return "Loving-Kindness"
        }
    }
    var subtitle: String {
        switch self {
        case .breath448: return "Inhale 4 · Hold 4 · Exhale 6"
        case .breath478: return "Inhale 4 · Hold 7 · Exhale 8"
        case .box: return "Inhale 4 · Hold 4 · Exhale 4 · Hold 4"
        case .grounding: return "5 sight · 4 touch · 3 sound · 2 smell · 1 taste"
        case .bodyScan: return "A gentle tour of your body"
        case .lovingKindness: return "Soft words toward yourself"
        }
    }
    var symbol: String {
        switch self {
        case .breath448, .breath478, .box: return "lungs.fill"
        case .grounding: return "leaf.fill"
        case .bodyScan: return "figure.stand"
        case .lovingKindness: return "heart.fill"
        }
    }
    var tint: Color {
        switch self {
        case .breath448: return AppColors.primary
        case .breath478: return AppColors.accentPurple
        case .box: return AppColors.accentGreen
        case .grounding: return AppColors.accentPeach
        case .bodyScan: return AppColors.accentYellow
        case .lovingKindness: return AppColors.primaryDeep
        }
    }
    var inhale: Int { 4 }
    var hold1: Int {
        switch self {
        case .breath448: return 4
        case .breath478: return 7
        case .box: return 4
        default: return 0
        }
    }
    var exhale: Int {
        switch self {
        case .breath448: return 6
        case .breath478: return 8
        case .box: return 4
        default: return 0
        }
    }
    var hold2: Int {
        switch self {
        case .box: return 4
        default: return 0
        }
    }
    var cycles: Int {
        switch self {
        case .breath448, .breath478, .box: return 3
        default: return 1
        }
    }
}
