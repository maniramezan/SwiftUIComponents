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
- When public APIs change, update `docs/ai-integration.md` (the single consumer API reference) and the target's DocC landing page in the same change. Do not duplicate the API reference into `CLAUDE.md` or `README.md` — they link to `docs/ai-integration.md` instead.

### Reusable Shared Helpers
Before reaching for a bespoke implementation, check whether an existing shared helper already covers the case — deduplicating these is the intended design, not an accident:
- **Scroll edge-fade geometry**: `ScrollLayoutMath` (`Sources/Components/Layout/Scroll/ScrollLayout.swift`) owns `edgeFade` / `accessibilityStep` and the `ScrollGeometrySnapshot` / `ScrollEdgeVeil` / `ScrollEdgeBand` types. Any horizontally scrollable component that veils its edges (`SegmentedPicker`, `CarouselRow`, `TitledPageView`) must use these, applied via the internal `View.scrollEdgeVeil(...)` modifier — do not hand-roll per-component edge-fade math or veil views.
- **`Bundle.requiresDesignCompatibility`** (`Sources/Components/Surfaces/Adaptive/Bundle+Compatibility.swift`): the single source for the `UIDesignRequiresCompatibility` Info.plist decision used by glass vs. fallback surfaces/buttons. Reuse it instead of re-reading the Info.plist key inline.
- **`.designNoticeCard(background:cornerRadius:padding:)`** / `NoticeCard` (`Sources/Components/Feedback/Notice/NoticeCard.swift`): full-width, padded, rounded container for inline notice, banner, and error cards. Reuse for any surface with a fill color, `twoUnits` default padding, and `oneAndHalfUnits` corner radius.
- **`.designPillMetrics(horizontalPadding:)`** / `PillMetrics` (`Sources/Components/Selection/Chips/PillMetrics.swift`): capsule-pill padding (`oneUnit` vertical), `minimumHitTarget` height, and capsule content shape. Combine with `.designCapsuleSurface(...)` rather than hand-rolling chip backgrounds.
- **`theme.motion.animation(reducingMotion:)`** (`DesignSystem.Motion`): resolve the active animation from the current Reduce Motion setting. Use instead of the inline `reduceMotion ? reducedMotionAnimation : standardAnimation` ternary.
- **`AttributedString(markdownOrPlainText:)`** (`Sources/Components/Typography/AttributedString+Markdown.swift`): parse user/model-provided Markdown with `.full` interpreted syntax, falling back to plain text on malformed input. Use for any string that *may* contain Markdown but must never crash.
- **Typography weight ladder** (`Typography.subheadlineMedium`, `title3Semibold`, …, or `TypographySlot`): use these instead of re-weighting a slot inline (`theme.typography.subheadline.weight(.medium)`), so a custom theme's overrides flow through.
- **Public building blocks**: settings/list rows → `ListRow`; labeled form inputs → `TextInputField`; linear progress → `ThemeProgressViewStyle`; circular identity → `AvatarView`; wrapping chips/tags → `FlowLayout`. Compose these rather than adding near-duplicates.

## API Hygiene
- **No public conformances of types you don't own.** Never add `extension Int: SomeProtocol` (or any standard-library/SwiftUI type) to a library target — the conformance leaks into every consumer module and collides with theirs. Previews and tests use private sample types (e.g. `PreviewSegment`, `MenuPickerTestItem`).
- **Log, don't trap, on caller misuse.** For invalid arguments (empty items, selection not in items, `rows > 1` without `rowHeight`) log an OSLog `.fault` with subsystem `com.swiftuicomponents` and degrade gracefully. `precondition`/`fatalError` crash the host app.
- **Package-owned strings are localized.** Any text the package itself shows or speaks (placeholders, accessibility labels, role names) goes through `Strings` in `Sources/Components/Localization/Strings.swift` and the String Catalog with every locale listed in `Scripts/check-localizations.py`. Never hard-code English in an `accessibilityLabel`/`Value`/`Hint`. Caller-supplied content stays verbatim. See the `add-package-string` skill.
- **Public value enums** conform to `Sendable` (plus `Hashable`/`CaseIterable` where it makes sense) so they can be stored in state and iterated in showcase pickers.
- **Keep pure math pure.** Put geometry/pacing/decision logic in `nonisolated static` helpers (`ScrollLayoutMath`, `FlowLayout.arrange`, `TypewriterRevealPacing`) and test those directly, rather than duplicating the algorithm inside a test.
- **Identity:** key `ForEach` by a stable model identity, never by `enumerated().offset`, when the collection can change.

