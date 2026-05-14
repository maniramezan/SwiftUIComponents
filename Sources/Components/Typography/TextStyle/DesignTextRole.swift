/// Semantic text roles for reusable components.
public enum DesignTextRole: Sendable {
    /// Primary title text used for screen or section headings.
    case title
    /// Emphasized label text used for navigation items and key labels.
    case headline
    /// Standard body text for primary readable content.
    case body
    /// De-emphasized text for supplementary or secondary information.
    case secondary
    /// Small text for metadata, timestamps, and annotations.
    case caption
    /// Text styled to indicate an error or validation failure.
    case error
}
