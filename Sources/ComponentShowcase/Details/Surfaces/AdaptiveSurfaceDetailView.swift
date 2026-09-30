import Components
import DesignSystem
import SwiftUI

struct AdaptiveSurfaceDetailView: View {
    @Environment(\.designTheme) private var theme
    @State private var shape: AdaptiveSurfaceShape = .roundedRectangle
    @State private var interactive = false
    @State private var tinted = false
    @State private var bordered = false
    @State private var customRadius = false
    @State private var hairlineBorder = false

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Appearance") {
                Picker("Shape", selection: $shape) {
                    ForEach(AdaptiveSurfaceShape.allCases, id: \.self) { shape in
                        Text(shape.rawValue).tag(shape)
                    }
                }
                Toggle("Interactive glass", isOn: $interactive)
                Toggle("Tint glass", isOn: $tinted)
                Toggle("Fallback border", isOn: $bordered)
                Toggle("Hairline border", isOn: $hairlineBorder)
                Toggle("Custom corner radius", isOn: $customRadius)
            }
            ShowcaseSection("Surface") {
                Text("Sample")
                    .padding(theme.spacing.threeUnits)
                    .designAdaptiveSurface(
                        tint: tinted ? theme.colors.primary : nil,
                        interactive: interactive,
                        cornerRadius: customRadius ? theme.radius.oneUnit : nil,
                        shape: shape,
                        fallbackBorderColor: bordered ? theme.colors.textPrimary : nil,
                        fallbackBorderWidth: hairlineBorder ? theme.stroke.hairline : nil
                    )
            }
        }
    }
}

#Preview {
    ScrollView {
        AdaptiveSurfaceDetailView()
            .padding()
    }
}
