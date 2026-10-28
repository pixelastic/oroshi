bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
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

  bats_run_zsh "printer-send /tmp/report.pdf"
  [[ "$status" -eq 0 ]]
  [[ "$(sed -n 1,2p "$BATS_TMP_DIR/lp-args")" = $'-d\nHLL2375DW' ]]
}

@test "passes the file path to lp unchanged" {
  mock_ssid "Waterfront"
  mock_lp

  bats_run_zsh "printer-send '/tmp/my report.pdf'"
  [[ "$status" -eq 0 ]]
  [[ "$(sed -n 3p "$BATS_TMP_DIR/lp-args")" = "/tmp/my report.pdf" ]]
}

@test "sends the file to Ricoh-IM-C300 when the SSID is algolia" {
  mock_ssid "algolia"
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/lp-args")" = $'-d\nRicoh-IM-C300\n/tmp/report.pdf' ]]
}

@test "does not use the home printer when the SSID is algolia" {
  mock_ssid "algolia"
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf"
  [[ "$(sed -n 2p "$BATS_TMP_DIR/lp-args")" != "HLL2375DW" ]]
  [[ "$(sed -n 2p "$BATS_TMP_DIR/lp-args")" != "" ]]
}

@test "exits non-zero and does not call lp when the SSID is unknown" {
  mock_ssid "Coffeeshop"
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}

@test "shows the detected SSID and the known SSIDs in the error" {
  mock_ssid "Coffeeshop"
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf 2>&1 >/dev/null"
  [[ "$output" == *"Coffeeshop"* ]]
  [[ "$output" == *"Waterfront"* ]]
  [[ "$output" == *"algolia"* ]]
}

# Mock nmcli to report no active wifi network
mock_no_wifi() {
  nmcli() { printf 'no:Aircat\nno:Waterfront\n'; }
  bats_mock nmcli
}

@test "exits non-zero and does not call lp when no wifi is active" {
  mock_no_wifi
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/lp-args" ]]
}

@test "states in the error that no wifi is active" {
  mock_no_wifi
  mock_lp

  bats_run_zsh "printer-send /tmp/report.pdf 2>&1 >/dev/null"
  [[ "$output" == *"no active wifi"* ]]
}
