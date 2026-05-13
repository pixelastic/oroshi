# Deleting a worktree does not delete its branch

`git-worktree-delete` removes only the worktree directory — not the associated branch. The branch must be deleted separately with existing tools (`vbD`). This decouples two distinct operations: stopping work in a worktree context, and deciding the fate of the branch. A branch may still need to exist (open PR, pending review) even after its local worktree is no longer needed.
