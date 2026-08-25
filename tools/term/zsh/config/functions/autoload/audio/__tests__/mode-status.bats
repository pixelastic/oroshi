bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  mkdir -p "$BATS_TMP_DIR/modes"
}

@test "shows all five modes" {
  bats_run_zsh "mode-status"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"sound"* ]]
  [[ "$stripped" == *"mic2txt-autosubmit"* ]]
  [[ "$stripped" == *"mic2txt-language"* ]]
  [[ "$stripped" == *"mic2txt-slack"* ]]
  [[ "$stripped" == *"mic2txt-model"* ]]
}

@test "shows defaults when no mode files exist" {
  bats_run_zsh "mode-status"
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"sound"*"disabled"* ]]
  [[ "$stripped" == *"mic2txt-autosubmit"*"disabled"* ]]
  [[ "$stripped" == *"mic2txt-language"*"fr"* ]]
  [[ "$stripped" == *"mic2txt-slack"*"disabled"* ]]
  [[ "$stripped" == *"mic2txt-model"*"openai"* ]]
}

@test "reflects enabled boolean mode" {
  echo "enabled" > "$BATS_TMP_DIR/modes/sound"

  bats_run_zsh "mode-status"
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"sound"*"enabled"* ]]
}

@test "reflects custom enum value" {
  echo "groq" > "$BATS_TMP_DIR/modes/mic2txt-model"

  bats_run_zsh "mode-status"
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"mic2txt-model"*"groq"* ]]
}

@test "displays modes in top bar order" {
  bats_run_zsh "mode-status"
  local stripped="$(bats_strip_ansi "$output")"

  # Extract line numbers for each mode to verify order
  local line1="$(echo "$stripped" | grep -n "sound" | head -1 | cut -d: -f1)"
  local line2="$(echo "$stripped" | grep -n "mic2txt-autosubmit" | head -1 | cut -d: -f1)"
  local line3="$(echo "$stripped" | grep -n "mic2txt-language" | head -1 | cut -d: -f1)"
  local line4="$(echo "$stripped" | grep -n "mic2txt-slack" | head -1 | cut -d: -f1)"
  local line5="$(echo "$stripped" | grep -n "mic2txt-model" | head -1 | cut -d: -f1)"

  [[ $line1 -lt $line2 ]]
  [[ $line2 -lt $line3 ]]
  [[ $line3 -lt $line4 ]]
  [[ $line4 -lt $line5 ]]
}
