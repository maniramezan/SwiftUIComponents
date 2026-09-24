---
name: new-component
description: Add a new public SwiftUI component (view, style, or modifier) to the Components or DesignSystem target end to end — source, docs, DocC topic, AI reference, showcase page with live controls, and tests. Use when asked to add, create, or extract a reusable component, or to break an existing component into public pieces.
---

# Add a component

Follow every step; a component PR is incomplete without all of them (see `AGENTS.md`).

## 1. Check for an existing building block

Search `Sources/Components` and the **Reusable Shared Helpers** list in `AGENTS.md` first.
Extend or compose an existing component (e.g. `ListRow`, `TextInputField`, `NoticeCard`,
`PillMetrics`, `ScrollLayoutMath`) instead of adding a near-duplicate.

## 2. Source file

- Put it in the matching feature folder: `Actions/`, `Controls/`, `Indicators/`, `Layout/`,
  `Selection/`, `Surfaces/`, `Feedback/`, `Navigation/`, `Collections/`, `Media/`, `Typography/`.
- One public type per file; its supporting enums get their own files.
- Read the theme with `@Environment(\.designTheme) private var theme`. Resolve every spacing,
  radius, stroke, font, and color from tokens. A raw value is allowed only as a documented
  `nil`-defaults-to-theme override parameter (see `SectionHeader.titleFont`).
- Decompose the body into private `View`/`ViewModifier` structs at the bottom of the file,
  never `@ViewBuilder` computed properties or methods.
- Put geometry or decision logic in `nonisolated static` helpers so tests can call them.
- Accessibility: hide decorative images, combine text that reads as one unit, add
  `.isSelected`/`.isButton`/`.isHeader` traits, and honor `accessibilityReduceMotion`
  through `theme.motion.animation(reducingMotion:)`.
- Package-owned text (placeholders, a11y labels) → the `add-package-string` skill.
  Caller-supplied strings are rendered verbatim; say so in the doc comment.
- Invalid input → log an OSLog `.fault` and degrade; never `precondition`.
- Add a `#Preview` wrapped in `PreviewContent { theme in ... }` using domain-neutral data.

## 3. Documentation

- `///` on every public symbol, including enum cases and `public extension` members. Include a
  usage snippet on the type.
- Add the type to the right `### ` group in `Sources/Components/Components.docc/Components.md`
  (modifiers also go in `Modifiers.md`).
- Add a usage block to the snippet in `docs/ai-integration.md` (and a **Do Not** line if there
  is an obvious misuse).

## 4. Showcase

- Create `Sources/ComponentShowcase/Details/<Group>/<Name>DetailView.swift` built from
  `ShowcaseSection` blocks, with **live controls for every meaningful parameter and state**
  (`TextField`, `Toggle(...).toggleStyle(ThemeToggleStyle())`, `Picker`, `Slider`, `Stepper`).
- Register it: a case plus `systemImage` and an existing `group` in
  `Navigation/ShowcaseComponent.swift`, and a route in `Navigation/ShowcaseDetailView.swift`.

## 5. Tests

- `Tests/SwiftUIComponentsTests/Components/<Name>Tests.swift`, Swift Testing (`@Suite`, `@Test`),
  `@testable import Components`.
- Unit-test the pure helpers; render every visual variant with `renderForCoverage(_:size:)` so
  changed-line coverage stays at 80% or higher.

## 6. Validate and commit

- `python3 Scripts/check-doc-comments.py && python3 Scripts/check-localizations.py`
- On macOS: `./Scripts/validate.sh`. Without a Swift toolchain, keep lines within 120 columns
  by hand and state in the PR that the change was not compiled locally.
- Commit as `feat(<scope>): add <Name>`.
