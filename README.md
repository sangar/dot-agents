# Agent Configuration Repository

This repository contains configuration, tools, and skills for AI agents running in the OpenCode environment.

## Overview

This is a personal agent configuration repository that provides:
- **Skills**: Reusable domain-specific capabilities (Trello, VictoriaLogs, Errbit, etc.)
- **Tools**: Command-line utilities for external service integration
- **Rules**: Persistent guidance for AI agent behavior
- **Planner Configuration**: System prompts and workflows for agent orchestration

## Repository Structure

```
.
├── .agents/
│   ├── AGENTS.md              # Agent guidance and conventions
│   ├── planner/               # Planner system configuration
│   │   ├── system.md          # Core system prompts
│   │   ├── workflows/         # Workflow definitions
│   │   ├── memory/            # Memory management
│   │   └── tests/             # Test configurations
│   ├── rules/                 # Persistent agent rules
│   ├── skills/                # Agent skills (domain capabilities)
│   │   ├── browser-automation/
│   │   ├── c-best-practices/
│   │   ├── c-libraries/
│   │   ├── create-agent/
│   │   ├── create-rule/
│   │   ├── create-skill/
│   │   ├── create-tool/
│   │   ├── errbit/
│   │   ├── git-scripts/
│   │   ├── migrate-to-skills/
│   │   ├── trello/
│   │   └── victoria-logs/
│   └── tools/                 # External tool integrations
│       ├── errbit/
│       ├── git/
│       ├── trello/
│       └── vlogs/
├── .claude/
│   ├── CLAUDE.md              # Claude-specific configuration
│   └── skills/                # Symlinks into .agents/skills/ for Claude Code discovery
├── .config/
│   └── opencode/
│       └── AGENTS.md          # OpenCode configuration reference
└── install.sh                 # Links ~/.agents, ~/.claude/CLAUDE.md and ~/.claude/skills here
```

## Available Skills

| Skill | Description |
|-------|-------------|
| `browser-automation` | Reliable browser automation using OpenCode Browser primitives |
| `c-best-practices` | Performance-oriented C style: arenas, pools, length-based strings, explicit ownership |
| `c-libraries` | Find and evaluate existing C libraries before reimplementing, with a Go-to-C package map |
| `create-agent` | Scaffold production-grade subagent configurations |
| `create-rule` | Create persistent AI guidance rules |
| `create-skill` | Author new agent skills |
| `create-tool` | Create external tool integrations |
| `errbit` | Interface with Errbit error tracking |
| `git-scripts` | Analyze git repository history and patterns |
| `migrate-to-skills` | Convert rules and commands to skills format |
| `trello` | Interface with Trello boards and cards |
| `victoria-logs` | Query and analyze VictoriaLogs |

## Available Tools

| Tool | Purpose | Language |
|------|---------|----------|
| `errbit` | Error tracking integration | Ruby |
| `git-scripts` | Git analysis utilities | Shell |
| `trello` | Trello API integration | Ruby |
| `vlogs` | VictoriaLogs queries | Ruby |

## Setup

On a new machine, clone the repository and run the install script once. It symlinks `~/.agents`, `~/.claude/CLAUDE.md` and `~/.claude/skills` into the repository and is safe to rerun.

```bash
./install.sh
```

## Usage

Skills are automatically loaded when relevant tasks are detected. To use a skill explicitly:

```
@skill_name
```

Tools can be invoked from the command line or by agents:

```bash
# Git analysis
.agents/tools/git/git-what-changed
.agents/tools/git/git-who-built

# Trello operations
.agents/tools/trello/tool.rb <operation> [args]

# VictoriaLogs queries
.agents/tools/vlogs/vlogs <query>
```

## Configuration

Agent behavior is guided by:
- `.agents/AGENTS.md` - Project-level conventions
- `.agents/rules/*.md` - Persistent rules
- `~/.agents/rules/*.md` - Global user rules (not in this repo)

## Skill Locations

Skills live in `.agents/skills/<name>/SKILL.md`. Claude Code does not look there. It only discovers skills from `~/.claude/skills/`, project `.claude/skills/`, plugins, and synced skills.

So `.claude/skills/` in this repository holds a tracked relative symlink per skill, pointing at `../../.agents/skills/<name>`, and `~/.claude/skills` is a symlink to that directory. Pulling the repository is enough for a new skill to appear in Claude Code on every machine.

When adding a skill:

```bash
ln -s ../../.agents/skills/<name> .claude/skills/<name>
```

The `@~/.agents/skills/**/SKILL.md` line in `.agents/AGENTS.md` does not expand. `@`-imports take literal paths only. A skill is inlined into every session only when listed with its full path, which is heavier than skill discovery and is reserved for skills that should always be in context.

The `synced/` folder inside `.claude/skills/` is managed by claude.ai and is gitignored.

## Development

This repository is actively developed. When modifying:
- **Skills**: Update corresponding `SKILL.md` files, and add a symlink under `.claude/skills/` for new skills (see Skill Locations)
- **Tools**: Update `README.md` and `USAGE.md` documentation
- **Rules**: Changes take effect immediately for agent sessions

## Security

⚠️ **Never commit credentials or secrets:**
- `.env` files are gitignored
- Token files (`.trello_token`, `.errbit_token`) are gitignored
- Use environment variables or secure credential storage

## License

Private configuration repository.
