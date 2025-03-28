# Rust
function oroshi_tools_rust() {
	# Stop if cargo not installed
	local cargoPath=~/.cargo/env
	[[ -r $cargoPath ]] || return

	source $cargoPath
}
oroshi_tools_rust
unfunction oroshi_tools_rust
