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

## Scale the process

- For small, behavior-preserving follow-ups such as applying already-triaged
  review comments, use the shortest safe path: edit the known file, run the
  narrowest relevant check, and hand off.
- Reserve plans, tickets, reuse maps, full development-environment setup, and
  whole-diff review cycles for substantive work that changes behavior,
  ownership, architecture, dependencies, or multiple concerns, or when the
  focused validation fails.

## Repository work artifacts

- Put agent-created planning and working documents under `docs/` unless the
  repository or a tool has an established artifact contract. Put
  implementation specs at `docs/plans/<feature>.md` and their local
  tracer-bullet tickets at
  `docs/plans/<feature>/tickets/<NN>-<slug>.md`.
- Treat `docs/` as a filesystem contract. It may be ignored by Git or linked
  to a worktree-specific store. Inspect it with filesystem-aware commands;
  Git status, tracked-file listings, and ignore-aware searches cannot prove
  that a plan or ticket is absent.
- Before implementing work in a repository, read the matching local plan and
  every ticket. Work one unblocked ticket per implementation run unless the
  user explicitly requests a larger scope.

## Formatting safety

- In dirty or shared worktrees, format only the files explicitly in scope. Do
  not run repository-wide formatter tasks.
- Record the changed-file list before formatting and verify it afterward.
  Remove formatter edits outside the task before continuing.

## Reuse audit gate

- Before implementation, search the repository and its installed dependencies
  for every proposed helper, parser, data type, service, and orchestration path.
- Record a reuse map in the matching ticket before editing source code. For
  each capability, name its current owner and state whether the change reuses,
  deepens, or deletes it. Add a new seam only when the ticket gives a concrete
  reason the capability cannot fit an existing owner.
- Before handoff, inspect the full diff against its base for parallel paths,
  duplicated policy, and obsolete code.
- Run each available structural simplicity and maintainability review once
  against the complete implementation-ticket diff. Resolve concrete,
  ticket-relevant findings, and record why any finding is rejected when it
  conflicts with a verified requirement or expands the ticket's scope.
- Repeat those reviews only when the resulting changes materially alter
  architecture, ownership, or control flow. Routine cleanup completes the
  existing review cycle.

For historical project context (past decisions, setup notes, credentials),
search the read-only `~/.codex/claude-project-memory` tree — read the repo's
`memory/MEMORY.md` index first. Treat memories as historical evidence, not
current truth.
