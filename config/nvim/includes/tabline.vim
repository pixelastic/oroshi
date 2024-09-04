" TABS {{{
" Do not limit the number of tabs to open when launching vim
set tabpagemax=1000
" Open file in new tab with ,t
nnoremap <Leader>t :tabe<Space>

" Custom tabline {{{
" Defining my own tabline, so I can add custom names to specific tabs
" Note: This is based on the example given in :help setting-tabline
set tabline=%!OroshiTabLine()

" OroshiTabLine {{{
" Builds the whole tabline, but defers the name of each tag to OroshiTabLabel
function! OroshiTabLine()
  let tabLine = ''

  for rawTabIndex in range(tabpagenr('$'))
    let currentTab = tabpagenr()
    let tabIndex = rawTabIndex + 1
    let isCurrentTab = currentTab == tabIndex


    " Add tab number metadata (for mouse clicks)
    let tabLine ..= '%' .. (tabIndex) .. 'T'

    " Now pass the actual label to OroshiTabLabel
    " Highlight current tab differently
    let tabLabel = OroshiTabLabel(tabIndex, isCurrentTab)
    let tabLine ..= tabLabel
  endfor

  " Fill up to the right
  let tabLine ..= '%#TabLineFill#'

  " Reset the tab number metadata
  let tabLine ..= '%T'

  " Add a X to close, on the right (only if more than 1 tab)
  if tabpagenr('$') > 1
    let tabLine ..= '%=%#TabLine#%999XX'
  endif

  return tabLine
endfunction
" }}}

" OroshiTabLabel {{{
" Define the label of each tab, with a slightly different for current and
" non-current tabs
function! OroshiTabLabel(tabIndex, isCurrentTab)
  let bufferId = tabpagebuflist(a:tabIndex)[0]
  let fullPath = expand('#' . bufferId . ':p')
  let basename = fnamemodify(fullPath, ':t')
  let isModified = getbufvar(bufferId, '&mod')
  " Find the filetypeKey, to color based on the type of file
  let filetypeKey = FiletypeKey(fullPath)
  " Define the icon for the current tab, we'll need it later
  if a:isCurrentTab == 1 && filetypeKey !=# ''
    execute 'let icon=$FILETYPE_' . filetypeKey . '_ICON'
  endif

  " Stop early if it's an FZF tab, we don't need to see it
  if basename =~# '\#FZF$'
    return ''
  endif

  " Build the tabLabel string
  let tabLabel = basename

  " Empty file
  if tabLabel ==# ''
    let tabLabel = '[No Name]'
  endif

  " If the tabLabel is a useless index.* file, we add the directory name
  if tabLabel =~# '^index\.'
    let directoryName = fnamemodify(fullPath, ':h:t')
    let tabLabel = directoryName . '/' . tabLabel
  endif

  " Mark as modified
  if isModified == 1
    let tabLabel = tabLabel . ' '
  endif

  " Current tab
  if a:isCurrentTab == 1
    " Prefix with the icon
    " vint: -ProhibitUsingUndeclaredVariable
    if icon !=# ''
      let tabLabel = icon . tabLabel
    endif
    " vint: +ProhibitUsingUndeclaredVariable

    " Add more space around
    let tabLabel = ' ' . tabLabel . ' '

    " Highlight
    if filetypeKey !=# ''
      let tabLabel = Colorize(tabLabel, 'TabLineSelFiletype_' . filetypeKey)
    else
      let tabLabel = Colorize(tabLabel, 'TabLineSel')
    endif

    let tabLabel = Colorize('', 'TabLineSelSeparator') . tabLabel . Colorize(' ', 'TabLineSelSeparator')

    return tabLabel
  endif

  " Other tabs
  " Add more space around
  let tabLabel = ' ' . tabLabel . ' '

  " Highlight
  if filetypeKey !=# ''
    let tabLabel = Colorize(tabLabel, 'TabLineFiletype_' . filetypeKey)
  else
    let tabLabel = Colorize(tabLabel, 'TabLine')
  endif

  return tabLabel
endfunction
" }}}

" }}}
