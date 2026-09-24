import Components
import DesignSystem
import SwiftUI

/// Showcases ``ListRow`` with live controls for every parameter and accessory kind.
struct ListRowDetailView: View {

    fileprivate enum AccessoryKind: String, CaseIterable, Identifiable {
        case none = "None"
        case value = "Value"
        case badge = "Badge"
        case toggle = "Toggle"
        case chevron = "Chevron"

        var id: String { rawValue }
    }

    @State private var title = "Storage"
    @State private var showsSubtitle = true
    @State private var subtitle = "12 items"
    @State private var showsIcon = true
    @State private var usesCustomTint = false
    @State private var accessory: AccessoryKind = .value
    @State private var isOn = true
    @State private var tapCount = 0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable row") {
                if accessory == .toggle {
                    ListRow(
                        title,
                        subtitle: showsSubtitle ? subtitle : nil,
                        systemImage: showsIcon ? "internaldrive" : nil,
                        iconTint: usesCustomTint ? theme.colors.warning : nil
                    ) {
                        ListRowDetailAccessory(kind: accessory, isOn: $isOn)
                    }
                    .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                    .designCardSurface()
                } else {
                    Button {
                        tapCount += 1
                    } label: {
                        ListRow(
                            title,
                            subtitle: showsSubtitle ? subtitle : nil,
                            systemImage: showsIcon ? "internaldrive" : nil,
                            iconTint: usesCustomTint ? theme.colors.warning : nil
                        ) {
                            ListRowDetailAccessory(kind: accessory, isOn: $isOn)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                    .designCardSurface()
                }

                Text("Row taps: \(tapCount)")
                    .designTextStyle(.caption)
            }

            ShowcaseSection("Controls") {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                Toggle("Subtitle", isOn: $showsSubtitle)
                    .toggleStyle(ThemeToggleStyle())
                if showsSubtitle {
                    TextField("Subtitle", text: $subtitle)
                        .textFieldStyle(.roundedBorder)
                }
                Toggle("Leading icon", isOn: $showsIcon)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Custom icon tint", isOn: $usesCustomTint)
                    .toggleStyle(ThemeToggleStyle())
                    .disabled(!showsIcon)
                Picker("Accessory", selection: $accessory) {
                    ForEach(AccessoryKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
            }

            ShowcaseSection("In a list") {
                VStack(spacing: 0) {
                    ListRow("Notifications", systemImage: "bell") {
                        Toggle("Notifications", isOn: $isOn).labelsHidden()
                    }
                    Divider()
                    ListRow("Version", systemImage: "info.circle") {
                        Text("2.4.1")
                    }
                    Divider()
                    ListRow("Status", subtitle: "Updated today", systemImage: "checkmark.seal") {
                        Badge("New", isProminent: true)
                    }
                }
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .designCardSurface()
            }
        }
    }
}

/// The trailing accessory selected in the ``ListRowDetailView`` controls.
private struct ListRowDetailAccessory: View {
    let kind: ListRowDetailView.AccessoryKind
    @Binding var isOn: Bool

    var body: some View {
        switch kind {
        case .none:
            EmptyView()
        case .value:
            Text("1.2 GB")
        case .badge:
            Badge("Beta")
        case .toggle:
            Toggle("Enabled", isOn: $isOn).labelsHidden()
        case .chevron:
            Image(systemName: "chevron.forward")
        }
    }
}

#Preview {
    ScrollView {
        ListRowDetailView()
            .padding()
    }
}
