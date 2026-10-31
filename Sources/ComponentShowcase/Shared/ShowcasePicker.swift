import DesignSystem
import SwiftUI

/// A captioned picker for showcase playground controls.
///
/// A plain `Picker` inside a showcase card is not in a `Form`, so SwiftUI draws only
/// its selected value and the control's purpose is lost. This shows the title as a
/// caption above the picker. The caption is hidden from assistive technology because
/// the picker keeps its title as its accessibility label, and the picker spans the
/// full width so it left-aligns inside centered stacks. Apply `pickerStyle(_:)`
/// to the picker as usual; it flows through to the wrapped `Picker`.
struct ShowcasePicker<SelectionValue: Hashable, Content: View>: View {

    let title: String
    @Binding var selection: SelectionValue
    let content: Content
    @Environment(\.designTheme) private var theme

    init(
        _ title: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            Text(title)
                .designTextStyle(.secondary)
                .accessibilityHidden(true)
            Picker(title, selection: $selection) { content }
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var value = 1
    ShowcasePicker("Role", selection: $value) {
        Text("One").tag(1)
        Text("Two").tag(2)
    }
    .padding()
}
