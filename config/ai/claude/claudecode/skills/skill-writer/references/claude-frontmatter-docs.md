# Frontmatter Cheatsheet

Quick-lookup for Claude Code skill frontmatter syntax.

---

## All fields

```yaml
---
name: my-skill              # lowercase, hyphens, max 64 chars. Defaults to dir name.
description: ...            # recommended. truncated at 1536 chars in listing.
when_to_use: ...            # appended to description, counts toward 1536 cap
argument-hint: [issue]      # shown in autocomplete
arguments: issue branch     # named positional args for $name substitution
disable-model-invocation: true  # only user can invoke (not Claude)
user-invocable: false       # hidden from / menu, Claude-only
allowed-tools: Read Grep    # pre-approved tools while skill is active
model: claude-opus-4-6      # model override for this skill's turn
effort: high                # low / medium / high / xhigh / max
context: fork               # run in isolated subagent
agent: Explore              # subagent type when context: fork
hooks: ...                  # lifecycle hooks scoped to this skill
paths: src/**/*.ts          # activate only when working on matching files
shell: bash                 # bash (default) or powershell
---
```

## Invocation control

| Frontmatter | User can invoke | Claude can invoke | Loaded in context |
|---|---|---|---|
| (default) | Yes | Yes | Description always; full skill on invocation |
| `disable-model-invocation: true` | Yes | No | Description NOT in context |
| `user-invocable: false` | No | Yes | Description always; full skill on invocation |

## String substitutions

| Variable | Value |
|---|---|
| `$ARGUMENTS` | Full argument string as typed |
| `$ARGUMENTS[N]` / `$N` | Argument by 0-based index |
| `$name` | Named arg declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Active effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing SKILL.md |

## Dynamic context injection

`` !`command` `` runs a shell command before Claude sees the skill content. Output replaces the placeholder.

```yaml
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

Multi-line:
````
```!
node --version
git status --short
```
````

This is preprocessing — Claude only sees the rendered output, not the command.

## Subagent fork (`context: fork`)

Skill content becomes the subagent prompt. No access to conversation history. Use `agent:` to specify the subagent type (`Explore`, `Plan`, `general-purpose`, or any custom agent).

## Supporting files

Files in the skill directory are NOT loaded automatically — Claude must read them explicitly. Reference them from SKILL.md with an "open when..." reason so Claude knows when to load them.

Keep SKILL.md under 500 lines. Move reference material to separate files.

## Skill content lifecycle

Once invoked, SKILL.md content stays in context for the full session (recurring token cost per turn). After auto-compaction: top 5000 tokens of each invoked skill re-attached, shared budget of 25K tokens, most recent skills prioritized.
