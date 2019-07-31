" JAVASCRIPT
" Misc {{{
" Indentation rules
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=eslint_d\ --stdin\ --fix-to-stdout\ -
" }}}
" Folding {{{
setlocal foldmethod=syntax
setlocal foldlevelstart=99
setlocal foldtext=JavascriptFoldText()
function! JavascriptFoldText()
  let output = getline(v:foldstart)
  let lines = v:foldend - v:foldstart
  let output = substitute(output, '{$', '{...' . lines . '}', '')
  let output = substitute(output, '[$', '[...' . lines . ']', '')
  return output
endfunction
" }}}
" Linting {{{
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = 'eslint_d'
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR><CR>
function! JavascriptBeautify() 
  let l:initialLine = line('.')
  execute '%!eslint_d --stdin --fix-to-stdout'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}

" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.info(
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## ${}<Left>
" Test boilerplate
inoremap <buffer> bfe beforeEach(() => {});ko
inoremap <buffer> abfe beforeEach(async () => {});ko
inoremap <buffer> bfa beforeAll(() => {});ko
inoremap <buffer> abfa beforeAll(async () => {});ko
inoremap <buffer> iit it('', () => {<CR>});k2li
inoremap <buffer> aiit it('', async () => {<CR>});k2li
inoremap <buffer> cnt context('', () => {});kllllllli
inoremap <buffer> dsc describe('', () => {});klllllllli
inoremap <buffer> ccact const actual = 
inoremap <buffer> ccinp const input = 
inoremap <buffer> mrv mockReturnValue();hi
inoremap <buffer> thp toHaveProperty('');hhi
inoremap <buffer> thbc toHaveBeenCalled();
inoremap <buffer> thbw toHaveBeenCalledWith();hhi
inoremap <buffer> jsp jest.spyOn()i
inoremap <buffer> tthen then(() => {});ko
inoremap <buffer> @para @param {Array} 
inoremap <buffer> @parb @param {boolean} 
inoremap <buffer> @parn @param {number} 
inoremap <buffer> @paro @param {object} 
inoremap <buffer> @pars @param {string} 
inoremap <buffer> @reta @returns {Array} 
inoremap <buffer> @retb @returns {boolean} 
inoremap <buffer> @retf @returns {Function} 
inoremap <buffer> @retn @returns {number} 
inoremap <buffer> @reto @returns {object} 
inoremap <buffer> @retps @returns {Promise.<string>} 
inoremap <buffer> @retp @returns {Promise} 
inoremap <buffer> @rets @returns {string} 
inoremap <buffer> @retv @returns {void}
nnoremap <buffer> ii_ mzggoimport _ from 'lodash';`z
" Import module
nnoremap <buffer> <Leader>i :ImportJSWord<CR>
" }}}
