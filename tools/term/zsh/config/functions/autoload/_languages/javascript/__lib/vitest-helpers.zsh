# Shared helpers for js-test
# Resolves which vitest binary to run

source "${0:A:h}/tool-helpers.zsh"

# Return the vitest binary to run: the project's with a project config and binary, oroshi's otherwise
function __vitest-bin() {
  local projectRoot="$1"
  local oroshiBin="$OROSHI_ROOT/node_modules/.bin/vitest"

  # No project — oroshi's bundled vitest
  if [[ $projectRoot == "" ]]; then
    print "$oroshiBin"
    return 0
  fi

  # Project has no vite.config.js (the only name aberlaas reads), so it does not use vitest on its own
  if [[ ! -f "$projectRoot/vite.config.js" ]]; then
    print "$oroshiBin"
    return 0
  fi

  # Project has a config but no vitest installed
  local toolRoot="$(__tool-root vitest "$projectRoot")"
  if [[ $toolRoot == "" ]]; then
    print "$oroshiBin"
    return 0
  fi

  print "$toolRoot/node_modules/.bin/vitest"
}
