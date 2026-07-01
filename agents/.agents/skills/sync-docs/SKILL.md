---
name: sync-docs
description: >
  Reconcile documentation (Markdown, comments, docstrings) with the code so it is
  correct, current, and consistent with project style. Treats code as ground truth and
  docs as suspect, then reports mismatches by severity for approval before editing —
  skipping the gate, but still reporting, when action is pre-authorized. Use to update,
  audit, fix, or refresh docs, or when docs have drifted from code.
---

# Sync Docs

Bring documentation back in line with the code. **Code is ground truth; documentation is guilty until proven correct.** A comment, docstring, or README sentence is a *claim* to verify against the code — never evidence about how the code behaves.

Scope is documentation only: Markdown, code comments, and docstrings. Do not change code behavior. If the code itself looks wrong, flag it separately (step 4) — never rewrite a doc to paper over a suspected bug, and never edit code to match a doc.

## 1. Establish scope

Fix the set of docs in play, narrowest sensible default first:
- User named files / dirs / a subsystem → that.
- "the docs I just touched" / post-refactor → `git diff` and `git status` to find changed code and its docs.
- Otherwise ask, or default to docs co-located with recently changed code. Do not silently sweep the whole repo.

Note whether the user pre-authorized action ("just fix them", "update and commit"). That flag decides step 6.

## 2. Load the style bar

Find the guidance the docs must conform to, in priority order:
- `AGENTS.md` (or your agent's equivalent guidance file, and files they include), `CONTRIBUTING*`, `.editorconfig`, docstring-convention config (e.g. ruff / pydocstyle in `pyproject.toml`).
- Absent explicit rules, infer house style from well-maintained neighboring docs.

Extract the concrete checks to apply later — e.g. docs are stateless (describe the present; no "used to be" / "now" / history), comments say *why* not *what*, imperative mood, type-annotation and modern-syntax expectations. Carry these into steps 4 and 5.

## 3. Read the code skeptically

For each doc in scope, read the code it documents — signatures, defaults, control flow, raised errors, real imports and paths — and derive what is *actually* true. Do this before re-reading the doc's prose, so the prose can't anchor you.

Work one code unit at a time, confirming or refuting each doc claim against the code with `file:line` evidence. If your tooling supports parallel sub-tasks, verify independent files / subsystems concurrently.

## 4. Diff claims against reality

Classify every mismatch. Two are doc bugs; the third is not — do not miss it:
- **Doc wrong** → doc misdescribes correct code. Fix the doc.
- **Doc stale** → doc describes code that was renamed, moved, removed, or changed. Fix or delete the doc.
- **Code possibly wrong** → doc states the clearly *intended* behavior and the code diverges. This is a code bug wearing a doc's clothes. Do **not** rewrite the doc to match the bug — surface it as a separate finding.

## 5. Report, grouped by severity

Present findings most-severe first. Each carries `file:line`, the specific claim, the code evidence, and the proposed fix:
- **Critical** — actively misleading: wrong signature / behavior / default, dead references to removed APIs, anything where a reader who trusts the doc hits an error or wrong result.
- **Major** — stale or incorrect but not dangerous: outdated examples, renamed identifiers, obsolete sections, wrong-but-harmless detail.
- **Minor** — style / consistency only: tense, phrasing, history references, formatting, missing type hints in examples.

List separately any **suspected code bugs** (step 4) and any docs you propose to **delete** rather than fix.

## 6. Approval gate

- **Not pre-authorized** → stop after the report; wait for the user to pick what to apply.
- **Pre-authorized** → still deliver the report, then proceed to apply without waiting.

## 7. Apply

- Edit only the approved items. Match the style bar from step 2 exactly.
- Write **stateless** docs: describe what the code is now; never justify by contrast with the past or narrate the change you are making.
- Fix the smallest span that makes the claim true — no unrelated rewrapping or churn. Delete a stale doc rather than caveat it.
- Do not author documentation where none exists unless asked; this skill reconciles existing docs, it does not write new ones.

## 8. Report back

Summarize what changed by severity, what was deleted, what was deferred, and any suspected code bugs still open. Show the diff or the list of edited `file:line`s.
