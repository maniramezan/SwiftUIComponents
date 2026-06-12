import SwiftUI

/// Corner-radius tokens for consistent shape language.
public protocol Radius: Sendable {
    /// 8 pt radius for compact controls.
    var oneUnit: CGFloat { get }
    /// 12 pt radius for standard controls and cards.
    var oneAndHalfUnits: CGFloat { get }
    /// 16 pt radius for larger containers.
    var twoUnits: CGFloat { get }
    /// 24 pt radius for prominent sheets/cards.
    var threeUnits: CGFloat { get }
    /// Large radius intended for capsule-like shapes.
    var pill: CGFloat { get }
}

/// Default corner-radius tokens for shared components.
public struct DefaultRadius: Radius {
    /// 8 pt radius for compact controls.
    public let oneUnit: CGFloat
    /// 12 pt radius for standard controls and cards.
    public let oneAndHalfUnits: CGFloat
    /// 16 pt radius for larger containers.
    public let twoUnits: CGFloat
    /// 24 pt radius for prominent sheets/cards.
    public let threeUnits: CGFloat
    /// Large radius intended for capsule-like shapes.
    public let pill: CGFloat

    /// Creates a radius scale.
    public init(
        oneUnit: CGFloat = 8,
        oneAndHalfUnits: CGFloat = 12,
        twoUnits: CGFloat = 16,
        threeUnits: CGFloat = 24,
        pill: CGFloat = 999
    ) {
        self.oneUnit = oneUnit
        self.oneAndHalfUnits = oneAndHalfUnits
        self.twoUnits = twoUnits
        self.threeUnits = threeUnits
        self.pill = pill
    }
}
