function! FixEpub()
  " I often need to tweak epub files, so I convert them to txt and manually edit
  " them. This will help in doing most of the work

  normal! mz
  " Dialogs should use the em dash (–) and not the simple dash (-)
  silent! %s/\v^-/–/e
  " Use common guillemets
  silent! %s/“/"/e
  silent! %s/”/"/e
  silent! %s//"/e
  silent! %s//"/e
  " Same goes for apostrophes
  silent! %s/’/'/e
  silent! %s/‘/'/e
  silent! %s/`/'/e
  silent! %s//'/e
  " Fixing ". .." and ". . ."
  silent! %s/\v( ?)\. \.( ?)\./.../e
  silent! %s/…/.../e

  " Force space after dot and comma
  silent! %s/\v(\.|,)([^ "\.])/\1 \2/e
  " Force space after caps
  silent! %s/\v(\l)(\u)/\1 \2/e
  " Force space when case change inside a word
  silent! %s/\v(\u{2})(\l)/\1 \2/e

  " Fix new lines after a comma in dialogues.
  silent! %s/\v^— ((.*)[^\.!\?])\n\n([^—](.*))$/— \1 \3/e
  " Fix sentence cut in half with new lines
  silent! %s/\v(\l)(\n)+(\l)/\1 \3/e
  " Punctuation signs lost on new lines
  silent! %s/\v\n\n(\?|!|;|»)/ \1/e
  " French guillemets breaking sentences in new lines
  silent! %s/\v»\n\n(\U)/" \1/e

  " Setting the first line as the main title
  if getline(1) !~ '^\#'
    execute 'normal ggI# '
  endif
  " Putting each Chapter in caps
  silent! %s/\v^Chapter (.*)$/## CHAPTER \U\1/e
  " Using lines containing only a number as chapters
  silent! %s/\v^([0-9]+)$/## CHAPTER \1/e
  " Guessing titles by large number of empty lines around and short sentences
  " Note: Will have false positive on short lines.
  " silent! %s/\v\n{3,}(.{,50})\n*/\r\r## \1\r\r/e

  " Fix lines that only contain whitespace
  silent! %s/\s+$//e
  " Condensate multiple new lines into only one
  silent! %s/\v\n{3,}/\r\r/e

  " Marking each heading as a chapter
  " silent! %s/\v^([^#]{2}\L+)$/## \1/e
  nohl
  normal! `z
endfunction " }}}
