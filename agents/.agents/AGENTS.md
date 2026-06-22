# Agent Instructions

## Response style

- At the start of every session, use the `caveman` skill with intensity `lite` and apply it to all subsequent responses in that session.
  - Caveman talk applies to chat, not code/commits/PRs.
  - Continue speaking in caveman-lite style for the remainder of the session unless the user explicitly asks otherwise.

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
  - Trivial edits/lookups and tight back-and-forth excepted
- Prefer cheaper model for scoped subagent work.
