import SwiftUI

#if canImport(AppKit)
    import AppKit

    // MARK: - AppKit Bridge

    /// `NSPopUpButton`-backed trigger used by ``MenuPicker`` on macOS.
    struct AppKitMenuPicker<Item: MenuPickerItem>: NSViewRepresentable {
        let items: [Item]
        @Binding var currentValue: Item
        let longestLabel: String
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let triggerFont: NSFont
        let width: CGFloat
        let onSelection: (Item) -> Void

        func makeNSView(context: Context) -> NSPopUpButton {
            let button = NSPopUpButton(frame: .zero, pullsDown: false)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.alignment = .center
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.target = context.coordinator
            button.action = #selector(Coordinator.selectionChanged(_:))
            let constraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
            constraint.isActive = true
            context.coordinator.widthConstraint = constraint
            return button
        }

        func updateNSView(_ view: NSPopUpButton, context: Context) {
            context.coordinator.items = items
            view.removeAllItems()
            var selectedIndex: Int?
            for (index, item) in items.enumerated() {
                view.addItem(withTitle: item.title)
                if selectedIndex == nil, item.id == currentValue.id {
                    selectedIndex = index
                }
            }
            if let selectedIndex {
                view.selectItem(at: selectedIndex)
            }
            view.font = triggerFont
            view.sizeToFit()
            context.coordinator.widthConstraint?.constant = width
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(onSelection: onSelection)
        }

        func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSPopUpButton, context: Context) -> CGSize? {
            let targetHeight = nsView.fittingSize.height
            return CGSize(width: width, height: targetHeight)
        }

        @MainActor
        final class Coordinator: NSObject {
            var onSelection: (Item) -> Void
            var items: [Item] = []
            var widthConstraint: NSLayoutConstraint?

            init(onSelection: @escaping (Item) -> Void) {
                self.onSelection = onSelection
            }

            @objc func selectionChanged(_ sender: NSPopUpButton) {
                let index = sender.indexOfSelectedItem
                guard index >= 0, index < items.count else { return }
                onSelection(items[index])
            }
        }

    }

#endif
