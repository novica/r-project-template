# ADR-NNN: short title for solved problem and found solution
| | |
| ---| ---|
| **Status** |  🟡 Proposed / 🟢 Accepted / 🔵 Superseded by ADR-NNN |
| **Created**  | YYYY-MM-DD |
| **Last Updated**  | YYYY-MM-DD |
| **Deciders** | Name |
| **Tags** | template |

---

## Context

Describe the background and constraints written for future human **and AI** developers.

## Problem Statement

Summarize the main challenge in one or two sentences.
Then, phrase the decision explicitly as a question.

## Options Considered

Use the table below to evaluate your options against key decision drivers.
1.	**Define your drivers** — the forces, constraints, or architectural qualities that matter most (e.g. scalability, maintainability, observability, budget, effort).
Add each driver as a column name.
2.	**List your options** — add each considered solution as a row.
3. **(Optional) Assign weights** to drivers to show relative importance.
4.	**Describe each option** — one line summary.
5.	**Score each option** for how well it satisfies each driver using the legend: ✅ = 3 (Good) ⚠️ = 2 (Acceptable) ❌ = 1 (Poor)
6.	**Compute overall score**:
```
overall score = (Driver1 weight × Driver1 score)
              + (Driver2 weight × Driver2 score)
              + ...
              + (DriverN weight × DriverN score)
```
7. **(Optional) Add short notes** on the main pros and cons for each option.
8. **(Optional) Sort the rows** according to the overall score (best fit at the top)

|  Option  | Description | Driver 1 | Driver 2 | Driver N | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|
| **Weight**   | - | 1 | 1 | 1 | - |
| **A** |  |  |  |  |  | |
| **B** |  |  |  |  |  | |
| **C** |  |  |  |  |  | |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will use **Option X** because...

Justify your choice using the results of the decision matrix above. Describe evidence to support the scoring.

## Consequences

* Good, because...
* Bad, because...
* Unknowns/risks

## Confirmation

How will you ensure this ADR is implemented and enforced?

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | |
| **Issues** | |
| **PRs**    | |
