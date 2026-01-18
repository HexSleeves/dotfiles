# Claude Code Architecture

Simple setup using Claude Code's native capabilities.

## Components

```
.claude/
├── agents/           # Specialized subagents
├── commands/         # Slash commands (/dev, /plan, etc.)
├── skills/           # Auto-activating knowledge bases
└── settings.json     # Configuration
```

## Available Agents

| Agent | Purpose |
|-------|---------|
| `principal-orchestrator` | Coordinate complex multi-domain tasks |
| `architect-advisor` | System design, architecture decisions |
| `quality-guardian` | Security, code quality, reviews |
| `refactor-planner` | Code improvement planning |
| `documentation-architect` | Create documentation |
| `web-research-specialist` | External research |

## Decision Framework

- **Simple task** → Direct interaction
- **Known workflow** → Use a command (`/dev`, `/plan`, etc.)
- **Domain expertise needed** → Use a subagent
- **Complex multi-step** → `/orchestrate`

## Best Practices

- Start simple, escalate only if needed
- Read files before editing
- Use TodoWrite for multi-step tasks
- Run tests after changes
