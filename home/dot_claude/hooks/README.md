# Hooks

This directory is for Claude Code hooks. Hooks are scripts that run at specific points in Claude's workflow.

## Hook Types

- `UserPromptSubmit` - Before Claude sees user's prompt
- `PreToolUse` - Before a tool executes
- `PostToolUse` - After a tool executes
- `Stop` - After Claude finishes responding

## Configuration

Hooks are registered in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/my-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Current Status

No hooks are currently configured. Add hooks here as needed.
