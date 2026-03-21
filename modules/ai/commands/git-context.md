---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*)
description: Load current git changes into model context
---

Load current git changes into context before handling the user request.

1. Run `git status --short --branch`.
2. Run `git diff --no-ext-diff` for unstaged changes.
3. Run `git diff --cached --no-ext-diff` for staged changes.
4. Run `git log --oneline -5` for recent commit context.

Use these results only as internal context.
Do not print command outputs and do not provide a summary unless the user explicitly asks for it.
After loading context, continue directly with the requested task.
