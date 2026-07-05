/// A result builder that collects the shelves of a ``CarouselBoard``.
///
/// It supports the usual control flow inside the board closure — `if`,
/// `if/else`, `for` loops, and `switch` — so shelves can be included
/// conditionally or generated from a collection.
@resultBuilder
public enum CarouselShelfBuilder {

    /// Wraps a single shelf expression.
    public static func buildExpression(_ shelf: some CarouselShelfConvertible) -> [any CarouselShelfConvertible] {
        [shelf]
    }

    /// Passes through an already-collected array of shelves.
    public static func buildExpression(_ shelves: [any CarouselShelfConvertible]) -> [any CarouselShelfConvertible] {
        shelves
    }

    /// Concatenates the shelves declared in a block.
    public static func buildBlock(_ components: [any CarouselShelfConvertible]...) -> [any CarouselShelfConvertible] {
        components.flatMap { $0 }
    }

    /// Flattens the shelves produced by a `for` loop.
    public static func buildArray(_ components: [[any CarouselShelfConvertible]]) -> [any CarouselShelfConvertible] {
        components.flatMap { $0 }
    }

    /// Handles an `if` without an `else`.
    public static func buildOptional(_ component: [any CarouselShelfConvertible]?) -> [any CarouselShelfConvertible] {
        component ?? []
    }

    /// Handles the first branch of an `if/else` or `switch`.
    public static func buildEither(first component: [any CarouselShelfConvertible]) -> [any CarouselShelfConvertible] {
        component
    }

    /// Handles the second branch of an `if/else` or `switch`.
    public static func buildEither(second component: [any CarouselShelfConvertible]) -> [any CarouselShelfConvertible] {
        component
    }

    /// Supports `if #available(...)` limited-availability blocks.
    public static func buildLimitedAvailability(_ component: [any CarouselShelfConvertible])
        -> [any CarouselShelfConvertible]
    {
        component
    }
}
