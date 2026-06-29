import SwiftUI

// MARK: - Brand Colors
enum AppColors {
    // Primary brand
    static let primary = Color(red: 0.96, green: 0.55, blue: 0.55)        // soft coral red
    static let primaryDeep = Color(red: 0.90, green: 0.40, blue: 0.45)     // deeper coral
    static let primarySoft = Color(red: 1.00, green: 0.86, blue: 0.86)     // soft pink
    static let primaryUltraSoft = Color(red: 1.00, green: 0.94, blue: 0.94) // very soft pink

    // Backgrounds
    static let background = Color(red: 1.00, green: 0.96, blue: 0.96)      // page background
    static let cardBackground = Color.white
    static let cardSoft = Color(red: 1.00, green: 0.97, blue: 0.97)

    // Text
    static let textPrimary = Color(red: 0.20, green: 0.13, blue: 0.20)
    static let textSecondary = Color(red: 0.45, green: 0.36, blue: 0.40)
    static let textTertiary = Color(red: 0.65, green: 0.55, blue: 0.58)
    static let textOnPrimary = Color.white

    // Accents
    static let accentGreen = Color(red: 0.55, green: 0.78, blue: 0.65)
    static let accentPurple = Color(red: 0.72, green: 0.62, blue: 0.85)
    static let accentPeach = Color(red: 1.00, green: 0.78, blue: 0.70)
    static let accentYellow = Color(red: 1.00, green: 0.86, blue: 0.55)

    // Dividers / borders
    static let divider = Color(red: 1.00, green: 0.92, blue: 0.92)
    static let border = Color(red: 0.98, green: 0.88, blue: 0.88)

    // Semantic
    static let success = Color(red: 0.40, green: 0.78, blue: 0.55)
    static let warning = Color(red: 1.00, green: 0.72, blue: 0.45)
    static let danger = Color(red: 0.95, green: 0.45, blue: 0.45)
}

// MARK: - Typography
enum AppFonts {
    // Use system font with custom tracking to feel like a designed editorial app
    static func display(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    static func displaySemi(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    static func title(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold)
    }
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular)
    }
    static func bodyMedium(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular)
    }
    static func micro(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .medium)
    }
    static func tabLabel() -> Font {
        .system(size: 10, weight: .medium)
    }
}

// MARK: - Reusable Gradients
enum AppGradients {
    static let heroBackground = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.95, blue: 0.95),
            Color(red: 1.00, green: 0.88, blue: 0.90)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let primaryButton = LinearGradient(
        colors: [Color(red: 1.00, green: 0.62, blue: 0.62), Color(red: 0.95, green: 0.50, blue: 0.55)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let softPink = LinearGradient(
        colors: [Color(red: 1.00, green: 0.94, blue: 0.94), Color(red: 1.00, green: 0.88, blue: 0.90)],
        startPoint: .top,
        endPoint: .bottom
    )
    static let breathingRing = RadialGradient(
        colors: [
            Color(red: 1.00, green: 0.78, blue: 0.78),
            Color(red: 1.00, green: 0.62, blue: 0.65)
        ],
        center: .center,
        startRadius: 5,
        endRadius: 90
    )
}

// MARK: - Common shapes & sizes
enum AppMetrics {
    static let cornerLarge: CGFloat = 24
    static let cornerMedium: CGFloat = 18
    static let cornerSmall: CGFloat = 12
    static let cardPadding: CGFloat = 18
    static let pagePadding: CGFloat = 20
    static let cardShadow: CGFloat = 8
}
