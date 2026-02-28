---
tags:
  - docs
---


# ADR-001: Use Architectural Decision Records
| | |
| ---| ---|
| **Status** | 🟢 Accepted |
| **Created**  | 2025-10-12 |
| **Last Updated**  | 2025-10-12 |
| **Deciders** | Gemma Danks |

---

## Context

Architectural decisions are design choices that have a significant impact on one or more architecture qualities (e.g. modifiability, maintainability, observability, testability, scalability, interoperability, extensibility, portability). These decisions shape both the current state of a project and its long-term trajectory. Over time, the rationale for these decisions can get lost if they are not written down. One certainty in software development is that there will at some point be a need, or a desire, to change and adapt to new requirements, technologies and best practices.

Without knowing why a decision was made, there is a risk that future developers will not feel empowered to make changes. This will lead to the accumulation of technical debt when working around the current architecture in the short-term and, in the long-term, will make the project obsolete. Conversely, there may be a very good reason for sticking to the original decision but if future developers are not aware of this reason they may make changes that must later be reverted, wasting time and effort. Nygard refers to these two alternatives as "blind acceptance" and "blind reversal" in [a 2011 blog post on documenting architectural decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions), which we recommend reading for additional context.

Another force to consider, at the time of writing in 2025, is the rapid adoption of AI tools for software development. A future developer may defer to an AI coding assistant or agent to recommend changes. Unless there is an AI-readable record of the rationale for earlier decisions, these tools are more likely to recommend reversing those they see as suboptimal. If this record exists, however, AI can be used more effectively to evolve a project and help onboard new developers (e.g. by providing summaries, answering questions and explaining the rationale behind certain choices).

## Problem Statement

How do we share the rationale for architectural decisions with future human or AI developers so that they can make more informed choices that ensure the continuity and evolvability of the project?

## Options Considered

|    Option    | Description                    | Maintainability | Knowledge Retention | Traceability | AI Usability | Effort | Discoverability | Overall score | Notes |
|--------------|--------------------------------|-------------|-----------------|-------------| ----- | ------|------| ----| ---|
| **Weight**   | -                              | 1  | 2 | 1  | 1  | 1 | 1 | - |
| **ADR**      | Architectural Decision Record  | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | 21 |  |
| **Docs**     | Architecture page in docs      | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ✅ | 20 |  |
| **README**   | Architecture section in README | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ⚠️ | 19 |  |
| **Diagrams** | Flowcharts of decision trees   | ⚠️ | ⚠️ | ❌ | ❌ | ⚠️ | ⚠️ | 11  |  |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

Maintaining a collection of [Architectural Decision Records](https://adr.github.io/) (ADRs) has been standard practice in industry, beginning the 1990s and popularised by [Nygard's 2011 blog post](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions). ADRs are small text files, written in Markdown, that describe the context, the decision, and the consequences of the decision (both good and bad). They ensures a detailed decision history that is human and AI-readable. Several templates for ADRs have been developed and are in use. These vary in the number of sections and level of detail and can be customised. They are easy to maintain and provide the best way to retain history of rationale for decisions but there is a larger effort involved in creating and reviewing them.

Informal documentation in the project README or docs requires less effort and is easy to maintain but the history is mostly in the git commits and is harder to find and evaluate by humans. Using the documentation rather than the README makes the information more discoverable.

Flowcharts provide a human-friendly visual overview but are more difficult to maintain and not as AI-friendly (although flowcharts as code is AI-friendly and might work well as a supplement if they are kept up-to-date).

## Decision Outcome

We will keep a collection of [Architectural Decision Records](https://adr.github.io/) using a template based on [MADR](https://adr.github.io/madr/), which extends the template proposed by Nygard to include evaluating alternatives, which provides additional valuable knowledge to share with future developers and facilitates a re-evaluation at a later date.

The **title** in the ADR file will use the pattern `ADR-NNN: <Verb> <Object> [optional qualifier]`, where NNN is a zero padded three digit number (e.g. ADR-001: Use Architectural Decision Records). ADRs will be numbered sequentially and monotonically. Numbers will not be reused.

**Metadata** listed under the title will include: the status of the ADR (🟡 Proposed, if not yet agreed upon and/or under review / 🟢 Accepted if agreed upon / 🔵 Superseded by ADR-NNN if another decision reverses/replaces it), the date created, date last updated, a list of decision-makers and a list of tags.

A **Context** section will describe the forces at play in value-neutral language, stating the facts on the background to a decision.

A **Problem Statement** will summarise the challenge faced and, where possible, articulate it as a clear question to be answered.

An **Options Considered** section will include a decision matrix scoring each of the options considered against the key drivers behind the decision. To avoid false precision, a simple scoring system will be used to rate an option as either good (✅), ok (⚠️) or poor (❌). Emoticons will be used to provide human readers with a quick visual overview. These are also readable by current AI tools, such as ChatGPT, and keeping a legend with numerical scoring improves AI-readability. Optional weights will represent the relative importance of drivers and an overall score used to rank the options. A short description will supplement and summarise this decision matrix.

The **Decision Outcome** section states the final decision and the justification based on the results of the decision matrix evaluation. It is stated in full sentences, with active voice.

A **Consequences** section describes the resulting context, after applying the decision. This should describe both the positive and negative impacts of the decision on the project and should also list any unknowns or risks (and optionally what should be done to mitigate these risks).

The whole document should be one or two pages long. We will write each ADR as if it is a conversation with a future developer and in a way that maximises its usefulness for AI assistants.

We will keep ADRs in the project repository under `docs/architecture/adr/`. The filename will match the ADR title without the `ADR` prefix, all lowercase and `-` replacing spaces, e.g. `001-use-architectural-decision-records.md`. A template in this directory (`template.md`) will used for all new ADRs for consistency.

If we change a decision at a later date, we will keep the old ADR but mark it as superseded. This way it is available for additional context.

## Consequences

Future developers will have clarity over why architecturally significant decisions were made and feel empowered to reverse these decisions as technologies and best practices evolve. AI assistants will gain the context needed to make better suggestions and recommendations. Developers will also benefit from using AI to summarise and explain earlier decisions. This will also be a powerful way to quickly onboard new developers, particularly as the collection of ADRs grows.

There will be additional effort required for developers to create and review ADRs but this will pay off in the long-run by reducing the risk of wasting time and effort changing decisions that should not be changed or repeating mistakes that sharing more knowledge would have prevented. Effort can be reduced by using AI assistants to draft and review ADRs (this ADR and the template can be provided as context).

## Confirmation

Developers will be prompted to confirm that they have checked for relevant ADRs when opening a PR. If they are making changes that includes a design choice they will be prompted to create a new ADR with status "Proposed", which must be reviewed and accepted before merging any code changes.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | |
| **Issues** | |
| **PRs**    | |
