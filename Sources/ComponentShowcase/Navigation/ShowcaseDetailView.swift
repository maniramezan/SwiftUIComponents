import Components
import DesignSystem
import SwiftUI

/// Routes the selected ``ShowcaseComponent`` to its dedicated detail view.
struct ShowcaseDetailView: View {

    let component: ShowcaseComponent

    var body: some View {
        Group {
            if component.fillsDetailPane {
                // A full-page experience (e.g. the chat playground) needs the
                // whole detail pane, not the padded ScrollView every other
                // component's static reference content uses below.
                ShowcaseDetailContent(component: component)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ShowcaseDetailContent(component: component)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle(component.rawValue)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(component.fillsDetailPane ? .inline : .large)
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
        case .textInputField: TextInputFieldDetailView()
        case .segmentedPicker: SegmentedPickerDetailView()
        case .badges: BadgesDetailView()
        case .textStyles: TextStylesDetailView()
        case .listRow: ListRowDetailView()
        case .avatar: AvatarDetailView()
        case .sectionHeader: SectionHeaderDetailView()
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
        case .progress: ProgressDetailView()
        case .asyncContent: AsyncContentDetailView()
        case .pagedView: PagedViewDetailView()
        case .chat: ChatPlaygroundDetailView()
        case .carouselRow: CarouselRowDetailView()
        case .carouselBoard: CarouselBoardDetailView()
        }
    }
}
