# AGENTS.md
- Preserve backward compatibility only when a current requirement or verified
  external consumer needs it. Otherwise, remove obsolete paths instead of
  adding compatibility layers or fallbacks.
- Choose the simplest implementation that fully meets the current
  requirements. Avoid speculative abstractions, configuration, and
  indirection.
- Grow the system in layers. Start from the smallest version that works end
  to end, and add each new capability on top of a product that already
  works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall
  complexity or improve reliability. Do not reimplement common
  functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own
  implementation or adding packages. Do not assume a library lacks a
  capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap
  that only works for now and is meant to be replaced later.

For historical project context (past decisions, setup notes, credentials),
search the read-only `~/.codex/claude-project-memory` tree — read the repo's
`memory/MEMORY.md` index first. Treat memories as historical evidence, not
current truth.
