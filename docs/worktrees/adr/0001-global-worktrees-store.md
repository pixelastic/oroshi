# Global worktrees store shared across all repos

All worktrees, regardless of which repo they belong to, are created in a single directory (`$OROSHI_WORKTREES_DIR`). The alternative — a per-repo worktrees subfolder (siblings of the repo) — was rejected because it pollutes `~/local/www/projects/` and makes it impossible to get a global view of all work in progress. The global store keeps `projects/` clean.
