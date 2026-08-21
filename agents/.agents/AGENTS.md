# Agent Instructions

## Response style

- Default chat style: concise. Lead with the result; skip preamble and narration.
  - Claude Code enforces this via the built-in `Concise` output style. Other
    agents apply the rules directly:
    - First sentence answers "what happened" or "what's the answer". No
      preamble ("Let me...", "Now I'll..."), no closing recap.
    - Report outcomes, decisions, and anything the user must act on. Do not
      restate the request, the plan, or each step taken.
    - Simple questions get 1-3 sentences of plain prose. Headers, tables, and
      bullet lists only when they carry real structure.
    - State things plainly. No hedging boilerplate. Raise a caveat only when it
      changes what the user should do next.
    - Answer completely when asked for an explanation or detail. Conciseness
      never withholds requested information.
    - Never trade correctness for brevity. Error reports, failing test output,
      security warnings, and destructive-action confirmations keep full content.
  - Applies to chat, not code/commits/PRs.
  - Use the `caveman` skill when the user asks for a terser voice.

## Visual media

- Treat your own reading of images and video as low-confidence. You frequently
  misjudge fine detail, spatial relationships, small text, colors, counts, and
  motion across frames.
- Defer to the user as the authority on what an image or video shows. Prefer
  asking them to confirm or describe over asserting what you see.
- State any visual interpretation as tentative and flag the uncertainty. Do not
  make decisions or claims that hinge on unverified visual detail.

## Coding

### Program Flow

- Do not work around problems by editing `PYTHONPATH` or other environment
  variables; fix the underlying packaging/import structure instead.
- Avoid nested functions and imports, except when specifically idiomatic (closures/decorators).
- Do not hardcode absolute/machine-specific paths in code for portability.
  Derive paths relative to the file, project root, or a configurable base;
- Remove unused code instead of leaving it dead. Delete code that a change makes
  obsolete (unreferenced functions, unreachable branches, commented-out blocks)
  rather than keeping it around. Version control preserves history.

### Style

- Maximize code readability. Be verbose with names and don't abbreviate.
- Write self-documenting code instead of relying on comments.
  - Comments explain why. Code explains what and how (if possible).
  - Docstrings can provide overview for high-level functions.
- Comment short and terse. Drop articles (a/an/the). Use exact technical terms.
  - Bad: "This shim is necessary to maintain backwards compatibility because PR #62 renames the module from X to Y"
  - Good: "Backwards-compatibility. Module renamed in #62 (X → Y)"
- Documentation and comments are stateless. Describe what the code is now;
  justify it on its own terms, not by contrast with the past.
  - Do not reference history, prior versions, or how something changed (e.g.
    "now lower than before", "used to be X", "after the refactor").
  - Bad: "Timeout reduced to 5s to avoid the old hangs"
  - Good: "5s timeout bounds worst-case request latency"

### Python

- Add type annotations wherever possible.
  - Be abstract: `Sequence[...]` instead of `List[...]` when possible.
  - Be precise: Only use `Any`/`object` when *everything* is allowed.
- Prefer the most modern syntax available.
  - `X | None` over `Optional[X]`, builtin generics (`list`, `dict`, `tuple`) over `typing.List`/`Dict`/`Tuple`, etc.

### Testing

- Test desired behavior, not implementation details. A test should fail when the
  behavior breaks, not when refactoring changes the code.
  - Avoid change-detection tests that merely assert the current implementation
    (e.g. snapshotting internal state or mirroring the code under test).
- Be strategic to limit execution time and maintenance cost.
  - Cover the meaningful cases (core paths, edge cases, regressions); skip
    redundant or low-value tests.
  - Prefer fast, focused tests; reserve slow/integration tests for behavior unit
    tests cannot reach.

## Commits

- Follow the [Conventional Commits](https://www.conventionalcommits.org/)
  specification for all commit messages.
- Format: `<type>[optional scope]: <description>`, e.g. `feat(auth): add token
  refresh`.
- Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
  `build`, `ci`, `chore`, `revert`.
- Use the imperative mood in the description (`add`, not `added`/`adds`).
- Append `!` after the type/scope (or add a `BREAKING CHANGE:` footer) for
  breaking changes.

## Subagents

- Eagerly delegate to concurrent subagents for speed and to keep parent context focused.
  - Parallelizable work, broad searches/exploration, and independent subtasks.
  - While diagnosing local issues, dispatch a subagent to research online (docs, forums, issue trackers, papers) in parallel and keep diagnosing locally while it works.
  - Trivial edits/lookups and tight back-and-forth excepted.
- For scoped subagent work, use a model one tier cheaper than the main session model (e.g. Sonnet when the session runs Opus, Haiku when it runs Sonnet).
