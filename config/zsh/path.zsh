# Define a custom $PATH variable that look for all our binaries
function oroshi_path() {
	local hostname="$(hostname)"

	local customPath=(
		# Language binaries
		~/.yarn/bin
		~/.config/yarn/global/node_modules/.bin
		~/.rbenv/bin
		~/.rbenv/shims
		~/.pyenv/bin
		~/.pyenv/shims
		~/.cargo/bin

		# Installed binaries
		~/local/bin
		~/.local/bin
		~/local/src/fzf/bin

		# Custom binaries
		# TODO: Load those automatically based on the directory structure
		~/.oroshi/scripts/bin
		~/.oroshi/scripts/bin/ai
		~/.oroshi/scripts/bin/convert/bin
		~/.oroshi/scripts/bin/coriolis/bin
		~/.oroshi/scripts/bin/docker
		~/.oroshi/scripts/bin/http
		~/.oroshi/scripts/bin/img
		~/.oroshi/scripts/bin/json
		~/.oroshi/scripts/bin/pdf/bin
		~/.oroshi/scripts/bin/spotify
		~/.oroshi/scripts/bin/tmux
		~/.oroshi/scripts/bin/video/bin
		~/.oroshi/scripts/bin/zsh

		# Private binaries
		~/.oroshi/private/scripts/bin

		# Local binaries
		~/.oroshi/scripts/bin/local/$hostname
		~/.oroshi/private/scripts/bin/local/$hostname
	)

	# Custom git-related binaries
	for directory in ~/.oroshi/scripts/bin/git/*; do
		customPath+=($directory)
	done
	# Custom fzf-related binaries
	for directory in ~/.oroshi/scripts/bin/fzf/**/; do
		customPath+=($directory)
	done
	# Custom img-related binaries
	for directory in ~/.oroshi/scripts/bin/img/*; do
		customPath+=($directory)
	done

	# Prepend our path to the existing path
	path=($customPath $path)
}
oroshi_path
unfunction oroshi_path
