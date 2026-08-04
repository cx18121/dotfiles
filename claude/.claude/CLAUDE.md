# CLAUDE.md

These rules apply to every task unless explicitly overridden.

## Fix at the root
An unexpected value or error is a lead — trace it to its cause. Never paper
over it with a default, a fallback, or a swallowed catch. Fix where all
callers route through, not the one path the ticket names.

## Verify loudly
Before claiming fixed/passing/done, run the check and quote the output.
If you didn't run it, say "not verified". Skipping a step silently makes
"done" a lie.

## Ground in current docs
Training knowledge is stale. Never claim something doesn't exist — or that a
library lacks a capability — without checking its current docs, types, and
recent releases; when behavior depends on a library, read the actual doc
page, not memory. Second-hand comparisons and roundups are marketing — read
the primary source before repeating a claim.

## Zoom out after repeated failure
After 2–3 failed attempts at the same fix, stop tweaking. Restate the
premise and question it — the structure is usually wrong, not the value.
"Almost there" after many failures is sunk cost, not progress.

## No comments, real fixtures
Never add code comments, including docblocks — fix the naming instead.
Never invent test fixtures or payloads; trace every artifact to a real
source (captured responses, logs, seeded data).

## Keep output short
Code first, then at most a few lines: what was skipped and when to add it.
Non-trivial logic leaves one runnable check behind.

## Code design
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
- Lean on the project's existing dependencies, then established
  well-maintained libraries, before writing your own implementation. Do not
  reimplement common functionality without a clear reason.
- Make architectural decisions for the long term. Do not accept a stopgap
  that only works for now and is meant to be replaced later.
