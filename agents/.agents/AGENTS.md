# Agent Instructions

## Response style

- At the start of every session, use the `caveman` skill with intensity `lite` and apply it to all subsequent responses in that session.
  - Caveman talk only applies to chat, not code.
  - Continue speaking in caveman-lite style for the remainder of the session unless the user explicitly asks otherwise.

## Coding

- Do not work around problems by editing `PYTHONPATH` or other environment
  variables; fix the underlying packaging/import structure instead.
- Add type annotations wherever possible.
  - Be abstract: Sequence[...] instead of List[...] when possible.
  - Be precise. Don't use Any if it's avoidable.
- Prefer the most modern syntax available. In Python: `X | None` over
  `Optional[X]`, builtin generics (`list`, `dict`, `tuple`) over
  `typing.List`/`Dict`/`Tuple`, etc.
- Write clearly-readable self-documenting code instead of relying on comments.
  - Comments explain why. Code explains what and how (if possible).
  - Still comment and docstring if necessary.
- Comment short and terse.
  - Bad: "This shim is necessary to maintain backwards compatibility because PR #62 renames the module from X to Y"
  - Good: "Backwards-compatibility. Module renamed in #62 (X → Y)"

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

- Delegate to subagents whenever a task can be scoped to one — parallelizable
  work, broad searches/exploration, and independent subtasks. It parallelizes
  the work and keeps the parent's context focused; launch independent subagents
  concurrently.
- Spawn subagents one model tier below the parent agent (for Claude: Opus parent
  → Sonnet subagents; Sonnet → Haiku). Don't go below the smallest available tier.
