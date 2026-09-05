---
name: ast-grep
description: Perform precise structural code searches and AST-safe repetitive edits. Use for syntax-aware searches, refactors, or transformations across source files.
---

# ast-grep

Use `ast-grep` when matching code structure rather than text. Always search first and inspect results before applying a rewrite.

```bash
ast-grep run --pattern 'console.log($$$ARGS)' --lang ts
ast-grep run --pattern 'console.log($$$ARGS)' --rewrite 'logger.debug($$$ARGS)' --lang ts --update-all
```

Use `--globs` to limit files and `--json=compact` when machine-readable results are useful. Never run `--update-all` before verifying the matching search.
