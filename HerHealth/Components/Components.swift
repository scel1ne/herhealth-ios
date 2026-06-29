import SwiftUI

// MARK: - Card container
struct SoftCard<Content: View>: View {
    var padding: CGFloat = AppMetrics.cardPadding
    var corner: CGFloat = AppMetrics.cornerMedium
    var fill: Color = AppColors.cardBackground
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(AppColors.border.opacity(0.6), lineWidth: 0.6)
            )
            .shadow(color: AppColors.primaryDeep.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Primary button
struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    var fill: LinearGradient = AppGradients.primaryButton
    var action: () -> Void

    init(_ title: String, systemImage: String? = nil, fill: LinearGradient = AppGradients.primaryButton, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.fill = fill
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let s = systemImage {
                    Image(systemName: s)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(AppFonts.headline(15))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(fill)
            )
            .shadow(color: AppColors.primaryDeep.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Secondary / outlined button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.headline(15))
                .foregroundStyle(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppColors.primary, lineWidth: 1.4)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Section header
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFonts.title(18))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            if let t = trailing {
                Text(t)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.primary)
            }
        }
    }
}

// MARK: - Bell icon button
struct IconRoundButton: View {
    let systemImage: String
    var badge: Bool = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColors.cardBackground)
                    .frame(width: 38, height: 38)
                    .shadow(color: AppColors.primaryDeep.opacity(0.08), radius: 6, x: 0, y: 2)
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                if badge {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 8, height: 8)
                        .offset(x: 11, y: -11)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Toggle card row
struct ReminderRow: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.headline(15))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(AppColors.primary)
                .labelsHidden()
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
}

// MARK: - Tab Bar
struct AppTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selection == tab ? .semibold : .regular))
                        Text(tab.title)
                            .font(AppFonts.tabLabel())
                    }
                    .foregroundStyle(selection == tab ? AppColors.primary : AppColors.textTertiary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 22)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 0.5)
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home, learn, calm, chat, me
    var id: String { rawValue }
    var title: String {
        switch self {
        case .home: return "Home"
        case .learn: return "Learn"
        case .calm: return "Calm"
        case .chat: return "Chat"
        case .me: return "Me"
        }
    }
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .calm: return "leaf.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .me: return "person.fill"
        }
    }
}

// MARK: - App Root (5-tab shell with custom TabBar)
struct AppRootView: View {
    @State private var selectedTab: AppTab = AppRootView.initialTab

    static var initialTab: AppTab {
        if let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--tab=") }) {
            let name = String(arg.dropFirst("--tab=".count))
            return AppTab(rawValue: name) ?? .home
        }
        return .home
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()
            Group {
                switch selectedTab {
                case .home:
                    HomeView { tab in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selectedTab = tab
                        }
                    }
                case .learn: LearnView()
                case .calm:  CalmView()
                case .chat:  ChatView()
                case .me:    MeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
            AppTabBar(selection: $selectedTab)
        }
        .preferredColorScheme(.light)
    }
}
