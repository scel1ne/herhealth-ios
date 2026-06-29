import SwiftUI

// MARK: - Reusable illustration glyphs drawn with SF Symbols + brand-tinted chips
struct IllustrationChip<Symbol: View>: View {
    let tint: Color
    let symbol: () -> Symbol
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tint.opacity(0.18))
            symbol()
                .font(.system(size: size * 0.45, weight: .regular))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Logo
struct HerHealthLogo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("H")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(AppColors.primary)
                Text("er")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                Text("H")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(AppColors.primary)
                Text("ealth")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .tracking(-0.5)
            Text("Mind over Cancer")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.leading, 2)
        }
    }
}

// MARK: - Person illustration (decorative)
struct PersonIllustration: View {
    var size: CGFloat = 180
    var body: some View {
        ZStack {
            // soft halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColors.primarySoft.opacity(0.7), AppColors.primarySoft.opacity(0)],
                        center: .center, startRadius: 10, endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
            // leaves / branches
            BranchShape()
                .stroke(AppColors.accentPeach, lineWidth: 1.5)
                .frame(width: size, height: size)
                .opacity(0.85)
            // person (using system symbols combined)
            VStack(spacing: 0) {
                Circle()
                    .fill(AppColors.primarySoft)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .overlay(
                        Text("😊")
                            .font(.system(size: size * 0.12))
                    )
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.primary.opacity(0.85))
                    .frame(width: size * 0.42, height: size * 0.38)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.white.opacity(0.9))
                            .font(.system(size: size * 0.12))
                    )
            }
            .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
    }
}

struct BranchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // left branch
        p.move(to: CGPoint(x: rect.width * 0.10, y: rect.height * 0.85))
        p.addQuadCurve(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.35),
                       control: CGPoint(x: rect.width * 0.05, y: rect.height * 0.55))
        // right branch
        p.move(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.15))
        p.addQuadCurve(to: CGPoint(x: rect.width * 0.65, y: rect.height * 0.55),
                       control: CGPoint(x: rect.width * 0.95, y: rect.height * 0.40))
        return p
    }
}
