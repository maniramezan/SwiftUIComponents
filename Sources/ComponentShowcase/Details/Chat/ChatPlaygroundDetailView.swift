import Components
import DesignSystem
import SwiftUI

/// One consolidated, full-page showcase for every chat-related component —
/// ``ChatBubble``/``ChatBubbleView``, ``StructuredChatBubbleView``,
/// ``TypingIndicatorBubbleView``/``TypingDotsView``,
/// ``AssistantQuickActionChipRow``, ``AssistantContextCard``, the assistant
/// notice banners, ``AssistantConversationList``, and ``TypewriterReveal`` —
/// behind a single real chat screen instead of a separate sidebar entry (and
/// static reference card) per component.
///
/// Playground configuration lives behind the nav bar's settings button, and
/// the turn-based conversation log — a different data model than the
/// playground's free-form composer — behind its own nav bar button, so the
/// main screen itself reads as a real, full-page chat experience rather than
/// a form.
struct ChatPlaygroundDetailView: View {
    var body: some View {
        ChatPlayground()
    }
}

#Preview {
    NavigationStack {
        ChatPlaygroundDetailView()
    }
}

// MARK: - Settings-driven permutations

/// What the composer shows at the bottom of the screen.
private enum ComposerMode: String, CaseIterable, Identifiable {
    case none = "None"
    case textField = "Text field"
    case quickActions = "Quick actions"
    case both = "Both"
    var id: String { rawValue }

    var showsTextField: Bool { self == .textField || self == .both }
    var showsQuickActions: Bool { self == .quickActions || self == .both }
}

/// Which ``AssistantContextCard`` variant, if any, sits above the scrollback.
private enum ContextCardMode: String, CaseIterable, Identifiable {
    case none = "None"
    case quoted = "Quoted body"
    case plain = "Plain body"
    case titleOnly = "Title only"
    var id: String { rawValue }
}

/// Which assistant notice banner, if any, sits above the scrollback.
private enum NoticeKind: String, CaseIterable, Identifiable {
    case none = "None"
    case status = "Status banner"
    case unavailableWithSettings = "Unavailable — with settings"
    case unavailable = "Unavailable — no settings"
    case upgrade = "Upgrade notice"
    case limit = "Limit prompt"
    case disclaimer = "Disclaimer footer"
    var id: String { rawValue }
}

/// Which typing-indicator primitive renders while a reply is pending.
private enum TypingIndicatorStyle: String, CaseIterable, Identifiable {
    case chatBubble = "Chat bubble"
    case indicatorBubble = "Indicator bubble"
    case dotsOnly = "Dots only"
    var id: String { rawValue }
}

/// The shape of the simulated assistant reply, which selects between
/// ``ChatBubbleView`` and ``StructuredChatBubbleView``'s two parsing paths.
private enum ResponseStyle: String, CaseIterable, Identifiable {
    /// A one-line reply rendered as plain markdown by ``ChatBubbleView``.
    case plain = "Plain"
    /// A `## `-headed reply rendered as titled sections.
    case structured = "Structured"
    /// Bare leading labels promoted into headings via `autoPromotingHeadings`.
    case bareLabels = "Bare labels"
    var id: String { rawValue }

    var isStructured: Bool { self != .plain }
}

/// The `contentLayoutDirection` passed to every bubble — the direction the
/// *message text* is laid out in, independent of the interface's own
/// direction. See ``ChatBubble``.
private enum ContentDirectionMode: String, CaseIterable, Identifiable {
    case inherit = "Inherit"
    case leftToRight = "Left-to-right"
    case rightToLeft = "Right-to-left"
    var id: String { rawValue }

    var layoutDirection: LayoutDirection? {
        switch self {
        case .inherit: nil
        case .leftToRight: .leftToRight
        case .rightToLeft: .rightToLeft
        }
    }
}

/// A quick action defined by the person driving the showcase.
///
/// ``AssistantQuickActionChipRow`` is generic over the caller's own action
/// model, so the showcase owns a mutable list — titles, icons, and per-action
/// states are all editable from the settings sheet — rather than hard-coding
/// a fixed action set.
private struct DemoAction: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var systemImage: String
    var state: AssistantQuickActionState = .available
}

/// The SF Symbols offered for a quick action, kept domain-neutral so the
/// showcase demonstrates the component rather than any particular product's
/// action set.
private let demoActionSymbols = ["sparkles", "bolt", "star", "tag", "flag", "bookmark", "square.and.arrow.up"]

