# Scripts Audit Decisions

## Confirmed DELETE (70 + __pdf/ directory)

### Directories
- `__pdf/` — entire directory (17 scripts), replaced by Pietro JS lib

### Ruby (22)
- `smartcase` — smart title case rename
- `slurp` — broken (missing etc/ dep)
- `mts2mp4` — MTS to MP4 converter
- `camera-extract` — extract photos from camera
- `subtitle-download` — broken (missing etc/ dep)
- `subtitle-fps` — hardcoded FPS converter using obscure `horst` tool
- `subtitle-guess` — brittle filename regex matcher
- `subtitle-import-synchro` — broken (missing etc/ dep)
- `html2txt` — redundant with html2mkd
- `milkyway-mount-path` — hardcoded external drive
- `painting-inspiration` — hardcoded Dropbox paths
- `s3-push-public` — S3 push, likely dead
- `serenity-backup-perso` — hardcoded external drive
- `trash-list` — broken (missing etc/ dep)
- `update-dir` — broken (missing etc/ dep)
- `sass2scss` — no history, ruby, likely dead
- `scss2css` — no history, ruby, likely dead

### Bash (16)
- `cmus-is-running` — cmus dead
- `cmus-next` — cmus dead
- `cmus-previous` — cmus dead
- `cmus-seek` — cmus dead
- `cmus-toggle-pause` — cmus dead
- `cmus-toggle-shuffle` — cmus dead
- `writer` — LibreOffice Writer launcher
- `agf` — ripgrep wrapper, no references
- `bats-echo` — no references
- `js-check-tests` — focused test checker
- `json_reformat` — jq wrapper
- `npm-is-local` — no references
- `npm-which` — no references
- `nvm-version-current` — no references
- `python-version-debug` — debug info
- `pip-install-version` — pyenv pip install
- `calc` — LibreOffice Calc launcher
- `clean-boot` — clean boot files
- `hexographer` — Java map editor launcher
- `mkdiralpha` — create A-Z directories

### sh/node/? (4)
- `git-find-unclean-repos` — sh
- `remark-fix` — sh (flag remark config for cleanup too)
- `remark-lint` — sh (flag remark config for cleanup too)
- `meetup-attendee-list` — node, broken

### ZSH (28)
- `simplify` — ancient readability+html2mkd pipeline (from alive list)
- `html2mkd` — vendored 2008 Python html2text (from alive list)
- `SELECT` — SQL-like SELECT for files
- `argsf` — no references outside cheat sheet
- `argsp` — no references outside cheat sheet
- `convert-comics` — download/sync comics
- `copy-verbose` — cp with progress
- `get-version-system` — git/hg detection
- `heroicmaps-extract` — Heroic Maps zip extractor
- `jvc-extract` — JVC camera MTS extractor
- `jx` — JSON key extractor (superseded by json-*)
- `kbR` — keyboard shortcut removal (22.04 only)
- `kba` — keyboard shortcut add (22.04 only)
- `kbz` — keyboard shortcut remove (22.04 only)
- `michel-compress-video` — batch video compressor
- `move-verbose` — mv with progress
- `path.basename` — trivial ZSH builtin
- `path.dirname` — trivial ZSH builtin
- `path.extname` — trivial ZSH builtin
- `path.filename` — trivial ZSH builtin
- `path.resolve` — trivial ZSH builtin
- `peek` — Peek screen recorder (not in 24.04 keybindings)
- `picture-sync` — no references
- `reload-tests` — no references
- `scrap` — download images from web page
- `sync-comics` — comic sync
- `trash-exists` — check trashed files
- `weather` — display weather

## Confirmed KEEP (109)

### Ruby → migrate to ZSH (13)
- `video-has-sound` — check if video has audio track
- `image-orientation` — get image orientation
- `html2pdf` — convert HTML to PDF (keep if not too complex, else delete)
- `better-rmdir` — trash-put wrapper, aliased as `rmdir`
- `file2dir` — move file into same-name directory (rename, "rename" domain)
- `prefix-date` — prefix filenames with date (rename, "rename" domain)
- `rename-fat32` — FAT32-safe filenames (rename, "rename" domain)
- `capitalize-title` — capitalize "XX - Title.ext" files (rename, "rename" domain + better name)
- `url2host` — extract hostname from URL
- `version-compare` — compare semver strings (rename: version-is-newer/older)
- `cesoir` — movie night picker (keep for fun)
- `font-exists` — check if font is installed
- `git-submodule-create` — create a git submodule

### Bash → migrate to ZSH (5)
- `python-version` — output current Python version
- `file-count` — count files/dirs (potential rename)
- `my-ip` — display local IP (potential rename)
- `ping-average` — average ping latency (potential rename)
- `sort-by-length` — sort lines by length (potential rename)
- `unmark` — remove directory bookmark (potential rename)

