import Components
import DesignSystem
import SwiftUI

struct ContainersDetailView: View {
    @State private var isDisclosureExpanded = false
    @State private var showsLongDisclosureDetail = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Card") {
                Container(style: .card) {
                    Text("Card container content").frame(maxWidth: .infinity)
                }
            }

            ShowcaseSection("Elevated") {
                Container(style: .elevated) {
                    Text("Elevated container content").frame(maxWidth: .infinity)
                }
            }

            ShowcaseSection("Outlined") {
                Container(style: .outlined) {
                    Text("Outlined container content").frame(maxWidth: .infinity)
                }
            }

            ShowcaseSection("Disclosure Card") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    DisclosureCard(isExpanded: $isDisclosureExpanded) {
                        Text("Section title")
                    } detail: {
                        Text(
                            showsLongDisclosureDetail
                                ? "Additional information can span multiple lines to validate wrapping and dynamic height."
                                : "Additional information"
                        )
                    }

                    Toggle("Expanded", isOn: $isDisclosureExpanded)
                        .toggleStyle(ThemeToggleStyle())
                    Toggle("Long detail", isOn: $showsLongDisclosureDetail)
                        .toggleStyle(ThemeToggleStyle())
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ContainersDetailView()
            .padding()
    }
}
