import Components
import DesignSystem
import SwiftUI

private enum DemoAction: String, CaseIterable, Identifiable {
    case translate, explain, examples, grammar
    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
    var systemImage: String {
        switch self {
        case .translate: "character.book.closed"
        case .explain: "lightbulb"
        case .examples: "list.bullet"
        case .grammar: "textformat.abc"
        }
    }
}

struct AssistantQuickActionsDetailView: View {
    @State private var actionStates: [DemoAction: AssistantQuickActionState] = [
        .translate: .used,
        .explain: .available,
        .examples: .disabled,
        .grammar: .hidden,
    ]
    @State private var isInteractionEnabled = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Quick action chips") {
                AssistantQuickActionChipRow<DemoAction>(
                    actions: DemoAction.allCases,
                    isInteractionEnabled: isInteractionEnabled,
                    state: { actionStates[$0] ?? .available },
                    label: { $0.displayName },
                    systemImage: { $0.systemImage },
                    onSelect: { actionStates[$0] = .used }
                )
            }

            ShowcaseSection("Text-only chips") {
                AssistantQuickActionChipRow<DemoAction>(
                    actions: DemoAction.allCases,
                    isInteractionEnabled: true,
                    label: { $0.displayName },
                    onSelect: { _ in }
                )
            }

            ShowcaseSection("Controls") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Toggle("Interaction enabled", isOn: $isInteractionEnabled)
                        .toggleStyle(ThemeToggleStyle())
                    Button("Renew all actions") {
                        actionStates = Dictionary(
                            uniqueKeysWithValues: DemoAction.allCases.map { ($0, .available) }
                        )
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        AssistantQuickActionsDetailView()
            .padding()
    }
}
