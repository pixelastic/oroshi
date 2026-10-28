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
