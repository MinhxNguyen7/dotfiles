---
name: handoff
description: >
  Prepare the session for /clear or /compact so the next agent resumes cleanly.
  Updates documentation and memories, atomically commits (or proposes commits for)
  completed work, and writes a durable handoff for the next agent.
  Use when the user runs /handoff, or says they are about to clear, compact, wrap up,
  or hand off the session.
---

Prepare the working session so the next agent — after `/clear` or `/compact` — resumes with zero friction.

**Core principle.** `/clear` wipes all context; `/compact` keeps only a lossy summary. Anything worth keeping must live in a durable artifact — committed code, docs, memories, or files on disk — *before* the wipe. A handoff that exists only in chat dies with the context. Persist, don't narrate.

Work the steps in order. Persistence comes before the handoff so the handoff can reference the final committed state.

## 1. Assess the session

- Run `git status`, `git diff`, and `git log` (for commits made this session).
- Sort changes into **done**, **in-progress**, and **blocked / undecided**.
- Note open questions, TODOs, and decisions the user still owes.

## 2. Update documentation

- Reconcile docs with what actually changed — design docs, READMEs, docstrings.
- Capture *why* (decisions, trade-offs, gotchas), not the obvious *what*.
- Delete docs a change made stale rather than letting them rot.

## 3. Update memories

- Write or update durable facts that help next session: project state, decisions, blockers, and the concrete **next step**. Convert relative dates to absolute.
- Update the memory index (`MEMORY.md`). Delete memories a change has proven wrong.
- Skip what code, git history, or existing docs already record.

## 4. Commit completed work (atomically)

- Group changes into **atomic** commits — one logical change each — using Conventional Commits, imperative mood.
- Before claiming "done": run the relevant build / tests / lint. Report failures honestly; never fold a failing change into a "done" commit.
- **Authorization:** commit directly only if durably authorized this session. Otherwise present the commit plan (grouping + messages) and ask. If on the default branch, create a branch first.
- Leave in-progress or experimental work uncommitted, or on a clearly named WIP branch. Never pass half-done work off as complete.

## 5. Write the handoff for the next agent

Persist it durably — its reliable home is a `project` memory (auto-loaded next session); for a long or temporary handoff, a `HANDOFF.md` in the repo or scratchpad. Then also show it to the user. Keep it skimmable, next-action first:

- **Now do this:** the single most important next action.
- **State:** branch; what is committed (SHAs) vs uncommitted / WIP.
- **Done this session:** bullets, referencing commits.
- **Next steps:** concrete, ordered.
- **Open decisions / blockers:** anything unresolved or needing the user.
- **Gotchas & context:** non-obvious traps, where to look.
- **Resume fast:** key files, entry points, commands to run or verify.

## 6. Report back

Tell the user concisely: what you committed (or the commit plan awaiting approval), which docs and memories you updated, and where the handoff lives. They can then safely `/clear` or `/compact`.

---

**Tune by target** (optional arg `clear` or `compact`):
- Heading to `/clear` → persistence is critical; the handoff *must* land on disk or in memory.
- Heading to `/compact` → the summary survives, so lean on memories and commits and keep the handoff lighter.
