---
name: code-writer
description: Use when writing or modifying code in any programming language. Apply when adding functions, fixing bugs, or implementing features.
---

# Code Writer

## Overview

Code should communicate intent clearly. Excessive comments and output statements create noise that obscures logic.

**Core principle:** Minimize noise, maximize signal. Comments explain *why*, not *what*. Output statements serve a purpose, not narration.

## Language-Specific Skills

These guidelines apply to all programming languages. For language-specific patterns and conventions, use the appropriate language-specific skill:

- **JavaScript**: Use `js-writer` skill for JavaScript/Node.js code
- **ZSH**: Use `zsh-writer` skill for ZSH functions in .oroshi repository

Language-specific skills extend these core guidelines with syntax and idioms specific to that language.

## When to Use

- Writing new functions or methods
- Modifying existing code
- Adding features or fixing bugs
- Refactoring code

**When NOT to use:**

- Generated code (linters handle style)
- Configuration files (different conventions)

## Output Statements

**Output statements** include: `console.log()`, `print()`, `echo`, `printf()`, `puts`, `System.out.println()`, etc.

### Default: ZERO output statements

**Allowed ONLY for:**

1. **Display functions** - Functions whose purpose IS to output data
2. **Error messages to stderr** - Usage errors with clear error indication

**FORBIDDEN:**

- Progress messages (`"Processing..."`, `"Starting..."`, `"Done"`)
- Status summaries (`"Found X items"`, `"Total: Y"`)
- Empty lines (`console.log("")`)
- Decorative headers (`"===== Summary ====="`)
- Debug traces (`"checkpoint 1"`, `"here"`)

### Examples

```javascript
// ✅ Display function - output IS the purpose
function listBranches(branches) {
  branches.forEach(b => console.log(b.name));
}

// ✅ Error to stderr
if (!filePath) {
  console.error("Error: File path required");
  return null;
}

// ❌ FORBIDDEN - Progress narration
console.log("Starting analysis...");
const results = compute(data);
console.log(`Found ${results.length} items`);
```

**If unsure whether to add output: DON'T.**

## Comments

### Default: Function documentation ONLY

**Allowed:**

1. **Function documentation** - What it does, parameters, return value
2. **Section comments** - ONE comment for 3+ grouped operations
3. **Data meaning** - What data represents (not what code does)

**FORBIDDEN:**

- Explaining what code does (code should be self-explanatory)
- One comment per operation/line
- Loop comments (`// Process each item`)
- Format conversions (`// color1 #ef4444` when RGB already in code)
- Source metadata that isn't actionable (`// from palette index 5`)
- Breadcrumbs from debugging process
- Obvious section headers (`// Additional colors`)

### Examples

```c
// ✅ Explains semantic meaning
#define BLACK ((Color){0, 0, 0})  // Off/disabled

// ❌ FORBIDDEN - Redundant format conversion
#define RED ((Color){239, 68, 68})  // #ef4444

// ❌ FORBIDDEN - Per-line metadata
#define PURPLE ((Color){128, 90, 213})  // color5 from kitty

// ❌ FORBIDDEN - Obvious section header
// Additional color definitions
#define CYAN ((Color){8, 145, 178})
```

```javascript
// ✅ Function documentation
/**
 * Retry operation up to maxAttempts times
 * @param {Function} operation - Async function to retry
 * @returns {Promise} Result of operation
 */
async function retryOperation(operation, maxAttempts) {
  // ...
}

// ✅ ONE section comment for 3+ validations
// Validate required config fields
if (!config.apiKey) throw new Error("Missing apiKey");
if (!config.endpoint) throw new Error("Missing endpoint");
if (!config.timeout) throw new Error("Missing timeout");

// ✅ Data meaning
// First line contains headers
if (lineNumber === 0) {
  return parseHeaders(line);
}

// ❌ FORBIDDEN - Explains what code does
// Check if file exists
if (!fs.existsSync(filePath)) {
  return null;
}

// ❌ FORBIDDEN - Loop comment
// Loop through users
for (const user of users) {
  processUser(user);
}
```

**When editing existing code: Never remove existing comments.**

**If unsure whether to add comment: DON'T.**

## Quick Reference

| Category | Default | Allowed | Forbidden |
|----------|---------|---------|-----------|
| **Output** | Zero | Display functions, errors to stderr | Progress, status, decorative headers |
| **Comments** | Function docs only | Section (3+ ops), data meaning | What code does, per-line, format conversions |

## Common Mistakes

| Mistake | Why Wrong | Fix |
|---------|-----------|-----|
| Per-line comments | Visual noise, obvious from code | Remove, use descriptive names |
| Format conversion comments | Redundant data in different format | Remove, keep one format |
| Progress messages | Narrates obvious execution | Remove or use logging framework |
| Section headers stating obvious | Spatial grouping already clear | Remove |
| Breadcrumb comments | Documents debugging journey | Remove after fixing |

## Real-World Impact

**Before:**
```c
// Additional colors from kitty palette
#define RED     ((Color){239, 68, 68})    // color1 #ef4444
#define PURPLE  ((Color){128, 90, 213})   // color5 #805ad5
#define CYAN    ((Color){8, 145, 178})    // color6 #0891b2
```

**After:**
```c
#define RED     ((Color){239, 68, 68})
#define PURPLE  ((Color){128, 90, 213})
#define CYAN    ((Color){8, 145, 178})
```

Clean code: 60% less noise, same information, better readability.
