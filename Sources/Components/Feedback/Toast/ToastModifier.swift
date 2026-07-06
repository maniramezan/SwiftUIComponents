import DesignSystem
import SwiftUI

/// Presents a ``ToastView`` (or custom content) as a transient overlay anchored
/// to the top or bottom safe-area edge of the modified view.
///
/// Use the `.toast(_:role:systemImage:isPresented:edge:duration:action:)`
/// and `.toast(isPresented:edge:duration:content:)` helpers rather than
/// applying this modifier directly.
struct ToastModifier<ToastContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let edge: VerticalEdge
    let duration: Duration?
    let announcement: LocalizedStringResource?
    let toastContent: ToastContent

    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGFloat = 0

    init(
        isPresented: Binding<Bool>,
        edge: VerticalEdge,
        duration: Duration?,
        announcement: LocalizedStringResource? = nil,
        @ViewBuilder content: () -> ToastContent
    ) {
        self._isPresented = isPresented
        self.edge = edge
        self.duration = duration
        self.announcement = announcement
        self.toastContent = content()
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: edge == .top ? .top : .bottom) {
                if isPresented {
                    toastContent
                        .padding(theme.spacing.twoUnits)
                        .safeAreaPadding(safeAreaEdges)
                        .offset(y: dragOffset)
                        .gesture(dismissGesture)
                        // Lets VoiceOver / switch users dismiss without the swipe
                        // gesture (the two-finger "escape" scrub triggers this).
                        .accessibilityAction(.escape) { dismiss() }
                        .transition(transition)
                        .onAppear(perform: announce)
                        .task {
                            guard let duration else { return }
                            try? await Task.sleep(for: duration)
                            guard !Task.isCancelled else { return }
                            dismiss()
                        }
                }
            }
            .animation(theme.motion.standardAnimation, value: isPresented)
    }

    /// Speaks the toast to VoiceOver when it appears, so the transient message
    /// is not missed before it auto-dismisses. No-op for custom content that
    /// supplies no announcement text.
    private func announce() {
        guard let announcement else { return }
        var spoken = AttributedString(String(localized: announcement))
        spoken.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(spoken).post()
    }

    /// Slide-and-fade normally; fade only under Reduce Motion.
    private var transition: AnyTransition {
        if reduceMotion { return .opacity }
        let moveEdge: Edge = edge == .top ? .top : .bottom
        return .move(edge: moveEdge).combined(with: .opacity)
    }

    /// Keeps the toast below the top safe area or above the bottom safe area,
    /// while preserving the normal horizontal design-system spacing.
    private var safeAreaEdges: Edge.Set {
        edge == .top ? .top : .bottom
    }

    /// Lets the user swipe the toast away toward its anchored edge.
    private var dismissGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                dragOffset = edge == .top ? min(0, translation) : max(0, translation)
            }
            .onEnded { value in
                let threshold: CGFloat = theme.spacing.threeUnits
                let translation = value.translation.height
                let shouldDismiss = edge == .top ? translation < -threshold : translation > threshold
                if shouldDismiss {
                    dismiss()
                } else {
                    withAnimation(theme.motion.standardAnimation) { dragOffset = 0 }
                }
            }
    }

    private func dismiss() {
        withAnimation(theme.motion.standardAnimation) { isPresented = false }
        dragOffset = 0
    }
}

// MARK: - View API

public extension View {

    /// Presents a role-tinted toast with an optional trailing action.
    ///
    /// The toast is anchored to `edge`, inset from that edge's safe area,
    /// animates in with a slide-and-fade (a plain fade under Reduce Motion), and
    /// can always be swiped away. Pass a `duration` to auto-dismiss after it, or
    /// `nil` to keep the toast until the user taps the action or swipes it away.
    /// Toasts with actions ignore `duration` and remain visible until explicit
    /// dismissal, giving assistive technology and motor-control users enough time
    /// to reach the action. On dismissal — by timer, swipe, or action tap —
    /// `isPresented` is set back to `false`.
    ///
    /// ```swift
    /// .toast("Saved", role: .success, isPresented: $showToast)
    /// .toast("Item deleted", role: .info, isPresented: $showToast,
    ///        duration: nil, action: .init("Undo") { restore() })
    /// ```
    ///
    /// - Parameters:
    ///   - message: The message text. Rendered verbatim, so localize it on your side.
    ///   - role: The semantic role controlling accent color and default icon. Defaults to `.info`.
    ///   - systemImage: An optional SF Symbol name overriding the role's default icon.
    ///   - isPresented: Drives presentation; set back to `false` when the toast dismisses.
    ///   - edge: The edge the toast is anchored to and animates from. Defaults to `.bottom`.
    ///   - duration: Auto-dismiss delay, or `nil` to persist until the user dismisses. Defaults to `.seconds(3)`.
    ///   - action: An optional trailing action (e.g. "Undo"). Its handler runs and then dismisses the toast.
    func toast(
        _ message: String,
        role: ToastRole = .info,
        systemImage: String? = nil,
        isPresented: Binding<Bool>,
        edge: VerticalEdge = .bottom,
        duration: Duration? = .seconds(3),
        action: ToastAction? = nil
    ) -> some View {
        let wrappedAction = action.map { original in
            ToastAction(original.title) {
                original.handler()
                isPresented.wrappedValue = false
            }
        }
        return modifier(
            ToastModifier(
                isPresented: isPresented,
                edge: edge,
                duration: wrappedAction == nil ? duration : nil,
                announcement: Strings.Toast.accessibilityLabel(role: role, message: message)
            ) {
                ToastView(message, role: role, systemImage: systemImage, action: wrappedAction)
            }
        )
    }

    /// Presents fully custom toast content as a transient overlay.
    ///
    /// Use this when ``ToastView`` is not enough — for example a multi-line layout
    /// or a custom control. The modifier owns safe-area-aware positioning, the
    /// slide/fade transition, swipe-to-dismiss, and (when `duration` is non-`nil`)
    /// the auto-dismiss timer; it sets `isPresented` back to `false` on timer or
    /// swipe. Any action *inside* your content should flip `isPresented` itself.
    ///
    /// - Parameters:
    ///   - isPresented: Drives presentation; set back to `false` when the toast dismisses.
    ///   - edge: The edge the toast is anchored to and animates from. Defaults to `.bottom`.
    ///   - duration: Auto-dismiss delay, or `nil` to persist until the user dismisses. Defaults to `.seconds(3)`.
    ///   - content: The toast's content.
    func toast<ToastContent: View>(
        isPresented: Binding<Bool>,
        edge: VerticalEdge = .bottom,
        duration: Duration? = .seconds(3),
        @ViewBuilder content: () -> ToastContent
    ) -> some View {
        modifier(
            ToastModifier(isPresented: isPresented, edge: edge, duration: duration, content: content)
        )
    }
}

#Preview("Toast — presentation") {
    PreviewContent { theme in
        ToastPreviewHost()
            .padding(theme.spacing.twoUnits)
    }
}

/// Interactive preview host that toggles toasts on and off.
private struct ToastPreviewHost: View {
    @State private var showAutoDismiss = false
    @State private var showPersistent = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.twoUnits) {
            ThemeButton("Show auto-dismiss toast") { showAutoDismiss = true }
            ThemeButton("Show persistent toast", role: .secondary) { showPersistent = true }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast("Saved to your library", role: .success, isPresented: $showAutoDismiss)
        .toast(
            "Item deleted",
            role: .info,
            isPresented: $showPersistent,
            edge: .top,
            duration: nil,
            action: .init("Undo") {}
        )
    }
}
