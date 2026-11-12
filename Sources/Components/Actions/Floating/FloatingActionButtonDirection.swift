import SwiftUI

/// The direction in which a floating action button reveals its actions.
public enum FloatingActionButtonDirection: Sendable, Hashable, CaseIterable {
    /// Reveals actions above the trigger, with the first item nearest the trigger.
    case up
    /// Reveals actions below the trigger, with the first item nearest the trigger.
    case down
    /// Reveals actions toward the leading edge, mirroring in right-to-left layouts.
    case leading
    /// Reveals actions toward the trailing edge, mirroring in right-to-left layouts.
    case trailing

    var isHorizontal: Bool { self == .leading || self == .trailing }

    var reversesItems: Bool { self == .up || self == .leading }

    var scrollAnchor: UnitPoint {
        switch self {
        case .up: .bottomTrailing
        case .down: .topTrailing
        case .leading: .trailing
        case .trailing: .leading
        }
    }

}
