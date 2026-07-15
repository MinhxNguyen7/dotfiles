---
name: patent-mining
description: >
  Mine a codebase for patentable inventions: parallel subagents map novel
  mechanisms and non-obvious combinations, then parallel research verifies each
  against prior art (patents, papers, open source), yielding ranked
  attorney-ready invention disclosures. Use when asked to find patentable ideas,
  run an IP audit, prepare invention disclosures, or check patentability or
  prior art of an idea.
---

# Patent Mining

Turn a codebase into a ranked list of invention disclosures a patent attorney can act on. The two heavy phases — the architecture scan and the prior-art research — are embarrassingly parallel. **Run them as fan-out workflows or concurrent subagents; never grind through them sequentially in the main context.** The main context's job is orchestration, triage between phases, and the final report.

## Ground rules

- **Not legal advice.** Output is triage and evidence-gathering for a patent attorney, not a legal opinion. Say so in the report. Never state "this is patentable" — state what prior art was and was not found, and how strong the candidate looks.
- **Confidentiality.** Prior-art research sends queries to external services. Phrase every external query as a generic technical concept ("tactile-feedback residual policy for insertion tasks"), never as proprietary code, internal codenames, file paths, or verbatim invention text. Code stays local; only abstracted concepts go out.
- **Disclosure clocks matter.** Public repos, releases, papers, talks, and demos are prior art against their own inventors. The US gives a 12-month grace period for the inventor's own disclosure; most other jurisdictions (EPO, CN, JP) require absolute novelty. Check whether the code or its ideas are already public and flag the earliest disclosure date per candidate.

## What counts as a candidate

Patents cover technical methods and systems — code itself is copyright. Hunt for the *mechanism*, not the implementation:

| Shape | Signal in code |
|---|---|
| Novel algorithm | Non-textbook math/logic solving a concrete technical problem; no library does it |
| Non-obvious combination | Two or more known techniques fused where the fusion does the work (e.g. sensor modality X gating controller Y) |
| System architecture | Unusual split of responsibilities across components/machines with a measurable technical effect |
| Control/feedback method | Closed-loop logic, safety envelopes, admittance/impedance schemes, curriculum or scheduling logic |
| Data structure / protocol | Purpose-built representation or wire format enabling something previously impractical |
| Hardware–software interplay | Software compensating for or exploiting specific hardware behavior |
| Performance mechanism | Trick with measured effect (latency, memory, accuracy) that changes *how* the machine works, not just how much |
| ML training method | Novel loss, data pipeline, augmentation, sim-to-real transfer, reward shaping — the training *procedure*, not the weights |

The **combination shape is the most commonly missed**: each part can be well known so long as combining them was non-obvious and solves a technical problem. Scanners should report combinations, not just isolated cleverness.

Skip: textbook algorithms, standard design patterns, straightforward use of a library, configuration/tuning, UI/UX, and pure business logic (high §101 rejection risk).

## Pipeline

```
1 Scan (parallel)  →  2 Triage (main)  →  3 Prior-art research (parallel)  →  4 Assess  →  5 Report
```

Scout inline first: enumerate subsystems from the repo layout, README/docs, and build config. That subsystem list is the fan-out input — don't fan out blind.

## Phase 1 — Architecture scan (parallel)

Fan out readers along **two axes simultaneously**:

- **By subsystem**: one agent per major module/package, prompted to explain what is technically unusual about how it works and why it was built that way (git log and design docs are evidence of the problem being solved).
- **By cross-cutting lens**: agents that sweep the whole repo for one invention shape each — algorithms, combinations, control methods, hw/sw interplay, performance mechanisms, ML training methods, protocols/formats.

Subsystem readers find depth; lens sweepers find combinations that span modules. Both return the same structured record:

```json
{
  "title": "short mechanism name",
  "problem": "technical problem it solves",
  "mechanism": "how it works, element by element",
  "novelty_hypothesis": "what specifically seems new or non-obviously combined",
  "evidence": ["src/path/file.py:120-180"],
  "shape": "algorithm | combination | architecture | control | protocol | hw-sw | performance | ml-method"
}
```

Instruct scanners to over-report at this stage (recall over precision) and to explicitly look across module boundaries for combinations.

## Phase 2 — Synthesize and triage (main context)

This step genuinely needs all scan results at once — it is the one legitimate barrier:

1. **Merge duplicates** — subsystem and lens agents will find the same mechanism from different angles; merged records are stronger (more evidence, better articulation).
2. **Compose combinations** — pairs of individually weak findings may form one strong combination candidate. Actively look for these.
3. **Cut** — drop candidates failing the "skip" list or with no articulable novelty hypothesis.
4. **Cap** — carry forward roughly 5–15 candidates. Researching 50 weak candidates wastes the research budget; note the cut list in the final report so nothing silently disappears.

