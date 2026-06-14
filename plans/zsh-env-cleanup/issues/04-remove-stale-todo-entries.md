## TLDR

Delete the two `TODO.md` entries that tracked removal of `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD`.

## What to build

`TODO.md` contains two entries (lines 37–38) that tracked this cleanup work:

```
Double check we no longer use ZSH_CONFIG_PATH
nor OROSHI_ZSH_AUTOLOAD
```

Once issues 01–03 are complete, these variables are fully removed from the codebase. Delete both entries.

## Acceptance criteria

- [ ] `TODO.md` no longer mentions `ZSH_CONFIG_PATH`
- [ ] `TODO.md` no longer mentions `OROSHI_ZSH_AUTOLOAD`
