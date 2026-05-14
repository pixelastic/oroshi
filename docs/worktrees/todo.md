# Todo — trucs en vrac à planifier

## 1. Nommage des dossiers de worktrees

Actuellement `git-worktree-create` utilise `${repoMain:t}` (nom du dossier) comme préfixe.
Problème : dans oroshi le dossier s'appelle `.oroshi`, donc on obtient `.oroshi--fix_bug` au lieu de `oroshi--fix_bug`.

Il faut lire le nom du projet depuis git (ex: `git remote get-url origin` parsé, ou un helper dédié `git-directory-name`).
Si le helper n'existe pas encore, il faudra le créer avant de modifier `git-worktree-create`.

## 2. Prompt zsh dans un worktree

Quand on est dans un worktree, le prompt affiche le nom/type du projet courant — mais le projet courant c'est le worktree, pas le projet parent.
Il faudrait que le prompt détecte qu'on est dans un worktree et affiche le projet parent (ex: "oroshi" avec la bonne couleur/icône) plutôt que le sous-dossier du worktree.

Lié à `oroshi-prompt-populate:git_is_worktree` (issue 0010) et probablement aux parts qui affichent le nom de projet.
