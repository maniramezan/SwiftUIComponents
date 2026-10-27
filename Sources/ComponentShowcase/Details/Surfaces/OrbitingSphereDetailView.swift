import Components
import DesignSystem
import SwiftUI

struct OrbitingSphereDetailView: View {
    @Environment(\.designTheme) private var theme
    @State private var style = SphereOrbitStyle.spatial
    @State private var count = 5
    @State private var isAnimating = true
    @State private var showsOrbit = true
    @State private var size = 288.0
    @State private var radius = 86.0
    @State private var centerSize = 96.0
    @State private var itemSize = 40.0
    @State private var duration = 12.0
    @State private var phase = -90.0
    @State private var tint = Color.blue
    @State private var centerLabel = "+"
    @State private var selected = ""

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Interactive orbit") {
                OrbitingSphere(
                    (0..<count).map { SphereShowcaseItem(id: $0) },
                    style: style, size: size, radius: radius, isAnimating: isAnimating,
                    revolutionDuration: duration, phase: .degrees(phase), showsOrbit: showsOrbit
                ) {
                    SphereView(diameter: centerSize, tint: tint) {
                        Text(centerLabel).font(theme.typography.title).foregroundStyle(theme.colors.onPrimary)
                    }
                } satellite: { item in
                    Button {
                        selected = item.label
                        isAnimating = false
                    } label: {
                        SphereView(diameter: itemSize, tint: tint) {
                            Text(item.label).foregroundStyle(theme.colors.onPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                Text(selected.isEmpty ? "Select an item to pause" : "Selected: \(selected)")
            }
            ShowcaseSection("Motion and projection") {
                Picker("Projection", selection: $style) {
                    Text("Spatial").tag(SphereOrbitStyle.spatial)
                    Text("Ring").tag(SphereOrbitStyle.ring)
                }
                Toggle("Animate", isOn: $isAnimating).toggleStyle(ThemeToggleStyle())
                Toggle("Show orbit", isOn: $showsOrbit).toggleStyle(ThemeToggleStyle())
                Stepper("Items: \(count)", value: $count, in: 0...10)
                LabeledContent("Seconds per turn") { Slider(value: $duration, in: 2...30) }
                LabeledContent("Starting angle") { Slider(value: $phase, in: -180...180) }
            }
            ShowcaseSection("Size and appearance") {
                LabeledContent("Canvas") { Slider(value: $size, in: 200...400) }
                LabeledContent("Orbit radius") { Slider(value: $radius, in: 50...150) }
                LabeledContent("Center diameter") { Slider(value: $centerSize, in: 44...180) }
                LabeledContent("Item diameter") { Slider(value: $itemSize, in: 24...64) }
                ColorPicker("Sphere color", selection: $tint)
                TextField("Center label", text: $centerLabel)
            }
        }
    }
}

private struct SphereShowcaseItem: Identifiable {
    let id: Int
    var label: String { String(id + 1) }
}

#Preview {
    ScrollView { OrbitingSphereDetailView().padding() }
}
