---
description: Generate clean commit message following project conventions
allowed-tools: Bash(git:*)
---

# Git Commit Message Generator

Analyze staged changes and generate a clean, professional commit message.

## Steps

1. Run `git status` to see changed files
2. Run `git diff --staged` to see actual changes
3. Run `git log --oneline -5` to understand commit style

## Commit Format

```
Brief, imperative title under 50 characters

Detailed explanation of what changed and why. Focus on motivation
and context rather than describing the code changes themselves.

- Use bullet points for multiple related changes
- Reference issues when relevant: Resolves #123

Breaking Changes: (if applicable)
```

## Guidelines

- **Title**: Imperative mood ("Add feature" not "Added" or "Adds")
- **Body**: Explain the "why" and provide context
- **Length**: Title ≤50 chars, body wrapped at 72 chars
- **NO**: Co-authored-by, AI attribution, or generated-by footers

## After Message

Create the commit with the generated message.