/// One message in the playground's scrollback.
private struct ChatPlaygroundMessage: Identifiable, Equatable {
    /// What the bubble renders, which selects the bubble primitive used.
    enum Content: Equatable {
        /// Message text, rendered by ``ChatBubbleView`` or
        /// ``StructuredChatBubbleView``.
        case text(String)
        /// A reply in flight, rendered by the configured typing indicator.
        case typing
        /// A non-text body built with ``ChatBubble`` directly.
        case custom
    }

    let id: UUID
    let role: ChatMessageRole
    var content: Content

    init(id: UUID = UUID(), role: ChatMessageRole, content: Content) {
        self.id = id
        self.role = role
        self.content = content
    }
}

/// A simulated reply in flight: the placeholder message id showing the
/// typing indicator, and how long to wait before replacing it with text.
///
/// `.task(id:)`-driven (see ``ChatPlayground/body``) rather than a bare
/// `Task`, so a new send cancels any still-pending reply instead of racing
/// it.
private struct PendingReply: Equatable {
    let messageID: UUID
    let delaySeconds: Double
}

// MARK: - Playground

/// The full-page interactive chat surface: an optional notice banner and
/// context card, the scrollback (filling all remaining vertical space),
/// then a composer shaped by `composerMode` pinned to the bottom.
private struct ChatPlayground: View {
    private static let sampleResponses = [
        "Sure — here's what I found.",
        "Good question. Let me break that down.",
        "Here's a quick summary for you.",
        "That makes sense — here's my take.",
        "I looked into that. Here's the answer.",
    ]

    private static let structuredResponse = """
        ## Summary
        A short overview of the item you asked about.

        ## Details
        - The first supporting point.
        - The second supporting point.
        """

    private static let bareLabelResponse =
        "Summary A short overview of the item you asked about. Details The first supporting point."

    private static let initialMessages = [
        ChatPlaygroundMessage(
            role: .assistant,
            content: .text(
                "Ask me anything — tap the settings icon in the nav bar to change how this screen behaves."
            )
        )
    ]

    @State private var messages = ChatPlayground.initialMessages
    @State private var draftText = ""
    @State private var composerRole: ChatMessageRole = .user
    @State private var composerMode: ComposerMode = .both
    @State private var contextCardMode: ContextCardMode = .quoted
    @State private var noticeKind: NoticeKind = .none
    @State private var contentDirectionMode: ContentDirectionMode = .inherit
    @State private var isInterfaceMirrored = false
    @State private var responseStyle: ResponseStyle = .plain
    @State private var isAutoReplyEnabled = true
    @State private var responseDelaySeconds: Double = 1.5
    @State private var typingIndicatorStyle: TypingIndicatorStyle = .chatBubble
    @State private var isQuickActionInteractionEnabled = true
    @State private var showsQuickActionIcons = true
    @State private var quickActions = ChatPlayground.initialQuickActions
    @State private var pendingReply: PendingReply?
    @State private var isShowingSettings = false
    @State private var isShowingConversationLog = false
    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var ambientLayoutDirection

