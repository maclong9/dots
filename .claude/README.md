# Claude Code Configuration

Minimal, efficient configuration for complete-stack Swift and modern web development.

## Structure

```
.claude/
├── CLAUDE.md                 # Core philosophy (70 lines)
├── settings.json             # Claude Code settings
├── agents/                   # 6 streamlined specialists
│   ├── swift-stack-specialist.md
│   ├── web-stack-specialist.md
│   ├── posix-shell-specialist.md
│   ├── pkl-specialist.md
│   ├── container-specialist.md
│   └── debug-specialist.md
└── commands/                 # 2 focused commands
    ├── commit.md
    └── review.md
```

## Tech Stack

### Complete-Stack Swift
- Swift 6 + SwiftUI (iOS, macOS, watchOS, tvOS)
- Hummingbird backend + Fluent/PostgreSQL/Redis
- WebUI server-rendered frontend
- PKL configuration
- apple/container deployment

### Modern Web
- TypeScript + Next.js 14+
- React Server Components
- Deno/Fresh
- TailwindCSS

### Infrastructure
- POSIX shell scripting
- apple/container for production
- Multi-service orchestration

## Agents

Agents auto-activate based on context:
- **swift-stack-specialist**: All Swift development (language, SwiftUI, Hummingbird, WebUI, DB)
- **web-stack-specialist**: All web development (TypeScript, Next.js, React, Tailwind)
- **posix-shell-specialist**: CLI tools and shell scripting
- **pkl-specialist**: Configuration management
- **container-specialist**: Deployment and orchestration
- **debug-specialist**: Cross-language troubleshooting

## Commands

- `/commit` - Generate clean commit messages
- `/review` - Quick code quality assessment

## Philosophy

**Research → Plan → Implement**
1. Understand existing patterns
2. Use TodoWrite for multi-step tasks
3. Build incrementally, validate continuously

**Code Standards**
- ≤50 lines per function
- Single responsibility
- Type safety (no `any`, `interface{}`)
- Test-driven development

**Decision Framework**
Prefer: Testable → Readable → Consistent → Simple → Reversible

## Benefits

✅ **Minimal** - 6 agents vs 27, focused on your stack
✅ **Efficient** - Fast context loading, no bloat
✅ **Complete** - Covers Swift, web, infrastructure, debugging
✅ **Production-ready** - Deployment strategies included

Built for complete-stack Swift and modern web development.
