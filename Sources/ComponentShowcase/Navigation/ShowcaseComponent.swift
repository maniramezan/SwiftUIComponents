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
    case pillChips = "Pill Chips"

    // MARK: - Display
    case badges = "Badges"
    case textStyles = "Text Styles"

    // MARK: - Surfaces
    case surfaces = "Surfaces"
    case adaptiveSurface = "Adaptive Surface"
    case selectableCard = "Selectable Card"
    case containers = "Containers"

    // MARK: - Feedback
    case errorBanner = "Error Banner"
    case errorSection = "Error Section"
    case loading = "Loading"
    case ghostLoading = "Ghost Loading"
    case emptyState = "Empty State"

    // MARK: - Pagination
    case pagedView = "Paged View"
    case segmentedPicker = "Segmented Picker"

    // MARK: - Chat
    case chatBubble = "Chat Bubble"
    case typingIndicator = "Typing Indicator"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .buttons: return "button.programmable"
        case .compactAction: return "circle.grid.2x1.fill"
        case .searchBar: return "magnifyingglass"
        case .toggle: return "switch.2"
        case .menuPicker: return "list.bullet"
        case .pillChips: return "capsule.fill"
        case .segmentedPicker: return "rectangle.split.3x1.fill"
        case .badges: return "seal.fill"
        case .textStyles: return "textformat"
        case .surfaces: return "square.on.square"
        case .adaptiveSurface: return "square.stack.3d.up"
        case .selectableCard: return "checkmark.square"
        case .containers: return "rectangle.on.rectangle"
        case .errorBanner: return "exclamationmark.triangle"
        case .errorSection: return "xmark.octagon"
        case .loading: return "arrow.2.circlepath"
        case .ghostLoading: return "rectangle.dashed"
        case .emptyState: return "tray"
        case .pagedView: return "rectangle.split.3x1"
        case .chatBubble: return "bubble.left.and.bubble.right"
        case .typingIndicator: return "ellipsis.message"
        }
    }

    /// Logical grouping label used as a section header in the sidebar.
    var group: String {
        switch self {
        case .buttons, .compactAction:
            return "Actions"
        case .searchBar, .toggle, .menuPicker, .pillChips:
            return "Controls"
        case .badges, .textStyles:
            return "Display"
        case .surfaces, .adaptiveSurface, .selectableCard, .containers:
            return "Surfaces"
        case .errorBanner, .errorSection, .loading, .ghostLoading, .emptyState:
            return "Feedback"
        case .pagedView, .segmentedPicker:
            return "Pagination"
        case .chatBubble, .typingIndicator:
            return "Chat"
        }
    }
}
