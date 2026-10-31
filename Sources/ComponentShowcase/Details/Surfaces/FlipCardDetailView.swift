import Components
import DesignSystem
import SwiftUI

struct FlipCardDetailView: View {
    @State private var axis = FlipAxis.horizontal
    @State private var timing = 0
    @State private var front = "Front"
    @State private var back = "Back"
    @State private var controlledFaceUp = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        ShowcaseSection("Tap a card to flip it") {
            VStack(spacing: theme.spacing.threeUnits) {
                ShowcaseTextField("Front", text: $front)
                ShowcaseTextField("Back", text: $back)
                ShowcasePicker("Axis", selection: $axis) {
                    Text("Horizontal").tag(FlipAxis.horizontal)
                    Text("Vertical").tag(FlipAxis.vertical)
                }
                ShowcasePicker("Animation", selection: $timing) {
                    Text("Theme").tag(0)
                    Text("Linear").tag(1)
                    Text("Spring").tag(2)
                }
                Toggle("Face up", isOn: $controlledFaceUp)
                FlipCard(
                    isFaceUp: $controlledFaceUp, axis: axis,
                    animation: timing == 0 ? nil : timing == 1 ? .linear(duration: 0.5) : .spring()
                ) {
                    Text(front)
                } back: {
                    Text(back)
                }

                VStack(spacing: theme.spacing.oneUnit) {
                    Text("Horizontal (self-managing)")
                        .designTextStyle(.secondary)
                    FlipCard(axis: .horizontal) {
                        FlipCardDetailFlashcard(title: "Bonjour", subtitle: "French")
                    } back: {
                        FlipCardDetailFlashcard(title: "Hello", subtitle: "English")
                    }
                }

                VStack(spacing: theme.spacing.oneUnit) {
                    Text("Vertical (self-managing)")
                        .designTextStyle(.secondary)
                    FlipCard(axis: .vertical) {
                        FlipCardDetailFlashcard(title: "Gracias", subtitle: "Spanish")
                    } back: {
                        FlipCardDetailFlashcard(title: "Thank you", subtitle: "English")
                    }
                }

                VStack(spacing: theme.spacing.oneUnit) {
                    Text("Controlled (external button)")
                        .designTextStyle(.secondary)
                    FlipCard(isFaceUp: $controlledFaceUp) {
                        FlipCardDetailFlashcard(title: "Danke", subtitle: "German")
                    } back: {
                        FlipCardDetailFlashcard(title: "Thanks", subtitle: "English")
                    }
                    ThemeButton("Flip", role: .secondary) { controlledFaceUp.toggle() }
                }
            }
        }
    }
}

/// A single flashcard face shown inside ``FlipCardDetailView``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff and update each face independently.
private struct FlipCardDetailFlashcard: View {
    let title: String
    let subtitle: String

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.halfUnit) {
            Text(title)
                .designTextStyle(.title)
            Text(subtitle)
                .designTextStyle(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.threeUnits)
    }
}

#Preview {
    ScrollView {
        FlipCardDetailView()
            .padding()
    }
}
