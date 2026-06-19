bats_load_library 'helper'

setup() {
  bats_tmp_dir

  THEMING_DIR="$BATS_TMP_DIR/tools/term/zsh/config/theming"
  mkdir -p "$THEMING_DIR/src"
  mkdir -p "$THEMING_DIR/dist"
  mkdir -p "$BATS_TMP_DIR/tools/term/kitty/config"

  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"

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

  cat >"$THEMING_DIR/src/colors.jsonc" <<'JSONC'
{
  "git-branch": "orange"
}
JSONC
}

# --- ZSH output ---

@test "produces dist/colors.zsh with typeset declaration" {
  bats_run_zsh "colors-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/colors.zsh" ]]
  run grep "typeset -gA COLORS" "$THEMING_DIR/dist/colors.zsh"
  [[ "$status" -eq 0 ]]
}

@test "dist/colors.zsh sets yellow-7 ansi and hex" {
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[yellow-7]}"
  [[ "${lines[0]}" = "47" ]]
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[yellow-7:hex]}"
  [[ "${lines[0]}" = "#975a16" ]]
}

# --- JSON output ---

@test "produces dist/colors.json with correct yellow-7 values" {
  bats_run_zsh "colors-build"
  [[ -f "$THEMING_DIR/dist/colors.json" ]]
  run jq -r '."yellow-7".ansi' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "47" ]]
  run jq -r '."yellow-7".hex' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "#975a16" ]]
}

# --- Canonical alias auto-generation ---

@test "canonical: COLORS[orange] equals COLORS[orange-5]" {
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[orange]}"
  [[ "${lines[0]}" = "105" ]]
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[orange:hex]}"
  [[ "${lines[0]}" = "#ea580c" ]]
}

@test "canonical: COLORS[gray] equals COLORS[gray-5]" {
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[gray]}"
  [[ "${lines[0]}" = "205" ]]
}

# --- Dark alias auto-generation ---

@test "dark alias: COLORS[orange-dark] equals COLORS[orange-0], COLORS[blue-dark] equals COLORS[blue-0]" {
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[orange-dark]}"
  [[ "${lines[0]}" = "100" ]]
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[blue-dark]}"
  [[ "${lines[0]}" = "50" ]]
}

# --- Aliases ---

@test "aliases: COLORS[git-branch] resolves to orange ansi and hex" {
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[git-branch]}"
  [[ "${lines[0]}" = "105" ]]
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[git-branch:hex]}"
  [[ "${lines[0]}" = "#ea580c" ]]
}

@test "aliases: no alias-git-branch key in either output" {
  bats_run_zsh "colors-build"
  run grep "alias-git-branch" "$THEMING_DIR/dist/colors.zsh"
  [[ "$status" -ne 0 ]]
  run jq 'has("alias-git-branch")' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "false" ]]
}

# --- No legacy keys in output ---

@test "dist/colors.json contains no dark- prefixed or gap-slot keys" {
  bats_run_zsh "colors-build"
  run jq '[keys[] | select(startswith("dark-"))] | length' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "0" ]]
  run jq '[to_entries[] | select(.value.ansi >= 16 and .value.ansi <= 19)] | length' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "0" ]]
}

# --- Coverage ---

@test "dist/colors.json has 200 palette entries (20 families x 10 shades)" {
  local conf="$BATS_TMP_DIR/tools/term/kitty/config/colors.conf"
  local familyStart shade slot
  for familyStart in 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 200 210 220 230; do
    for shade in 0 1 2 3 4 5 6 7 8 9; do
      slot=$(( familyStart + shade ))
      printf "color%-4s  #%06x\n" "$slot" "$(( familyStart * 1000 + shade ))" >>"$conf"
    done
  done
  bats_run_zsh "colors-build"
  run jq '[keys[] | select(test("-[0-9]$"))] | length' "$THEMING_DIR/dist/colors.json"
  [[ "$output" = "200" ]]
}

# --- Nested key flattening ---

@test "nested: git.branch in colors.jsonc produces COLORS[git-branch]" {
  cat >"$THEMING_DIR/src/colors.jsonc" <<'JSONC'
{
  "git": {
    "branch": "orange"
  }
}
JSONC
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[git-branch]}"
  [[ "${lines[0]}" = "105" ]]
}

@test "nested: docker.container-run produces COLORS[docker-container-run]" {
  cat >"$BATS_TMP_DIR/tools/term/kitty/config/colors.conf" <<'CONF'
color30   #f0fff4
color35   #38a169
CONF
  cat >"$THEMING_DIR/src/colors.jsonc" <<'JSONC'
{
  "docker": {
    "container-run": "green"
  }
}
JSONC
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[docker-container-run]}"
  [[ "${lines[0]}" = "35" ]]
}

@test "nested: top-level comment key produces COLORS[comment]" {
  cat >"$THEMING_DIR/src/colors.jsonc" <<'JSONC'
{
  "comment": "gray"
}
JSONC
  bats_run_zsh "colors-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/colors.zsh' && echo \${COLORS[comment]}"
  [[ "${lines[0]}" = "205" ]]
}

# --- Both outputs ---

@test "generates both dist/colors.zsh and dist/colors.json in single run" {
  bats_run_zsh "colors-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/colors.zsh" ]]
  [[ -f "$THEMING_DIR/dist/colors.json" ]]
}
