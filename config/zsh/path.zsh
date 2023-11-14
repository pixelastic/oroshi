# Define a custom $PATH variable that look for all our binaries
function oroshi_path() {
	local hostname="$(hostname)"

	# Build the list of subdirs in ./scripts/bin
	local localBinariesPath=()
	for directory in ~/.oroshi/scripts/bin/**/; do
		# Skip all directories starting with __
		[[ $directory == */__* ]] && continue
		# As well as node_modules added by zx
		[[ $directory == */node_modules* ]] && continue

		localBinariesPath+=(${directory:0:-1})
	done

	# The default node version to use is the one marked as "default" in nvm
	local defaultNodeVersion="$(<~/.nvm/alias/default)"
	local nodeBinariesPath=$HOME/.nvm/versions/node/${defaultNodeVersion}/bin
	# The default python version to use is the one saved in ~/.pyenv/version Note:
	# The default method of using pyenv is relying on its shims, but they spawn so
	# many wrapped bash shell scripts that using them adds 1-2 seconds delay to
	# each python command. Instead, we specifically add the binaries from the
	# current version to the PATH
	local defaultPythonVersion="$(<~/.pyenv/version)"
	local pythonBinariesPath=$HOME/.pyenv/versions/${defaultPythonVersion}/bin

	path=(
		# Local binaries
		~/.oroshi/private/scripts/bin/local/$hostname

		# Private binaries
		~/.oroshi/private/scripts/bin

		# Custom binaries
		$localBinariesPath

		# Installed binaries
		~/local/bin
		~/.local/bin
		~/local/src/fzf/bin

		# Language binaries
		$nodeBinariesPath
		~/.rbenv/bin
		~/.rbenv/shims
		~/.pyenv/bin
		$pythonBinariesPath
		~/.cargo/bin

		# System paths
		# (Check /etc/environment for the exact list)
		/usr/local/sbin
		/usr/local/bin
		/usr/sbin
		/usr/bin
		/sbin
		/bin
		/usr/games
		/usr/local/games
		/snap/bin
	)
}
oroshi_path
unfunction oroshi_path
