bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Marks only — paths simplified by stripping $HOME/ prefix
@test "outputs mark entries with name and simplified path description" {
  mark-list-raw() {
    echo "alpha▮$HOME/projects/alpha"
    echo "beta▮$HOME/docs/beta"
  }
  projects-load-definitions() { typeset -gA PROJECTS; }
  bats_mock mark-list-raw projects-load-definitions

  bats_run_zsh "complete-jumps"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "$output" == *"alpha:projects/alpha"* ]]
  [[ "$output" == *"beta:docs/beta"* ]]
}

# Projects only
@test "outputs project entries with icon+name description" {
  mark-list-raw() { :; }
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[myproj:path]=~/some/path
    PROJECTS[myproj:icon]="P "
  }
  bats_mock mark-list-raw projects-load-definitions

  bats_run_zsh "complete-jumps"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "myproj:P myproj" ]]
}

# Both — merged, project wins on collision
@test "merges marks and projects, project wins on name collision" {
  mark-list-raw() {
    echo "onlymark▮$HOME/marks/onlymark"
    echo "shared▮$HOME/marks/shared"
  }
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[shared:path]=~/projects/shared
    PROJECTS[shared:icon]="S "
    PROJECTS[onlyproj:path]=~/projects/onlyproj
    PROJECTS[onlyproj:icon]="O "
  }
  bats_mock mark-list-raw projects-load-definitions

  bats_run_zsh "complete-jumps"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 3 ]]
  # Mark-only entry uses simplified path as description
  [[ "$output" == *"onlymark:marks/onlymark"* ]]
  # Collision: project wins, shows icon+name
  [[ "$output" == *"shared:S shared"* ]]
  [[ "$output" != *"marks/shared"* ]]
  # Project-only entry
  [[ "$output" == *"onlyproj:O onlyproj"* ]]
}

# Mark uses project icon when project has icon but no path
@test "mark uses project icon when matching project has no path" {
  mark-list-raw() { echo "mymark▮$HOME/targets/mymark"; }
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[mymark:icon]="M "
  }
  bats_mock mark-list-raw projects-load-definitions

  bats_run_zsh "complete-jumps"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "mymark:M mymark" ]]
}

# Projects without :path excluded
@test "excludes projects missing a :path key" {
  mark-list-raw() { :; }
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[nopath:icon]="N "
    PROJECTS[haspath:path]=~/some/path
    PROJECTS[haspath:icon]="H "
  }
  bats_mock mark-list-raw projects-load-definitions

  bats_run_zsh "complete-jumps"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "haspath:H haspath" ]]
  [[ "$output" != *"nopath"* ]]
}