    /// Four neutrally-named actions, all selectable. Per-action states are
    /// set explicitly from the settings sheet rather than seeded here, so
    /// nothing starts out in a state the reviewer didn't ask for.
    private static var initialQuickActions: [DemoAction] {
        [
            DemoAction(title: "Action 1", systemImage: "sparkles"),
            DemoAction(title: "Action 2", systemImage: "bolt"),
            DemoAction(title: "Action 3", systemImage: "star"),
            DemoAction(title: "Action 4", systemImage: "tag"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            ChatPlaygroundNoticeBanner(kind: noticeKind)

            ChatPlaygroundContextCard(mode: contextCardMode)

            ChatPlaygroundScrollback(
                messages: messages,
                responseStyle: responseStyle,
                typingIndicatorStyle: typingIndicatorStyle,
                contentLayoutDirection: contentDirectionMode.layoutDirection
            )
            .frame(maxHeight: .infinity)

            if composerMode.showsQuickActions {
                AssistantQuickActionChipRow<DemoAction>(
                    actions: quickActions,
                    isInteractionEnabled: isQuickActionInteractionEnabled,
                    state: { $0.state },
                    label: { $0.title },
                    systemImage: { showsQuickActionIcons ? $0.systemImage : nil },
                    onSelect: { action in
                        if let index = quickActions.firstIndex(where: { $0.id == action.id }) {
                            quickActions[index].state = .used
                        }
                        sendMessage(role: .user, text: action.title)
                    }
                )
                .padding(.horizontal, theme.spacing.oneUnit)
            }

            if composerMode.showsTextField {
                ChatPlaygroundComposer(draftText: $draftText, onSend: sendDraft)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Mirrors the whole surface the way a right-to-left *localization*
        // would, so a reviewer can see that role alignment flips with the
        // interface while `contentLayoutDirection` (below, per bubble) does
        // not.
        .environment(\.layoutDirection, isInterfaceMirrored ? .rightToLeft : ambientLayoutDirection)
        .task(id: pendingReply) {
            await resolvePendingReply()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingConversationLog = true
                } label: {
                    Label("Conversation log", systemImage: "list.bullet.rectangle")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingSettings = true
                } label: {
                    Label("Chat settings", systemImage: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            ChatPlaygroundSettingsSheet(
                composerRole: $composerRole,
                composerMode: $composerMode,
                contextCardMode: $contextCardMode,
                noticeKind: $noticeKind,
                contentDirectionMode: $contentDirectionMode,
                isInterfaceMirrored: $isInterfaceMirrored,
                responseStyle: $responseStyle,
                isAutoReplyEnabled: $isAutoReplyEnabled,
                responseDelaySeconds: $responseDelaySeconds,
                typingIndicatorStyle: $typingIndicatorStyle,
                quickActions: $quickActions,
                isQuickActionInteractionEnabled: $isQuickActionInteractionEnabled,
                showsQuickActionIcons: $showsQuickActionIcons,
                onRenewQuickActions: renewQuickActions,
                onAppendCustomBubble: { messages.append(ChatPlaygroundMessage(role: .assistant, content: .custom)) },
                onResetConversation: resetConversation,
                onDone: { isShowingSettings = false }
            )
        }
        .sheet(isPresented: $isShowingConversationLog) {
            ConversationLogSheet(
                contentLayoutDirection: contentDirectionMode.layoutDirection,
                onDone: { isShowingConversationLog = false }
            )
        }
    }

    private func sendDraft() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        draftText = ""
        sendMessage(role: composerRole, text: trimmed)
    }

    private func sendMessage(role: ChatMessageRole, text: String) {
        // Sending again supersedes any reply still in flight: drop its
        // placeholder before appending, or the cancelled `.task(id:)` would
        // leave a typing bubble stuck in the scrollback forever.
        cancelPendingReply()
        messages.append(ChatPlaygroundMessage(role: role, content: .text(text)))

        guard isAutoReplyEnabled, role == .user else { return }
        let typingMessageID = UUID()
        messages.append(ChatPlaygroundMessage(id: typingMessageID, role: .assistant, content: .typing))
        pendingReply = PendingReply(messageID: typingMessageID, delaySeconds: responseDelaySeconds)
    }

    private func cancelPendingReply() {
        guard let inFlight = pendingReply else { return }
        messages.removeAll { $0.id == inFlight.messageID }
        pendingReply = nil
    }

    /// Returns every action to `.available` without discarding the titles
    /// and icons the reviewer configured.
    private func renewQuickActions() {
        for index in quickActions.indices {
            quickActions[index].state = .available
        }
    }

    /// Resets the whole surface: the scrollback, any reply in flight, the
    /// draft, and the quick actions tapping has marked `.used` — otherwise a
    /// "reset" would leave the chips latched to the previous conversation.
    private func resetConversation() {
        pendingReply = nil
        messages = Self.initialMessages
        draftText = ""
        renewQuickActions()
    }

    private func resolvePendingReply() async {
        guard let pendingReply else { return }
        try? await Task.sleep(for: .seconds(pendingReply.delaySeconds))
        guard !Task.isCancelled, let index = messages.firstIndex(where: { $0.id == pendingReply.messageID }) else {
            return
        }
        messages[index].content = .text(responseText)
        self.pendingReply = nil
    }

    private var responseText: String {
        switch responseStyle {
        case .plain: Self.sampleResponses.randomElement() ?? "Got it."
        case .structured: Self.structuredResponse
        case .bareLabels: Self.bareLabelResponse
        }
    }
}

// MARK: - Above the scrollback

/// The assistant notice banner selected in settings, or nothing for `.none`.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff the banner independently of the chat surface around it.
private struct ChatPlaygroundNoticeBanner: View {
    let kind: NoticeKind

    var body: some View {
        switch kind {
        case .none:
            EmptyView()
        case .status:
            AssistantStatusBanner(message: "The assistant is temporarily unavailable.")
        case .unavailableWithSettings:
            AssistantUnavailableBanner(
                reason: "Turn on Apple Intelligence in Settings to use the assistant.",
                settingsAction: .init(title: "Open Settings", action: {})
            )
        case .unavailable:
            AssistantUnavailableBanner(reason: "This feature isn't supported on this device.")
        case .upgrade:
            AssistantUpgradeNotice(
                message: "Upgrade to Premium for unlimited assistant help.",
                upgradeTitle: "Upgrade to Premium",
                systemImage: "globe",
                onUpgrade: {}
            )
        case .limit:
            AssistantLimitPromptCard(
                message: "You've reached today's assistant limit.",
                supportingText: "Upgrade for unlimited help.",
                primaryActionTitle: "Upgrade",
                secondaryActionTitle: "Not now",
                onPrimaryAction: {},
                onSecondaryAction: {}
            )
        case .disclaimer:
            AssistantDisclaimerFooter(
                text: "AI responses can be inaccurate. Always double-check important information."
            )
        }
    }
}

/// The ``AssistantContextCard`` variant selected in settings, or nothing for
/// `.none`.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff the card independently of the chat surface around it.
private struct ChatPlaygroundContextCard: View {
    let mode: ContextCardMode

    var body: some View {
        switch mode {
        case .none:
            EmptyView()
        case .quoted:
            AssistantContextCard(
                title: "Example term",
                highlight: "Level 1",
                bodyText: "This is an example sentence the term appeared in.",
                bodyStyle: .quoted,
                footnote: "From: Reference source"
            )
        case .plain:
            AssistantContextCard(
                title: "Example pattern",
                highlight: "Level 2",
                bodyText: "SUBJECT + VERB + OBJECT",
                bodyStyle: .plain
            )
        case .titleOnly:
            AssistantContextCard(title: "Example term")
        }
    }
}

// MARK: - Scrollback

/// The scrolling message log for ``ChatPlayground``, auto-scrolling to the
/// newest message whenever the conversation changes — including the in-place
/// swap of a typing placeholder for its reply, which leaves the message
/// count untouched but can grow the content well past the visible area.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update the scrollback independently of the
/// composer around it.
private struct ChatPlaygroundScrollback: View {
    let messages: [ChatPlaygroundMessage]
    let responseStyle: ResponseStyle
    let typingIndicatorStyle: TypingIndicatorStyle
    let contentLayoutDirection: LayoutDirection?
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ForEach(messages) { message in
                        ChatPlaygroundBubble(
                            message: message,
                            responseStyle: responseStyle,
                            typingIndicatorStyle: typingIndicatorStyle,
                            contentLayoutDirection: contentLayoutDirection
                        )
                        .id(message.id)
                    }
                }
                .padding(theme.spacing.oneUnit)
            }
            .onChange(of: messages) {
                guard let lastID = messages.last?.id else { return }
                withAnimation(theme.motion.animation(reducingMotion: reduceMotion)) {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }
}

/// One message in the scrollback, rendered with the bubble primitive its
/// content and the current settings call for.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff each row independently as the conversation grows.
private struct ChatPlaygroundBubble: View {
    let message: ChatPlaygroundMessage
    let responseStyle: ResponseStyle
    let typingIndicatorStyle: TypingIndicatorStyle
    let contentLayoutDirection: LayoutDirection?
    @Environment(\.designTheme) private var theme

    var body: some View {
        switch message.content {
        case .typing:
            switch typingIndicatorStyle {
            case .chatBubble:
                ChatBubbleView(role: message.role, content: "", isTyping: true)
            case .indicatorBubble:
                TypingIndicatorBubbleView()
            case .dotsOnly:
                TypingDotsView()
            }
        case .custom:
            ChatBubble(role: message.role, contentLayoutDirection: contentLayoutDirection) {
                HStack(spacing: theme.spacing.oneUnit) {
                    Image(systemName: "map.fill")
                        .foregroundStyle(theme.colors.primary)
                    Text("Custom bubble content")
                        .designTextStyle(.body)
                }
            }
        case .text(let text) where responseStyle.isStructured && message.role == .assistant:
            StructuredChatBubbleView(
                role: message.role,
                content: text,
                autoPromotingHeadings: ["Summary", "Details"],
                contentLayoutDirection: contentLayoutDirection
            )
        case .text(let text):
            ChatBubbleView(
                role: message.role,
                content: text,
                contentLayoutDirection: contentLayoutDirection
            )
        }
    }
}

// MARK: - Composer

/// The text-field composer pinned to the bottom of ``ChatPlayground``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so typing a draft re-renders only the composer, not the whole scrollback.
private struct ChatPlaygroundComposer: View {
    @Binding var draftText: String
    let onSend: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.oneUnit) {
            TextField("Message…", text: $draftText)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onSend)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(theme.typography.title2)
                    .foregroundStyle(isDraftEmpty ? theme.colors.textSecondary : theme.colors.primary)
            }
            .buttonStyle(.plain)
            .disabled(isDraftEmpty)
            .accessibilityLabel(Text("Send"))
        }
        .padding(.horizontal, theme.spacing.oneUnit)
        .padding(.bottom, theme.spacing.oneUnit)
    }

    private var isDraftEmpty: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Settings sheet

