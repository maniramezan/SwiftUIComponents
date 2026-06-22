import DesignSystem
import SwiftUI

/// A value that can be displayed by `MenuPicker`.
public protocol MenuPickerItem: Hashable, Identifiable {
    /// The display title for the item.
    var title: String { get }
}

/// Adds a default title implementation for types whose `description` is already user-facing.
public extension MenuPickerItem where Self: CustomStringConvertible {
    /// Default title derived from `CustomStringConvertible`.
    var title: String { description }
}

/// A lightweight dropdown-like picker that keeps the trigger width in sync with the widest option and
/// works consistently across iOS, macOS, and Mac Catalyst.
///
/// ```swift
/// enum Flavor: String, CaseIterable, MenuPickerItem {
///     case vanilla, chocolate, strawberry
///     var id: String { rawValue }
///     var title: String { rawValue.capitalized }
/// }
///
/// @State private var flavor: Flavor = .vanilla
///
/// MenuPicker(items: Flavor.allCases, currentValue: $flavor)
/// ```
public struct MenuPicker<Item: MenuPickerItem>: View {

    // MARK: - Styling Constants

    fileprivate static var triggerBorderOpacity: CGFloat { 0.25 }
    private static var longListThreshold: Int { 30 }

    // MARK: - Items

    private let items: [Item]
    private let longestLabel: String

    // MARK: - Selection State

    @Binding private var currentValue: Item
    @State private var measuredWidth: CGFloat = 0
    @State private var isListPresented = false
    @Environment(\.designTheme) private var theme

    // MARK: - Callbacks

    private let onWidthChange: ((CGFloat) -> Void)?

    /// Initializes a `MenuPicker`.
    /// - Parameters:
    ///   - items: The items to display. Must be non-empty and must contain `currentValue`.
    ///   - currentValue: The currently selected item. Must exist in `items`.
    ///   - onWidthChange: Optional callback that receives the measured width so parents can react (e.g., switch layouts).
    public init(
        items: some RandomAccessCollection<Item>,
        currentValue: Binding<Item>,
        onWidthChange: ((CGFloat) -> Void)? = nil
    ) {
        let items = Array(items)
        precondition(!items.isEmpty, "MenuPicker requires at least one item.")
        precondition(
            items.contains(where: { $0.id == currentValue.wrappedValue.id }),
            "currentValue must exist in items."
        )
        self.items = items
        self._currentValue = currentValue
        self.longestLabel = Self.longestLabel(in: items)
        self.onWidthChange = onWidthChange
    }

    /// The SwiftUI body for the menu picker.
    public var body: some View {
        #if canImport(UIKit)
            let requiredWidth = measuredWidth > 0 ? measuredWidth : measureWidth(for: theme.typography.controlUIFont)
            if items.count > Self.longListThreshold {
                WheelMenuPicker(
                    items: items,
                    currentValue: $currentValue,
                    title: currentValue.title,
                    width: requiredWidth,
                    horizontalPadding: theme.spacing.oneAndHalfUnits,
                    verticalPadding: theme.spacing.oneUnit,
                    triggerFont: theme.typography.control,
                    isPresented: $isListPresented
                )
                .frame(width: requiredWidth, alignment: .center)
                .layoutPriority(1)
                .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
            } else {
                UIKitMenuPicker(
                    items: items,
                    currentValue: $currentValue,
                    longestLabel: longestLabel,
                    horizontalPadding: theme.spacing.oneAndHalfUnits,
                    verticalPadding: theme.spacing.oneUnit,
                    triggerFont: theme.typography.controlUIFont,
                    foregroundColor: theme.colors.textPrimary,
                    width: requiredWidth,
                    onSelection: { newValue in
                        currentValue = newValue
                    }
                )
                .frame(width: requiredWidth, alignment: .center)
                .layoutPriority(1)
                .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
            }
        #elseif canImport(AppKit)
            let requiredWidth = measuredWidth > 0 ? measuredWidth : measureWidth(for: theme.typography.controlNSFont)

            AppKitMenuPicker(
                items: items,
                currentValue: $currentValue,
                longestLabel: longestLabel,
                horizontalPadding: theme.spacing.oneAndHalfUnits,
                verticalPadding: theme.spacing.oneUnit,
                triggerFont: theme.typography.controlNSFont,
                width: requiredWidth,
                onSelection: { newValue in
                    currentValue = newValue
                }
            )
            .frame(width: requiredWidth, alignment: .leading)
            .onAppear {
                if measuredWidth == 0 {
                    handleWidthChange(requiredWidth)
                }
            }
            .layoutPriority(1)
            .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
        #else
            Picker(selection: selectedID) {
                ForEach(items) { item in
                    Text(item.title)
                        .font(theme.typography.control)
                        .tag(item.id)
                }
            } label: {
                ZStack(alignment: .leading) {
                    Text(longestLabel)
                        .font(theme.typography.control)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: LongestLabelWidthKey.self, value: proxy.size.width)
                            }
                        )
                        .hidden()
                    Text(currentValue.title)
                        .font(theme.typography.control)
                }
                .frame(minWidth: measuredWidth, alignment: .leading)
                .onPreferenceChange(LongestLabelWidthKey.self) { width in
                    handleWidthChange(width)
                }
            }
            .pickerStyle(.menu)
            .menuIndicator(.hidden)
            .frame(minWidth: measuredWidth, alignment: .leading)
            .layoutPriority(1)
            .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
        #endif
    }

}

