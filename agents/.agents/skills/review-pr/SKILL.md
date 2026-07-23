---
name: review-pr
description: >
  Review a pull request end-to-end: understand it with parallel subagents, propose an
  updated PR description if it no longer matches the diff, and post a review with
  inline comments. Use when asked to review a PR, write or update a PR description, or both.
  Accepts a PR number, URL, or branch; defaults to the PR for the current branch.
---

# Review PR

Two deliverables: an accurate PR description (updated only when stale, with user
approval) and a posted review with inline comments.

## 1. Resolve the PR and a clean checkout

- Identify the PR from the argument (number, URL, or branch); default to the PR for
  the current branch.
- Fetch title, body, base/head branches, commits, full diff, and existing
  reviews/comments (e.g. `gh pr view` / `gh pr diff` on GitHub).
- If the current checkout is already on the PR head branch, work in place. Otherwise
  fetch and check out the head branch in a fresh git worktree, and inspect code from
  there — never switch the user's working tree. Remove the worktree when done.

## 2. Understand, then review, with subagents

Fan out parallel subagents where supported; otherwise run the same passes sequentially.

- **Understand:** split the diff into coherent areas (subsystem, file group). One agent
  per area reads the changed code in context — not just the diff — and reports what
  changed, why, and how it fits the surrounding code.
- **Review:** with that understanding, agents hunt real problems: correctness bugs,
  missing or weak tests, design concerns, doc drift. Every finding needs file:line and
  a concrete failure scenario.
- Verify each finding against the code before posting; drop speculation and stylistic
  noise.

## 3. PR description — update only if stale

Draft a concise description from the understanding pass: what the PR does, why, notable
decisions, how it was validated. Follow the repo's PR template if one exists.

Compare against the existing description:

- **Accurate** → leave it untouched and say so.
- **Missing, placeholder, or stale** (misstates scope, omits significant changes,
  describes code no longer in the diff) → show the proposed description and get the
  user's approval before posting it.

Never overwrite the description without approval.

## 4. Post the review

- Post verified findings as inline comments anchored to the changed lines, each with
  severity, rationale, and a suggested fix when cheap.
- Add a short summary review: overall verdict, key risks, anything merge-blocking.
- Match the repo's review conventions and tone.
