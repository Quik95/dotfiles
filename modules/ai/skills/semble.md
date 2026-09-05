---
name: semble
description: Search a codebase by intent, behavior, or unknown symbols. Use before broad text searches when exploring code or understanding an implementation.
---

# Semble

Use `semble search` for semantic or exploratory code search. It builds and maintains a local cache automatically.

```bash
semble search "authentication flow" . --max-snippet-lines 10
semble search "save model to disk" . --top-k 10
semble search "database host port" . --content config
```

Use `semble find-related <file> <line> .` after finding a promising result to locate similar code.

Use `rg` only when every literal occurrence is needed.