### ZSH — keep as-is or migrate to autoloaded function (91)

#### AI/Ralph (3)
- `plan-badge` — render plan progress badge
- `ralph-is-running` — check if Ralph session is active
- `review-blog-start` — upload markdown to Google Docs

#### Audio (3)
- `audio-duration` — get audio/video duration in seconds
- `mic2txt-autosubmit-mode-toggle` — toggle autosubmit mode
- `mic2txt-language-toggle` — toggle mic2txt language

#### Bats fixtures (3)
- `bats-fixture-script-foo` — test fixture
- `bats-fixture-script-bar` — test fixture
- `bats-fixture-script-baz` — test fixture

#### Bundle/Gem/Ruby (7)
- `bundle-install` — bundle install + rehash
- `bundle-install-in-progress` — check if bundle install running
- `bundle-update` — bundle update + rehash
- `gem-install` — gem install + rehash
- `gem-uninstall` — gem uninstall + rehash
- `gem-update` — gem update + rehash
- `has-ruby` — check if Ruby available

#### Docker (9)
- `docker-container-list`
- `docker-image-build`
- `docker-image-push`
- `docker-images-remote-refresh`
- `docker-oroshi-commit`
- `docker-oroshi-list`
- `docker-oroshi-run`
- `docker-run-interactive`
- `docker-run`

#### FZF (5)
- `ctrl-shift-o` — fuzzy search directories
- `fzf-apt-packages` — fuzzy search apt packages
- `fzf-git-files-dirty-stageable`
- `fzf-git-files-dirty`
- `fzf-js-test` — fuzzy pick JS test

#### Git (16)
- `git-commit-cancel`
- `git-commit-remove`
- `git-commit-remove-all`
- `git-commit-submodule`
- `git-directory-root-bin` — binary wrapper for vim (pattern: -bin suffix)
- `git-file-resurrect`
- `git-issue-create`
- `git-issue-list`
- `git-pullrequest-list`
- `git-remote-remove`
- `git-remote-rename`
- `git-remote-switch`
- `git-stash-apply`
- `git-stash-create`
- `git-submodule-list`
- `git-submodule-remove`

#### Image (6, all need rename: domain-action)
- `gifmin` → gif-min
- `jpgmin` → jpg-min
- `pngalpha` → png-alpha
- `pngblack` → png-black
- `pngmask` → png-mask
- `pngunalpha` → png-unalpha

#### JSON (3)
- `json-count`
- `json-filter`
- `jsonl2json`

#### Kitty (1)
- `kitty-tab-window-count`

#### Lua/Vim (2)
- `lua-lint-selene`
- `lua-test-path`

#### Media conversion (5, mp4min → mp4-min)
- `bin2iso`
- `dds2png`
- `mp42avi`
- `mp42mp3`
- `mp4min` → mp4-min

#### Video (3)
- `video-index-fix`
- `video-stream-remove`
- `video-volume-increase`

#### Desktop/System (4)
- `better-keepass` — KeePass with GTK scaling
- `cpu-percent` — CPU usage (rename: sys- domain)
- `ram-percent` — RAM usage (rename: sys- domain)
- `dconf-watch` — dconf/gsettings listener
- `statusbar-clock` — Kitty statusbar (must stay script)

#### File operations (3)
- `rcp` — rsync copy
- `rmv` — rsync move
- `filename-valid` — sanitize filenames (rename needed)

#### Text/encoding (3)
- `base64decode` — decode base64 (potential rename)
- `base64encode` — encode base64 (potential rename)
- `xml2json` — convert XML to JSON

#### Misc (14)
- `algolia-download` — rename: algolia-index-download
- `colorize-bin` — evaluate if needs to be script
- `css-fix`
- `fork` — run command in background with lockfile
- `install-deb`
- `is-older` — potential rename
- `isomount`
- `kindle-screensaver` — rename needed
- `node-module-install`
- `sequential-rename` — rename needed
- `switch-extract`
- `urls` — rename needed
- `website-download`
- `rar-repair`
- `zsh2json` — rename needed

## Design decisions noted during audit
- `-bin` suffix pattern for autoloaded functions that need a script wrapper (NeoVim, Kitty, etc.)
- Potential "rename" domain for file-renaming scripts (file2dir, prefix-date, rename-fat32, capitalize-title)
- Image scripts need domain-action naming (gif-min, png-alpha, etc.)
- cpu-percent/ram-percent belong in a `sys-` domain
- Remark config needs cleanup alongside remark-fix/remark-lint deletion
