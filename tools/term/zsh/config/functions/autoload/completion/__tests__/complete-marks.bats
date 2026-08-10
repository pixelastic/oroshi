bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Outputs only mark entries even when projects exist
@test "outputs only marks when both marks and projects exist" {
  mark-list-raw() {
    echo "alpha▮$HOME/projects/alpha"
    echo "beta▮$HOME/docs/beta"
  }
  bats_mock mark-list-raw

  bats_run_zsh "typeset -gA PROJECTS; PROJECTS[myproj:path]=~/some/path; PROJECTS[myproj:icon]='P '; complete-marks"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "$output" == *"alpha:projects/alpha"* ]]
  [[ "$output" == *"beta:docs/beta"* ]]
  [[ "$output" != *"myproj"* ]]
}

# Returns nothing when no marks exist
@test "returns empty when no marks" {
  mark-list-raw() { :; }
  bats_mock mark-list-raw

  bats_run_zsh "complete-marks"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
