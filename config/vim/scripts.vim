" Detect filetypes based on first line instead of file extension
" See :help new-filetype-scripts

if did_filetype()
  finish
endif

let firstline = getline(1)

" Examples
" if firstline =~ '^<template'
"   setfiletype html
"   finish
" endif
