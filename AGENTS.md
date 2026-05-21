# Repository Guidelines

## Research & Planning
- Review Apple SwiftUI/SwiftPM docs and recent Swift Forums posts before coding; cite notable references in PRs to demonstrate alignment.
- When proposing a component, default to cross-platform SwiftUI APIs so it works on all declared platforms; call out platform-specific implementations explicitly if parity is not possible.
- If a pattern is unclear, confirm with official samples, WWDC talks, or other reputable sources before committing.
- Every change must include automated tests (`swift test`); note any manual UI verification in the PR description.

## Project Structure & Module Organization
- `Package.swift` is the single source of truth; keep the declared platforms (macOS 15, iOS 18, Mac Catalyst 18) consistent and only add targets when isolation truly requires it.
- Primary sources live in `Sources/DesignSystem/` and `Sources/Components/`; store each public view or modifier in its own file with private helpers nearby.
- `ComponentShowcase` is a demo/reference target for previews and exploration. Do not add reusable production APIs there; promote stable UI into `Components` instead.
- Tests live under `Tests/SwiftUIComponentsTests/` and should mirror source file names (e.g., `MenuPickerTests.swift`). Shared fixtures or snapshots go in `Tests/Resources/`.
- DocC catalogs live in `Sources/<Target>/<Target>.docc/`. Each library target has its own catalog with a landing page.

## Architecture Decisions
- `DesignSystem` owns tokens, default token implementations, and theme environment wiring.
- `Components` depends on `DesignSystem` and owns reusable production-facing views, modifiers, and helper protocols.
- `ComponentShowcase` depends on `Components` and `DesignSystem` and exists to demonstrate usage, not to define the package's public architecture.
- Apply theming through `.designTheme(_:)` at the root of a hierarchy and read tokens from `@Environment(\.designTheme)` inside views.
- When public APIs change, update `README.md`, `docs/ai-integration.md`, and `CLAUDE.md` in the same change so consumer docs and AI guidance stay aligned.

## Build, Test, and Development Commands
- `swift package resolve` updates dependencies whenever `Package.swift` changes.
- `swift build -Xswiftc -warnings-as-errors` performs incremental compilation with warnings treated as errors; add `--configuration release` before tagging.
- `swift test --parallel` runs the suite locally, and `swift test --enable-code-coverage` prepares reports for coverage gates.
- `swift package generate-documentation --target <Target> --warnings-as-errors` validates DocC locally.
- `open Package.swift` launches Xcode 16 for previews, Instruments, and doc comments.

## Documentation Requirements
- **Every** public symbol (type, property, method, enum case, initializer) **must** have a `///` doc comment before it can be merged.
- Doc comments should describe behavior, inputs, and assumptions — not just restate the name.
- CI runs `swift package generate-documentation --warnings-as-errors` for both `DesignSystem` and `Components` on every PR; undocumented public symbols will fail the build.
- When adding a new public type, add it to the relevant `Topics` section in the target's DocC landing page (`DesignSystem.md` or `Components.md`).
- Keep README examples, AI integration docs, and the consumer `CLAUDE.md` snippet on the current public API names and initializer signatures.

## Coding Style & Naming Conventions
- Follow the Swift API Design Guidelines: UpperCamelCase for types, lowerCamelCase for functions and variables, protocols named for capabilities (`SelectableMenuItem`).
- Prefer value semantics (`struct`, `enum`) and immutable `let` bindings; use four-space indentation and limit each file to one public type.
- Document all public APIs with `///` comments that describe behavior, inputs, and assumptions.
- Run `swift format --in-place Sources Tests` (or Xcode's formatter) before committing to keep diffs clean.
- When a view introduces supporting private subviews or helpers, define them in `extension` blocks at the bottom of the file and separate sections with `// MARK:` comments to keep each entity focused.

## Testing Guidelines
- Tests use Swift Testing (`@Test`); name methods descriptively and colocate helpers with the tests that need them.
- Cover both success and failure paths, using deterministic seeds for async or animation-driven scenarios so results are reproducible.
- Target 80%+ coverage on new functionality and require at least one regression test for every bug fix.

## Commit & Pull Request Guidelines
- Commit messages stay present tense and action-oriented ("Add MenuPicker selection badge"); group related files together.
- PRs should summarize the change, link issues, attach screenshots or videos for UI work, list external references consulted, and include `swift test` results.
- Rebase frequently and rerun `swift test` before requesting review to prevent CI churn.
