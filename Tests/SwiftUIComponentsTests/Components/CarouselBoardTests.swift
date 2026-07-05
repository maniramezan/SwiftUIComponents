import SwiftUI
import Testing

@testable import Components

// MARK: - Shelf construction

@MainActor
@Test("CarouselShelf builds data-backed and fully-custom shelves")
func carouselShelfConstruction() {
    _ = CarouselShelf("Featured", items: CarouselTestItem.samples) { Text($0.title) }
    _ = CarouselShelf("Keyed", items: [1, 2, 3], id: \.self) { Text("\($0)") }
    _ = CarouselShelf("Custom") { Text("Anything") }
}

@MainActor
@Test("CarouselShelf derives its identifier from the title")
func carouselShelfIDFromTitle() {
    let shelf = CarouselShelf("Top Free", items: CarouselTestItem.samples) { Text($0.title) }
    #expect(shelf.shelfID == AnyHashable("Top Free"))
}

// MARK: - Result builder

@MainActor
@Test("A board collects one shelf per declaration, preserving order")
func boardCollectsShelvesInOrder() {
    let shelves = CarouselShelfBuilder.buildBlock(
        CarouselShelfBuilder.buildExpression(CarouselShelf("A", items: [1], id: \.self) { Text("\($0)") }),
        CarouselShelfBuilder.buildExpression(CarouselShelf("B", items: ["x"], id: \.self) { Text($0) }),
        CarouselShelfBuilder.buildExpression(CarouselShelf("C") { Text("custom") })
    )
    #expect(shelves.count == 3)
    #expect(shelves.map(\.shelfID) == [AnyHashable("A"), AnyHashable("B"), AnyHashable("C")])
}

@MainActor
@Test("buildOptional yields no shelves when the condition is false")
func builderOptionalEmpty() {
    #expect(CarouselShelfBuilder.buildOptional(nil).isEmpty)
    let present = CarouselShelfBuilder.buildOptional(
        [CarouselShelf("A", items: [1], id: \.self) { Text("\($0)") }]
    )
    #expect(present.count == 1)
}

@MainActor
@Test("buildEither passes each branch through unchanged")
func builderEitherBranches() {
    let first = CarouselShelfBuilder.buildEither(
        first: [CarouselShelf("A", items: [1], id: \.self) { Text("\($0)") }]
    )
    let second = CarouselShelfBuilder.buildEither(
        second: [CarouselShelf("B") { Text("b") }]
    )
    #expect(first.map(\.shelfID) == [AnyHashable("A")])
    #expect(second.map(\.shelfID) == [AnyHashable("B")])
}

@MainActor
@Test("buildArray flattens shelves produced by a loop")
func builderArrayFlattens() {
    let parts = (0..<3).map { index in
        [CarouselShelf("Shelf \(index)", items: [index], id: \.self) { Text("\($0)") }]
    }
    let flattened = CarouselShelfBuilder.buildArray(parts)
    #expect(flattened.count == 3)
}

// MARK: - Board / heterogeneous shelves

@MainActor
@Test("A board mixes shelves with different item types")
func boardMixesHeterogeneousShelves() {
    _ = CarouselBoard {
        CarouselShelf("Numbers", items: [1, 2, 3], id: \.self) { Text("\($0)") }
        CarouselShelf("Words", items: ["a", "b"], id: \.self) { Text($0) }
        CarouselShelf("Models", items: CarouselTestItem.samples) { Text($0.title) }
        CarouselShelf("Banner") { Color.clear }
    }
    _ = CarouselBoardContent {
        CarouselShelf("Numbers", items: [1, 2, 3], id: \.self) { Text("\($0)") }
    }
}
