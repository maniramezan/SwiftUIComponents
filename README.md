# SwiftUIComponents

Themeable, cross-platform SwiftUI building blocks targeting **macOS 15**, **iOS 18**, and **Mac Catalyst 18**. The package ships two libraries — `DesignSystem` (tokens) and `Components` (views) — that can be adopted independently through Swift Package Manager.

## Libraries

| Library | Purpose |
|---|---|
| **DesignSystem** | Spacing, radius, stroke, motion, color, and typography token protocols with sensible defaults. Inject a custom `DesignTheme` to rebrand the entire component set. |
| **Components** | Production-ready views and modifiers — buttons, inputs, badges, cards, containers, and feedback states — that adapt automatically to the active theme. |

## Installation

Add the package to your project via Xcode or `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/SwiftUIComponents.git", from: "1.0.0"),
]
```

Then add the libraries you need to your target:

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
            DesignSearchBar(text: $query, prompt: "Search…")
            DesignButton("Submit", role: .primary) {
                // handle tap
            }
        }
        .designTheme(DefaultDesignTheme())
    }
}
```

## AI-Assisted Integration

When using Claude Code or another AI assistant to build with SwiftUIComponents, add a project-level CLAUDE.md so the AI understands the library's API surface. A ready-made snippet — covering imports, theme setup, all components, common patterns, and anti-patterns — is available in [`docs/ai-integration.md`](docs/ai-integration.md).

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
