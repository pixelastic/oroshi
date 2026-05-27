# shellcheck disable=SC2154
# Ruby

# Display project ruby version
# -  (red) if no global ruby
# -  (orange) if no global rbenv
# - {nothing} if not a ruby repo (no .ruby-version)
# -  X.Y.Z (red) if local version isn't installed
# -  X.Y.Z (green) if local and current match
function oroshi-prompt-populate:ruby_version() {
	OROSHI_PROMPT_PARTS[ruby_version]=""

	# Not even a system-wide ruby installation
	if [[ ! -v commands[ruby] ]]; then
		OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLOR_ALIAS_ERROR} %f"
		return
	fi

	# No Rbenv
	if [[ ! -v commands[rbenv] ]]; then
		OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLOR_ALIAS_WARNING} %f"
		return
	fi

	local rubyVersionPath="$(find-up .ruby-version)"

	# No local version defined
	if [[ $rubyVersionPath == '' ]]; then
		return
	fi

	local expectedVersion="$(<$rubyVersionPath)"

	# Local version is in use
	if rbenv version-name &>/dev/null; then
		OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLOR_ALIAS_SUCCESS} $expectedVersion%f"
		return
	fi

	# Local version is not even installed
	OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLOR_ALIAS_ERROR} $expectedVersion%f"
}

# Check if a bundle install is in progress
function oroshi-prompt-populate:bundle_install_in_progress() {
	OROSHI_PROMPT_PARTS[bundle_install_in_progress]=""

	if bundle-install-in-progress; then
		OROSHI_PROMPT_PARTS[bundle_install_in_progress]="%F{$COLORS_RED_8} %f"
	fi
}
