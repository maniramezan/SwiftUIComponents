import Components
import DesignSystem
import SwiftUI

struct OrbitingSphereDetailView: View {
    @Environment(\.designTheme) private var theme
    @State private var configuration = SphereOrbitConfiguration()
    @State private var motion = SphereOrbitMotion.paused
    @State private var appearance = ShowcaseSphereAppearance()
    @State private var count = 5
    @State private var selected = ""

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseOrbitPreview(count: count, appearance: appearance, isPaused: motion.isPaused, selected: $selected)
            ShowcaseOrbitPlacementControls(configuration: $configuration, count: $count)
            ShowcaseOrbitMotionControls(motion: $motion)
            ShowcaseOrbitTiltControls(title: "Pitch", tilt: $motion.pitch)
                .disabled(configuration.style != .spatial)
            ShowcaseOrbitTiltControls(title: "Roll", tilt: $motion.roll)
                .disabled(configuration.style != .spatial)
            ShowcaseSphereAppearanceControls(appearance: $appearance)
        }
        .sphereOrbitConfiguration(configuration)
        .sphereOrbitMotion(motion)
    }
}

private struct ShowcaseSphereAppearance {
    var canvasSize = 288.0
    var centerSize = 96.0
    var itemSize = 40.0
    var tint = Color.blue
    var centerLabel = "+"
}

private struct ShowcaseOrbitPreview: View {
    let count: Int
    let appearance: ShowcaseSphereAppearance
    let isPaused: Bool
    @Binding var selected: String
    @Environment(\.designTheme) private var theme

    var body: some View {
        ShowcaseSection("Interactive orbit") {
            OrbitingSphere((0..<count).map { SphereShowcaseItem(id: $0) }) {
                SphereView(diameter: appearance.centerSize, tint: appearance.tint) {
                    Text(appearance.centerLabel).font(theme.typography.title).foregroundStyle(theme.colors.onPrimary)
                }
            } satellite: { item in
                Button {
                    selected = item.label
                } label: {
                    SphereView(diameter: appearance.itemSize, tint: appearance.tint) {
                        Text(item.label).foregroundStyle(theme.colors.onPrimary)
                    }
                    .frame(minWidth: theme.motion.minimumHitTarget, minHeight: theme.motion.minimumHitTarget)
                }
                .buttonStyle(.plain)
                .disabled(!isPaused)
            }
            .frame(width: appearance.canvasSize, height: appearance.canvasSize)
            .frame(maxWidth: .infinity)
            Text(isPaused ? "Select an item" : "Pause motion to select an item")
            if !selected.isEmpty { Text("Selected: \(selected)") }
        }
    }
}

private struct ShowcaseOrbitPlacementControls: View {
    private static let customRadius = 86.0
    @Binding var configuration: SphereOrbitConfiguration
    @Binding var count: Int

    private var phase: Binding<Double> {
        Binding(get: { configuration.phase.degrees }, set: { configuration.phase = .degrees($0) })
    }

    private var automaticRadius: Binding<Bool> {
        Binding(
            get: { configuration.radius == nil },
            set: { configuration.radius = $0 ? nil : Self.customRadius }
        )
    }

    private var radius: Binding<Double> {
        Binding(
            get: { configuration.radius.map(Double.init) ?? Self.customRadius },
            set: { configuration.radius = CGFloat($0) }
        )
    }

    var body: some View {
        ShowcaseSection("Placement") {
            ShowcasePicker("Projection", selection: $configuration.style) {
                Text("Spatial").tag(SphereOrbitStyle.spatial)
                Text("Ring").tag(SphereOrbitStyle.ring)
            }
            Toggle("Show orbit", isOn: $configuration.showsOrbit).toggleStyle(ThemeToggleStyle())
            Stepper("Items: \(count)", value: $count, in: 0...10)
            LabeledContent("Starting angle") { Slider(value: phase, in: -180...180) }
            Toggle("Automatic radius", isOn: automaticRadius).toggleStyle(ThemeToggleStyle())
            LabeledContent("Orbit radius") { Slider(value: radius, in: 50...150) }
                .disabled(configuration.radius == nil)
        }
    }
}

