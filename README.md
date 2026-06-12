# SwiftUIComponents

Themeable, cross-platform SwiftUI building blocks targeting **macOS 15**, **iOS 18**, and **Mac Catalyst 18**. The package ships three SwiftPM library products: `DesignSystem` (tokens), `Components` (reusable views and modifiers), and `ComponentShowcase` (example screens and internal previews).

## Libraries

| Library | Purpose |
|---|---|
| **DesignSystem** | Spacing, radius, stroke, motion, color, and typography token protocols with sensible defaults, including native-aligned segmented control colors. Inject a custom `Theme` to rebrand the entire component set. |
| **Components** | Production-ready views and modifiers built on `DesignSystem` — buttons, inputs, badges, cards, containers, chat UI, and feedback states. |
| **ComponentShowcase** | Internal showcase screens used to demonstrate and validate components in one place. Treat this as a demo/reference target, not a dependency for production app code. |

## Architecture

- `DesignSystem` owns tokens, default token implementations, and theme environment wiring.
- `Components` depends on `DesignSystem` and owns reusable production-facing views, modifiers, and helper protocols.
- `ComponentShowcase` depends on `Components` and `DesignSystem` and exists for demos, previews, and exploration only.
- Apply `.designTheme(...)` near the root of a hierarchy and let components read the active theme from `@Environment(\.designTheme)`.

## Installation

Add the package to your project via Xcode or `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/maniramezan/SwiftUIComponents.git", from: "0.1.0"),
]
```

Then add the libraries you need to your target. Most apps should depend on `DesignSystem` and `Components`, but not `ComponentShowcase`:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "DesignSystem", package: "SwiftUIComponents"),
        .product(name: "Components", package: "SwiftUIComponents"),
    ]
)
```

## Quick Start

```swift
import Components
import DesignSystem
import SwiftUI

struct ContentView: View {
    @State private var query = ""

    var body: some View {
        VStack {
            SearchBar(text: $query, placeholder: "Search components")
            ThemeButton("Submit", role: .primary) {
                // handle tap
            }
        }
        .designTheme(DefaultTheme())
    }
}
```

## Accessibility & Localization

Components ship with VoiceOver support built in — labels, traits, hidden decorative
elements, Reduce Motion handling, and adjustable/scroll actions on the paged and
segmented controls. The package localizes its **own** chrome (the dismiss button,
loading/typing announcements, error prefixes, paginator and clear-search labels)
through a String Catalog resolved from `Bundle.module`; currently only English (`en`)
is provided, and additional translations can be contributed to
`Sources/Components/Resources/Localizable.xcstrings`.

**Content you pass in is your responsibility to localize.** Strings such as a
`ThemeButton` title, a `SearchBar` placeholder, `SelectionNode` titles, or a
`ConfirmToolbarButton` accessibility label are rendered verbatim — pass already-localized
values (e.g. `String(localized:)`) so they read correctly in every language and to
VoiceOver.

## AI-Assisted Integration

When using Claude Code or another AI assistant to build with SwiftUIComponents, add a project-level `CLAUDE.md` so the AI understands the library's current API surface and package architecture. A ready-made snippet covering imports, theme setup, package layering, reusable component usage, and anti-patterns is available in [`docs/ai-integration.md`](docs/ai-integration.md).

## Build & Test

```bash
swift build -Xswiftc -warnings-as-errors   # compile with warnings as errors
swift test --parallel                        # run the test suite
swift test --enable-code-coverage            # generate coverage data
swift format lint --strict Sources Tests     # check formatting
```

## Documentation

DocC documentation is built and published automatically on every push to `main`. To build locally:

```bash
swift package generate-documentation --target DesignSystem --warnings-as-errors
swift package generate-documentation --target Components --warnings-as-errors
```

All public symbols must have `///` doc comments; CI enforces this via `--warnings-as-errors`.

## CI

GitHub Actions run fast validation on every PR and deeper documentation publishing on `main`:

- **CI** (`build.yml`) — format lint, build (warnings-as-errors), test, DocC validation, and coverage checks on every PR and push to `main`.
- **Documentation** (`docs.yml`) — on `main` pushes, renders component snapshots, builds DocC for both targets, and deploys to GitHub Pages.

PRs must keep changed executable source lines at or above 80% coverage. Pushes to
`main` also run the full source coverage baseline so the first public series does
not regress below the current package-wide test signal while new behavior is added.

## Contributing

Read [`AGENTS.md`](AGENTS.md) for coding standards, documentation requirements, testing expectations, and PR guidelines. Key rules:

- Every public symbol needs a `///` doc comment.
- Every change needs tests (`swift test`).
- Run `swift format --in-place Sources Tests` before committing.
- Warnings are treated as errors in CI.

## License

See [LICENSE](LICENSE) for details.
