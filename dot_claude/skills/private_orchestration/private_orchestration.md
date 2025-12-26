---
name: orchestration
description: Multi-agent orchestration patterns and best practices for coordinating complex development workflows. Auto-activates for tasks requiring multiple agents or complex coordination.
---

# Multi-Agent Orchestration Skill

This skill provides patterns and best practices for orchestrating multiple Claude Code agents to solve complex problems efficiently.

## When This Skill Activates

- Tasks spanning multiple domains (frontend + backend + infrastructure)
- Complex features requiring parallel work streams
- System-wide changes or migrations
- Problems requiring multiple types of expertise
- Tasks with explicit coordination needs

## Core Orchestration Principles

### 1. Maximize Parallelism

**Always prefer parallel over sequential when possible:**

```
GOOD (Parallel):
┌─── Research best practices
├─── Explore existing codebase
└─── Review requirements
     ↓
  Synthesize & Plan

BAD (Sequential):
Research → Explore → Review → Plan
```

### 2. Decompose Before Executing

Break complex tasks into atomic subtasks:
- Each subtask should be completable by one agent
- Identify hard vs soft dependencies
- Group independent work for parallel execution

### 3. Synthesize Results

After parallel execution:
- Collect all outputs
- Identify conflicts
- Resolve trade-offs
- Create unified plan

## Agent Catalog

### Orchestration Agents
| Agent | Use For |
|-------|---------|
| `principal-orchestrator` | Overall coordination of complex tasks |
| `task-decomposer` | Breaking down complex work |
| `context-synthesizer` | Combining multi-agent outputs |
| `multi-agent-coordinator` | Low-level coordination |

### Domain Experts
| Agent | Use For |
|-------|---------|
| `architect-advisor` | System design, architecture decisions |
| `quality-guardian` | Security, code quality, testing |
| `refactor-planner` | Code improvement planning |
| `plan-reviewer` | Validating implementation plans |
| `documentation-architect` | Creating documentation |
| `web-research-specialist` | External research |

### Built-in Agents
| Agent | Use For |
|-------|---------|
| `Explore` | Fast codebase exploration |
| `Plan` | Feature implementation planning |
| `general-purpose` | Complex multi-step research |

## Orchestration Patterns

### Pattern 1: Research-Plan-Execute
Best for: New feature implementation

```
Phase 1 (Parallel Research):
├── Explore: Find existing patterns
├── web-research-specialist: Best practices
└── architect-advisor: Design options

Phase 2 (Synthesis):
└── Combine findings, create plan

Phase 3 (Parallel Implementation):
├── Backend work
├── Frontend work
└── Documentation

Phase 4 (Validation):
└── quality-guardian: Review all
```

### Pattern 2: Divide-and-Conquer
Best for: Large refactoring, migrations

```
Phase 1: task-decomposer breaks work

Phase 2 (Parallel):
├── Subtask A
├── Subtask B
└── Subtask C

Phase 3: context-synthesizer combines
```

### Pattern 3: Expert Consultation
Best for: Complex decisions

```
Phase 1 (Parallel Consultation):
├── architect-advisor: Architecture view
├── quality-guardian: Quality view
└── Research: Industry practices

Phase 2: Synthesize recommendations
```

### Pattern 4: Quality Gate
Best for: Production deployments

```
Phase 1 (Parallel Audits):
├── quality-guardian: Security audit
├── quality-guardian: Code review
└── quality-guardian: Performance check

Phase 2: Risk assessment & approval
```

## Launching Parallel Agents

When using the Task tool, launch multiple agents in a single message:

```
// In your response, make multiple Task tool calls:
Task(architect-advisor, "Design API for X")
Task(Explore, "Find existing patterns for X")
Task(web-research-specialist, "Best practices for X")
```

This launches all three agents simultaneously.

## Context Passing

When delegating to agents, always provide:

1. **Goal**: What the agent should accomplish
2. **Context**: What's been done, what's known
3. **Constraints**: Time, technology, compatibility limits
4. **Output Format**: What structure you expect back

## Common Anti-Patterns

### 1. Serial When Parallel Possible
**Bad**: Wait for agent A, then launch agent B, then C
**Good**: Launch A, B, C together if independent

### 2. Over-Delegation
**Bad**: Spawn agent for trivial subtask
**Good**: Handle simple tasks directly

### 3. Under-Synthesis
**Bad**: Just concatenate agent outputs
**Good**: Actively integrate and resolve conflicts

### 4. Missing Context
**Bad**: Launch agent without prior context
**Good**: Pass full context to each agent

## Resource Files

For detailed information on specific agents:
- [Agent Catalog](resources/agent-catalog.md)
- [Orchestration Patterns](resources/patterns.md)
- [Best Practices](resources/best-practices.md)

## Quick Reference

**Complex feature?** → `/orchestrate [description]`
**Need decomposition?** → Task(task-decomposer)
**Multiple perspectives?** → Parallel agent consultations
**Combining results?** → Task(context-synthesizer)
**Quality gate?** → Task(quality-guardian)
