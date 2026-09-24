import Foundation

/// A registered component entry shown in the showcase sidebar.
enum ShowcaseComponent: String, CaseIterable, Identifiable {

    // MARK: - Actions
    case buttons = "Buttons"
    case compactAction = "Compact Action Button"

    // MARK: - Controls
    case searchBar = "Search Bar"
    case toggle = "Toggle"
    case menuPicker = "Menu Picker"
    case selectionList = "Selection List"
    case pillChips = "Pill Chips"
    case textInputField = "Text Input Field"

    // MARK: - Display
    case badges = "Badges"
    case textStyles = "Text Styles"
    case listRow = "List Row"
    case avatar = "Avatar"
    case sectionHeader = "Section Header"

    // MARK: - Surfaces
    case surfaces = "Surfaces"
    case adaptiveSurface = "Adaptive Surface"
    case selectableCard = "Selectable Card"
    case flipCard = "Flip Card"
    case containers = "Containers"

    // MARK: - Feedback
    case errorBanner = "Error Banner"
    case errorSection = "Error Section"
    case loading = "Loading"
    case ghostLoading = "Ghost Loading"
    case emptyState = "Empty State"
    case toast = "Toast"
    case progress = "Progress"
    case asyncContent = "Async Content"

    // MARK: - Pagination
    case pagedView = "Paged View"
    case segmentedPicker = "Segmented Picker"

    // MARK: - Chat
    case chat = "Chat"

    // MARK: - Collections
    case carouselRow = "Carousel Row"
    case carouselBoard = "Shelves"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .buttons: return "button.programmable"
        case .compactAction: return "circle.grid.2x1.fill"
        case .searchBar: return "magnifyingglass"
        case .toggle: return "switch.2"
        case .menuPicker: return "list.bullet"
        case .selectionList: return "checklist"
        case .pillChips: return "capsule.fill"
        case .textInputField: return "character.cursor.ibeam"
        case .segmentedPicker: return "rectangle.split.3x1.fill"
        case .badges: return "seal.fill"
        case .textStyles: return "textformat"
        case .listRow: return "list.bullet.rectangle"
        case .avatar: return "person.crop.circle"
        case .sectionHeader: return "text.justify.leading"
        case .surfaces: return "square.on.square"
        case .adaptiveSurface: return "square.stack.3d.up"
        case .selectableCard: return "checkmark.square"
        case .flipCard: return "rectangle.portrait.rotate"
        case .containers: return "rectangle.on.rectangle"
        case .errorBanner: return "exclamationmark.triangle"
        case .errorSection: return "xmark.octagon"
        case .loading: return "arrow.2.circlepath"
        case .ghostLoading: return "rectangle.dashed"
        case .emptyState: return "tray"
        case .toast: return "bell.badge.fill"
        case .progress: return "chart.bar.fill"
        case .asyncContent: return "arrow.triangle.2.circlepath"
        case .pagedView: return "rectangle.split.3x1"
        case .chat: return "bubble.left.and.bubble.right"
        case .carouselRow: return "rectangle.portrait.on.rectangle.portrait"
        case .carouselBoard: return "rectangle.grid.1x2"
        }
    }

    /// Logical grouping label used as a section header in the sidebar.
    var group: String {
        switch self {
        case .buttons, .compactAction:
            return "Actions"
        case .searchBar, .toggle, .menuPicker, .selectionList, .pillChips, .textInputField:
            return "Controls"
        case .badges, .textStyles, .listRow, .avatar, .sectionHeader:
            return "Display"
        case .surfaces, .adaptiveSurface, .selectableCard, .flipCard, .containers:
            return "Surfaces"
        case .errorBanner, .errorSection, .loading, .ghostLoading, .emptyState, .toast, .progress, .asyncContent:
            return "Feedback"
        case .pagedView, .segmentedPicker:
            return "Pagination"
        case .chat:
            return "Chat"
        case .carouselRow, .carouselBoard:
            return "Collections"
        }
    }

    /// `true` for a full-page experience (e.g. the chat playground) that
    /// should occupy the whole detail pane instead of the padded
    /// `ScrollView` every other component's static reference content uses.
    var fillsDetailPane: Bool {
        self == .chat
    }
}
