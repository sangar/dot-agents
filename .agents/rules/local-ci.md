---
description: Local CI - checks live in one local entry point, never in new cloud CI, and run on the exact commit before calling work done or pushing
alwaysApply: true
---

# Local CI

You're the CI. Your machine is fast and the checks are cheap to run here, so run them yourself rather than pushing and waiting for a remote pipeline to tell you what broke.
Projects in ~/Work/make-app should follow the projects config, or add / update the conventions for sibling projects.

## One local entry point

Every project outside ~/Work/make-app has one command that runs every check: `bin/ci`, `make ci`, `npm run ci` or similar. Run the whole thing, not just the tests near your change.

## Don't add cloud CI

Never add cloud CI config (`.github/workflows/`, `.gitlab-ci.yml`, CircleCI and the like) to run checks. Add the check to the local entry point instead, creating it if it doesn't exist.

Leave existing cloud CI alone; other people may depend on it. Run local CI anyway, before pushing.

## Sign off on exactly what ships

1. Run every check on the code as it will be committed or pushed. When committing, commit first and run the checks on a clean working tree.
2. If any check fails, fix it and run every check again. Any change after a green run, even a one-line fix, needs a new run.
3. Report the sign-off: the commit SHA (or "uncommitted"), each command run, and its result.

Only then call the work done, or push when the user asks for it.

## Never

- Call work done with failing, skipped or partially run checks
- Sign off on a commit you didn't run the checks on
- Push "to see what CI says" instead of running the checks locally
- Disable, skip or loosen a check to get a green run

## When a check can't run locally

Say which check, and why it can't run (missing service, credentials, platform). Sign off on the rest and list what is unverified. Don't report it as passed.
