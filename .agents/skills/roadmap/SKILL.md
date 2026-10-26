---
name: roadmap
description: >-
  Write, update and review product roadmaps (ROADMAP.md). Use when creating a
  roadmap, adding or ticking off roadmap items, reprioritising, recording what
  shipped, or when the user mentions the roadmap, phases, focus, priorities,
  milestones such as POC or MVP, or feature ideas.
---

# Roadmaps

A roadmap answers three questions for someone new, human or agent: where is
this going, where are we now, and what do I do next. Everything in it serves
one of those.

## Structure

One `ROADMAP.md` at the root of the workspace, covering every repository in
it. Sections in this order:

1. **Vision.** One or two paragraphs on what the product becomes, told from
   the user's side ("someone installs the app, signs up, and..."). Then what
   it deliberately is not, and which repositories the file covers.
2. **`Checked on <YYYY-MM-DD>`.** The date the file was last checked against
   the code, not the date it was last edited.
3. **Focus.** A sentence or two on where the product is and its next
   [stage](#stages), then the three to five big pieces that get it there, in
   order: each a bold name, a line on what it includes and a link to its
   section, where the detail lives. Say what waits: small items wait unless
   they block one of these.
4. **Principles.** Short bullets, each led by a bold phrase, that settle
   trade-offs ("Reports are the product", "The driver owns their private
   trips"). Only ones that have decided, or will decide, a real choice.
5. **Where we are.** A few sentences on what is live, a table per repository
   (state, last commit or build, tests), and what went wrong on the way and
   what changed because of it.
6. **Phases or areas.** One `##` section for each big piece, ordered as they
   will be done and named for what it delivers ("Price and billing", "Before
   the App Store release"). Each opens with a status line ("Done." / "Now." /
   "After X."), why the section exists and its [bar](#planning), then its
   items. A section that takes the product to a new stage says what will show
   it got there.
7. **Feature ideas,** grouped as *Worth doing soon*, *Later*, *Not now* (with
   the condition for revisiting) and *Not doing* (with why). Ordered by value
   for the complexity they add.
8. **Open questions.** Each with the current leaning and how it will be
   decided: a measurement, a conversation, a date.

## Stages

A product moves through stages, and reaches each when something real shows
it, not when the code is written:

- **Proof of concept (POC):** the riskiest assumption holds, tested with as
  little as possible.
- **Minimum viable product (MVP):** real users do the job with the smallest
  version that does it.
- **Beta:** invited users rely on it with their own data.
- **Launch:** strangers find it, sign up and use it without talking to us.
- **Paying customers:** people pay for it.
- **Growth:** more users, teams, countries and integrations.

Place the product by who uses it and what is live, not by what is built.
Stages can merge: launch and paying often do.

The focus is the big pieces that take the product to its next stage, and on
to the stage after when fewer than three get it there. A big piece is a whole
section that users notice when it ships, never a step inside one: "Android on
Google Play", not "register the upload key". For example:

```markdown
## Focus

Trip recording is built on iOS and Android, and the web app and admin are in
production. What moves Trilo forward now are the big pieces that turn it into
a product people pay for, in this order:

1. **Billing on the web:** the 30-day trial, Stripe Checkout and the Customer
   Portal, the webhook, and locking the reports after the trial. See
   [Price and billing](#price-and-billing).
2. **The trilo.no front page and SEO:** the landing page, terms, support and
   company details, and the pages for what people search for. See
   [trilo.no front page](#trilono-front-page).
3. **Paying in the iPhone app and the App Store release:** StoreKit next to
   Stripe, deleting the account, and the rest of
   [Before the App Store release](#before-the-app-store-release).
4. **Android on Google Play:** the upload key, the Play Console, a closed beta
   and drives in a car. See [Phase 4](#phase-4-android-app).

The small items in the rest of this file, such as configuration, review notes
and cleanup jobs, wait unless they block one of these.
```

## Items

```markdown
- [ ] **Outcome in a few words.** Why it matters, what is concrete about it
      (files, endpoints, env vars, accounts), and what "done" looks like.
      1. [x] **Sub-step done,** with what was found or decided.
      2. [ ] **Sub-step left.**
```

- Lead with the outcome, not the task: "Stop bot sign-ups", not "Add rate
  limiting".
- Put the problem before the solution. A reader should be able to choose a
  better solution than the one written down.
- Name the real things: file paths, commands, settings, services, numbers.
- Split anything with more than one step into numbered sub-steps, ordered.
- Note blockers and dependencies inline ("waits for the upload key").
- Order items within a section by what to do first.

## Keeping it true

- Update the roadmap in the same change as the work it describes.
- Before ticking an item, check it against the code, git history or
  production. Then update `Checked on`.
- When an item is done, tick it and leave one sentence on what shipped and
  when, with absolute dates ("deployed on 21 October"), never "yesterday".
- When a whole phase is done, collapse it: "Done." plus a summary line, and
  only the items worth remembering. Leftovers move to where they will be done.
- When the product reaches its next stage, say so under *Where we are* and
  write the focus for the stage after it.
- Record surprises, incidents and reversed decisions under *Where we are*.
  They are why the plan changed.
- Move an idea into a phase only when it is next; until then it stays under
  *Feature ideas*.
- An answered open question becomes a principle, an item, or a *Not doing*
  entry, and leaves *Open questions*.

## Planning

- Plan in outcomes users notice, not output shipped.
- **Set the bar from what people already use.** For each big piece, look at
  the popular products that do the same job: what they all do is expected,
  and what their users praise or complain about is where to do better. Then
  look outside the field, at the best-known products that solve a similar
  problem, for ideas to borrow. Name them: "swipe to sort, as in Mail", "a
  read-only role, as OsmoV has". Check each claim on the product's own pages
  or in its reviews, not from memory.
- Be precise about now, rough about next, vague about later. No dates on
  anything past the current focus.
- Ship each phase to real users before starting the next; slices, not layers.
- Saying what is not being done is half the roadmap.
- Treat every assumption about users, prices or formats as an open question
  until something real (a measurement, three customers) answers it.
- Prefer few items in progress. A long focus list is no focus.

## Style

- Plain, full sentences. Explain in one line what a term means the first time.
- Link between sections with anchors and to files with relative links.
- No status emojis, percentages or owner columns unless the team uses them.
- Detail belongs in the issue tracker or a checklist file; link to it rather
  than copy it.
