import Components
import DesignSystem
import SwiftUI

/// Routes the selected ``ShowcaseComponent`` to its dedicated detail view.
struct ShowcaseDetailView: View {

    let component: ShowcaseComponent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ShowcaseDetailContent(component: component)
                    .padding()
            }
        }
        .navigationTitle(component.rawValue)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

/// Routes `component` to its dedicated detail view.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the enclosing scroll view.
private struct ShowcaseDetailContent: View {
    let component: ShowcaseComponent

    var body: some View {
        switch component {
        case .buttons: ButtonsDetailView()
        case .compactAction: CompactActionDetailView()
        case .searchBar: SearchBarDetailView()
        case .toggle: ToggleDetailView()
        case .menuPicker: MenuPickerDetailView()
        case .selectionList: SelectionListDetailView()
        case .pillChips: PillChipsDetailView()
        case .segmentedPicker: SegmentedPickerDetailView()
        case .badges: BadgesDetailView()
        case .textStyles: TextStylesDetailView()
        case .surfaces: SurfacesDetailView()
        case .adaptiveSurface: AdaptiveSurfaceDetailView()
        case .selectableCard: SelectableCardDetailView()
        case .flipCard: FlipCardDetailView()
        case .containers: ContainersDetailView()
        case .errorBanner: ErrorBannerDetailView()
        case .errorSection: ErrorSectionDetailView()
        case .loading: LoadingDetailView()
        case .ghostLoading: GhostLoadingDetailView()
        case .emptyState: EmptyStateDetailView()
        case .toast: ToastDetailView()
        case .pagedView: PagedViewDetailView()
        case .chatBubble: ChatBubbleDetailView()
        case .typingIndicator: TypingIndicatorDetailView()
        case .carouselRow: CarouselRowDetailView()
        case .carouselBoard: CarouselBoardDetailView()
        }
    }
}
