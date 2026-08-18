setup() {
  PROJECT_ROOT="$(git rev-parse --show-toplevel)"
}

@test "config.toml has [extensions] section with enabled = true" {
  grep -q '^\[extensions\]' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
  grep -q 'enabled = true' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
}

@test "config.toml has [extension.added-only] with color variables" {
  grep -q '^\[extension\.added-only\]' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
  grep -q 'colorAdded = "{{git-added:hex}}"' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
  grep -q 'colorModified = "{{git-modified:hex}}"' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
  grep -q 'colorRemoved = "{{git-removed:hex}}"' "$PROJECT_ROOT/tools/git/hunk/config/src/config.toml"
}

@test "deploy script symlinks added-only.js to extensions dir" {
  grep -q 'extensions/added-only.js' "$PROJECT_ROOT/tools/git/hunk/deploy"
}

@test "added-only.js extension entry point exists" {
  [[ -f "$PROJECT_ROOT/tools/git/hunk/extensions/added-only.js" ]]
}
