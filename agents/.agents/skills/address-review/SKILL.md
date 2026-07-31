---
name: address-review
description: >
  Address the review on a pull request: read every review comment, verify each claim
  against the code with parallel subagents, then delegate the confirmed fixes to
  subagents — one per fix, sequential, atomic commits — and delegate replying to each
  inline comment and resolving its thread. Use when asked to address, respond to, or
  act on PR review feedback. Accepts a PR number, URL, or branch; defaults to the PR
  for the current branch.
---

# Address Review

Turn review feedback into verified fixes, atomic commits, and resolved threads. Not
every comment is correct — confirm each against the code before changing anything, and
push back with reasons when a claim is wrong.

You orchestrate: gather, verify, dispatch, check. Subagents do the work — verifying
claims, editing and committing fixes, replying and resolving threads. Do not edit files
or post replies yourself; your job is sequencing the dispatches and reviewing what comes
back.

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

## 3. Delegate the fixes — one subagent per fix

Order confirmed fixes by dependency and file so commits stay clean, then dispatch one
subagent per fix **sequentially**. They share a working tree: concurrent fixes race on
edits and on the index, and interleaved commits stop being atomic.

Give each subagent everything it needs to work without re-deriving your verification:
the comment text and file:line, the verdict and the concrete fix, and instructions to

- apply the smallest change that addresses the comment, and nothing else;
- verify it — run the relevant build/test/lint — and report the command and result;
- commit atomically: one logical fix, Conventional Commits, imperative mood, referencing
  the review point;
- return the commit SHA, the files touched, and what changed.

Between dispatches, check what came back: inspect the commit, confirm verification
actually ran and passed, and confirm the scope stayed inside the comment. Re-dispatch
with correction when a subagent overreached, left tests failing, or missed the point.
A subagent that reports a fix is impossible or the comment was wrong on closer reading
flips that item to refuted or needs-decision — don't force the fix through.

Keep unrelated cleanups out. Leave "needs decision" items uncommitted until the user rules.

## 4. Delegate replies and resolution

Push the commits so the SHAs are referenceable. Then fan out reply subagents **in
parallel** — one per thread, independent, no shared state. Each gets the thread ID, the
verdict, and the exact SHA, and does one of:

- **Fixed** → reply with what changed and the commit SHA, then resolve the thread.
- **Refuted** → reply with the evidence; leave the thread open for the reviewer.
- **Needs decision** → reply with the trade-off, leave open, and report it back to you
  for the user.

Replying and resolving are outward-facing and public. Invoking this skill authorizes
them, but confirm first if authorization is unclear — and settle that before dispatching,
not after a subagent has already posted.

## 5. Report back

Aggregate the subagent returns and summarize: what was fixed (with SHAs), what you pushed
back on and why, and what still needs the user's decision.
