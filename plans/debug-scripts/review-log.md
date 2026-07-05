## Issue 02 — debug-script skill

### Missing template sections (Overview, Core Workflow, Rationalizations, Checklist)

```markdown
# Debug Script

## When to Use
...
## Pattern
...
## ZSH Example
...
## Node Variant
...
```

**Problem:** Standards agent flagged missing Overview, Core Workflow steps, Common Rationalizations table, and Checklist as hard violations against skill-template.md.
**Reason skipped:** The procedural template applies to workflow skills. Reference skills (caveman, code-writer) use flat prose. debug-script is a reference — padding it with empty workflow scaffolding would reduce clarity.

### Node variant reads JSON with require('fs')

```js
const entries = JSON.parse(require('fs').readFileSync(file, 'utf8'));
```

**Problem:** CLAUDE.md says "DON'T: Use python or node to inspect JSON. Use jq instead."
**Reason skipped:** The rule targets using node as a JSON inspection tool. This is a Node script example that happens to read a JSON file — it is not an inspection use case. Rewriting with jq would make the Node example nonsensical.
