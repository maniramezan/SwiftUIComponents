# SwiftUIComponents

Themeable, cross-platform SwiftUI building blocks targeting **macOS 15**, **iOS 18**, and **Mac Catalyst 18**. The package ships three SwiftPM library products: `DesignSystem` (tokens), `Components` (reusable views and modifiers), and `ComponentShowcase` (example screens and internal previews).

## Libraries

| Library | Purpose |
|---|---|
| **DesignSystem** | Spacing, radius, stroke, motion, color, and typography token protocols with sensible defaults. Inject a custom `Theme` to rebrand the entire component set. |
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
    .package(url: "https://github.com/<org>/SwiftUIComponents.git", from: "1.0.0"),
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

## AI-Assisted Integration

When using Claude Code or another AI assistant to build with SwiftUIComponents, add a project-level `CLAUDE.md` so the AI understands the library's current API surface and package architecture. A ready-made snippet covering imports, theme setup, package layering, reusable component usage, and anti-patterns is available in [`docs/ai-integration.md`](docs/ai-integration.md).

## Build & Test

```bash
swift build -Xswiftc -warnings-as-errors   # compile with warnings as errors
swift test --parallel                        # run the test suite
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

Two GitHub Actions workflows run on every PR and push to `main`:

- **CI** (`build.yml`) — format lint, build (warnings-as-errors), test, and DocC validation.
- **Documentation** (`docs.yml`) — builds DocC for both targets; on `main` pushes, deploys to GitHub Pages.

## Contributing

Read [`AGENTS.md`](AGENTS.md) for coding standards, documentation requirements, testing expectations, and PR guidelines. Key rules:

- Every public symbol needs a `///` doc comment.
- Every change needs tests (`swift test`).
- Run `swift format --in-place Sources Tests` before committing.
- Warnings are treated as errors in CI.

## License

See [LICENSE](LICENSE) for details.
