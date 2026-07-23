---
name: address-review
description: >
  Address the review on a pull request: read every review comment, verify each claim
  against the code with parallel subagents, then fix the confirmed ones sequentially
  with atomic commits — replying to each inline comment with the fix and resolving the
  thread. Use when asked to address, respond to, or act on PR review feedback.
  Accepts a PR number, URL, or branch; defaults to the PR for the current branch.
---

# Address Review

Turn review feedback into verified fixes, atomic commits, and resolved threads. Not
every comment is correct — confirm each against the code before changing anything, and
push back with reasons when a claim is wrong.

## 1. Gather the review

- Resolve the PR from the argument (number, URL, branch); default to the PR for the
  current branch.
- Fetch the whole picture: summary review body, inline comments (with file:line and
  thread IDs), and each thread's resolved state (e.g. `gh pr view --comments` plus
  `gh api` for review threads on GitHub).
- Work on the PR head branch. If it isn't checked out, fetch and check it out; never
  rewrite the user's working tree out from under them.
- List every actionable item. Skip already-resolved threads and pure praise.

## 2. Verify each claim with subagents

Fan out one subagent per claim (or per coherent cluster); run the passes sequentially
where parallel isn't supported.

Each subagent reads the relevant code in context — not just the quoted diff — and
returns a verdict:

- **Confirmed** — real issue; report file:line and a concrete fix.
- **Refuted** — wrong or already handled; report the evidence.
- **Needs decision** — valid but a scope, design, or judgment call for the user.

Never take a comment at face value. Drop refuted and speculative items from the fix list.

## 3. Fix sequentially, commit atomically

Order confirmed fixes by dependency and file so commits stay clean. For each:

- Apply the smallest change that addresses the comment.
- Verify it — run the relevant build/test/lint. Never commit a fix you didn't check.
- Commit atomically: one logical fix per commit, Conventional Commits, imperative mood,
  referencing the review point.

Keep unrelated cleanups out. Leave "needs decision" items uncommitted until the user rules.

## 4. Respond and resolve

Push the commits so the SHAs are referenceable, then, per inline comment:

- **Fixed** → reply with what changed and the commit SHA, then resolve the thread.
- **Refuted** → reply with the evidence; leave the thread open for the reviewer.
- **Needs decision** → reply with the trade-off, surface it to the user, leave open.

Replying and resolving are outward-facing and public. Invoking this skill authorizes
them, but confirm first if authorization is unclear.

## 5. Report back

Summarize: what you fixed (with SHAs), what you pushed back on and why, and what still
needs the user's decision.
