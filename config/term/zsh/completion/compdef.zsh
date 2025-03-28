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
	git-branch-copy \
	git-branch-merge \
	git-branch-rebase \
	git-branch-remove \
	git-branch-rename \
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
compdef _git-files-staged \
	git-file-unstage
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
compdef _docker-containers-running \
	docker-container-stop
compdef _docker-containers-ids \
	docker-container-name
# }}}
# Images {{{
compdef '_files -g "*.{bmp,gif,jpg,jpeg,png,svg,tiff,webp}"' \
	img2json \
	img-color-count \
	img-convert \
	img-darken \
	img-dimensions \
	img-display \
	img-is-grayscale \
	img-is-landscape \
	img-is-portrait \
	img-lighten \
	img-luminosity \
	img-open \
	img-resize
compdef '_files -g "*.png"' \
	png2gif \
	png2jpg \
	png2svg \
	pngmin \
	png-trim
compdef '_files -g "*.{jpg,jpeg}"' \
	jpg2gif \
	jpg2png \
	jpg2svg
compdef '_files -g "*.gif"' \
	gif2jpg \
	gif2png \
	gif2svg \
	gif-is-animated \
	gif-is-looping
compdef '_files -g "*.svg"' \
	svg2gif \
	svg2jpg \
	svg2png
compdef _image-resize img-resize
# }}}
# Videos {{{
compdef '_files -g "*.{avi,mkv,mp4,mpg}"' \
	better-vlc \
	video-dimensions \
	video-has-sound \
	video-increase-volume \
	video-index-fix \
	video-info \
	video-split \
	video-stream-audio-current \
	video-stream-audio-list \
	video-stream-audio-list-raw \
	video-stream-list \
	video-stream-remove \
	video-upload-youtube
compdef _video-streams-audio \
	video-stream-audio-switch \
	video-stream-audio-remove
# }}}
# Images + Videos {{{
compdef '_files -g "*.{bmp,gif,jpg,jpeg,png,svg,tiff,webp,avi,mkv,mp4,mpg,webm}"' \
	dimensions
# }}}
# PDF {{{
compdef '_files -g "*.pdf"' \
	pdf2txt \
	pdf2img \
	pdf-open \
	pdf-page-count \
	pdf-split
# }}}
# Ebooks {{{
compdef '_files -g "*.epub"' \
	better-ebook-viewer \
	epub2mobi
compdef '_files -g "*.mobi"' \
	mobi2epub
compdef '_files -g "*.{epub,mobi}"' \
	ebook-cover-current \
	ebook-cover-remove \
	ebook-cover-update \
	ebook-meta \
	ebook-metadata-update
# }}}
# Node {{{
compdef _nvm-lazyload lazyloadNvm
compdef _node-versions-installed node-version-switch
compdef _node-modules \
	node-module-remove
# }}}
# Yarn {{{
compdef _yarn-runnables \
	yarn-run
compdef _yarn-dependencies \
	yarn-dependency-remove \
	yarn-dependency-update
compdef _yarn-dependencies-recursive \
	yarn-dependency-why
compdef _yarn-lintable-files \
	yarn-run-lint \
	yarn-run-lint-fix
compdef _yarn-testable-files \
	yarn-run-test \
	yarn-run-test-watch
# Yarn links
# => For Yarn Classic (v1)
compdef _yarn-link-classic-all \
	yarn-link-classic-remove
compdef _yarn-link-classic-disabled \
	yarn-link-classic-enable
compdef _yarn-link-classic-enabled \
	yarn-link-classic-disable
# => For wrapper on top of both versions
compdef _yarn-link-universal \
	yarn-link
compdef _yarn-link-universal-enabled \
	yarn-link-remove

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
compdef '_files -g "*.{7z,Z,bz2,cbr,cbz,deb,gz,htmlz,rar,tar,tar.bz2,tar.gz,tar.lzma,tar.xz,tbz2,tgz,txz,xz,zip,ZIP}"' \
	extract
# }}}
# Watch and reload {{{
# TODO: Ideally watch-and-reload should complete to files in the current
# directory or any defined command/alias/function
# }}}
