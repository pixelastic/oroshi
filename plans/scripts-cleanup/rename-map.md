# Rename Map

Naming convention: `domain-action` with hyphens. Conversion scripts use `source-to-target`.

## Image domain (`scripts/bin/img/`)

| Current | Proposed | Notes |
|---|---|---|
| `imgmin` | `img-compress` | main compressor |
| `gifmin` | `gif-compress` | gifsicle wrapper |
| `jpgmin` | `jpg-compress` | wrapper around imgmin |
| `pngmin` | `png-compress` | wrapper around imgmin |

## Image domain (top-level)

| Current | Proposed | Notes |
|---|---|---|
| `pngalpha` | `png-add-alpha` | make color transparent |
| `pngblack` | `png-fill-black` | fill non-transparent with black |
| `pngmask` | `png-make-mask` | invert transparency |
| `pngunalpha` | `png-remove-alpha` | replace transparency with color |
| `gif2png` | `gif-to-png` | convert GIF→PNG |

## Media conversion

| Current | Proposed | Notes |
|---|---|---|
| `mp4min` | `mp4-compress` | ffmpeg re-encode |
| `mp42avi` | `mp4-to-avi` | |
| `mp42mp3` | `mp4-to-mp3` | |
| `bin2iso` | `bin-to-iso` | disc image conversion |
| `dds2png` | `dds-to-png` | texture conversion |
| `vcd2mpg` | `vcd-to-mpg` | VCD extraction |

## Text/Encoding

| Current | Proposed | Notes |
|---|---|---|
| `base64decode` | `base64-decode` | |
| `base64encode` | `base64-encode` | |
| `xml2json` | `xml-to-json` | |
| `zsh2json` (in `zsh/`) | `zsh-to-json` | env→JSON for kitty statusbar |

## Filename operations

| Current | Proposed | Notes |
|---|---|---|
| `file2dir` | `file-to-dir` | wrap files in same-name dirs (Ruby) |
| `prefix-date` | `filename-prefix-date` | prepend date to filename (Ruby) |
| `rename-fat32` | `filename-sanitize-fat32` | FAT32-safe rename (Ruby) |
| `capitalize-title` | `filename-capitalize-title` | capitalize "XX - Title" (Ruby) |
| `sequential-rename` | `filename-sequential` | zero-padded sequential rename |
| `filename-valid` | `filename-sanitize` | replace accents/special chars |

## System domain

| Current | Proposed | Notes |
|---|---|---|
| `cpu-percent` | `sys-cpu-percent` | CPU usage for statusbar; `sys-` groups system metrics |
| `ram-percent` | `sys-ram-percent` | RAM usage for statusbar; `sys-` groups system metrics |

## Individual renames

| Current | Proposed | Notes |
|---|---|---|
| `jsclean` | `js-clean` | fixmyjs wrapper |
| `md2html` | `md-to-html` | markdown conversion |
| `html2pdf` | `html-to-pdf` | HTML→PDF via wkhtmltopdf |
| `algolia-download` | `algolia-index-download` | clarify it downloads an index, not the app |
| `version-compare` | `version-is-newer` | clarify direction: returns 0 if $1 > $2 |

## No rename needed

These already follow `domain-action`:
- `image-orientation` — EXIF orientation (Ruby)
- `file-count` — count files in dir (Bash)
- `my-ip` — print public IP (Bash)
- `ping-average` — average ping (Bash)
- `sort-by-length` — sort lines (Bash)
- `unmark` — remove macOS quarantine (Bash)
- `video-has-sound` — probe audio stream
- `video-index-fix` — fix mp4 index
- `video-volume-increase` — boost audio
