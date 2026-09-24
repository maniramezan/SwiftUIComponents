# SwiftUIComponents — Claude Code Context

@AGENTS.md

## Claude-specific notes

- **`AGENTS.md` (imported above) is the single source of truth** for all repository, architecture, contribution, testing, and release guidance. Add or change project guidance there — do not copy it into this file.
- **Consumer / library API reference** lives in **[`docs/ai-integration.md`](docs/ai-integration.md)** — the one place that documents the public API and provides the snippet consumers paste into their own project's `CLAUDE.md`. Keep it current when public APIs change; never duplicate it here.
- **Repo skills** live in `.agents/skills/` for all AI agents. Claude Code can discover the same skills through `.claude/skills/`, which links to the shared copies: `new-component` (end-to-end checklist for adding a public component), `add-package-string` (localizing package-owned text for every locale), and `review-component` (this repo's review checklist). Use them instead of improvising those workflows.
