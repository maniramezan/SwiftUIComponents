import SwiftUI

public extension EmptyStateView where Action == EmptyView {
    /// Creates an empty state view without an action.
    init(title: String, message: String? = nil, systemImage: String? = nil) {
        self.init(title: title, message: message, systemImage: systemImage) {
            EmptyView()
        }
    }
}