/// The settings sheet presented from the nav bar's settings button: every
/// live control for the playground's configurable parameters and states.
private struct ChatPlaygroundSettingsSheet: View {
    @Binding var composerRole: ChatMessageRole
    @Binding var composerMode: ComposerMode
    @Binding var contextCardMode: ContextCardMode
    @Binding var noticeKind: NoticeKind
    @Binding var contentDirectionMode: ContentDirectionMode
    @Binding var isInterfaceMirrored: Bool
    @Binding var responseStyle: ResponseStyle
    @Binding var isAutoReplyEnabled: Bool
    @Binding var responseDelaySeconds: Double
    @Binding var typingIndicatorStyle: TypingIndicatorStyle
    @Binding var quickActions: [DemoAction]
    @Binding var isQuickActionInteractionEnabled: Bool
    @Binding var showsQuickActionIcons: Bool
    let onRenewQuickActions: () -> Void
    let onAppendCustomBubble: () -> Void
    let onResetConversation: () -> Void
    let onDone: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
                    ShowcaseSection("Surface") {
                        SurfaceSettings(
                            composerMode: $composerMode,
                            composerRole: $composerRole,
                            contextCardMode: $contextCardMode,
                            noticeKind: $noticeKind
                        )
                    }

                    ShowcaseSection("Quick actions") {
                        QuickActionSettings(
                            actions: $quickActions,
                            isInteractionEnabled: $isQuickActionInteractionEnabled,
                            showsIcons: $showsQuickActionIcons,
                            onRenewAll: onRenewQuickActions
                        )
                    }

