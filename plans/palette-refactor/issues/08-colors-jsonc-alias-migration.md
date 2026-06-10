## TLDR

Update every alias value in `colors.jsonc` so that the hex color each alias resolves to matches the old system's hex — preserving full visual continuity despite the palette renumbering.

## What to build

Edit `tools/term/zsh/config/theming/src/colors.jsonc`. No structural changes (that's issue 04). Only alias target values change.

### New aliases to add

```jsonc
"black": "gray-0",   // terminal background = #0c0f15
"white": "gray-1",   // terminal foreground = #ffffff
```

### Red family — switch from canonical to explicit shade

The old `RED` canonical was `#ef4444` (TW v3 red-500). After issue 07, this hex lives at `red-4`. All aliases that pointed to `"red"` must move to `"red-4"` to keep the same hex.

| Alias | Before | After |
|-------|--------|-------|
| `docker-image-orphan` | `"red"` | `"red-4"` |
| `error` | `"red"` | `"red-4"` |
| `exception` | `"red"` | `"red-4"` |
| `git-branch-head` | `"red"` | `"red-4"` |
| `git-branch-master` | `"red"` | `"red-4"` |
| `git-dirty` | `"red"` | `"red-4"` |
| `git-rebase` | `"red"` | `"red-4"` |
| `git-remote-head` | `"red"` | `"red-4"` |
| `git-removed` | `"red"` | `"red-4"` |
| `git-untracked` | `"red"` | `"red-4"` |
| `todo` | `"red"` | `"red-4"` |
| `vim-normal-cursor` | `"red"` | `"red-4"` |
| `git-behind` | `"red-8"` | `"red-7"` |
| `variable-type` | `"red-4"` | `"red-3"` |

### TW v3 families — systematic N→N-1 shift

For orange, cyan, teal, sky, amber, violet: old shade N mapped to TW-(N×100); new shade N maps to TW-((N+1)×100). To keep the same hex, subtract 1 from the shade number.

**Orange:**
| Alias | Before | After |
|-------|--------|-------|
| `docker-tag` | `"orange-6"` | `"orange"` (canonical = TW-600 = same hex) |
| `docker-tag-latest` | `"orange-5"` | `"orange-4"` |
| `git-worktree` | `"orange-7"` | `"orange-6"` |
| `match` | `"orange-3"` | `"orange-2"` |
| `modifier` | `"orange-light"` | `"orange-2"` |

**Cyan:**
| Alias | Before | After |
|-------|--------|-------|
| `unknown` | `"cyan-4"` | `"cyan-3"` |
| `git-tag-exact` | `"cyan-5"` | `"cyan-4"` |
| `yarn-link-classic` | `"cyan-6"` | `"cyan"` (canonical = TW-600 = same hex) |
| `git-tag-parent` | `"cyan-8"` | `"cyan-7"` |

**Teal** (special: old `TEAL` canonical was TW-700, not TW-600):
| Alias | Before | After |
|-------|--------|-------|
| `punctuation` | `"teal"` | `"teal-6"` |
| `vim-command-cursor` | `"teal"` | `"teal-6"` |
| `git-stash` | `"teal-3"` | `"teal-2"` |
| `noise` | `"teal-7"` | `"teal-6"` |

**Violet** (special: old `VIOLET` canonical was TW-400, not TW-600):
| Alias | Before | After |
|-------|--------|-------|
| `executable` | `"violet"` | `"violet-3"` |
| `file` | `"violet"` | `"violet-3"` |
| `git-modified` | `"violet"` | `"violet-3"` |
| `git-tracked` | `"violet"` | `"violet-3"` |
| `git-worktree-dirty` | `"violet"` | `"violet-3"` |
| `interpolation-variable` | `"violet"` | `"violet-3"` |
| `notice` | `"violet"` | `"violet-3"` |
| `package-version-mismatch` | `"violet"` | `"violet-3"` |
| `variable` | `"violet"` | `"violet-3"` |
| `key` | `"violet-3"` | `"violet-2"` |
| `variable-definition` | `"violet-light"` | `"violet-2"` |

**Sky:**
| Alias | Before | After |
|-------|--------|-------|
| `date` | `"sky-7"` | `"sky-6"` |

**Amber:**
| Alias | Before | After |
|-------|--------|-------|
| `boolean` | `"amber-5"` | `"amber-4"` |
| `ai` | `"amber-7"` | `"amber-6"` |

**Blue (TW v1 — only specific shades affected):**
| Alias | Before | After |
|-------|--------|-------|
| `link` | `"blue-4"` | `"blue-3"` |
| `git-remote-algolia` | `"blue-4"` | `"blue-3"` |

**Removed `*-light` and `gray-light` names:**
| Alias | Before | After |
|-------|--------|-------|
| `glob` | `"green-light"` | `"green-3"` |
| `import` | `"yellow-light"` | `"yellow-3"` |
| `text` | `"gray-light"` | `"gray-3"` |

### Unchanged aliases

Gray aliases (`"comment": "gray"`, `"git-message": "gray-4"`, `"selected-background": "gray-8"`, etc.) require **no changes** — the gray scale redesign in issue 07 automatically restores their hex values.

Amber, emerald, sky, neutral canonicals (`"flag": "amber"`, `"docker-image": "sky"`, etc.) require **no changes** — their canonical hex values are preserved.

Green and yellow canonical aliases require **no changes** — TW v1 values are unchanged.

## Behavioral Tests

Written in `tools/term/zsh/config/theming/__tests__/colors-build.bats`.

Fixture must include the families covered (red TW v3, gray special scale, orange, cyan, teal, violet).

| Test | Expected |
|------|----------|
| `COLORS[error:hex]` | `#ef4444` |
| `COLORS[variable-type:hex]` | `#f87171` |
| `COLORS[git-behind:hex]` | `#991b1b` |
| `COLORS[git-worktree:hex]` | `#c2410c` |
| `COLORS[punctuation:hex]` | `#0f766e` |
| `COLORS[variable:hex]` | `#a78bfa` |
| `COLORS[black:hex]` | `#0c0f15` |
| `COLORS[white:hex]` | `#ffffff` |
| `COLORS[link:hex]` | `#63b3ed` |

## Acceptance criteria

- [ ] `"black": "gray-0"` and `"white": "gray-1"` added to `colors.jsonc`
- [ ] All 14 red aliases updated as specified
- [ ] All orange, cyan, teal, violet, sky, amber aliases updated as specified
- [ ] `link` and `git-remote-algolia` point to `blue-3`
- [ ] `glob`, `import`, `text` no longer use `*-light` names
- [ ] `COLORS[error:hex]` = `#ef4444`
- [ ] `COLORS[variable-type:hex]` = `#f87171`
- [ ] `COLORS[black:hex]` = `#0c0f15`
- [ ] `COLORS[white:hex]` = `#ffffff`
- [ ] `COLORS[punctuation:hex]` = `#0f766e`
- [ ] `COLORS[variable:hex]` = `#a78bfa`
- [ ] All `colors-build.bats` tests pass
