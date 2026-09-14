bats_load_library 'helper'

# Single column alphabetic sort

@test "sorts lines alphabetically by column 1" {
	local input="cherry▮10\napple▮30\nbanana▮20"
	bats_run_zsh "echo \"$input\" | column-sort 1"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "apple▮30" ]]
	[[ "${lines[1]}" == "banana▮20" ]]
	[[ "${lines[2]}" == "cherry▮10" ]]
}

# Single column numeric sort

@test "sorts lines numerically by column 1 when values are numbers" {
	local input="30▮cherry\n10▮apple\n20▮banana"
	bats_run_zsh "echo \"$input\" | column-sort 1"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "10▮apple" ]]
	[[ "${lines[1]}" == "20▮banana" ]]
	[[ "${lines[2]}" == "30▮cherry" ]]
}

# Multi-column sort

@test "sorts by primary column first, then by secondary on ties" {
	local input="b▮2▮x\na▮1▮y\nb▮1▮z\na▮2▮w"
	bats_run_zsh "echo \"$input\" | column-sort 1,2"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "a▮1▮y" ]]
	[[ "${lines[1]}" == "a▮2▮w" ]]
	[[ "${lines[2]}" == "b▮1▮z" ]]
	[[ "${lines[3]}" == "b▮2▮x" ]]
}

# Descending order

@test "sorts descending when index is negative" {
	local input="10▮apple\n30▮cherry\n20▮banana"
	bats_run_zsh "echo \"$input\" | column-sort -1"
	[[ "$status" -eq 0 ]]
	IFS=$'\n' read -r -d '' -a lines <<< "$output" || true
	[[ "${lines[0]}" == "30▮cherry" ]]
	[[ "${lines[1]}" == "20▮banana" ]]
	[[ "${lines[2]}" == "10▮apple" ]]
}

# Empty input

@test "outputs nothing on empty stdin" {
	bats_run_zsh "echo '' | column-sort 1"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
