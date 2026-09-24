import Components
import DesignSystem
import SwiftUI

/// Showcases ``ThemeProgressViewStyle`` with live controls for value, labels, tint,
/// and indeterminate mode.
struct ProgressDetailView: View {
    @State private var value = 0.4
    @State private var isIndeterminate = false
    @State private var showsLabel = true
    @State private var showsValueLabel = true
    @State private var usesSuccessTint = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable progress") {
                ProgressDetailBar(
                    value: isIndeterminate ? nil : value,
                    showsLabel: showsLabel,
                    showsValueLabel: showsValueLabel
                )
                .progressViewStyle(ThemeProgressViewStyle(tint: usesSuccessTint ? theme.colors.success : nil))
            }

            ShowcaseSection("Controls") {
                LabeledContent("Value") {
                    Slider(value: $value, in: 0...1)
                }
                .disabled(isIndeterminate)
                Toggle("Indeterminate", isOn: $isIndeterminate)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Label", isOn: $showsLabel)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Current value label", isOn: $showsValueLabel)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Success tint", isOn: $usesSuccessTint)
                    .toggleStyle(ThemeToggleStyle())
            }
        }
    }
}

/// A `ProgressView` whose labels are included or omitted per the showcase controls.
private struct ProgressDetailBar: View {
    let value: Double?
    let showsLabel: Bool
    let showsValueLabel: Bool

    var body: some View {
        if let value {
            ProgressView(value: value) {
                if showsLabel { Text("Uploading") }
            } currentValueLabel: {
                if showsValueLabel { Text(value, format: .percent.precision(.fractionLength(0))) }
            }
        } else {
            ProgressView {
                if showsLabel { Text("Preparing") }
            }
        }
    }
}

#Preview {
    ScrollView {
        ProgressDetailView()
            .padding()
    }
}
