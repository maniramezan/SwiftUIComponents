import OSLog

struct TitledPageCollection<Element, ID: Hashable> {
    struct Entry: Identifiable {
        let id: ID
        let title: String
        let element: Element
        let index: Int
    }

    let entries: [Entry]
    let titles: [String]
    let indices: [ID: Int]
    let header: [TitledPageTitle<ID>]

    init(_ elements: some RandomAccessCollection<Element>, id: KeyPath<Element, ID>, title: KeyPath<Element, String>) {
        var entries: [Entry] = []
        var indices: [ID: Int] = [:]
        for element in elements {
            let identity = element[keyPath: id]
            guard indices[identity] == nil else {
                Logger(subsystem: "com.swiftuicomponents", category: "TitledPageView")
                    .fault("Duplicate page identity; ignoring the repeated page")
                continue
            }
            indices[identity] = entries.count
            entries.append(Entry(id: identity, title: element[keyPath: title], element: element, index: entries.count))
        }
        self.entries = entries
        self.indices = indices
        self.titles = entries.map(\.title)
        self.header = entries.map { TitledPageTitle(id: $0.id, title: $0.title, index: $0.index) }
    }
}

struct TitledPageTitle<ID: Hashable>: Identifiable {
    let id: ID
    let title: String
    let index: Int
}
