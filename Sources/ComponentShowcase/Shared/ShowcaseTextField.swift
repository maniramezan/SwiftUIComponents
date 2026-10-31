import DesignSystem
import SwiftUI

/// A captioned, bordered text field for showcase playground controls.
///
/// A plain `TextField` inside a showcase card renders as bare text, so a control's
/// purpose and editability are unclear once it holds a value. This shows the
/// title as a caption above a rounded-border field. The caption is hidden from
/// assistive technology because the field carries the same title as its explicit accessibility label.
struct ShowcaseTextField: View {

    let title: String
    @Binding var text: String
    @Environment(\.designTheme) private var theme

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            Text(title)
                .designTextStyle(.secondary)
                .accessibilityHidden(true)
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel(title)
        }
    }
}

#Preview {
    @Previewable @State var text = "Sample"
    ShowcaseTextField("Title", text: $text)
        .padding()
}
