# Claude Development Guidelines

This document provides development guidelines for this project. Detailed review conventions live in the project skill under `.claude/skills/` (`java-review`).

## Key Resources

- **docs/PLAN.md**: Phased plan, module layout and open decisions
- **docs/**: Architecture, offline auth design and IdP requirements

## IntelliJ MCP Tool Preferences

When working with this project, prefer IntelliJ IDE MCP tools (`mcp__idea__*`) over generic alternatives:

- **File operations**: Use `mcp__idea__read_file`, `mcp__idea__create_new_file` instead of Bash/generic Read/Write
- **Project navigation**: Use `mcp__idea__search_symbol`, `mcp__idea__search_text`, `mcp__idea__list_directory_tree` for code exploration
- **Building/testing**: Use `mcp__idea__build_project`, `mcp__idea__execute_run_configuration` instead of manual mvn commands
- **Refactoring**: Use `mcp__idea__rename_refactoring` for safe renames across the project
- **Git operations**: Use `mcp__idea__git_status` to check repo state
- **Linting/diagnostics**: Use `mcp__idea__get_file_problems`, `mcp__idea__lint_files` for code quality checks
- **Debugging**: Use `mcp__idea__xdebug_*` tools for stepping through code when needed

IntelliJ MCP tools are aware of the project structure, dependencies, and IDE state, making them more reliable than shell-based alternatives.

## Architecture Overview

JavaFX desktop app (SnapFX UI, PF4J plugins) demonstrating OIDC login that keeps working when the IdP is unreachable. Maven multi-module, JDK 21, classpath (no JPMS):

- `auth-api`: `AuthProvider` extension point, token/session model
- `app`: JavaFX + SnapFX shell, PF4J host
- `plugin-oidc-online`: discovery, Authorization Code + PKCE, refresh
- `plugin-oidc-offline`: encrypted token cache, JWKS cache, offline policy

See `docs/PLAN.md` for phases and open decisions.

### Key Architectural Patterns

**Plugins** — Auth providers are PF4J plugins loaded from `plugins/` at startup. Plugins depend on `auth-api` only; the app never depends on a plugin module.

**Offline policy** — Time-based checks use an injected `Clock`. Tokens at rest are always encrypted (AES-GCM); the max-offline window is the documented trade-off for undetectable revocation.

## Git Commit Messages

Commit messages use a **one-line format with semicolons** to separate concerns:

```
Brief action; additional change; optional note
```

**Examples:**
- `Add offline policy with fixed-clock tests; reject tokens past the max-offline window`
- `Simplify token store contract: throw on corrupted data instead of returning null; remove nullable returns`

**Guidelines:**
- One line only — concise and scannable in git log
- Use semicolons to separate multiple logical changes
- Use imperative mood: "add", "fix", "refactor" (not "added", "fixed")
- Focus on **what changed and why**, not implementation details
- Capitalize first word
- No period at end

## Implementation Tasks

During implementation tasks (planning, coding, testing):
- **Do not commit** unless explicitly asked
- Work iteratively and validate completeness before committing
- Use feature branches for significant work
- Plan all changes upfront before execution
