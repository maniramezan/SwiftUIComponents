import DesignSystem
import OSLog
import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

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

    nonisolated private static var longListThreshold: Int { 30 }

    nonisolated private static var logger: Logger {
        Logger(subsystem: "com.swiftuicomponents", category: "MenuPicker")
    }

    /// Controls which presentation `MenuPicker` uses on iOS.
    public enum PresentationStyle: Sendable {
        /// Uses a native dropdown menu for short lists and falls back to a compact wheel sheet
        /// once the list exceeds an internal item-count threshold.
        case automatic
        /// Always uses the native dropdown menu, regardless of item count. Prefer this when a
        /// picker must visually and behaviorally match a sibling `MenuPicker` (e.g. a month and
        /// year picker shown side by side) so one doesn't silently diverge into a different
        /// presentation once its list happens to cross the automatic threshold.
        case menu
    }

    // MARK: - Items

    private let items: [Item]
    private let longestLabel: String
    private let preferredStyle: PresentationStyle

    // MARK: - Selection State

    @Binding private var currentValue: Item
    @State private var measuredWidth: CGFloat = 0
    @State private var isListPresented = false
    @Environment(\.designTheme) private var theme
    /// Read so a Dynamic Type change re-evaluates `body` and re-measures the
    /// trigger against the rescaled control font.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Callbacks

    private let onWidthChange: ((CGFloat) -> Void)?

    /// Initializes a `MenuPicker`.
    /// - Parameters:
    ///   - items: The items to display. Should be non-empty and contain `currentValue`; otherwise the
    ///     picker logs a fault and still shows `currentValue` as its title, with no option checked.
    ///   - currentValue: The currently selected item. Should exist in `items`.
    ///   - preferredStyle: Which iOS presentation to use. Defaults to `.automatic`.
    ///   - onWidthChange: Optional callback that receives the measured width so parents can react (e.g., switch layouts).
    public init(
        items: some RandomAccessCollection<Item>,
        currentValue: Binding<Item>,
        preferredStyle: PresentationStyle = .automatic,
        onWidthChange: ((CGFloat) -> Void)? = nil
    ) {
        let items = Array(items)
        if items.isEmpty {
            Self.logger.fault("MenuPicker received no items; showing currentValue with an empty menu.")
        } else if !items.contains(where: { $0.id == currentValue.wrappedValue.id }) {
            Self.logger.fault(
                "MenuPicker currentValue is not among its \(items.count, privacy: .public) items; no option is checked."
            )
        }
        self.items = items
        self._currentValue = currentValue
        // Include the current value so the trigger never clips it, even when it is missing from `items`.
        self.longestLabel = Self.longestLabel(in: items + [currentValue.wrappedValue])
        self.preferredStyle = preferredStyle
        self.onWidthChange = onWidthChange
    }

    /// The SwiftUI body for the menu picker.
    public var body: some View {
        #if canImport(UIKit)
            // Measured on every evaluation (a single string measurement) rather than cached, so a
            // change to `items`, the theme's control font, or Dynamic Type re-sizes the trigger.
            let requiredWidth = measureWidth(for: theme.typography.controlUIFont)
            Group {
                if Self.usesWheelSheet(for: preferredStyle, itemCount: items.count) {
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
                }
            }
            .frame(width: requiredWidth, alignment: .center)
            .layoutPriority(1)
            .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
            .onChange(of: requiredWidth, initial: true) { _, newWidth in
                handleWidthChange(newWidth)
            }
        #elseif canImport(AppKit)
            let requiredWidth = measureWidth(for: theme.typography.controlNSFont)

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
            .layoutPriority(1)
            .accessibilityLabel(Text(Strings.MenuPicker.selectedOption(currentValue.title)))
            .onChange(of: requiredWidth, initial: true) { _, newWidth in
                handleWidthChange(newWidth)
            }
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

// MARK: - State Helpers

private extension MenuPicker {
    /// Records a newly measured trigger width and forwards it to `onWidthChange`, ignoring
    /// zero widths and repeats so the callback fires once per real change.
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

    /// Determines whether the iOS picker should use its compact wheel sheet.
    nonisolated static func usesWheelSheet(
        for style: PresentationStyle,
        itemCount: Int
    ) -> Bool {
        style == .automatic && itemCount > longListThreshold
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

// MARK: - Preview

/// Sample item for the preview. Deliberately not an `Int` conformance: a public
/// retroactive `Int: MenuPickerItem` would leak into every consumer module.
private struct PreviewHour: MenuPickerItem {
    let id: Int
    var title: String { "\(id):00" }
}

#Preview {
    @Previewable @State var currentValue = PreviewHour(id: 9)
    PreviewContent { theme in
        MenuPicker(items: (9...17).map { PreviewHour(id: $0) }, currentValue: $currentValue)
            .padding(theme.spacing.twoUnits)
            .background(Color.pink)
    }
}
