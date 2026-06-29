import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        .init(role: .user, text: "I found a lump and I'm scared.", timestamp: "9:41 AM"),
        .init(role: .assistant, text: "It's understandable to feel scared. Many breast lumps are not cancer. Let's take this one step at a time.", timestamp: "9:41 AM"),
        .init(role: .assistant, text: "Would you like grounding, facts, or help preparing questions for a clinician?", timestamp: "9:41 AM")
    ]
    @State private var input: String = ""

    private let quickReplies = [
        ("I feel anxious", "exclamationmark.bubble.fill", AppColors.accentPeach),
        ("Help me breathe", "lungs.fill", AppColors.accentGreen),
        ("Tell me facts", "lightbulb.fill", AppColors.accentYellow),
        ("Talk to a professional", "stethoscope", AppColors.accentPurple)
    ]

    private let quickActions: [(String, String, Color)] = [
        ("60-sec\ngrounding", "leaf.fill", AppColors.primary),
        ("Questions\nfor my doctor", "list.bullet.clipboard.fill", AppColors.accentPeach),
        ("When to seek\nurgent care", "cross.case.fill", AppColors.primary)
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, AppMetrics.pagePadding)
                    .padding(.top, 8)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            quickReplyStrip
            quickActionGrid
            inputBar
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Companion")
                    .font(AppFonts.display(26))
                    .foregroundStyle(AppColors.textPrimary)
                Text("24/7 supportive guidance")
                    .font(AppFonts.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            ZStack {
                Circle().fill(AppColors.primaryUltraSoft)
                    .frame(width: 64, height: 64)
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 32))
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.horizontal, AppMetrics.pagePadding)
        .padding(.top, 8)
    }

    private var quickReplyStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickReplies, id: \.0) { item in
                    Button {
                        send(text: item.0)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.1)
                                .font(.system(size: 11, weight: .semibold))
                            Text(item.0)
                                .font(AppFonts.caption(12))
                        }
                        .foregroundStyle(item.2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(item.2.opacity(0.15)))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, AppMetrics.pagePadding)
        }
        .padding(.top, 10)
    }

    private var quickActionGrid: some View {
        HStack(spacing: 10) {
            ForEach(quickActions, id: \.0) { a in
                Button { send(text: a.0.replacingOccurrences(of: "\n", with: " ")) } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(a.2.opacity(0.18))
                                .frame(width: 32, height: 32)
                            Image(systemName: a.1)
                                .font(.system(size: 14))
                                .foregroundStyle(a.2)
                        }
                        Text(a.0)
                            .font(AppFonts.caption(12))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, AppMetrics.pagePadding)
        .padding(.top, 12)
    }

    private var inputBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                HStack {
                    TextField("Type your message", text: $input)
                        .font(AppFonts.body(14))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "face.smiling")
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(AppColors.cardBackground)
                )
                .overlay(
                    Capsule().stroke(AppColors.border, lineWidth: 0.6)
                )
                Button {
                    send(text: input)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(AppGradients.primaryButton))
                }
                .buttonStyle(ScaleButtonStyle())
                .opacity(input.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, AppMetrics.pagePadding)
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                Text("If you are in crisis or have urgent symptoms, contact a healthcare professional.")
                    .font(AppFonts.micro(10))
            }
            .foregroundStyle(AppColors.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppMetrics.pagePadding)
        }
        .padding(.top, 10)
        .padding(.bottom, 110)
        .background(
            LinearGradient(colors: [AppColors.background.opacity(0), AppColors.background], startPoint: .top, endPoint: .bottom)
        )
    }

    private func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(.init(role: .user, text: trimmed, timestamp: "9:42 AM"))
        input = ""
        let reply = cannedReply(for: trimmed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            messages.append(.init(role: .assistant, text: reply, timestamp: "9:42 AM"))
        }
    }

    private func cannedReply(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("anxious") || lower.contains("scared") || lower.contains("afraid") {
            return "Try a slow 4-4-6 breath with me. Inhale 4, hold 4, exhale 6. You're safe here."
        } else if lower.contains("breathe") || lower.contains("breath") {
            return "Let's begin. Inhale… 2, 3, 4. Hold… 2, 3, 4. Exhale… 2, 3, 4, 5, 6. Beautiful."
        } else if lower.contains("fact") || lower.contains("tell me") {
            return "Around 80% of breast lumps are non-cancerous. Still, any new lump deserves a clinical check. You're doing the right thing by asking."
        } else if lower.contains("doctor") || lower.contains("professional") {
            return "Great idea. I can help you prepare 3 questions for your visit. Would you like a template?"
        } else if lower.contains("grounding") {
            return "Notice 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. Take your time."
        } else if lower.contains("urgent") {
            return "Seek urgent care if you have: a rapidly growing lump, skin changes, nipple discharge (especially bloody), or new inversion. Trust your instincts."
        } else {
            return "I hear you. Would you like to talk more, or shall we try a gentle grounding exercise together?"
        }
    }
}

// MARK: - Message bubble
struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .top) {
            if message.role == .user { Spacer(minLength: 40) }
            if message.role == .assistant {
                ZStack {
                    Circle().fill(AppColors.primaryUltraSoft)
                        .frame(width: 30, height: 30)
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                }
            }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(AppFonts.body(14))
                    .foregroundStyle(message.role == .user ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(message.role == .user ? AppColors.primary : AppColors.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(message.role == .user ? Color.clear : AppColors.border.opacity(0.6), lineWidth: 0.6)
                    )
                Text(message.timestamp)
                    .font(AppFonts.micro(10))
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.horizontal, 6)
            }
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