## ComponentShowcase Coverage (Required)

- Every new public component must be added to the `ComponentShowcase` target in the same PR that introduces it.
- Its showcase must provide live controls for every meaningful configurable parameter and state so reviewers can exercise behavior without editing source code. A static `#Preview`, construction test, snapshot, or documentation snippet does not satisfy this requirement.
- New-component PRs are incomplete until the showcase target builds and the configurable entry is reachable from the showcase UI.
- Register the entry in `ShowcaseComponent` (case, `systemImage`, and an existing `group`) and route it in `ShowcaseDetailView`; build its page from `ShowcaseSection` blocks.

## Build, Test, and Development Commands
- `swift package resolve` updates dependencies whenever `Package.swift` changes.
- `swift build -Xswiftc -warnings-as-errors` performs incremental compilation with warnings treated as errors; add `--configuration release` before tagging.
- `swift test --parallel` runs the suite locally, and `swift test --enable-code-coverage` prepares reports for coverage gates.
- `swift package generate-documentation --target <Target> --warnings-as-errors` validates DocC locally.
- `./Scripts/validate.sh` runs exactly what CI runs: resolve, `swift format lint --strict`, `check-localizations.py`, `check-doc-comments.py`, a warnings-as-errors build, and the tests.
- `python3 Scripts/check-localizations.py` and `python3 Scripts/check-doc-comments.py` need only Python, so run them even where no Swift toolchain is available.

### Working without a Swift toolchain
SwiftUI only builds on Apple platforms. In a Linux container (for example a cloud agent session) you cannot build, lint, or test: run the two Python checks above, keep lines within the 120-column `.swift-format` limit by hand (wrap long `comment:` strings onto their own line, as `Strings.swift` does), and say plainly in the PR that the change was not compiled locally and relies on CI.
- `open Package.swift` launches Xcode 16 for previews, Instruments, and doc comments.

## Documentation Requirements
- **Every** public symbol (type, property, method, enum case, initializer) **must** have a `///` doc comment before it can be merged.
- Doc comments should describe behavior, inputs, and assumptions — not just restate the name.
- `Scripts/check-doc-comments.py` (run by `Scripts/validate.sh` in CI) fails on any public declaration without a `///` comment — including enum cases and members of `public extension`/`public protocol` blocks. DocC's `--warnings-as-errors` (also run in CI) catches broken symbol links, but not missing docs.
- When adding a new public type, add it to the relevant `Topics` section in the target's DocC landing page (`DesignSystem.md` or `Components.md`).
- Keep `docs/ai-integration.md` (the consumer API reference and copy-paste snippet) on the current public API names and initializer signatures.

