import SwiftUI

/// Standard spacing scale based on a 4-point half-step and 8-point base unit.
public protocol DesignSpacing: Sendable {
    /// 4 pt spacing for tight inline gaps.
    var halfUnit: CGFloat { get }
    /// 8 pt spacing for compact item gaps.
    var oneUnit: CGFloat { get }
    /// 12 pt spacing for medium control padding.
    var oneAndHalfUnits: CGFloat { get }
    /// 16 pt spacing for standard content padding.
    var twoUnits: CGFloat { get }
    /// 20 pt spacing for roomy inline spacing.
    var twoAndHalfUnits: CGFloat { get }
    /// 24 pt spacing for section padding.
    var threeUnits: CGFloat { get }
    /// 32 pt spacing for large section breaks.
    var fourUnits: CGFloat { get }
    /// 40 pt spacing for extra-large section breaks.
    var fiveUnits: CGFloat { get }
    /// 48 pt spacing for maximum standard spacing.
    var sixUnits: CGFloat { get }
}

/// Default spacing tokens for shared components.
public struct DefaultDesignSpacing: DesignSpacing {
    public let halfUnit: CGFloat
    public let oneUnit: CGFloat
    public let oneAndHalfUnits: CGFloat
    public let twoUnits: CGFloat
    public let twoAndHalfUnits: CGFloat
    public let threeUnits: CGFloat
    public let fourUnits: CGFloat
    public let fiveUnits: CGFloat
    public let sixUnits: CGFloat

    /// Creates a spacing scale. Defaults follow a 4/8-point grid.
    public init(
        halfUnit: CGFloat = 4,
        oneUnit: CGFloat = 8,
        oneAndHalfUnits: CGFloat = 12,
        twoUnits: CGFloat = 16,
        twoAndHalfUnits: CGFloat = 20,
        threeUnits: CGFloat = 24,
        fourUnits: CGFloat = 32,
        fiveUnits: CGFloat = 40,
        sixUnits: CGFloat = 48
    ) {
        self.halfUnit = halfUnit
        self.oneUnit = oneUnit
        self.oneAndHalfUnits = oneAndHalfUnits
        self.twoUnits = twoUnits
        self.twoAndHalfUnits = twoAndHalfUnits
        self.threeUnits = threeUnits
        self.fourUnits = fourUnits
        self.fiveUnits = fiveUnits
        self.sixUnits = sixUnits
    }
}
