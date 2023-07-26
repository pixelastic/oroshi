# Define a custom $PATH variable that look for all our binaries
function oroshi_path() {
	local hostname="$(hostname)"

	# Build the list of subdirs in ./scripts/bin
	local localBinariesPath=()
	for directory in ~/.oroshi/scripts/bin/**/; do
		# Skip all directories starting with __
		[[ $directory == */__* ]] && continue
		localBinariesPath+=(${directory:0:-1})
	done

	path=(
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

		# Language binaries
		~/.yarn/bin
		~/.config/yarn/global/node_modules/.bin
		~/.rbenv/bin
		~/.rbenv/shims
		# ~/.pyenv/bin
		# ~/.pyenv/shims
		~/.cargo/bin

		# Installed binaries
		~/local/bin
		~/.local/bin
		~/local/src/fzf/bin

		# Custom binaries
		$localBinariesPath

		# Private binaries
		~/.oroshi/private/scripts/bin

		# Local binaries
		~/.oroshi/private/scripts/bin/local/$hostname
	)
}
oroshi_path
unfunction oroshi_path
