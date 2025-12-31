# Repository Guidelines

## Research & Planning
- Review Apple SwiftUI/SwiftPM docs and recent Swift Forums posts before coding; cite notable references in PRs to demonstrate alignment.
- When proposing a component, default to cross-platform SwiftUI APIs so it works on all declared platforms; call out platform-specific implementations explicitly if parity is not possible.
- If a pattern is unclear, confirm with official samples, WWDC talks, or other reputable sources before committing.
- Every change must include automated tests (`swift test`); note any manual UI verification in the PR description.

## Project Structure & Module Organization
- `Package.swift` is the single source of truth; keep the declared platforms (macOS 15, iOS 18, Mac Catalyst 18) consistent and only add targets when isolation truly requires it.
- Primary sources live in `Sources/SwiftUIComponents/`; store each public view or modifier in its own file with private helpers nearby.
- Tests live under `Tests/SwiftUIComponentsTests/` and should mirror source file names (e.g., `MenuPickerTests.swift`). Shared fixtures or snapshots go in `Tests/Resources/`.

## Build, Test, and Development Commands
- `swift package resolve` updates dependencies whenever `Package.swift` changes.
- `swift build` performs incremental compilation; add `--configuration release` before tagging to catch release-only warnings.
- `swift test --parallel` runs the suite locally, and `swift test --enable-code-coverage` prepares reports for coverage gates.
- `open Package.swift` launches Xcode 16 for previews, Instruments, and doc comments.

## Coding Style & Naming Conventions
- Follow the Swift API Design Guidelines: UpperCamelCase for types, lowerCamelCase for functions and variables, protocols named for capabilities (`SelectableMenuItem`).
- Prefer value semantics (`struct`, `enum`) and immutable `let` bindings; use four-space indentation and limit each file to one public type.
- Document all public APIs with `///` comments that describe behavior, inputs, and assumptions.
- Run `swift format --in-place Sources Tests` (or Xcode’s formatter) before committing to keep diffs clean.
- When a view introduces supporting private subviews or helpers, define them in `extension` blocks at the bottom of the file and separate sections with `// MARK:` comments to keep each entity focused.

## Testing Guidelines
- Tests use XCTest; name methods `testComponent_behaviorExpectation` and colocate helpers with the tests that need them.
- Cover both success and failure paths, using deterministic seeds for async or animation-driven scenarios so results are reproducible.
- Target 80%+ coverage on new functionality and require at least one regression test for every bug fix.

## Commit & Pull Request Guidelines
- Commit messages stay present tense and action-oriented (“Add MenuPicker selection badge”); group related files together.
- PRs should summarize the change, link issues, attach screenshots or videos for UI work, list external references consulted, and include `swift test` results.
- Rebase frequently and rerun `swift test` before requesting review to prevent CI churn.
