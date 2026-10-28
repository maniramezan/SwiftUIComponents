import Testing

@testable import Components

struct SphereOrbitCollectionTests {
    private struct Item: Identifiable {
        let id: Int
        let label: String
    }

    @Test("Entries and animation identities share the same deduplicated order")
    func duplicateIdentity() {
        let collection = SphereOrbitCollection([
            Item(id: 4, label: "First"), Item(id: 8, label: "Second"), Item(id: 4, label: "Repeated"),
        ])
        #expect(collection.ids == [4, 8])
        #expect(collection.entries.map(\.id) == collection.ids)
        #expect(collection.entries.map(\.item.label) == ["First", "Second"])
        #expect(collection.entries.map(\.position) == [0, 0.5])
    }

    @Test("Insertion and removal preserve identities while redistributing normalized positions")
    func collectionChanges() {
        let items = [Item(id: 3, label: "A"), Item(id: 7, label: "B"), Item(id: 9, label: "C")]
        let original = SphereOrbitCollection(items)
        let inserted = SphereOrbitCollection(items + [Item(id: 11, label: "D")])
        let removed = SphereOrbitCollection([items[0], items[2]])
        #expect(original.ids == [3, 7, 9])
        #expect(inserted.entries.map(\.position) == [0, 0.25, 0.5, 0.75])
        #expect(Array(inserted.ids.prefix(items.count)) == original.ids)
        #expect(removed.ids == [3, 9])
        #expect(removed.entries.map(\.position) == [0, 0.5])
    }

    @Test("Empty collections do not produce invalid positions")
    func emptyCollection() {
        let collection = SphereOrbitCollection([Item]())
        #expect(collection.entries.isEmpty)
        #expect(collection.ids.isEmpty)
    }
}
