import SwiftUI

#if canImport(UIKit)
    import UIKit

    // MARK: - UIKit Bridge

    /// `UIButton`-backed dropdown trigger used by ``MenuPicker`` on iOS and Mac Catalyst.
    struct UIKitMenuPicker<Item: MenuPickerItem>: UIViewRepresentable {
        let items: [Item]
        @Binding var currentValue: Item
        let longestLabel: String
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: UIFont
        let foregroundColor: Color
        let width: CGFloat
        let onSelection: (Item) -> Void

        func makeUIView(context: Context) -> UIButton {
            var initialConfig = UIButton.Configuration.plain()
            initialConfig.titleAlignment = .center
            let button = UIButton(configuration: initialConfig)
            button.showsMenuAsPrimaryAction = true
            let constraint = button.widthAnchor.constraint(equalToConstant: width)
            // One below `.required` so this can coexist with UIKit's own temporary/interim layout
            // constraints (e.g. `_UITemporaryLayoutWidth == 0`) while a hosting SwiftUI parent is
            // still negotiating sizes, instead of hard-conflicting and logging Auto Layout errors.
            constraint.priority = UILayoutPriority(999)
            constraint.isActive = true
            context.coordinator.widthConstraint = constraint
            return button
        }

        func updateUIView(_ uiView: UIButton, context: Context) {
            uiView.configuration = makeConfiguration()
            uiView.menu = makeMenu()
            uiView.invalidateIntrinsicContentSize()
            guard context.coordinator.widthConstraint?.constant != width else { return }
            context.coordinator.widthConstraint?.constant = width
            uiView.layoutIfNeeded()
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        private func makeConfiguration() -> UIButton.Configuration {
            var configuration = UIButton.Configuration.plain()
            configuration.title = currentValue.title
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: verticalPadding,
                leading: horizontalPadding,
                bottom: verticalPadding,
                trailing: horizontalPadding
            )
            configuration.baseForegroundColor = UIColor(foregroundColor)
            let font = triggerFont
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
            return configuration
        }

        private func makeMenu() -> UIMenu {
            let actions = items.map { item in
                UIAction(title: item.title, state: item.id == currentValue.id ? .on : .off) { _ in
                    onSelection(item)
                }
            }
            return UIMenu(children: actions)
        }

        final class Coordinator {
            var widthConstraint: NSLayoutConstraint?
        }

        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIButton, context: Context) -> CGSize? {
            let targetHeight = uiView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            return CGSize(width: width, height: targetHeight)
        }
    }

    // MARK: - Wheel Picker (compact sheet, for long lists)

    /// Compact wheel-sheet presentation used by ``MenuPicker`` for long lists on iOS.
    struct WheelMenuPicker<Item: MenuPickerItem>: View {
        let items: [Item]
        @Binding var currentValue: Item
        let title: String
        let width: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: Font
        @Binding var isPresented: Bool

        var body: some View {
            Button(action: { isPresented = true }) {
                Text(title)
                    .font(triggerFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .frame(width: width, alignment: .center)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text(Strings.MenuPicker.changeSelectionHint))
            .sheet(isPresented: $isPresented) {
                Picker("", selection: $currentValue) {
                    ForEach(items) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.wheel)
                // Tuned to comfortably fit a native wheel picker's fixed
                // row height plus its drag indicator; not a spacing/size
                // token value since it isn't a gap or a component metric.
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
            }
        }
    }

#endif