                    ShowcaseSection("Responses") {
                        ResponseSettings(
                            responseStyle: $responseStyle,
                            typingIndicatorStyle: $typingIndicatorStyle,
                            isAutoReplyEnabled: $isAutoReplyEnabled,
                            responseDelaySeconds: $responseDelaySeconds
                        )
                    }

                    ShowcaseSection("Layout direction") {
                        LayoutDirectionSettings(
                            contentDirectionMode: $contentDirectionMode,
                            isInterfaceMirrored: $isInterfaceMirrored
                        )
                    }

                    ShowcaseSection("Conversation") {
                        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                            Button("Append custom-content bubble", action: onAppendCustomBubble)
                            Button("Reset conversation", action: onResetConversation)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(theme.spacing.twoUnits)
            }
            .navigationTitle("Chat Settings")
            #if os(iOS) || targetEnvironment(macCatalyst)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// Controls for what the chat surface shows: composer shape, the role the
/// next typed message is sent as, the context card, and the notice banner.
private struct SurfaceSettings: View {
    @Binding var composerMode: ComposerMode
    @Binding var composerRole: ChatMessageRole
    @Binding var contextCardMode: ContextCardMode
    @Binding var noticeKind: NoticeKind
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            LabeledContent("Composer") {
                Picker("Composer", selection: $composerMode) {
                    ForEach(ComposerMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
            }

            if composerMode.showsTextField {
                Picker("Next message role", selection: $composerRole) {
                    Text("User").tag(ChatMessageRole.user)
                    Text("Assistant").tag(ChatMessageRole.assistant)
                    Text("System").tag(ChatMessageRole.system)
                }
                .pickerStyle(.segmented)
            }

            LabeledContent("Context card") {
                Picker("Context card", selection: $contextCardMode) {
                    ForEach(ContextCardMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
            }

            LabeledContent("Notice") {
                Picker("Notice", selection: $noticeKind) {
                    ForEach(NoticeKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .labelsHidden()
            }
        }
    }
}

/// Controls for ``AssistantQuickActionChipRow``: the caller-defined action
/// list itself (title, icon, and state per action, plus add and remove), the
/// row-wide interaction gate, whether chips carry leading icons, and renewing
/// every chip back to `.available` after tapping has marked it `.used`.
private struct QuickActionSettings: View {
    @Binding var actions: [DemoAction]
    @Binding var isInteractionEnabled: Bool
    @Binding var showsIcons: Bool
    let onRenewAll: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            ForEach($actions) { action in
                QuickActionRow(action: action) { remove(action.wrappedValue) }
            }

            HStack(spacing: theme.spacing.oneUnit) {
                Button("Add action", action: addAction)
                Button("Renew all", action: onRenewAll)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Toggle("Interaction enabled", isOn: $isInteractionEnabled)
                .toggleStyle(ThemeToggleStyle())
            Toggle("Chip icons", isOn: $showsIcons)
                .toggleStyle(ThemeToggleStyle())
        }
    }

    private func addAction() {
        let symbol = demoActionSymbols[actions.count % demoActionSymbols.count]
        actions.append(DemoAction(title: "Action \(actions.count + 1)", systemImage: symbol))
    }

    private func remove(_ action: DemoAction) {
        actions.removeAll { $0.id == action.id }
    }
}

/// One editable quick action: its title, icon, presentation state, and a
/// control to drop it from the row.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so editing one action doesn't re-render the whole settings panel.
private struct QuickActionRow: View {
    @Binding var action: DemoAction
    let onRemove: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            HStack(spacing: theme.spacing.oneUnit) {
                TextField("Title", text: $action.title)
                    .textFieldStyle(.roundedBorder)

                Picker("Icon", selection: $action.systemImage) {
                    ForEach(demoActionSymbols, id: \.self) { symbol in
                        Label(symbol, systemImage: symbol).tag(symbol)
                    }
                }
                .labelsHidden()

                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.error)
                .accessibilityLabel(Text("Remove \(action.title)"))
            }

            Picker("State", selection: $action.state) {
                Text("Available").tag(AssistantQuickActionState.available)
                Text("Used").tag(AssistantQuickActionState.used)
                Text("Disabled").tag(AssistantQuickActionState.disabled)
                Text("Hidden").tag(AssistantQuickActionState.hidden)
            }
            .pickerStyle(.segmented)
        }
    }
}

/// Controls for the simulated reply: its shape, the typing indicator shown
/// while it's pending, and whether (and how slowly) it arrives at all.
private struct ResponseSettings: View {
    @Binding var responseStyle: ResponseStyle
    @Binding var typingIndicatorStyle: TypingIndicatorStyle
    @Binding var isAutoReplyEnabled: Bool
    @Binding var responseDelaySeconds: Double
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            LabeledContent("Response style") {
                Picker("Response style", selection: $responseStyle) {
                    ForEach(ResponseStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .labelsHidden()
            }

            LabeledContent("Typing indicator") {
                Picker("Typing indicator", selection: $typingIndicatorStyle) {
                    ForEach(TypingIndicatorStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .labelsHidden()
            }

            Toggle("Simulate assistant reply", isOn: $isAutoReplyEnabled)
                .toggleStyle(ThemeToggleStyle())

            if isAutoReplyEnabled {
                ResponseDelayControl(delaySeconds: $responseDelaySeconds)
            }
        }
    }
}

/// The two independent direction controls: the per-bubble
/// `contentLayoutDirection` (text direction only) and a mirrored interface
/// (which flips role alignment too). See ``ChatBubble``.
private struct LayoutDirectionSettings: View {
    @Binding var contentDirectionMode: ContentDirectionMode
    @Binding var isInterfaceMirrored: Bool
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            LabeledContent("Content direction") {
                Picker("Content direction", selection: $contentDirectionMode) {
                    ForEach(ContentDirectionMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
            }

            Toggle("Mirror interface (RTL app)", isOn: $isInterfaceMirrored)
                .toggleStyle(ThemeToggleStyle())

            Text(
                "Content direction lays out the message text only. Mirroring the interface also flips which side of the screen each role sits on."
            )
            .designTextStyle(.caption)
            .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

/// The response-delay slider shown under "Simulate assistant reply".
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the rest of the
/// settings panel.
private struct ResponseDelayControl: View {
    @Binding var delaySeconds: Double
    @Environment(\.designTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.oneUnit) {
            Text("Response delay")
                .designTextStyle(.secondary)
            Slider(value: $delaySeconds, in: 0...4, step: 0.5)
            Text(delayLabel)
                .designTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(minWidth: theme.spacing.sixUnits, alignment: .trailing)
        }
    }

    private var delayLabel: String {
        "\(delaySeconds.formatted(.number.precision(.fractionLength(1))))s"
    }
}

// MARK: - Conversation log

private struct DemoTurn: Identifiable, Equatable {
    let id: Int
    let label: String
    var state: AssistantConversationState
}

/// ``AssistantConversationList``'s turn states behind their own nav bar
/// button — streaming, complete, error-with-retry, structured completion,
/// and empty — plus ``TypewriterReveal``. A different data model than the
/// playground's free-form composer, so it gets its own sheet rather than
/// sharing the main chat surface.
private struct ConversationLogSheet: View {
    let contentLayoutDirection: LayoutDirection?
    let onDone: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                ConversationLogDemo(contentLayoutDirection: contentLayoutDirection)
                    .padding(theme.spacing.twoUnits)
            }
            .navigationTitle("Conversation Log")
            #if os(iOS) || targetEnvironment(macCatalyst)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// The live ``AssistantConversationList`` demo: retryable error turns, an
/// interaction gate, optional structured rendering, the empty state's idle
/// hint, and a ``TypewriterReveal`` with an adjustable reveal speed.
private struct ConversationLogDemo: View {
    private static let structuredResponse = """
        ## Summary
        A short overview of the item you asked about.

        ## Details
        - The first supporting point.
        - The second supporting point.
        """

    private static let initialTurns = [
        DemoTurn(id: 0, label: "Action 1", state: .complete("Here's what I found.")),
        DemoTurn(id: 1, label: "Action 2", state: .streaming("Here's what I")),
        DemoTurn(id: 2, label: "Action 3", state: .complete(ConversationLogDemo.structuredResponse)),
        DemoTurn(id: 3, label: "Action 4", state: .error("Something went wrong.")),
    ]

    let contentLayoutDirection: LayoutDirection?

    @State private var turns = ConversationLogDemo.initialTurns
    @State private var isInteractionEnabled = true
    @State private var usesStructuredRendering = true
    @State private var showsEmptyState = false
    @State private var revealSpeed: Double = 20
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Turns") {
                AssistantConversationList(
                    turns: showsEmptyState ? [] : turns,
                    isInteractionEnabled: isInteractionEnabled,
                    idleHint: "Tap an action below to get started.",
                    userLabel: { $0.label },
                    responseState: { $0.state },
                    retryTitle: "Retry",
                    onRetry: { turn in
                        guard let index = turns.firstIndex(where: { $0.id == turn.id }) else { return }
                        turns[index].state = .complete("Resolved.")
                    },
                    autoPromotingHeadings: usesStructuredRendering ? ["Summary", "Details"] : [],
                    contentLayoutDirection: contentLayoutDirection
                )
            }

            ShowcaseSection("Typewriter reveal") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    TypewriterReveal(
                        text: "The assistant is composing a response.",
                        charactersPerSecond: Int(revealSpeed)
                    ) { text in
                        ChatBubbleView(
                            role: .assistant,
                            content: text,
                            contentLayoutDirection: contentLayoutDirection
                        )
                    }

                    HStack(spacing: theme.spacing.oneUnit) {
                        Text("Reveal speed")
                            .designTextStyle(.secondary)
                        Slider(value: $revealSpeed, in: 5...120, step: 5)
                        Text("\(Int(revealSpeed))/s")
                            .designTextStyle(.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .frame(minWidth: theme.spacing.sixUnits, alignment: .trailing)
                    }
                }
            }

            ShowcaseSection("Controls") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Toggle("Interaction enabled (gates retry)", isOn: $isInteractionEnabled)
                        .toggleStyle(ThemeToggleStyle())
                    Toggle("Structured completed responses", isOn: $usesStructuredRendering)
                        .toggleStyle(ThemeToggleStyle())
                    Toggle("Show empty state", isOn: $showsEmptyState)
                        .toggleStyle(ThemeToggleStyle())
                    Button("Reset turns") { turns = Self.initialTurns }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
    }
}
