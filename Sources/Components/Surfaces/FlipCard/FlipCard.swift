import DesignSystem
import SwiftUI

/// A two-sided card that flips between a front and back face, for flashcard-style UI.
///
/// `FlipCard` shows one of two faces at a time and animates a 3D rotation around the
/// vertical axis when the visible face changes. Tapping the card flips it, and VoiceOver
/// users get an equivalent "Flip" custom action.
///
/// The card works in two modes. Use ``init(initiallyFaceUp:axis:animation:front:back:)`` for a
/// self-managing card that tracks its own flipped state — ideal for simple flashcards.
/// Use ``init(isFaceUp:axis:animation:front:back:)`` to drive the visible face from your own
/// `Binding<Bool>` when you need to read or change it externally (e.g. a "reveal answer"
/// button elsewhere on screen).
///
/// Each face is wrapped in a ``CardSurface`` and sized to fill the available width so the
/// card stays a stable size across the flip.
///
/// ```swift
/// // Self-managing
/// FlipCard {
///     Text("Bonjour").designTextStyle(.title)
/// } back: {
///     Text("Hello").designTextStyle(.title)
/// }
///
/// // Controlled
/// @State private var isFaceUp = true
/// FlipCard(isFaceUp: $isFaceUp) {
///     Text("Bonjour").designTextStyle(.title)
/// } back: {
///     Text("Hello").designTextStyle(.title)
/// }
/// ```
///
/// The flip animation defaults to the active theme's `motion.standardAnimation`. Pass an
/// `animation:` to override the timing for a single card (e.g. `.spring(duration: 0.5)`).
///
/// Under Reduce Motion the 3D rotation is replaced by a cross-fade between the two faces.
public struct FlipCard<Front: View, Back: View>: View {
    @State private var internalIsFaceUp: Bool
    private let externalIsFaceUp: Binding<Bool>?
    private let axis: FlipAxis
    private let animationOverride: Animation?
    private let front: Front
    private let back: Back
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a self-managing flip card that tracks its own flipped state.
    /// - Parameters:
    ///   - initiallyFaceUp: Which face is shown initially. `true` (the default) shows the
    ///     front face, `false` the back.
    ///   - axis: Whether the card flips around its vertical axis (``FlipAxis/horizontal``,
    ///     the default — faces sweep left/right) or its horizontal axis
    ///     (``FlipAxis/vertical`` — faces sweep top/bottom).
    ///   - animation: The animation used for the flip. When `nil` (the default) the active
    ///     theme's `motion.standardAnimation` is used.
    ///   - front: The content of the front face.
    ///   - back: The content of the back face.
    public init(
        initiallyFaceUp: Bool = true,
        axis: FlipAxis = .horizontal,
        animation: Animation? = nil,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._internalIsFaceUp = State(initialValue: initiallyFaceUp)
        self.externalIsFaceUp = nil
        self.axis = axis
        self.animationOverride = animation
        self.front = front()
        self.back = back()
    }

    /// Creates a flip card whose visible face is driven by an external binding.
    /// - Parameters:
    ///   - isFaceUp: Binding to which face is shown. `true` shows the front face, `false`
    ///     the back. Tapping the card toggles this value.
    ///   - axis: Whether the card flips around its vertical axis (``FlipAxis/horizontal``,
    ///     the default — faces sweep left/right) or its horizontal axis
    ///     (``FlipAxis/vertical`` — faces sweep top/bottom).
    ///   - animation: The animation used for the flip. When `nil` (the default) the active
    ///     theme's `motion.standardAnimation` is used.
    ///   - front: The content of the front face.
    ///   - back: The content of the back face.
    public init(
        isFaceUp: Binding<Bool>,
        axis: FlipAxis = .horizontal,
        animation: Animation? = nil,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._internalIsFaceUp = State(initialValue: isFaceUp.wrappedValue)
        self.externalIsFaceUp = isFaceUp
        self.axis = axis
        self.animationOverride = animation
        self.front = front()
        self.back = back()
    }

    public var body: some View {
        let isFaceUp = externalIsFaceUp ?? $internalIsFaceUp
        ZStack {
            FlipCardFace(content: front)
                .opacity(isFaceUp.wrappedValue ? 1 : 0)
                .accessibilityHidden(!isFaceUp.wrappedValue)
            FlipCardFace(content: back)
                // Pre-rotate the back face so its content reads correctly once the
                // container has rotated 180°.
                .rotation3DEffect(reduceMotion ? .zero : .degrees(180), axis: flipAxis)
                .opacity(isFaceUp.wrappedValue ? 0 : 1)
                .accessibilityHidden(isFaceUp.wrappedValue)
        }
        .rotation3DEffect(reduceMotion ? .zero : .degrees(isFaceUp.wrappedValue ? 0 : 180), axis: flipAxis)
        .animation(animationOverride ?? theme.motion.standardAnimation, value: isFaceUp.wrappedValue)
        .contentShape(Rectangle())
        .onTapGesture { isFaceUp.wrappedValue.toggle() }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text(Strings.FlipCard.flipHint))
        .accessibilityAction(named: Text(Strings.FlipCard.flipAction)) { isFaceUp.wrappedValue.toggle() }
    }

    private var flipAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch axis {
        case .horizontal: (x: 0, y: 1, z: 0)
        case .vertical: (x: 1, y: 0, z: 0)
        }
    }
}

/// One face of a ``FlipCard``: its content padded and wrapped in a themed
/// ``CardSurface``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff and update each face independently.
private struct FlipCardFace<Content: View>: View {
    let content: Content

    @Environment(\.designTheme) private var theme

    var body: some View {
        content
            .padding(theme.spacing.twoUnits)
            .frame(maxWidth: .infinity)
            .designCardSurface()
    }
}

#Preview("Flip Card") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            // Self-managing — tap to flip.
            FlipCard {
                Text("Bonjour")
                    .designTextStyle(.title)
            } back: {
                Text("Hello")
                    .designTextStyle(.title)
            }

            // Controlled — flipped from an external button.
            StatefulPreviewWrapper(true) { isFaceUp in
                VStack(spacing: theme.spacing.twoUnits) {
                    FlipCard(isFaceUp: isFaceUp, axis: .vertical) {
                        Text("Gracias")
                            .designTextStyle(.title)
                    } back: {
                        Text("Thank you")
                            .designTextStyle(.title)
                    }
                    ThemeButton("Flip") { isFaceUp.wrappedValue.toggle() }
                }
            }
        }
        .padding(theme.spacing.twoUnits)
    }
}

/// Drives a `Binding` in previews so interactive components can be exercised.
private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
