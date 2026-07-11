bats_load_library 'helper'

setup() {
	bats_tmp_dir

	# Create test projects.zsh for projects-load-definitions to source
	mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist"
	{
		printf 'typeset -gA PROJECTS\n'
		printf 'PROJECTS[oroshi:path]="/home/tim/local/www/oroshi"\n'
		printf 'PROJECTS[myproject:path]="/home/tim/local/www/myproject"\n'
	} > "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist/projects.zsh"
	bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
}

@test "no arg, CWD is known project: returns ok with project name and path" {
	project-name() { echo "oroshi"; }
	project-path() { echo "/home/tim/local/www/oroshi"; }
	bats_mock project-name project-path

	bats_run_zsh "sidequest-start"
	[ "$status" -eq 0 ]
	[[ "$output" == '{"status":"ok","projectName":"oroshi","projectPath":"/home/tim/local/www/oroshi"}' ]]
}

@test "no arg, CWD is not a known project: returns unknown JSON with candidates" {
	project-name() { echo ""; }
	bats_mock project-name

	bats_run_zsh "sidequest-start"
	[ "$status" -eq 0 ]
	[[ "$output" == *'"status":"unknown"'* ]]
	[[ "$output" == *"▮"* ]]
}

@test "known project name: returns ok with project name and path" {
	project-path() { echo "/home/tim/local/www/oroshi"; }
	bats_mock project-path

	bats_run_zsh "sidequest-start oroshi"
	[ "$status" -eq 0 ]
	[[ "$output" == '{"status":"ok","projectName":"oroshi","projectPath":"/home/tim/local/www/oroshi"}' ]]
}

@test "unknown project name: returns unknown JSON with candidates" {
	project-path() { return 1; }
	bats_mock project-path

	bats_run_zsh "sidequest-start unknownproject"
	[ "$status" -eq 0 ]
	[[ "$output" == *'"status":"unknown"'* ]]
	[[ "$output" == *"▮"* ]]
}

@test "unknown status: candidates contains all registered projects" {
	project-path() { return 1; }
	bats_mock project-path

	bats_run_zsh "sidequest-start unknownproject"
	[ "$status" -eq 0 ]
	[[ "$output" == *"oroshi▮"* ]]
	[[ "$output" == *"myproject▮"* ]]
}
