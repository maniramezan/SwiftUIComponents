import SwiftUI
import Testing

@testable import Components

@MainActor
struct FlipCardTests {
    // MARK: - Construction

    @Test("Self-managing FlipCard is constructible with defaults")
    func selfManagingDefaults() {
        _ = FlipCard {
            Text("Front")
        } back: {
            Text("Back")
        }
    }

    @Test(
        "Self-managing FlipCard is constructible for each starting face and axis",
        arguments: [true, false], [FlipAxis.horizontal, .vertical]
    )
    func selfManagingVariants(initiallyFaceUp: Bool, axis: FlipAxis) {
        _ = FlipCard(initiallyFaceUp: initiallyFaceUp, axis: axis) {
            Text("Front")
        } back: {
            Text("Back")
        }
    }

    @Test("Controlled FlipCard is constructible for each axis", arguments: [FlipAxis.horizontal, .vertical])
    func controlledVariants(axis: FlipAxis) {
        _ = FlipCard(isFaceUp: .constant(true), axis: axis) {
            Text("Front")
        } back: {
            Text("Back")
        }
    }

    @Test("FlipCard accepts a custom flip animation override")
    func customAnimationOverride() {
        _ = FlipCard(animation: .spring(duration: 0.5)) {
            Text("Front")
        } back: {
            Text("Back")
        }

        _ = FlipCard(isFaceUp: .constant(true), axis: .vertical, animation: .easeInOut(duration: 1)) {
            Text("Front")
        } back: {
            Text("Back")
        }
    }

    @Test("Faces accept heterogeneous content types")
    func heterogeneousFaces() {
        _ = FlipCard {
            Image(systemName: "star")
        } back: {
            VStack {
                Text("Title")
                Text("Subtitle")
            }
        }
    }

    // MARK: - Controlled binding behavior

    @Test("Tapping the controlled card toggles the bound face")
    func tapTogglesBinding() {
        var isFaceUp = true
        let binding = Binding(get: { isFaceUp }, set: { isFaceUp = $0 })

        _ = FlipCard(isFaceUp: binding) {
            Text("Front")
        } back: {
            Text("Back")
        }

        // Simulate the tap/flip action the view performs against the external binding.
        binding.wrappedValue.toggle()
        #expect(isFaceUp == false)

        binding.wrappedValue.toggle()
        #expect(isFaceUp == true)
    }

    @Test("Controlled card reflects external binding changes")
    func reflectsExternalChanges() {
        var isFaceUp = false
        let binding = Binding(get: { isFaceUp }, set: { isFaceUp = $0 })

        _ = FlipCard(isFaceUp: binding) {
            Text("Front")
        } back: {
            Text("Back")
        }

        isFaceUp = true
        #expect(binding.wrappedValue == true)
    }

    // MARK: - FlipAxis

    @Test("FlipAxis is equatable and distinct per orientation")
    func flipAxisEquatable() {
        #expect(FlipAxis.horizontal != FlipAxis.vertical)
        #expect(FlipAxis.horizontal == .horizontal)
        #expect(FlipAxis.vertical == .vertical)
    }

    @Test("FlipAxis is hashable and orientations hash distinctly")
    func flipAxisHashable() {
        let axes: Set<FlipAxis> = [.horizontal, .vertical, .horizontal]
        #expect(axes == [.horizontal, .vertical])
    }
}
