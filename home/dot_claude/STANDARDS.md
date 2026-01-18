# Code Standards

## Universal

- Clear, descriptive test names
- Semantic commits (feat:, fix:, docs:, etc.)
- Format before commit
- Run pre-commit checks

## TypeScript

- Runtime: Bun or Node.js 20+
- Linting: Biome or ESLint 9+ flat config
- Testing: Vitest or Jest
- Strict mode enabled

## Go

- ConnectRPC for services
- Table-driven tests
- 95%+ coverage target

## Shell Tools

**Use:** `rg`, `fd`, `bat`, `eza`, `jq`, `yq`, `fzf`
**Avoid:** `grep`, `find`, `cat`, `ls`
