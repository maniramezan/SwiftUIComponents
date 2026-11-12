enum FloatingActionIcon: String, CaseIterable, Sendable {
    case plus
    case close = "xmark"
    case edit = "pencil"
    case favorite = "star"
    case more = "ellipsis"

    var title: String {
        switch self {
        case .plus: "Plus"
        case .close: "Close"
        case .edit: "Edit"
        case .favorite: "Star"
        case .more: "More"
        }
    }
}
