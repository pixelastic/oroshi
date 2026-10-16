bats_load_library 'helper'

# Rules live in a sandbox OROSHI_ROOT, so each test controls its own rules file
setup() {
  bats_tmp_dir
  local dataDir="$BATS_TMP_DIR/oroshi/tools/term/zsh/config/functions/autoload/mic2txt/__data"
  mkdir -p "$dataDir"
  RULES_FILE="$dataDir/autocorrect.json"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
}

# --- Matching ---

@test "replaces a misheard word with its replacement" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"open the ichu now"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "open the issue now" ]]
}

@test "matches regardless of case" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"open the ICHU now"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "open the issue now" ]]
}

@test "does not replace a word that is part of a longer word" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"ichus and xichu"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "ichus and xichu" ]]
}

@test "does not replace a word glued to a hyphen" {
  jo ichu=issue >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"my-ichu and ichu-two"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "my-ichu and ichu-two" ]]
}

@test "treats regex characters in a key as literal text" {
  jo ".cloud=.claude" >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"use .cloud and xcloud"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "use .claude and xcloud" ]]
}

@test "handles accented characters in rules and text" {
  jo "où est=ou est" >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"dis moi où est l'été"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "dis moi ou est l'été" ]]
}

# --- Rules ---

@test "applies several rules on the same line" {
  jo ichu=issue "file pass=filepath" >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"the ichu has a file pass"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "the issue has a filepath" ]]
}

@test "suppresses a word when its replacement is empty" {
  jo euh= >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"so euh yes"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "so  yes" ]]
}

@test "leaves text unchanged when the rules file is missing" {
  bats_run_zsh "mic2txt-autocorrect" <<<"open the ichu now"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "open the ichu now" ]]
}

@test "leaves text unchanged when the rules object is empty" {
  echo '{}' >"$RULES_FILE"

  bats_run_zsh "mic2txt-autocorrect" <<<"open the ichu now"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "open the ichu now" ]]
}
