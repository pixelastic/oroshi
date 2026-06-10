bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/yarn/dependency/yarn-dependency-list-raw"
  export MOCK_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$MOCK_DIR"

  jo name=mock dependencies="$(jo lodash=4.17.21)" devDependencies="$(jo jest=29.0.0)" \
    > "$MOCK_DIR/package.json"

  find-up() { echo "$MOCK_DIR/package.json"; }
  bats_mock find-up

  yarn-link-list-raw() { return 0; }
  bats_mock yarn-link-list-raw
}

teardown() {
  bats_cleanup
}

@test "no flags: shows only dependencies, exit 0" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [[ "${lines[0]}" == "lodash▮4.17.21▮dependencies▮link-none▮" ]]
}

@test "--dev: shows only devDependencies, exit 0" {
  bats_run_zsh "$CURRENT" --dev
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [[ "${lines[0]}" == "jest▮29.0.0▮devDependencies▮link-none▮" ]]
}

@test "--all: shows both dependencies and devDependencies, exit 0" {
  bats_run_zsh "$CURRENT" --all
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [[ "${lines[0]}" == "lodash▮4.17.21▮dependencies▮link-none▮" ]]
  [[ "${lines[1]}" == "jest▮29.0.0▮devDependencies▮link-none▮" ]]
}

@test "--all: shows devDependencies even when dependencies field is absent, exit 0" {
  jo name=mock devDependencies="$(jo jest=29.0.0)" > "$MOCK_DIR/package.json"
  bats_run_zsh "$CURRENT" --all
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [[ "${lines[0]}" == "jest▮29.0.0▮devDependencies▮link-none▮" ]]
}
