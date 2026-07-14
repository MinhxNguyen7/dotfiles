---
name: challenge-hypotheses
description: >
  Adversarially stress-test the hypotheses the current or upcoming work stands on:
  extract each as a falsifiable claim, dispatch fresh-context subagents to refute it,
  update the plan from the verdicts. Use when expensive or hard-to-reverse work hinges
  on an unverified diagnosis or assumption, when debugging keeps not converging, when
  evidence fits one theory a little too well, or when the user asks to challenge or
  red-team the premises (optionally naming a claim).
---

# Challenge Hypotheses

Claims adopted early — "the bug is in X", "the library supports Y" — stop being questioned and start filtering the evidence. **A hypothesis that survives an honest refutation attempt has earned its place; one merely never challenged has not.**

Reviewers must have fresh context: never a fork — it inherits the bias under test. Without fresh-context subagents, use a separate or cleared session, or a reviewer given only the step-2 brief; never more reasoning in the current context.

If the invocation names a claim, skip steps 1 and 3: restate it neutrally (step 2) and dispatch (step 4).

## 1. Extract the hypotheses

List the claims the work stands on: **diagnoses** ("the failure is caused by X"), **factual assumptions** ("the API supports batch mode"), **strategy premises** ("doing A will achieve B"), **scope framings** ("only this module is involved").

In scope:

- Inferences, however well-supported. A diagnosis is always inference; only the raw observation (exact error text, literal output, code actually read) counts as directly observed.
- Claims from anyone. A user statement of fact is still a hypothesis; who asserted it affects only step 6.
- Claims you never articulated. Blind spots are invisible to you: have one fresh subagent derive the list independently from the artifacts (plan, diff, raw observations); merge what it adds.

Exploratory work resting on no contestable claims: say so and stop.

## 2. Restate each neutrally

Write the brief a reviewer receives:

- The claim, as one falsifiable sentence.
- Observations behind it — raw facts with reproduce pointers (command, `file:line`), not your reading of them.
- Observations you set aside — anomalies explained away to keep the claim alive. The reviewer's highest-value leads.
- What would count as refutation.

Check before dispatch: no mention of the plan, invested effort, or hoped-for verdict; no verdict-loading words; the brief must equally serve arguing the claim's negation.

## 3. Rank and select

Order by **blast radius × uncertainty** — work invalidated if false × how indirectly established. Challenge the top ~3; all of them when stakes are high (irreversible actions, hours-long jobs, external commitments) or the user asks.

Force-include the claim you would be most reluctant to see fall. Reluctance signals investment, not safety.

## 4. Dispatch adversarial reviewers

One fresh subagent per selected hypothesis (parallel where tooling allows), with a three-part mandate:

1. **Substitute** — strongest alternative explanations consistent with the same observations, before the refutation hunt anchors you.
2. **Refute** — hunt counter-evidence in code, data, docs, online. It counts only if it would change the verdict or plan; the brief's refutation bar is a floor, not the whole test.
3. **Discriminate** — cheapest decisive test separating claim from alternatives, pass/fail rule stated up front.

Reviewers may read anything and run non-destructive experiments — reversible and local (tests, scratch or working-tree state), nothing externally visible (pushes, deploys, deletions elsewhere).

Require a structured verdict: **REFUTED / WEAKENED / HOLDS / UNTESTABLE**, plus confidence, evidence, best alternative, decisive test, and what the reviewer could not access. REFUTED requires positive counter-evidence; failing to find support is UNTESTABLE or low-confidence HOLDS.

High stakes: split the three mandates across three reviewers — one reviewer stops at its first satisfying answer.

## 5. Run the cheap decisive tests

If a verdict hangs on a fast, non-destructive test, run it now. Judge only against the pass/fail rule fixed before the run; an ambiguous result is UNTESTABLE, not reinterpretation in the claim's favor.

## 6. Update, don't defend

Report verdicts verbatim — never downgrade one. To dispute one: re-dispatch a fresh reviewer with your rebuttal, or surface both positions to the user; never self-adjudicate.

| Hypothesis | Verdict | Key evidence | Consequence for plan |
|---|---|---|---|

- **REFUTED** → stop dependent work; re-diagnose with the best alternative as the new lead; state which completed work is invalidated.
- **WEAKENED** → continue only behind the decisive test.
- **UNTESTABLE** → open risk, not a pass: flag the assumption to the user and gate dependent work, or make it testable.
- **HOLDS** → proceed; record what was checked so it is not re-litigated.

Sunk work is not evidence. If the user asserted a refuted claim, present the counter-evidence and let them rule — neither silently override nor silently comply.
