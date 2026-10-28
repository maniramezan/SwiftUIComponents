# SwiftUIComponents design audit prompt

Audit the entire SwiftUIComponents codebase for SwiftUI API design, modeling, composition, and data-flow problems. Read AGENTS.md and apply the repository's review-component skill and available SwiftUI skills first.

This is a read-only source review. Stay on the current branch. Do not edit source, create branches, commit, open PRs, merge, or release. You may run existing checks and create their normal build artifacts. Inspect the installed toolchain and Package.swift deployment targets before recommending APIs. Support uncertain platform claims with official Apple documentation; distinguish platform guidance, repository rules, and your own judgment.

Review Sources/Components and Sources/DesignSystem systematically, including private helpers. Inspect showcase usage, tests, DocC, and docs/ai-integration.md to verify consumer experience and documented behavior. Keep an inventory of reviewed components and explicitly identify coverage gaps. Do not stop after a few examples.

Check:

1. Initializers separate caller-owned data, identity, bindings, actions, and content builders from reusable styling and behavior. Consider discoverable modifiers and typed configuration where they improve actual usage. Keep reasonable per-instance arguments explicit.
2. Related values have cohesive models and a clear source of truth. Find duplicated state, independently passed IDs and entries, flattened configuration, and invalid combinations. Avoid configuration bags that only conceal long parameter lists.
3. Environment values carry legitimate inherited policy and theme settings. Local overrides preserve unrelated inherited fields, and modifier order is documented and tested. Do not hide required model data or transient geometry in the environment.
4. View decomposition uses View or ViewModifier types. Flag computed properties or functions that return views to split a component's own body. Caller-supplied ViewBuilder parameters and public compositional modifier APIs are valid patterns.
5. State ownership, bindings, identity, and animation boundaries remain correct across updates. Check stable ForEach IDs, insertion/removal/reordering, pause/resume, visibility, scene changes, Reduce Motion, and VoiceOver. Keep non-animated context separate from interpolated values.
6. Resolve static configuration and collection preparation outside frame-by-frame work. Look for avoidable repeated allocations, filtering, sorting, validation, and logging in bodies or animation ticks. Use pure, testable helpers for geometry and timing. Check that regression tests exercise production paths rather than dead helpers or copies of the implementation. Do not cache derived values without a valid update strategy.
7. Prefer native SwiftUI layout, frames, and existing shared building blocks. Respect design tokens, accessibility, localization, public API documentation, showcase controls, and platform availability. Avoid blanket replacements of working GeometryReader usage or availability-compatible animation implementations.

Report concrete findings, ordered by correctness, public API usability, performance, then private readability. For each finding give file:line evidence, a consumer or runtime consequence, the smallest coherent improvement, compatibility tradeoffs, and meaningful regression coverage. Treat parameter counts as a review signal, not a violation. Do not invent findings to justify refactoring.

Finish with the component inventory, checks run and their results, unverified behavior, and a prioritized implementation plan. Keep this audit separate from implementing that plan.
