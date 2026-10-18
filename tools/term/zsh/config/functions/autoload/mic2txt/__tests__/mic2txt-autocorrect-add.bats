bats_load_library 'helper'

# Rules live under a sandbox HOME, so each test controls its own rules file
setup() {
  bats_tmp_dir
  DATA_DIR="$BATS_TMP_DIR/.oroshi/tools/term/zsh/config/functions/autoload/mic2txt/__data"
  mkdir -p "$DATA_DIR"
  RULES_FILE="$DATA_DIR/autocorrect.json"
  bats_mock_env HOME "$BATS_TMP_DIR"
}

@test "adds a new pair to the rules file" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.eovim' "$RULES_FILE")" == "NeoVim" ]]
}

@test "overwrites the replacement of an existing key" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add ichu ticket"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.ichu' "$RULES_FILE")" == "ticket" ]]
}

@test "keeps a single entry when run twice with the same key" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim && mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  [[ "$(jq 'length' "$RULES_FILE")" -eq 2 ]]
}

@test "keeps the other pairs untouched" {
  jo ichu=issue ischios=issues >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.ichu' "$RULES_FILE")" == "issue" ]]
  [[ "$(jq --raw-output '.ischios' "$RULES_FILE")" == "issues" ]]
}

@test "creates the rules object when the file is empty" {
  : >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.eovim' "$RULES_FILE")" == "NeoVim" ]]
}

@test "creates the file when it is missing" {
  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.eovim' "$RULES_FILE")" == "NeoVim" ]]
}

@test "accepts an empty replacement as a suppression rule" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add euh ''"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.euh | type' "$RULES_FILE")" == "string" ]]
  [[ "$(jq --raw-output '.euh' "$RULES_FILE")" == "" ]]
}

@test "fails with a usage message when the replacement is missing" {
  bats_run_zsh "mic2txt-autocorrect-add eovim"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "fails with a usage message when no argument is given" {
  bats_run_zsh "mic2txt-autocorrect-add"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "stores keys containing quotes and spaces correctly" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add 'say \"hi\" now' \"it's ok\""
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.["say \"hi\" now"]' "$RULES_FILE")" == "it's ok" ]]
}

@test "writes valid JSON" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect-add eovim NeoVim"
  [[ "$status" -eq 0 ]]
  jq --exit-status . "$RULES_FILE" >/dev/null
}
