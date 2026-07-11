import Components
import DesignSystem
import SwiftUI

struct FlipCardDetailView: View {
    @State private var controlledFaceUp = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        ShowcaseSection("Tap a card to flip it") {
            VStack(spacing: theme.spacing.threeUnits) {
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
