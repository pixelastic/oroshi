## Guidance

Rename the `to-prd` and `to-issues` Claude skills to `prd` and `issues`.

- Skills live in `tools/ai/claude/config/skills/`
- Use `git mv` for directory renames (preserves git history)
- Only change: directory name, `name:` frontmatter, `# heading`, and cross-references (`/to-prd`, `/to-issues`)
- Do NOT change: `description:` frontmatter, body content, reference sub-files, `allowlist.json`, `prd-end` script logic
- No tests — all changes are content/config artifacts

## Discoveries
