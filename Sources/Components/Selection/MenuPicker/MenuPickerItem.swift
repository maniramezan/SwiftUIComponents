/// A value that can be displayed by ``MenuPicker`` and ``SegmentedPicker``.
///
/// Conform your own model or enum; the package deliberately ships no
/// conformances for standard-library types.
///
/// ```swift
/// enum Flavor: String, CaseIterable, MenuPickerItem {
///     case vanilla, chocolate
///     var id: String { rawValue }
///     var title: String { rawValue.capitalized }
/// }
/// ```
public protocol MenuPickerItem: Hashable, Identifiable {
    /// The display title for the item.
    var title: String { get }
}

/// Adds a default title implementation for types whose `description` is already user-facing.
public extension MenuPickerItem where Self: CustomStringConvertible {
    /// Default title derived from `CustomStringConvertible`.
    var title: String { description }
}
