import OSLog

struct TitledPageCollection<Element, ID: Hashable> {
    struct Entry: Identifiable {
        let id: ID
        let element: Element
        let index: Int
        let titleKeyPath: KeyPath<Element, String>

        var title: String { element[keyPath: titleKeyPath] }
    }

    let entries: [Entry]
    let indices: [ID: Int]

    var titles: [String] { entries.map(\.title) }
    var header: [TitledPageTitle<ID>] {
        entries.map { TitledPageTitle(id: $0.id, title: $0.title, index: $0.index) }
    }

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
            entries.append(Entry(id: identity, element: element, index: entries.count, titleKeyPath: title))
        }
        self.entries = entries
        self.indices = indices
    }
}

struct TitledPageTitle<ID: Hashable>: Identifiable {
    let id: ID
    let title: String
    let index: Int
}
