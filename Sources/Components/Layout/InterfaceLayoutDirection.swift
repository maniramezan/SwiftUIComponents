import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

extension View {
    /// Lays out this hierarchy in `direction`, rebuilding it whenever the direction changes.
    ///
    /// Overriding `\.layoutDirection` at runtime is not enough on its own. Platform-backed content,
    /// such as the cells of a `List` or `Form` inside a `NavigationStack`, keeps rendering state
    /// from the previous direction: after a switch from right-to-left back to left-to-right its
    /// glyphs render reversed and its accessories land on the wrong edge, and rebuilding just the
    /// list does not clear it. This modifier gives the hierarchy a fresh identity for each
    /// direction, so it is laid out the way a cold launch would lay it out. It also writes the
    /// direction into the window scene's layout-direction trait, so UIKit views and presented
    /// sheets agree with SwiftUI.
    ///
    /// Apply it once, at the root of a scene's content, for an app that lets people switch its
    /// interface language between a left-to-right and a right-to-left one without relaunching:
    ///
    /// ```swift
    /// WindowGroup {
    ///     RootView()
    ///         .interfaceLayoutDirection(isRightToLeft ? .rightToLeft : .leftToRight)
    /// }
    /// ```
    ///
    /// - Important: A direction change discards view-local state inside the modified view,
    ///   including `@State`, scroll positions and the paths of `NavigationStack`s that don't
    ///   bind one. Keep any state that must survive the switch, such as the navigation path
    ///   leading to the screen where the language is chosen, outside the modified view.
    public func interfaceLayoutDirection(_ direction: LayoutDirection) -> some View {
        modifier(InterfaceLayoutDirection(direction: direction))
    }
}

/// Sets the SwiftUI layout direction and mirrors it into the window scene's UIKit traits.
struct InterfaceLayoutDirection: ViewModifier {
    let direction: LayoutDirection

    func body(content: Content) -> some View {
        #if canImport(UIKit) && !os(watchOS)
            content
                .id(direction)
                .environment(\.layoutDirection, direction)
                .background {
                    SceneLayoutDirectionBridge(direction: direction)
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
        #else
            content
                .id(direction)
                .environment(\.layoutDirection, direction)
        #endif
    }
}

#if canImport(UIKit) && !os(watchOS)
    /// A zero-size view that writes the layout direction into its window scene's trait overrides.
    private struct SceneLayoutDirectionBridge: UIViewRepresentable {
        let direction: LayoutDirection

        func makeUIView(context: Context) -> SceneLayoutDirectionView {
            let view = SceneLayoutDirectionView()
            view.direction = UITraitEnvironmentLayoutDirection(direction)
            return view
        }

        func updateUIView(_ uiView: SceneLayoutDirectionView, context: Context) {
            uiView.direction = UITraitEnvironmentLayoutDirection(direction)
        }
    }

    /// Applies ``direction`` to the window scene as soon as the view is in a window, and again on
    /// every change.
    final class SceneLayoutDirectionView: UIView {
        var direction: UITraitEnvironmentLayoutDirection = .unspecified {
            didSet {
                guard direction != oldValue else { return }
                applyDirection()
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            applyDirection()
        }

        private func applyDirection() {
            guard direction != .unspecified, let scene = window?.windowScene else { return }
            // Reading a trait override that was never set raises an assertion, so check first.
            let overrides = scene.traitOverrides
            if overrides.contains(UITraitLayoutDirection.self), overrides.layoutDirection == direction {
                return
            }
            scene.traitOverrides.layoutDirection = direction
        }
    }
#endif
