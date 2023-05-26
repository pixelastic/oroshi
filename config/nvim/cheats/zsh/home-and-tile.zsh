# Replace home path with ~
tildePath=${absolutePath/#$HOME/\~}

# Replace ~ with full path
absolutePath=${~tildePath}
