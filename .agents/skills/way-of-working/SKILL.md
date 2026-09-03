---
name: way-of-working
description: Apply team way-of-working priorities for Trello cards, bug columns, staging manual tests, review fixes, and work-in-progress decisions. Use when planning card order, deciding whether to switch tasks, handling Bugs/Priority cards, moving cards through Review & Test, or confirming staging tests.
---

# Way Of Working

## Core Priority Rules

1. Keep the Bugs/Priority column as empty as possible.
2. Prioritize Bugs/Priority cards over new non-bug work, regardless of the card's stated priority.
3. Highest-priority bugs override almost everything else.
4. Do a manual test of your own card as soon as it is on staging.
5. After manual testing your own card on staging, add a confirmation comment to the card.

## Decision Order

When deciding what to work on next:

1. If there is a Highest-priority bug, work on it first.
2. If your own card is in Review & Test and ready for manual testing on staging, test it and add the confirmation comment before taking ordinary Bugs/Priority cards.
3. If your current card has code review comments, complete those fixes before taking ordinary Bugs/Priority cards.
4. If your current card is actively in progress, normally complete it before taking ordinary Bugs/Priority cards.
5. If your current card will take many days, consider pausing it to help reduce the Bugs/Priority column.
6. If none of the above applies, prioritize Bugs/Priority cards before other work.

## Practical Examples

**Card in Review & Test vs Bugs/Priority**

Manual test your own staged card first and add the confirmation comment, unless there is a Highest-priority bug.

**Code review fixes vs Bugs/Priority**

Fix review comments on your current card first, unless there is a Highest-priority bug.

**Large in-progress card vs Bugs/Priority**

Continue the current task by default. If it will take many days, consider pausing it and taking Bugs/Priority work.

## Confirmation Comment

After manually testing your own card on staging, leave a short card comment that states:

```markdown
Manual test completed on staging.
```
