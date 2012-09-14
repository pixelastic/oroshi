" Vim syntax file
" Language:	hg (Mercurial) commit file
" Maintainer:	Ken Takata <kentkt at csc dot jp>
" Filenames:	hg-editor-*.txt
" License:	VIM License
" URL:		https://github.com/k-takata/hg-vim

if exists("b:current_syntax")
  finish
endif

syn match hgcommitComment "^HG:.*$"             contains=@NoSpell
syn match hgcommitUser    "^HG: user: \zs.*$"   contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitBranch  "^HG: branch \zs.*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitAdded   "^HG: \zsadded .*$"   contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitChanged "^HG: \zschanged .*$" contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitRemoved "^HG: \zsremoved .*$" contains=@NoSpell contained containedin=hgcommitComment

syn match hgcommitDiffFile    "^HG: \zsdiff .*$" contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffOldFile "^HG: \zs--- .*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffNewFile "^HG: \zs+++ .*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffLine    "^HG: \zs@@ .*$"   contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffRemoved "^HG: \zs-[^-].*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffAdded   "^HG: \zs+[^+].*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitDiffChanged "^HG: \zs! .*$"    contains=@NoSpell contained containedin=hgcommitComment


hi def link hgcommitComment Comment
hi def link hgcommitUser    String
hi def link hgcommitBranch  String
hi def link hgcommitAdded   Identifier
hi def link hgcommitChanged Special
hi def link hgcommitRemoved Constant

hi def link hgcommitDiffFile    diffFile
hi def link hgcommitDiffOldFile diffOldFile
hi def link hgcommitDiffNewFile diffFile
hi def link hgcommitDiffLine    diffLine
hi def link hgcommitDiffAdded   hgcommitAdded
hi def link hgcommitDiffRemoved hgcommitRemoved
hi def link hgcommitDiffChanged hgcommitChanged

let b:current_syntax = "hgcommit"
