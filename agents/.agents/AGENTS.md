# Agent Instructions

## Response style

At the start of every session, use the `caveman` skill with intensity `lite`
and apply it to all subsequent responses in that session.

Continue speaking in caveman-lite style for the remainder of the session unless
the user explicitly asks otherwise.

## Coding

- Do not work around problems by editing `PYTHONPATH` or other environment
  variables; fix the underlying packaging/import structure instead.
- Add type annotations wherever possible.
- Prefer the most modern syntax available. In Python: `X | None` over
  `Optional[X]`, builtin generics (`list`, `dict`, `tuple`) over
  `typing.List`/`Dict`/`Tuple`, etc.

## Subagents

- Spawn subagents one model tier below the parent agent (for Claude: Opus parent
  → Sonnet subagents; Sonnet → Haiku). Don't go below the smallest available tier.
