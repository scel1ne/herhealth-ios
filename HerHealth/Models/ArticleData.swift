import SwiftUI

// MARK: - Learn Content (full articles)
struct Article: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let category: String
    let readMinutes: Int
    let intro: String
    let sections: [ArticleSection]
    let takeaways: [String]
    let tag: LearnTag
}

struct ArticleSection: Identifiable, Hashable {
    let id = UUID()
    let heading: String
    let body: String
    let bullets: [String]
}

enum LearnTag: String, CaseIterable, Identifiable {
    case basics, myths, emotions, body, screening, relationships
    var id: String { rawValue }
    var label: String {
        switch self {
        case .basics: return "Basics"
        case .myths: return "Myths"
        case .emotions: return "Emotions"
        case .body: return "Body"
        case .screening: return "Screening"
        case .relationships: return "Relationships"
        }
    }
    var symbol: String {
        switch self {
        case .basics: return "book.fill"
        case .myths: return "xmark.octagon.fill"
        case .emotions: return "heart.text.square.fill"
        case .body: return "figure.stand"
        case .screening: return "stethoscope"
        case .relationships: return "person.2.fill"
        }
    }
}

enum ArticleLibrary {
    static let all: [Article] = [
        Article(
            title: "3-Minute Breast Cancer Basics",
            subtitle: "What every woman should know, simply.",
            icon: "book.fill", tint: AppColors.primary,
            category: "FEATURED", readMinutes: 3,
            intro: "Breast cancer is the most common cancer in women worldwide. Knowing the basics helps you act with calm and clarity.",
            sections: [
                .init(heading: "What it is",
                      body: "Breast cancer happens when cells in the breast grow out of control. Most are detected early, and most are highly treatable.",
                      bullets: ["Lumps can be benign or malignant", "Early detection improves outcomes", "Treatment is highly personalized"]),
                .init(heading: "Common signs to watch for",
                      body: "Many breast changes are not cancer, but knowing what's normal for you is your first protection.",
                      bullets: ["A new lump or mass", "Change in breast size or shape", "Skin dimpling or redness", "Nipple changes or discharge"]),
                .init(heading: "What you can do today",
                      body: "Three small actions make a meaningful difference.",
                      bullets: ["Monthly self-awareness (not strict self-exam)", "Talk with family about history", "Schedule a clinical exam if unsure"])
            ],
            takeaways: ["Most lumps are not cancer.", "Knowing your normal matters most.", "Talk with a clinician when in doubt."],
            tag: .basics
        ),
        Article(
            title: "Common Myths",
            subtitle: "Separate fact from fiction.",
            icon: "xmark.octagon.fill", tint: AppColors.accentPeach,
            category: "GUIDE", readMinutes: 4,
            intro: "Misinformation fuels fear. Here are the myths we hear most — and what the science actually says.",
            sections: [
                .init(heading: "Myth: Lumps always mean cancer",
                      body: "Around 80% of breast lumps are not cancer. They can be cysts, fibroadenomas, or hormonal changes.",
                      bullets: []),
                .init(heading: "Myth: Only women get breast cancer",
                      body: "Men have breast tissue too, and can develop breast cancer — though less commonly.",
                      bullets: []),
                .init(heading: "Myth: A healthy lifestyle guarantees prevention",
                      body: "Healthy habits lower risk, but don't eliminate it. Genetics and environment also play roles.",
                      bullets: []),
                .init(heading: "Myth: Mammograms are unsafe",
                      body: "Modern mammograms use very low radiation. The benefit of early detection far outweighs the small risk.",
                      bullets: [])
            ],
            takeaways: ["Question what you read online.", "When in doubt, ask a clinician.", "Stay curious, not anxious."],
            tag: .myths
        ),
        Article(
            title: "What If I Feel a Lump?",
            subtitle: "What to know and what to do.",
            icon: "magnifyingglass.circle.fill", tint: AppColors.primary,
            category: "GUIDE", readMinutes: 3,
            intro: "Finding a lump is scary. Take a breath — then take these gentle, practical steps.",
            sections: [
                .init(heading: "First, breathe",
                      body: "Most lumps are not cancer. Even when they are, early-stage breast cancer has excellent outcomes.",
                      bullets: []),
                .init(heading: "Notice the details",
                      body: "When did you notice it? Does it move? Is it tender? Is it related to your cycle?",
                      bullets: ["Size and shape", "Mobility", "Skin changes", "Cycle timing"]),
                .init(heading: "Next steps",
                      body: "Schedule a clinical breast exam within 1–2 weeks. Bring notes. Bring a friend if it helps.",
                      bullets: ["Note any changes since your last self-check", "List all symptoms, no matter how small", "Prepare 2–3 questions to ask"])
            ],
            takeaways: ["Don't panic. Don't ignore. Get checked.", "Bring a list of questions.", "Lean on people you trust."],
            tag: .screening
        ),
        Article(
            title: "Coping with Fear of Recurrence",
            subtitle: "Worry is normal. It can be tamed.",
            icon: "heart.slash.fill", tint: AppColors.accentPurple,
            category: "EMOTIONS", readMinutes: 5,
            intro: "Fear of recurrence is one of the most common experiences after treatment. Naming it is the first step to living alongside it.",
            sections: [
                .init(heading: "Why it shows up",
                      body: "Your body has been through a lot. Your mind is trying to keep you safe. Both deserve care.",
                      bullets: []),
                .init(heading: "Name the feeling",
                      body: "Try labeling the emotion in a single word. 'Worried.' 'Tight.' 'Sad.' Naming reduces the feeling's grip.",
                      bullets: []),
                .init(heading: "Notice the thought",
                      body: "Watch the thought come and go, like a cloud. You don't have to believe everything you think.",
                      bullets: []),
                .init(heading: "Choose a kind action",
                      body: "What would a kind friend suggest right now? A walk? A breath? A message?",
                      bullets: ["3-minute breathing", "5-4-3-2-1 grounding", "A message to a trusted friend"])
            ],
            takeaways: ["Worry is normal. You are not broken.", "Name, notice, choose.", "Reach out — never isolate."],
            tag: .emotions
        ),
        Article(
            title: "Body Image & Self-Compassion",
            subtitle: "Be kind to yourself every day.",
            icon: "figure.stand", tint: AppColors.accentGreen,
            category: "WELLNESS", readMinutes: 4,
            intro: "Your body has carried you through so much. Practicing kindness toward it is medicine, too.",
            sections: [
                .init(heading: "Mirror work",
                      body: "Each morning, notice three things you appreciate about your body. Speak to it softly.",
                      bullets: []),
                .init(heading: "Move to nourish, not punish",
                      body: "Choose movement that feels like a gift — walking, stretching, dancing in your kitchen.",
                      bullets: []),
                .init(heading: "Dress for kindness",
                      body: "Wear fabrics and shapes that make you feel held, soft, and seen.",
                      bullets: []),
                .init(heading: "Speak as to a friend",
                      body: "If your self-talk is harsh, ask: 'Would I say this to a dear friend?' If not, soften it.",
                      bullets: [])
            ],
            takeaways: ["Your body deserves kindness.", "Movement is medicine.", "Talk to yourself like a friend."],
            tag: .body
        ),
        Article(
            title: "Talking with Loved Ones",
            subtitle: "How to ask for the support you need.",
            icon: "person.2.fill", tint: AppColors.accentYellow,
            category: "RELATIONSHIPS", readMinutes: 3,
            intro: "It can be hard to ask for help. Here are gentle ways to start the conversation.",
            sections: [
                .init(heading: "Be specific",
                      body: "Instead of 'I need support,' try 'I would love a check-in text on Tuesdays.'",
                      bullets: []),
                .init(heading: "Name your needs",
                      body: "Practical help, listening, distraction, or just company. Different friends offer different gifts.",
                      bullets: []),
                .init(heading: "Set kind boundaries",
                      body: "It's okay to say 'I need space today' or 'I'd love a quiet visit.' Your needs are valid.",
                      bullets: [])
            ],
            takeaways: ["Specific asks get specific help.", "Your needs are valid.", "Let people in, gently."],
            tag: .relationships
        ),
        Article(
            title: "Screening Ages & Guidelines",
            subtitle: "A simple map to clinical screening.",
            icon: "stethoscope", tint: AppColors.primary,
            category: "SCREENING", readMinutes: 3,
            intro: "Screening guidelines vary by country and personal risk. Here is a gentle starting point — always confirm with your clinician.",
            sections: [
                .init(heading: "Average risk",
                      body: "Many guidelines suggest starting mammograms around age 40–50, then every 1–2 years.",
                      bullets: []),
                .init(heading: "Higher risk",
                      body: "Family history or genetic factors may suggest earlier or more frequent screening. Your doctor can guide you.",
                      bullets: []),
                .init(heading: "Self-awareness",
                      body: "Whatever your age, knowing your body's normal is a daily practice — not a strict exam.",
                      bullets: [])
            ],
            takeaways: ["Talk with your doctor about your own risk.", "Self-awareness complements clinical screening.", "Earlier is usually better."],
            tag: .screening
        )
    ]

    static func article(for route: HomeRoute) -> Article? {
        switch route {
        case .mythDetail: return all.first(where: { $0.tag == .myths })
        case .lumpDetail: return all.first(where: { $0.tag == .screening && $0.title.contains("Lump") })
        case .recurrenceDetail: return all.first(where: { $0.title.contains("Recurrence") })
        case .bodyImageDetail: return all.first(where: { $0.title.contains("Body Image") })
        default: return nil
        }
    }
}
