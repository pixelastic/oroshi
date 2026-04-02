# Conventional Commits Reference

## Format

```
<type>(<scope>): <description>

<body>
```

## Type

Common types (most frequently used first):

- **feat**: A new feature
- **fix**: A bug fix
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, whitespace)
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependencies, build process

## Scope

The scope should indicate the area of the codebase affected:

- Use lowercase
- Keep it concise (1-2 words)
- Examples: `auth`, `api`, `ui`, `database`, `config`, `cli`
- Can be omitted if change is global or doesn't fit a specific area

## Description

- Use imperative mood ("add" not "added" or "adds")
- Lowercase first letter (unless proper noun)
- No period at the end
- Keep under 72 characters
- Be specific but concise

## Body

- Separated from description by blank line
- Explain the core WHAT and essential WHY (not HOW - that's in the code)
- Be concise: 1-3 sentences for simple changes, more only if needed
- Avoid listing all file changes (git already shows this)
- Wrap at 72 characters per line
- Can have multiple paragraphs for complex changes

## Examples

### Simple feature
```
feat(auth): add password reset functionality

Users can request email reset links that expire after 1 hour,
with rate limiting (3 requests/hour) to prevent abuse.
```

### Bug fix
```
fix(api): prevent race condition in user creation

Add transaction lock to prevent duplicate user accounts when
multiple requests arrive simultaneously. Fixes 500 errors
during peak traffic.
```

### Refactoring
```
refactor(database): extract query builder into separate module

Move query construction into dedicated QueryBuilder class to
improve testability and reduce duplication. No functional changes.
```

### Multiple concerns example
If changes touch multiple unrelated areas, create separate commits:

```
feat(cli): add color output support
fix(config): resolve parsing error for nested objects
docs(readme): update installation instructions
```

Each should be its own commit with appropriate grouped files.
