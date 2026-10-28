nonisolated struct SphereOrbitCollection<Item: Identifiable> {
    struct Entry: Identifiable {
        let item: Item
        let position: Double
        var id: Item.ID { item.id }
    }

    let entries: [Entry]
    let ids: [Item.ID]

    init(_ items: [Item]) {
        let uniqueItems = SphereOrbitGeometry.uniqueItems(items)
        entries = uniqueItems.enumerated().map { index, item in
            Entry(item: item, position: Double(index) / Double(uniqueItems.count))
        }
        ids = uniqueItems.map(\.id)
    }
}
