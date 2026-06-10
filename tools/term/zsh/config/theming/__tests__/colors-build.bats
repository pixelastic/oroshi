bats_load_library 'helper'

setup() {
  CURRENT="$(realpath "${BATS_TEST_DIRNAME}/../colors-build")"
  bats_tmp_dir

  export THEMING_ROOT="$BATS_TMP_DIR/tools/term/zsh/config/theming"
  mkdir -p "$THEMING_ROOT/src"
  mkdir -p "$THEMING_ROOT/dist"
  mkdir -p "$BATS_TMP_DIR/tools/term/kitty/config"

  bats_mock_oroshi_root "$BATS_TMP_DIR"

  # Minimal colors.conf:
  # color47  → yellow-7  (range 40-49=yellow, shade 7)
  # color100 → orange-0  (range 100-109=orange, shade 0) — for dark alias test
  # color105 → orange-5  (range 100-109=orange, shade 5) — aliased by git-branch
  # color50  → blue-0    (range 50-59=blue, shade 0) — for dark alias test
  # color55  → blue-5    (range 50-59=blue, shade 5)
  # color200 → gray-0    (range 200-209=gray, shade 0)
  # color205 → gray-5    (range 200-209=gray, shade 5)
  cat >"$BATS_TMP_DIR/tools/term/kitty/config/colors.conf" <<'CONF'
color47   #975a16
color100  #1a120f
color105  #ea580c
color50   #0e1529
color55   #3182ce
color200  #111318
color205  #4b5563
CONF

  cat >"$THEMING_ROOT/src/colors.jsonc" <<'JSONC'
{
  "git-branch": "orange"
}
JSONC
}

teardown() {
  bats_cleanup
}

# --- ZSH output ---

@test "produces dist/colors.zsh" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.zsh" ]
}

@test "dist/colors.zsh declares typeset -gA COLORS" {
  bats_run_zsh "$CURRENT"
  run grep "typeset -gA COLORS" "$THEMING_ROOT/dist/colors.zsh"
  [ "$status" -eq 0 ]
}

@test "dist/colors.zsh sets yellow-7 ansi integer" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[yellow-7]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "47" ]
}

@test "dist/colors.zsh sets yellow-7 hex string" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[yellow-7:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#975a16" ]
}

# --- JSON output ---

@test "produces dist/colors.json" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.json" ]
}

@test "dist/colors.json has yellow-7 with correct ansi" {
  bats_run_zsh "$CURRENT"
  run jq -r '."yellow-7".ansi' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "47" ]
}

@test "dist/colors.json has yellow-7 with correct hex" {
  bats_run_zsh "$CURRENT"
  run jq -r '."yellow-7".hex' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "#975a16" ]
}

# --- Canonical alias auto-generation ---

@test "canonical: COLORS[orange] ansi equals COLORS[orange-5] ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[orange]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "105" ]
}

@test "canonical: COLORS[orange:hex] equals COLORS[orange-5:hex]" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[orange:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#ea580c" ]
}

@test "canonical: COLORS[gray] ansi equals COLORS[gray-5] ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[gray]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "205" ]
}

# --- Dark alias auto-generation ---

@test "dark alias: COLORS[orange-dark] ansi equals COLORS[orange-0] ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[orange-dark]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "100" ]
}

@test "dark alias: COLORS[blue-dark] ansi equals COLORS[blue-0] ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[blue-dark]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "50" ]
}

# --- Aliases ---

@test "aliases: COLORS[git-branch] resolves to ORANGE ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-branch]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "105" ]
}

@test "aliases: COLORS[git-branch:hex] resolves to ORANGE hex" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-branch:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#ea580c" ]
}

@test "aliases: no alias-git-branch key in dist/colors.zsh" {
  bats_run_zsh "$CURRENT"
  run grep "alias-git-branch" "$THEMING_ROOT/dist/colors.zsh"
  [ "$status" -ne 0 ]
}

@test "aliases: no alias-git-branch key in dist/colors.json" {
  bats_run_zsh "$CURRENT"
  run jq 'has("alias-git-branch")' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "false" ]
}

# --- No legacy keys in output ---

@test "dist/colors.json contains no keys prefixed with dark-" {
  bats_run_zsh "$CURRENT"
  run jq '[keys[] | select(startswith("dark-"))] | length' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "0" ]
}

@test "dist/colors.json contains no entries for gap slots 16-19" {
  bats_run_zsh "$CURRENT"
  run jq '[to_entries[] | select(.value.ansi >= 16 and .value.ansi <= 19)] | length' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "0" ]
}

# --- Coverage ---

@test "dist/colors.json has 200 palette entries (20 families x 10 shades)" {
  # Extend fixture to include all 20 families, all 10 shades each
  local conf="$BATS_TMP_DIR/tools/term/kitty/config/colors.conf"
  local familyStart shade slot
  for familyStart in 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 200 210 220 230; do
    for shade in 0 1 2 3 4 5 6 7 8 9; do
      slot=$(( familyStart + shade ))
      printf "color%-4s  #%06x\n" "$slot" "$(( familyStart * 1000 + shade ))" >>"$conf"
    done
  done
  bats_run_zsh "$CURRENT"
  run jq '[keys[] | select(test("-[0-9]$"))] | length' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "200" ]
}

# --- Nested key flattening ---

@test "nested: git.branch in colors.jsonc produces COLORS[git-branch]" {
  cat >"$THEMING_ROOT/src/colors.jsonc" <<'JSONC'
{
  "git": {
    "branch": "orange"
  }
}
JSONC
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-branch]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "105" ]
}

@test "nested: docker.container-running produces COLORS[docker-container-running]" {
  cat >"$BATS_TMP_DIR/tools/term/kitty/config/colors.conf" <<'CONF'
color30   #f0fff4
color35   #38a169
CONF
  cat >"$THEMING_ROOT/src/colors.jsonc" <<'JSONC'
{
  "docker": {
    "container-running": "green"
  }
}
JSONC
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[docker-container-running]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "35" ]
}

@test "nested: top-level comment key still produces COLORS[comment]" {
  cat >"$THEMING_ROOT/src/colors.jsonc" <<'JSONC'
{
  "comment": "gray"
}
JSONC
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[comment]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "205" ]
}

# --- Both outputs ---

@test "both dist/colors.zsh and dist/colors.json written in single run" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.zsh" ]
  [ -f "$THEMING_ROOT/dist/colors.json" ]
}
