---
name: git-scripts
description: Analyze git repository history and patterns using specialized scripts. Use when analyzing commit activity, identifying bug-prone areas, understanding code evolution, measuring development velocity, finding contributors, or when the user mentions git analysis, commit history, repository insights, code churn, or team contribution patterns.
---

# Git Scripts Tool

A collection of command-line utilities for analyzing git repository history and understanding code evolution patterns.

## Available Scripts

| Script | Purpose | Use When |
|--------|---------|----------|
| `git-commit-rate` | Commits per month | Tracking development velocity, identifying activity patterns |
| `git-firefight` | Emergency commits/reverts | Finding instability patterns, measuring quality processes |
| `git-what-changed` | Most modified files | Identifying high-churn areas, refactoring candidates |
| `git-where-bugs` | Bug-prone files | Finding technical debt hotspots, prioritizing testing |
| `git-who-built` | Contributor statistics | Understanding team patterns, identifying maintainers |

## Prerequisites

- Git repository
- Scripts in PATH or accessible
- Run from repository root

## Usage Examples

### Analyze Development Velocity

```bash
git-commit-rate
```

Output:
```
  45 2024-01
  38 2023-12
  52 2023-11
```

### Find Emergency Patterns

```bash
git-firefight
```

Shows reverts, hotfixes, rollbacks in last year.

### Identify High-Churn Files

```bash
git-what-changed
```

Output:
```
  156 src/components/Button.js
   89 src/utils/helpers.js
```

### Locate Bug-Prone Areas

```bash
git-where-bugs
```

Files most associated with bug fix commits.

### View Contributor Stats

```bash
git-who-built
```

Output:
```
  1234  John Smith
   987  Jane Doe
```

## When to Use

Use these scripts when:
- Starting on a new codebase to understand history
- Planning refactoring efforts
- Identifying areas needing tests
- Measuring team velocity or stability
- Reviewing contribution patterns
- Preparing for code audits

## Interpreting Results

**High file churn (`git-what-changed`)** → May need refactoring or better abstraction

**Frequent firefighting (`git-firefight`)** → Quality process issues, need more tests/review

**Concentrated bug fixes (`git-where-bugs`)** → Priority areas for tests and refactoring

**Uneven contributions (`git-who-built`)** → Knowledge silos, bus factor risk

## Customization

Scripts use a 1-year lookback by default. Adjust time window by editing the `--since` parameter:

```bash
git log --since="6 months ago"
git log --since="2023-01-01"
```

## Common Workflows

### New Repository Analysis

```bash
git-who-built      # Understand team
git-what-changed   # Find key files
git-where-bugs     # Identify risk areas
git-firefight      # Check stability
git-commit-rate    # See activity trends
```

### Pre-Refactoring Check

```bash
git-what-changed   # Find highest churn files
git-where-bugs     # Verify if they overlap with bug areas
```

## Output Format

All scripts output plain text suitable for:
- Terminal viewing
- Piping to other tools
- Including in reports
- Saving to files

## See Also

For detailed documentation on each script, see the README in `.agents/tools/git/README.md`.
