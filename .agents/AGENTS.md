# Agent Skills

Skills live in `~/.agents/skills/<name>/SKILL.md`. Claude Code only discovers skills from `~/.claude/skills/`, which is a symlink to this repository's `.claude/skills/`. Each skill gets a tracked relative symlink there: `ln -s ../../.agents/skills/<name> .claude/skills/<name>`, run from the repository root. The `@`-imports below take literal paths and do not expand globs; a skill is listed here only when it should be inlined into every session.

@~/.agents/skills/**/SKILL.md
@~/.agents/skills/errbit/SKILL.md
@~/.agents/skills/trello/SKILL.md
@~/.agents/skills/victoria-logs/SKILL.md
@~/.agents/skills/git-scripts/SKILL.md

# Agent Rules

Project rules are located in `.agents/rules/` to provide persistent context for the AI agent.
Global rules are located in `~/.agents/rules/` to provide persistent context for the AI agent.

# Agent Tools

Agent tools are located in `~/.agents/tools/` to provide agents access to AI tools.

# Testing

@~/.agents/rules/testing.md

# Coding

@~/.agents/rules/coding.md