If the user is available, show the triaged list before Phase 3 — they know which mechanisms the team actually considers valuable and which are known-borrowed.

## Phase 3 — Prior-art research (parallel per candidate)

For each candidate, run a **multi-modal sweep** — independent researchers each searching a different corpus, blind to each other:

| Researcher | Where | Looks for |
|---|---|---|
| Patents | Google Patents, Espacenet, WIPO Patentscope, USPTO Patent Public Search | Granted patents and applications with overlapping claims |
| Academic | Google Scholar, arXiv, Semantic Scholar | Papers describing the mechanism or its combination |
| Open source | GitHub/GitLab search, docs of major frameworks in the domain | Existing implementations, even partial |
| Industry | Product docs, engineering blogs, standards, conference talks | Commercial disclosure of the technique |

Every researcher prompt must include: the abstracted mechanism description (never proprietary text — see Ground rules), the element list to match against, and the instruction to return *closest* references with an element-by-element overlap map — a reference that covers 4 of 5 elements matters even though it doesn't anticipate.

Then an **adversarial examiner** agent per candidate: given the candidate and all found references, try to *reject* it the way a patent examiner would — anticipation from a single reference, or an obvious combination of two. Verdict schema:

```json
{
  "closest_references": [{"ref": "...", "type": "patent|paper|oss|product", "elements_disclosed": ["..."]}],
  "surviving_elements": ["elements no reference discloses"],
  "verdict": "blocked | narrowed | clear_so_far",
  "confidence": "low | medium | high",
  "reasoning": "examiner-style rejection attempt and why it did or didn't stick"
}
```

`narrowed` is a common and useful outcome: the broad idea is taken but a specific sub-mechanism survives — record which one.

## Phase 4 — Assessment

For each surviving candidate, score against the actual legal tests:

- **Novelty (§102)** — does any *single* reference disclose every element? (The examiner agent's anticipation attempt.)
- **Non-obviousness (§103)** — would a person of ordinary skill combine the found references to get here, with motivation to combine? Unexpected results, long-felt unsolved need, and failure of others all strengthen the case — cite benchmarks/metrics from the repo if they exist.
- **Eligibility (§101 / Alice)** — software claims need more than an abstract idea on a computer. Strongest framings: improvement to the functioning of a machine, concrete technical effect (latency, accuracy, safety), or coupling to a physical system (robot, sensor). Note the honest framing; don't invent one.
- **Enforceability / detectability** — can infringement be detected from outside the infringer's walls? Server-side or training-time mechanisms often can't; for those, **trade secret may beat patent** (a patent publishes the recipe). Flag this trade-off explicitly.
- **Disclosure status** — is this already public (public repo, paper, release notes)? Earliest date, and which jurisdictions that forecloses.

Recommendation per candidate: `file` (provisional first if timing is tight), `defensive-publication` (cheaply block competitors from patenting it), `trade-secret`, or `drop`.

## Phase 5 — Report

Deliver ranked invention disclosures, strongest first. Per candidate:

1. Title and one-paragraph summary
2. Technical problem and mechanism (element by element — these become claim elements)
3. Evidence in the codebase (file:line) and inventors if derivable from git history
4. Closest prior art with the overlap map, and what survives it
5. Assessment scores + recommendation + confidence
6. Disclosure status / deadlines

Close with the triage cut list (one line each, so the attorney sees what was considered) and the not-legal-advice statement.

## Orchestration notes

- Phases 1 and 3 are pure fan-outs. Use whatever parallel orchestration the harness offers — a workflow/orchestration engine if present, otherwise concurrent subagents (one per scan target in Phase 1; one per candidate×corpus plus one examiner per candidate in Phase 3). This skill's instructions are the opt-in for such tooling. Fall back to sequential only when no parallelism exists.
- Keep triage (Phase 2) and the final report in the main context; everything else is delegated.
- Where the harness supports structured/schema output from subagents, use the schemas above so results merge mechanically.
- Research agents need web search + fetch; scan agents need repo read access. Never hand scan output to research agents unabstracted — the main-context abstraction step is the confidentiality gate.

## Failure modes

- Everything `clear_so_far` → searches too literal; re-run with broader synonyms and adjacent-field terms (prior art for a robotics trick may live in aerospace or gaming).
- Everything `blocked` → examiner treated partial overlap as anticipation; anticipation needs one reference disclosing *all* elements — partial overlaps belong in the §103 analysis.
- No combination candidates → lens sweepers didn't run; add them — combinations are usually the strongest candidates.
- Report asserts patentability → legal opinion overstep; rewrite as evidence + strength assessment for attorney review.
