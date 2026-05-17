import DesignSystem
import SwiftUI

struct DesignPreviewContent<Content: View>: View {
    @Environment(\.designTheme) private var theme

    private let content: @MainActor (any DesignTheme) -> Content

    init(@ViewBuilder content: @escaping @MainActor (any DesignTheme) -> Content) {
        self.content = content
    }

    var body: some View {
        content(theme)
    }
}
