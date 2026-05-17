import DesignSystem
import SwiftUI

struct PreviewContent<Content: View>: View {
    @Environment(\.designTheme) private var theme

    private let content: @MainActor (any Theme) -> Content

    init(@ViewBuilder content: @escaping @MainActor (any Theme) -> Content) {
        self.content = content
    }

    var body: some View {
        content(theme)
    }
}
