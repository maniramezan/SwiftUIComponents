import Components
import DesignSystem
import SwiftUI

/// Showcases ``AvatarView`` with live controls for the name, image, and size.
struct AvatarDetailView: View {
    @State private var name = "Ada Lovelace"
    @State private var showsImage = false
    @State private var size: AvatarView.Size = .large
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable avatar") {
                AvatarView(name: name, image: showsImage ? Image(systemName: "photo") : nil, size: size)

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                Toggle("Image", isOn: $showsImage)
                    .toggleStyle(ThemeToggleStyle())
                Picker("Size", selection: $size) {
                    ForEach(AvatarView.Size.allCases, id: \.self) { size in
                        Text(String(describing: size).capitalized).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }

            ShowcaseSection("Sizes") {
                HStack(spacing: theme.spacing.oneAndHalfUnits) {
                    ForEach(AvatarView.Size.allCases, id: \.self) { size in
                        AvatarView(name: "Grace Hopper", size: size)
                    }
                }
            }

            ShowcaseSection("Fallbacks") {
                HStack(spacing: theme.spacing.oneAndHalfUnits) {
                    AvatarView(name: "Cher")
                    AvatarView(name: "Jean-Luc Picard")
                    AvatarView(name: "")
                }
            }

            ShowcaseSection("In a row") {
                ListRow("Grace Hopper", subtitle: "Online") {
                    AvatarView(name: "Grace Hopper", size: .small)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        AvatarDetailView()
            .padding()
    }
}
