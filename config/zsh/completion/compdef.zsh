# Custom completions
#
# We map in this file which completion functions to call with which commands
# Completion functions start with _ and are stored in ./compdef/
#
# To make dev and debug easier, those completion functions actually call real
# function (starting with complete- instead of the _) that are autoloaded and
# can be manually tested. Those functions are stored in
# ./functions/autoload/completion
#
# Sources:
# https://unix.stackexchange.com/questions/239528/dynamic-zsh-autocomplete-for-custom-commands
# https://unix.stackexchange.com/questions/27236/zsh-autocomplete-ls-command-with-directories-only
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
#
# Note: Because of compdef cache, compdef association defined here can stay
# active even if deleted from this file. To be sure to remove them:
# - rm -f ~/.zcompdump
# - reload the shell

compdef _jumps unmark j

# Git {{{
compdef _git-branches-local \
	git-branch-merge \
	git-branch-rebase \
	git-branch-remove \
	git-branch-switch
compdef _git-branches-remote \
	git-branch-pull \
	git-branch-remove-remote
compdef _git-tags-local \
	git-tag-switch \
	git-tag-remove \
	git-tag-status
compdef _git-files-dirty \
	git-file-add
compdef _git-submodules \
	git-submodule-remove
compdef _git-remotes \
	git-remote-switch \
	git-remote-remove \
	git-remote-rename
# }}}
# Docker {{{
compdef _docker-images-remote \
	docker-image-pull
compdef _docker-images-local-ids \
	docker-image-name
compdef _docker-images-local-names \
	docker-image-list \
	docker-image-count
compdef _docker-images-local-with-tags \
	docker-container-count \
	docker-image-comment \
	docker-image-copy \
	docker-image-exists \
	docker-image-id \
	docker-image-push \
	docker-image-remove \
	docker-run \
	docker-run-interactive
compdef _docker-images-local-with-tags-without-github \
	docker-image-copy-github
compdef _docker-containers \
	docker-container-exists \
	docker-container-id \
	docker-container-image-id \
	docker-container-image-name \
	docker-container-is-running \
	docker-container-remove \
	docker-container-state
compdef _docker-containers-ids \
	docker-container-name
# }}}
# Images {{{
compdef '_files -g "*.{bmp,gif,jpg,jpeg,png,svg,tiff,webp}"' \
	dimensions \
	img-open
compdef _image-resize resize
compdef '_files -g "*.png"' \
	png2gif \
	png2jpg \
	png-trim \
	png2svg
compdef '_files -g "*.{jpg,jpeg}"' \
	jpg2gif \
	jpg2png \
	jpg2svg
compdef '_files -g "*.gif"' \
	gif2jpg \
	gif2png \
	gif2svg
compdef '_files -g "*.svg"' \
	svg2gif \
	svg2jpg \
	svg2png
# }}}
# Videos {{{
compdef '_files -g "*.{avi,mkv,mp4,mpg}"' \
	video-dimensions \
	video-has-sound \
	video-increase-volume \
	video-index-fix \
	video-info \
	video-split \
	video-stream-list \
	video-stream-remove \
	video-upload-youtube \
	vlc
# }}}
# PDF {{{
compdef '_files -g "*.pdf"' \
	pdf-open \
	pdf-page-count \
	pdf2img \
	pdf-split
# }}}
# Ebooks {{{
compdef '_files -g "*.epub"' \
	ebook-cover-current \
	ebook-cover-remove \
	ebook-cover-update \
	epub2mobi
# }}}
# NVM {{{
compdef _nvm-lazyload lazyloadNvm
compdef _node-versions-installed node-version-switch
# }}}
# Yarn {{{
compdef _yarn-runnables \
	yarn-run
compdef _yarn-dependencies \
	yarn-dependency-update
compdef _yarn-dependencies-recursive \
	yarn-dependency-why
compdef _yarn-global-packages \
	yarn-global-remove
compdef _yarn-link-local \
	yarn-link-remove
compdef _yarn-link-global \
	yarn-link \
	yarn-link-remove-global
compdef _yarn-lintable-files \
	yarn-run-lint \
	yarn-run-lint-fix
compdef _yarn-testable-files \
	yarn-run-test \
	yarn-run-test-watch
# }}}
# JSON {{{
compdef '_files -g "*.json"' \
	json-filter \
	json-head
compdef '_files -g "*.jsonl"' \
	jsonl2json
# }}}
# Python {{{
compdef _pyenv-lazyload lazyloadPyenv
compdef _pip-packages \
	pip-update
# }}}
# SSH {{{
compdef _ssh-known-hosts ssh
# }}}
# Archives {{{
compdef '_files -g "*.{bz2,rar,tar,tar.gz,tgz,zip,ZIP,7z}"' \
	extract
# }}}
# Watch and reload {{{
# TODO: Ideally watch-and-reload should complete to files in the current
# directory or any defined command/alias/function
# }}}
