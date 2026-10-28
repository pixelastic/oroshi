bats_load_library 'helper'

# Create empty files in the temp dir
make_files() {
  local name
  for name in "$@"; do : > "$BATS_TMP_DIR/$name"; done
}

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
  make_files report.pdf "my report.pdf"
}

# Mock nmcli to report the given SSID as the active wifi network
mock_ssid() {
  export MOCK_SSID="$1"
  nmcli() { printf 'no:Aircat\nyes:%s\n' "$MOCK_SSID"; }
  bats_mock nmcli
}

# Mock lp to record its arguments, one per line
mock_lp() {
  lp() { printf '%s\n' "$@" > "$BATS_TMP_DIR/lp-args"; }
  bats_mock lp
}

@test "sends the file to HLL2375DW when the SSID is Waterfront" {
  mock_ssid "Waterfront"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf'"
  [[ "$status" -eq 0 ]]
  [[ "$(sed -n 1,2p "$BATS_TMP_DIR/lp-args")" = $'-d\nHLL2375DW' ]]
}

@test "passes the file path to lp unchanged" {
  mock_ssid "Waterfront"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/my report.pdf'"
  [[ "$status" -eq 0 ]]
  [[ "$(sed -n 3p "$BATS_TMP_DIR/lp-args")" = "$BATS_TMP_DIR/my report.pdf" ]]
}

@test "sends the file to Ricoh-IM-C300 when the SSID is algolia" {
  mock_ssid "algolia"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/lp-args")" = $'-d\nRicoh-IM-C300\n'"$BATS_TMP_DIR"'/report.pdf' ]]
}

@test "does not use the home printer when the SSID is algolia" {
  mock_ssid "algolia"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf'"
  [[ "$(sed -n 2p "$BATS_TMP_DIR/lp-args")" != "HLL2375DW" ]]
  [[ "$(sed -n 2p "$BATS_TMP_DIR/lp-args")" != "" ]]
}

@test "exits non-zero and does not call lp when the SSID is unknown" {
  mock_ssid "Coffeeshop"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf'"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}

@test "states in the error that no printer matches the wifi" {
  mock_ssid "Coffeeshop"
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf' 2>&1 >/dev/null"
  [[ "$output" == *"no printer for wifi"* ]]
  [[ "$output" != *"Coffeeshop"* ]]
  [[ "$output" != *"Waterfront"* ]]
}

# Mock nmcli to report no active wifi network
mock_no_wifi() {
  nmcli() { printf 'no:Aircat\nno:Waterfront\n'; }
  bats_mock nmcli
}

@test "exits non-zero and does not call lp when no wifi is active" {
  mock_no_wifi
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf'"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}

@test "states in the error that no wifi is active" {
  mock_no_wifi
  mock_lp

  bats_run_zsh "printer-send '$BATS_TMP_DIR/report.pdf' 2>&1 >/dev/null"
  [[ "$output" == *"no active wifi"* ]]
}

@test "sends all files in one lp call" {
  mock_ssid "Waterfront"
  mock_lp
  make_files a.pdf b.pdf

  bats_run_zsh "printer-send '$BATS_TMP_DIR/a.pdf' '$BATS_TMP_DIR/b.pdf'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/lp-args")" = "-d"$'\n'"HLL2375DW"$'\n'"$BATS_TMP_DIR/a.pdf"$'\n'"$BATS_TMP_DIR/b.pdf" ]]
}

@test "sends nothing when one file is missing" {
  mock_ssid "Waterfront"
  mock_lp
  make_files a.pdf

  bats_run_zsh "printer-send '$BATS_TMP_DIR/a.pdf' '$BATS_TMP_DIR/missing.pdf'"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}

@test "names the missing file in the error" {
  mock_ssid "Waterfront"
  mock_lp
  make_files a.pdf

  bats_run_zsh "printer-send '$BATS_TMP_DIR/a.pdf' '$BATS_TMP_DIR/missing.pdf' 2>&1 >/dev/null"
  [[ "$output" == *"$BATS_TMP_DIR/missing.pdf"* ]]
}

@test "prints the usage and exits non-zero when no file is given" {
  mock_ssid "Waterfront"
  mock_lp

  bats_run_zsh "printer-send 2>&1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage:"* ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}
