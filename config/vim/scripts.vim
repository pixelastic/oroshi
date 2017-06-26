" Detect filetypes based on first line instead of file extension
" See :help new-filetype-scripts

if did_filetype()
  finish
endif

let firstline = getline(1)

" Is a VueJS template
if firstline =~ '^<template'
  if firstline =~ 'pug'
    setfiletype pug
    finish
  endif
  setfiletype html
else
endif
