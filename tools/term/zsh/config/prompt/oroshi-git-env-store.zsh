# Keep a reference to commonly used $GIT_ variables, so we don't compute them
# too often
function oroshi-git-env-store() {
  GIT_DIRECTORY_IS_REPOSITORY="$(git-directory-is-repository && echo 1 || echo 0)"
  GIT_DIRECTORY_IS_WORKTREE="$(git-directory-is-worktree && echo 1 || echo 0)"
}
