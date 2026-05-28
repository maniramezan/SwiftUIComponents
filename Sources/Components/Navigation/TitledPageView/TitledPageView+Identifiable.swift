import DesignSystem
import SwiftUI

// MARK: - Identifiable convenience

public extension TitledPageView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// Creates a paged view over a collection whose elements are
    /// `Identifiable`. The id is derived automatically.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleAlignment: How to position the default title strip.
    ///   - indicatorStyle: Indicator visual treatment. Defaults to `.dots`.
    ///   - content: A view builder that produces the body for each page.
    init(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleAlignment: titleAlignment,
            indicatorStyle: indicatorStyle,
            content: content
        )
    }

    /// Creates an identifiable paged view with custom title and footer builders.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    init<TitleContent: View, FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleContent: titleContent,
            footerContent: footerContent,
            content: content
        )
    }

    /// Creates an identifiable paged view with a custom title builder.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - indicatorStyle: Indicator visual treatment. Defaults to `.dots`.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - content: A view builder that produces the body for each page.
    init<TitleContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            indicatorStyle: indicatorStyle,
            titleContent: titleContent,
            content: content
        )
    }

    /// Creates an identifiable paged view with a custom footer builder.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleAlignment: How to position the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    init<FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleAlignment: titleAlignment,
            footerContent: footerContent,
            content: content
        )
    }
}
