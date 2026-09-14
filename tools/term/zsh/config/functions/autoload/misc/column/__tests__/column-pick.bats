bats_load_library 'helper'

# Single column

@test "picks a single column from multi-column input" {
	local input="apple▮red▮round\nbanana▮yellow▮long"
	bats_run_zsh "echo \"$input\" | column-pick 2"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "red" ]]
	[[ "${lines[1]}" == "yellow" ]]
}

# Multiple columns

@test "picks multiple columns preserving specified order" {
	local input="apple▮red▮round\nbanana▮yellow▮long"
	bats_run_zsh "echo \"$input\" | column-pick 1,3"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "apple▮round" ]]
	[[ "${lines[1]}" == "banana▮long" ]]
}

# Reordering

@test "reorders columns when indices are non-sequential" {
	local input="apple▮red▮round\nbanana▮yellow▮long"
	bats_run_zsh "echo \"$input\" | column-pick 3,1"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "round▮apple" ]]
	[[ "${lines[1]}" == "long▮banana" ]]
}

# Empty input

@test "outputs nothing on empty stdin" {
	bats_run_zsh "echo '' | column-pick 1"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
