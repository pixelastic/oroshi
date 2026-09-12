# Todo.txt Format Conventions

## Tags

| Tag | Values | Example |
|---|---|---|
| `domain:<Name>` | PascalCase domain name | `domain:Git`, `domain:Nvim` |
| `size:<size>` | `small`, `medium`, `large` | `size:small` |
| `id:<slug>` | kebab-case, max 2 words | `id:git-prune` |
| `p:<slug>` | References another item's `id:` | `p:git-cleanup` |

## Domains

Domains group items by topic area (e.g. `Git`, `Nvim`, `Docker`, `Misc`).
Use an existing domain when possible; fall back to `Misc` if ambiguous.

## Sizes

T-shirt sizes estimate effort:

- **small** — under 30 minutes, well-scoped
- **medium** — 1-2 hours, some exploration needed
- **large** — half-day or more, open-ended

## Dependencies

The `p:<slug>` tag marks an item as blocked by another item.
An item can have multiple `p:` tags. Blocked items are excluded from `todo-list` unless `-x` is passed to topydo directly.

## Slugs

The `id:<slug>` tag uniquely identifies an item.
Slugs are kebab-case, max 2 words (e.g. `git-prune`, `nvim-lsp`).
