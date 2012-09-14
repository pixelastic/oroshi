" ACKRC
" Remove trailing spaces as lines consisting only of spaces will break ackrc
au BufWritePre <buffer> call RemoveTrailingSpaces()
