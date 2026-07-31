## TLDR

Install Vale binary and configure it with write-good + proselint packages.

## What to build

An install script at `tools/prose/vale/install` that downloads the Vale binary to `~/local/bin/vale` and runs `vale sync` to fetch the write-good and proselint packages.

A `vale.ini` config file at `tools/prose/vale/vale.ini` that activates both packages on all file types.

The `styles/` directory where packages are synced lives alongside `vale.ini` in `tools/prose/vale/`.

## Acceptance criteria

- [ ] `vale --version` works after running install script
- [ ] `vale.ini` activates write-good and proselint packages
- [ ] `vale sync --config tools/prose/vale/vale.ini` downloads packages into `tools/prose/vale/styles/`
- [ ] Running `echo "This is very really basically important" | vale --config tools/prose/vale/vale.ini --ext=.md` flags violations
