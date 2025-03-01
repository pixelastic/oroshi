# Images
alias diR="docker-image-remove"
alias dib="docker-image-build"
alias dicpgh="docker-image-copy-github"
alias dicp="docker-image-copy"
alias dic="docker-image-comment"
alias dii="docker-image-id"
alias dil="docker-image-list --exclude oroshi"
alias din="docker-image-name"
alias dipl="docker-image-pull"
alias dips="docker-image-push"
alias di#="docker-image-count"
alias di?="docker-image-exists"

# Run
alias dr="docker-run"
alias dri="docker-run-interactive"

# Containers
alias dcl="docker-container-list"
alias dc?="docker-container-exists"
alias dc#="docker-container-count"
alias dcr?="docker-container-is-running"
alias dcs="docker-container-state"
alias dcsto="docker-container-stop"
alias dcR="docker-container-remove"
alias dci="docker-container-id"
alias dcn="docker-container-name"
alias dcii="docker-container-image-id"
alias dcin="docker-container-image-name"

# Oroshi specific image
alias dol="docker-oroshi-list"
alias dor="docker-oroshi-run"
alias doc="docker-oroshi-commit"

# TODO:
# - dcc: Commit container. Needs to be running
# increments the version in patch by default
# can also use major, minor, patch or an explicit version
# creates a new ghcr.io images, with the version as the tag
# assumes current version from the highest tag locally on ghcr.io
#
# $ dro to run latest oroshi
# $ dcc to commit the running oroshi, and save it as a ghcr.io image
# Assumes default version is 0.0.0, unless another is taggued locally
# dcc incremets the patch, unless a specific version, minor, major
# ???

# # Docker Composer
# alias dc="docker-compose"
# # Images
# alias di?="di-exists"
# alias dip='docker-image-prune'
# alias dimv='docker-image-rename'
# # Containers
# alias dcr='docker-container-run'
# alias dce='docker-container-run --exec-mode'
# alias dr='docker run'