// MARK: - Preview

#Preview {
    @Previewable @State var currentValue = 9
    PreviewContent { theme in
        MenuPicker(items: 9...17, currentValue: $currentValue)
            .padding(theme.spacing.twoUnits)
            .background(Color.pink)
    }
}

#if canImport(UIKit)
    import UIKit

    // MARK: - UIKit Bridge

    private struct UIKitMenuPicker<Item: MenuPickerItem>: UIViewRepresentable {
        let items: [Item]
        @Binding var currentValue: Item
        let longestLabel: String
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: UIFont
        let foregroundColor: Color
        let width: CGFloat
        let onSelection: (Item) -> Void

        func makeUIView(context: Context) -> UIButton {
            var initialConfig = UIButton.Configuration.plain()
            initialConfig.titleAlignment = .center
            let button = UIButton(configuration: initialConfig)
            button.showsMenuAsPrimaryAction = true
            let constraint = button.widthAnchor.constraint(equalToConstant: width)
            constraint.isActive = true
            context.coordinator.widthConstraint = constraint
            return button
        }

        func updateUIView(_ uiView: UIButton, context: Context) {
            uiView.configuration = makeConfiguration()
            uiView.menu = makeMenu()
            uiView.invalidateIntrinsicContentSize()
            context.coordinator.widthConstraint?.constant = width
            uiView.layoutIfNeeded()
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        private func makeConfiguration() -> UIButton.Configuration {
            var configuration = UIButton.Configuration.plain()
            configuration.title = currentValue.title
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: verticalPadding,
                leading: horizontalPadding,
                bottom: verticalPadding,
                trailing: horizontalPadding
            )
            configuration.baseForegroundColor = UIColor(foregroundColor)
            let font = triggerFont
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
            return configuration
        }

        private func makeMenu() -> UIMenu {
            let actions = items.map { item in
                UIAction(title: item.title, state: item.id == currentValue.id ? .on : .off) { _ in
                    onSelection(item)
                }
            }
            return UIMenu(children: actions)
        }

        final class Coordinator {
            var widthConstraint: NSLayoutConstraint?
        }

        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIButton, context: Context) -> CGSize? {
            let targetHeight = uiView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            return CGSize(width: width, height: targetHeight)
        }
    }

#endif

