# Git Analysis Toolkit

A collection of specialized git scripts for analyzing repository history, understanding code evolution, and identifying patterns in development workflows. These tools provide quick insights into commit activity, bug-prone areas, contributor patterns, and more.

## Overview

This toolkit provides a set of command-line utilities that wrap common git log analysis operations. Each script focuses on a specific aspect of repository analysis, making it easy to understand the health, history, and evolution of your codebase.

## Installation

1. Clone or copy these scripts to a directory in your PATH
2. Ensure the scripts are executable:
   ```bash
   chmod +x git-*
   ```
3. The scripts use zsh, so ensure zsh is installed on your system

## Tools

### git-commit-rate

Analyzes the frequency of commits over time, showing commit count per month.

**Usage:**
```bash
git-commit-rate
```

**Output:**
```
  45 2024-01
  38 2023-12
  52 2023-11
  ...
```

**Use Cases:**
- Track development velocity over time
- Identify periods of high/low activity
- Understand seasonal patterns in development
- Measure the impact of process changes

### git-firefight

Identifies emergency commits, reverts, hotfixes, and rollbacks in the last year.

**Usage:**
```bash
git-firefight
```

**Output:**
```
a1b2c3d Revert "Introduce feature X"
e4f5g6h hotfix: critical security patch
i7j8k9l emergency: fix production outage
```

**Use Cases:**
- Identify patterns of instability
- Measure how often emergencies occur
- Track the effectiveness of quality processes
- Review post-mortem opportunities

### git-what-changed

Shows the most frequently modified files in the last year.

**Usage:**
```bash
git-what-changed
```

**Output:**
```
  156 src/components/Button.js
   89 src/utils/helpers.js
   67 config/webpack.config.js
   ...
```

**Use Cases:**
- Identify high-churn files that may need refactoring
- Find files that are central to the codebase
- Detect areas that require more tests
- Understand which parts of the code are evolving

### git-where-bugs

Identifies files most associated with bug fixes by searching commit messages for bug-related keywords.

**Usage:**
```bash
git-where-bugs
```

**Output:**
```
   23 src/services/auth.js
   18 src/components/Form.jsx
   15 src/utils/validation.ts
   ...
```

**Use Cases:**
- Find the most bug-prone areas of the codebase
- Identify files that need better testing
- Guide refactoring priorities
- Understand technical debt hotspots

### git-who-built

Shows contributor statistics, listing authors ranked by their number of non-merge commits.

**Usage:**
```bash
git-who-built
```

**Output:**
```
  1234  John Smith
   987  Jane Doe
   456  Bob Johnson
   ...
```

**Use Cases:**
- Understand team contribution patterns
- Identify key maintainers
- Track onboarding progress of new developers
- Review code ownership distribution

## How It Works

All scripts leverage git's built-in logging and filtering capabilities:

- **`git log`**: Retrieves commit history with customizable formatting
- **`git shortlog`**: Provides summarized commit statistics by author
- **`grep`**: Filters commit messages for patterns
- **`sort`/`uniq`**: Aggregates and counts occurrences

The scripts use zsh and pipe operations to transform raw git data into actionable insights.

## Customization

You can modify any script to adjust the time window or search patterns:

- Change `--since="1 year ago"` to `--since="6 months ago"` or `--since="2023-01-01"`
- Adjust the `head -20` count to show more or fewer results
- Modify grep patterns in `git-firefight` or `git-where-bugs` to match your commit conventions

## Tips

1. Run these tools from the root of your git repository
2. Ensure you have fetched the latest commits for accurate analysis
3. Combine these tools for comprehensive repository analysis
4. Run periodically to track trends over time

## Requirements

- Git repository
- zsh shell
- Standard Unix utilities (sort, uniq, grep, head)

## License

These scripts are provided as-is for repository analysis purposes.
