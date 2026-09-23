---
description: Coding best practices for all projects
alwaysApply: true
---

# Coding Guidelines

## Keep It Simple

- Write the simplest code that solves the problem at hand
- Prefer plain, boring solutions over clever ones
- Don't add abstractions, configuration, or flexibility for hypothetical future needs
- Solve the current problem; don't speculate about what might be needed later
- Delete code rather than commenting it out

## Self-Documenting Code

Code should explain itself. If code needs a comment to be understood, rewrite the code instead.

- Use descriptive, intention-revealing names for variables, functions, classes, and files
- Name things after what they mean in the domain, not how they are implemented
- Extract a well-named function instead of writing a comment describing a block of code
- Keep functions small and focused on a single responsibility
- Keep control flow flat: return early, avoid deep nesting
- Use the language's idioms and standard library so readers recognise familiar patterns
- Make invalid states hard to represent: use types, enums, and constants instead of magic values

## Comments

Explanatory comments should be kept to a minimum. Most comments are a sign that the code is not clear enough.

- **Don't** write comments that restate what the code does
- **Don't** write comments to explain unclear code; make the code clear instead
- **Don't** leave TODO, FIXME, or commented-out code behind
- **Do** comment the *why* when it cannot be expressed in code: a non-obvious business rule, a workaround for a specific bug, a surprising constraint from an external system
- **Do** link to the issue, ticket, or documentation that motivated a non-obvious decision
- Keep public API documentation (docstrings, JSDoc) short and focused on behaviour and contracts, not implementation

## Structure

- Follow the existing conventions and structure of the codebase you are working in
- Put things where the reader would expect to find them
- Keep related code together and unrelated code apart
- Avoid duplication, but don't merge code that only looks similar by coincidence
- Prefer composition over inheritance

## Changes

- Make small, focused changes that do one thing
- Don't refactor, reformat, or "improve" code unrelated to the task
- Don't introduce new dependencies when the standard library or an existing dependency will do
- Remove dead code, unused imports, and unused parameters as you encounter them in code you are already changing
- Handle errors where they can be meaningfully dealt with; don't swallow them silently

## Before Finishing

- Read the diff as if you were the reviewer
- Ask: could a new team member understand this without asking anyone?
- Ask: is there anything here I could remove without losing behaviour?