## Coding Style & Naming Conventions
- Follow the Swift API Design Guidelines: UpperCamelCase for types, lowerCamelCase for functions and variables, protocols named for capabilities (`SelectableMenuItem`).
- Prefer value semantics (`struct`, `enum`) and immutable `let` bindings; use four-space indentation and limit each file to one public type.
- Document all public APIs with `///` comments that describe behavior, inputs, and assumptions.
- Run `swift format --in-place Sources Tests` (or Xcode's formatter) before committing to keep diffs clean.
- When a view introduces supporting private subviews or helpers, define them as their own `View`/`ViewModifier`-conforming types (see **Performance & View Composition** below), organized in `extension` blocks or `// MARK:` sections at the bottom of the file.

## Product Isolation (Non-Negotiable)

- This public repository contains reusable primitives only. Never add application-specific logic, branding, feature names, analytics, domain models, business rules, strings, fixtures, or dependencies from any consuming app.
- Examples, previews, tests, documentation, symbol names, and sample data must be domain-neutral. Use generic concepts such as labels, status values, sections, items, and actions.
- Treat an app as a source of an abstract pattern, never as source code or sample content to copy. Search all changed lines for product/domain leakage before opening or updating a PR.
- If code is reusable across applications, it belongs here or in another appropriate shared library—not in an app repository.

## Performance & View Composition

- **Never split a view's body into `@ViewBuilder` computed properties or methods** (e.g. `@ViewBuilder private var rowContent: some View { ... }`, `private func item(_:) -> some View { ... }`). These are always inlined into the owning view's `body` and re-evaluated every time that body re-evaluates — they never get their own identity in the render tree, so SwiftUI cannot diff, skip, or animate them independently.
- Instead, extract subviews into their own `View`-conforming `struct`s (and modifier-style helpers into `ViewModifier`-conforming `struct`s applied via `.modifier(_:)`). This gives SwiftUI a real type to diff against and lets it skip re-rendering a subtree when its inputs haven't changed.
- This applies to internal/private decomposition of a single component's body. It does **not** apply to the standard `@ViewBuilder` *parameter* pattern used for caller-supplied content (e.g. `init(@ViewBuilder content: () -> Content)`), which is the correct, idiomatic way to accept child views from a caller.
- When reviewing or writing SwiftUI code in this repo, treat this as a top-priority performance concern — flag any `@ViewBuilder`-decorated computed property/method used to decompose a view's own body, and replace it with a dedicated `View`/`ViewModifier` type before merging.

## Design Tokens vs. Raw Values
- Never hardcode a raw `CGFloat`/`Font`/`Color` magic number directly in a view body (`.padding(12)`, `.frame(width: 52)`, `.font(.system(size: 14))`). Always resolve spacing from `theme.spacing.*` (`Spacing` protocol: `halfUnit`…`sixUnits`) and typography from `theme.typography.*` (`Typography` protocol) or `.designTextStyle(_ role: TextRole)`.
- The one accepted exception is a **documented, `nil`-defaults-to-theme override parameter** on a public API — e.g. `titleFont: Font? = nil` / `spacing: CGFloat? = nil` where the doc comment states the exact token used when `nil` (see `PaginationStyle.swift`, `SectionHeader.swift`, `CarouselRow.swift`). This is the established convention for letting callers customize per-call while still theming by default. A raw value is only a violation when it has **no** theme-derived fallback and no documented rationale (a bare magic number baked into behavior).
- Before adding a new numeric/font literal to a view body, check whether an existing `Spacing`/`Typography` token already matches; if one doesn't, ask whether the value should become a new token rather than a one-off literal.
- `#Preview` blocks are lower priority (dev-only, not shipped), but production view bodies must not bypass the theme.

## Testing Guidelines
- Tests use Swift Testing (`@Test`); name methods descriptively and colocate helpers with the tests that need them.
- Cover both success and failure paths, using deterministic seeds for async or animation-driven scenarios so results are reproducible.
- Target 80%+ coverage on new functionality and require at least one regression test for every bug fix.
- Hosted rendering goes through `renderForCoverage(_:size:)` (`Tests/SwiftUIComponentsTests/Support/ViewRenderingSupport.swift`); use `@testable import Components` to reach internal math helpers.

## Before You Finish
- New public API: `///` docs, DocC topic in `Components.md`/`DesignSystem.md`, an entry in `docs/ai-integration.md`, a showcase page with live controls, and tests. The `new-component` skill (`.claude/skills/new-component/SKILL.md`) walks through it.
- Behavior change or fix: a regression test, and a Conventional Commit whose type matches (`fix:` vs `feat:`; `!` for source-breaking changes).
- Search the diff for product/domain leakage (see **Product Isolation**).

## Commit & Pull Request Guidelines
- Use **Conventional Commits** — the release workflow derives version bumps from them. Format: `type(scope): summary`, present tense and action-oriented (`feat(picker): add MenuPicker selection badge`). Group related files together.
- Releasable types: `feat:` (minor), `fix:`/`perf:` (patch), and a `!` suffix or `BREAKING CHANGE:` footer (minor while pre-1.0, major after). Non-releasable: `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `build:`, `style:`.
- When squash-merging a PR, make the squash commit subject a valid Conventional Commit — that subject is what the release workflow reads.
- PRs should summarize the change, link issues, attach screenshots or videos for UI work, list external references consulted, and include `swift test` results.
- Rebase frequently and rerun `swift test` before requesting review to prevent CI churn.

## Releases
- Releases are automated by `.github/workflows/release.yml`: after the **CI** workflow succeeds on `main`, it computes the next version from the Conventional Commits since the last tag, creates an annotated **bare-SemVer** tag (e.g. `0.2.0` — **never a `v` prefix**), and publishes a GitHub Release with auto-generated notes. There is **no `CHANGELOG.md`** — release notes live on the GitHub Release.
- The first release is `0.1.0`. While pre-1.0: `feat:`/breaking → minor, `fix:`/`perf:` → patch. After a manual bump to `1.0.0`, standard SemVer applies (breaking → major).
- To cut a specific version manually, run the **Release** workflow via *workflow_dispatch* with a `force_version` input (bare, e.g. `0.4.0`).
- SwiftPM consumers pin these tags, e.g. `.package(url: "…/SwiftUIComponents", from: "0.1.0")`.
