import Components
import DesignSystem
import SwiftUI

/// Routes the selected ``ShowcaseComponent`` to its dedicated detail view.
struct ShowcaseDetailView: View {

    let component: ShowcaseComponent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                detailContent
                    .padding()
            }
        }
        .navigationTitle(component.rawValue)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.large)
        #endif
    }

    @ViewBuilder
    private var detailContent: some View {
        switch component {
        case .buttons: ButtonsDetailView()
        case .compactAction: CompactActionDetailView()
        case .searchBar: SearchBarDetailView()
        case .toggle: ToggleDetailView()
        case .menuPicker: MenuPickerDetailView()
        case .selectionSheet: SelectionSheetViewDetailView()
        case .pillChips: PillChipsDetailView()
        case .segmentedPicker: SegmentedPickerDetailView()
        case .badges: BadgesDetailView()
        case .textStyles: TextStylesDetailView()
        case .surfaces: SurfacesDetailView()
        case .adaptiveSurface: AdaptiveSurfaceDetailView()
        case .selectableCard: SelectableCardDetailView()
        case .containers: ContainersDetailView()
        case .errorBanner: ErrorBannerDetailView()
        case .errorSection: ErrorSectionDetailView()
        case .loading: LoadingDetailView()
        case .ghostLoading: GhostLoadingDetailView()
        case .emptyState: EmptyStateDetailView()
        case .pagedView: PagedViewDetailView()
        case .chatBubble: ChatBubbleDetailView()
        case .typingIndicator: TypingIndicatorDetailView()
        }
    }
}