#if canImport(UIKit)
    // MARK: - Wheel Picker (compact sheet, for long lists)

    private struct WheelMenuPicker<Item: MenuPickerItem>: View {
        let items: [Item]
        @Binding var currentValue: Item
        let title: String
        let width: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: Font
        @Binding var isPresented: Bool

        var body: some View {
            Button(action: { isPresented = true }) {
                Text(title)
                    .font(triggerFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .frame(width: width, alignment: .center)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text(Strings.MenuPicker.changeSelectionHint))
            .sheet(isPresented: $isPresented) {
                Picker("", selection: $currentValue) {
                    ForEach(items) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.wheel)
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
            }
        }
    }

#endif

#if canImport(AppKit)
    import AppKit

    // MARK: - AppKit Bridge

    private struct AppKitMenuPicker<Item: MenuPickerItem>: NSViewRepresentable {
        let items: [Item]
        @Binding var currentValue: Item
        let longestLabel: String
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: NSFont
        let width: CGFloat
        let onSelection: (Item) -> Void

        func makeNSView(context: Context) -> NSPopUpButton {
            let button = NSPopUpButton(frame: .zero, pullsDown: false)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.target = context.coordinator
            button.action = #selector(Coordinator.selectionChanged(_:))
            let constraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
            constraint.isActive = true
            context.coordinator.widthConstraint = constraint
            return button
        }

        func updateNSView(_ view: NSPopUpButton, context: Context) {
            context.coordinator.items = items
            view.removeAllItems()
            for item in items {
                view.addItem(withTitle: item.title)
            }
            if let index = items.firstIndex(where: { $0.id == currentValue.id }) {
                view.selectItem(at: index)
            }
            view.font = triggerFont
            view.alignment = .center
            view.sizeToFit()
            context.coordinator.widthConstraint?.constant = width
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(onSelection: onSelection)
        }

        func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSPopUpButton, context: Context) -> CGSize? {
            let targetHeight = nsView.fittingSize.height
            return CGSize(width: width, height: targetHeight)
        }

        @MainActor
        final class Coordinator: NSObject {
            var onSelection: (Item) -> Void
            var items: [Item] = []
            var widthConstraint: NSLayoutConstraint?

            init(onSelection: @escaping (Item) -> Void) {
                self.onSelection = onSelection
            }

            @objc func selectionChanged(_ sender: NSPopUpButton) {
                let index = sender.indexOfSelectedItem
                guard index >= 0, index < items.count else { return }
                onSelection(items[index])
            }
        }

    }

#endif

extension Int: @retroactive Identifiable {
    /// Identifies the integer value for `Identifiable` conformance.
    public var id: Int { self }
}

/// Provides sample `MenuPickerItem` behavior for integer values.
extension Int: MenuPickerItem {
    /// A generated title used for preview and sample items.
    public var title: String {
        let length = (self % 8) + 3
        let prefix = String(repeating: "A", count: length)
        return "\(prefix) \(self)"
    }
}

// MARK: - State Helpers

private extension MenuPicker {
    func handleWidthChange(_ width: CGFloat) {
        guard width > 0 else { return }
        if measuredWidth != width {
            measuredWidth = width
            onWidthChange?(width)
        }
    }

    /// A binding over `Item.ID` used by the fallback SwiftUI `Picker`.
    var selectedID: Binding<Item.ID> {
        Binding(
            get: { currentValue.id },
            set: { newID in
                if let newItem = items.first(where: { $0.id == newID }) {
                    currentValue = newItem
                }
            }
        )
    }
}

// MARK: - Platform Measurement

#if canImport(UIKit)
    private extension MenuPicker {
        func measureWidth(for font: UIFont) -> CGFloat {
            let textWidth = (longestLabel as NSString).size(withAttributes: [.font: font]).width
            return textWidth + (theme.spacing.oneAndHalfUnits * 2) + theme.spacing.halfUnit
        }
    }
#elseif canImport(AppKit)
    private extension MenuPicker {
        func measureWidth(for font: NSFont) -> CGFloat {
            let textWidth = (longestLabel as NSString).size(withAttributes: [.font: font]).width
            return Self.appKitTriggerWidth(
                textWidth: textWidth,
                horizontalPadding: theme.spacing.oneAndHalfUnits,
                edgeInset: theme.spacing.halfUnit,
                popUpChrome: theme.spacing.threeUnits
            )
        }
    }
#endif

// MARK: - Preference Keys

private struct LongestLabelWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Helpers

extension MenuPicker {
    /// Determines the longest formatted label to stabilize layout width.
    nonisolated static func longestLabel(in items: [Item]) -> String {
        items
            .map(\.title)
            .max(by: { $0.count < $1.count }) ?? ""
    }

    /// Computes the fixed trigger width for the AppKit `NSPopUpButton` bridge.
    ///
    /// The popup hosts its title at a fixed `.frame(width:)`, so the width must account not only for
    /// the measured text and horizontal padding but also for the disclosure-arrow chrome the control
    /// always reserves on its trailing edge. Omitting `popUpChrome` squeezes the title region and
    /// clips short labels (a 4-digit year would render as "2…").
    nonisolated static func appKitTriggerWidth(
        textWidth: CGFloat,
        horizontalPadding: CGFloat,
        edgeInset: CGFloat,
        popUpChrome: CGFloat
    ) -> CGFloat {
        textWidth + (horizontalPadding * 2) + edgeInset + popUpChrome
    }
}
