---
name: review-component
description: Review a change to this SwiftUI component library against its repo-specific rules — view composition performance, design tokens, accessibility, localization, API hygiene, docs, showcase, and tests. Use when asked to review a PR, a diff, or a component in this repository.
---

# Review checklist

Report concrete findings with `file:line`, most severe first. Check each item against the diff.

**Correctness and API hygiene**
- No public conformance of a type the package doesn't own (`extension Int: …`).
- No `precondition`/`fatalError`/force-unwrap on caller input; misuse logs a `.fault` and degrades.
- `ForEach` identity is stable (not `enumerated().offset` over mutable data).
- A custom `==` on a type stored in a view compares every value that affects rendering.
- Right-to-left layouts: rotations and offsets of directional glyphs (`chevron.forward`) account
  for `layoutDirection`; row alignment uses leading/trailing, not left/right.
- `onChange`/`onAppear` callbacks still fire when inputs change after the first render.

**Performance**
- No `@ViewBuilder` computed properties or methods decomposing a view's own body; subviews
  are `View`/`ViewModifier` structs.
- No repeated O(n) work per frame or tick (string indexing by count, re-measuring every
  subview in a `Layout` more than needed, `TimelineView` without need).

**Design tokens**
- No raw spacing, radius, font, or color literals in production view bodies, unless they are
  documented `nil`-defaults-to-theme overrides.
- Weighted fonts use the Typography ladder (`subheadlineMedium`), not `.weight(...)`.

**Accessibility and localization**
- Decorative images hidden; related text combined; traits (`.isSelected`, `.isHeader`,
  `.isButton`) set; Reduce Motion honored.
- No hard-coded English in package-owned text; new strings are in the catalog for all locales.

**Completeness**
- `///` on every public symbol (`python3 Scripts/check-doc-comments.py`), DocC topic,
  `docs/ai-integration.md` entry, showcase page with live controls, tests covering new
  lines, domain-neutral sample data, and a Conventional Commit type matching the change.