private struct ShowcaseOrbitMotionControls: View {
    @Binding var motion: SphereOrbitMotion
    @Environment(\.designTheme) private var theme

    private var themeTiming: Binding<Bool> {
        Binding(
            get: { motion.revolutionDuration == nil },
            set: { motion.revolutionDuration = $0 ? nil : theme.motion.orbitalRevolutionDuration }
        )
    }

    private var duration: Binding<Double> {
        Binding(
            get: { motion.revolutionDuration ?? theme.motion.orbitalRevolutionDuration },
            set: { motion.revolutionDuration = $0 }
        )
    }

    var body: some View {
        ShowcaseSection("Motion") {
            Toggle("Pause motion", isOn: $motion.isPaused).toggleStyle(ThemeToggleStyle())
            Toggle("Animate item changes", isOn: $motion.animatesChanges).toggleStyle(ThemeToggleStyle())
            Toggle("Use theme timing", isOn: themeTiming).toggleStyle(ThemeToggleStyle())
            LabeledContent("Seconds per turn") { Slider(value: duration, in: 2...30) }
                .disabled(motion.revolutionDuration == nil)
        }
    }
}

private struct ShowcaseSphereAppearanceControls: View {
    @Binding var appearance: ShowcaseSphereAppearance

    var body: some View {
        ShowcaseSection("Size and appearance") {
            LabeledContent("Canvas") { Slider(value: $appearance.canvasSize, in: 200...400) }
            LabeledContent("Center diameter") { Slider(value: $appearance.centerSize, in: 44...180) }
            LabeledContent("Item diameter") { Slider(value: $appearance.itemSize, in: 24...64) }
            ColorPicker("Sphere color", selection: $appearance.tint)
            ShowcaseTextField("Center label", text: $appearance.centerLabel)
        }
    }
}

private struct ShowcaseOrbitTiltSettings {
    var center: Double
    var amplitude: Double
    var cycleDuration: Double
    var followsRevolution: Bool

    init(tilt: SphereOrbitTilt, fallbackCycleDuration: Double) {
        center = tilt.center.degrees
        amplitude = tilt.amplitude.degrees
        cycleDuration = tilt.cycleDuration ?? fallbackCycleDuration
        followsRevolution = tilt.cycleDuration == nil
    }

    var configuration: SphereOrbitTilt {
        SphereOrbitTilt(
            center: .degrees(center), amplitude: .degrees(amplitude),
            cycleDuration: followsRevolution ? nil : cycleDuration
        )
    }
}

private struct ShowcaseOrbitTiltControls: View {
    private static let customCycleDuration = 30.0
    let title: String
    @Binding var tilt: SphereOrbitTilt

    private var settings: Binding<ShowcaseOrbitTiltSettings> {
        Binding(
            get: { ShowcaseOrbitTiltSettings(tilt: tilt, fallbackCycleDuration: Self.customCycleDuration) },
            set: { tilt = $0.configuration }
        )
    }

    var body: some View {
        let settings = self.settings
        ShowcaseSection(title) {
            LabeledContent("Center: \(settings.wrappedValue.center.formatted(.number.precision(.fractionLength(1))))°")
            {
                Slider(value: settings.center, in: -180...180)
            }
            LabeledContent(
                "Maximum deviation: \(settings.wrappedValue.amplitude.formatted(.number.precision(.fractionLength(1))))°"
            ) {
                Slider(value: settings.amplitude, in: 0...180)
            }
            Toggle("Follow revolution timing", isOn: settings.followsRevolution)
                .toggleStyle(ThemeToggleStyle())
            if !settings.wrappedValue.followsRevolution {
                LabeledContent(
                    "Cycle: \(settings.wrappedValue.cycleDuration.formatted(.number.precision(.fractionLength(1)))) seconds"
                ) {
                    Slider(value: settings.cycleDuration, in: 2...120)
                }
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
