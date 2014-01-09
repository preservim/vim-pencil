" ============================================================================
" File:        pencil.vim
" Description: autoload functions for vim-pencil plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Created:     December 28, 2013
" License:     The MIT License (MIT)
" ============================================================================

if exists("autoloaded_pencil") | finish | endif
let autoloaded_pencil = 1

let s:WRAP_MODE_DEFAULT = -1
let s:WRAP_MODE_OFF     = 0
let s:WRAP_MODE_HARD    = 1
let s:WRAP_MODE_SOFT    = 2

" Wrap-mode detector
" attempt to determine user's intent from modeline
function! s:detect_mode() abort
  let b:max_textwidth = -1
  let b:min_textwidth = 9999
  let b:max_wrapmargin = -1
  let b:min_wrapmargin = 9999

  call s:doModelines()
  if b:max_textwidth  == -1   &&
   \ b:min_textwidth  == 9999 &&
   \ b:max_wrapmargin == -1   &&
   \ b:min_wrapmargin == 9999
    " no relevant modeline params present
    return s:WRAP_MODE_DEFAULT
  elseif b:max_textwidth <= 0 && b:max_wrapmargin <= 0
    " no textwidth or wrapmargin were gt 0
    return s:WRAP_MODE_SOFT
  elseif b:min_textwidth > 0 || b:min_wrapmargin > 0
    " at least one textwidth or wrapmargin was gt 0
    return s:WRAP_MODE_HARD
  else
    " unsure what to do!
    return s:WRAP_MODE_DEFAULT
  endif
endfunction

function! pencil#setAutoFormat(mode)
  " 1=auto, 0=manual, -1=toggle
  if !exists('b:last_autoformat')
    let b:last_autoformat = 0
  endif
  let b:last_autoformat = a:mode == -1 ? !b:last_autoformat : a:mode
  if b:last_autoformat
    augroup pencil_autoformat
      autocmd InsertEnter <buffer> set formatoptions+=a
      autocmd InsertLeave <buffer> set formatoptions-=a
    augroup END
  else
    silent! autocmd! pencil_autoformat * <buffer>
  endif
endfunction

" Create mappings for word processing
" args:
"   'wrap': 'detect|off|hard|soft|toggle'
function! pencil#init(...) abort
  let l:args = a:0 ? a:1 : {}

  if !exists('b:wrap_mode')
    let b:wrap_mode = s:WRAP_MODE_OFF
  endif

  " If user explicitly requested wrap_mode thru args, go with that.
  let l:wrap_arg = get(l:args, 'wrap', 'detect')

  if (b:wrap_mode && l:wrap_arg ==# 'toggle') ||
   \ l:wrap_arg =~# '^\(off\|disable\|false\)$'
    let b:wrap_mode = s:WRAP_MODE_OFF
  elseif l:wrap_arg ==# 'hard'
    let b:wrap_mode = s:WRAP_MODE_HARD
  elseif l:wrap_arg ==# 'soft'
    let b:wrap_mode = s:WRAP_MODE_SOFT
  elseif l:wrap_arg ==# 'default'
    let b:wrap_mode = s:WRAP_MODE_DEFAULT
  else
    " this can return s:WRAP_MODE_ for soft, hard or default
    let b:wrap_mode = s:detect_mode()
  endif

  " translate default(-1) to soft(1) or hard(2) or off(0)
  if b:wrap_mode == s:WRAP_MODE_DEFAULT
    if g:pencil#wrapModeDefault =~# '^\(off\|disable\|false\)$'
      let b:wrap_mode = s:WRAP_MODE_OFF
    elseif g:pencil#wrapModeDefault ==# 'soft'
      let b:wrap_mode = s:WRAP_MODE_SOFT
    else
      let b:wrap_mode = s:WRAP_MODE_HARD
    endif
  endif

  " autoformat is only used in Hard mode, and then only during
  " Insert mode
  call pencil#setAutoFormat(
        \ b:wrap_mode == s:WRAP_MODE_HARD &&
        \ get(l:args, 'autoformat', g:pencil#autoformat))

  if b:wrap_mode == s:WRAP_MODE_HARD
    if &modeline == 0 && b:max_textwidth > 0
      " Compensate for disabled modeline
      execute 'setlocal textwidth=' . b:max_textwidth
    elseif &textwidth == 0
      execute 'setlocal textwidth=' . g:pencil#textwidth
    else
      setlocal textwidth<
    endif
    setlocal nowrap
  elseif b:wrap_mode == s:WRAP_MODE_SOFT
    setlocal textwidth=0
    setlocal wrap
    setlocal linebreak
    setlocal colorcolumn=0      " doesn't align as expected
  else
    setlocal textwidth<
    setlocal wrap< nowrap<
    setlocal linebreak< nolinebreak<
    setlocal colorcolumn<
  endif

  if b:wrap_mode
    setlocal autoindent         " needed by fo=n
    setlocal nolist
    setlocal wrapmargin=0
    setlocal display+=lastline
    setlocal formatoptions+=1   " don't break line before 1 letter word
    setlocal formatoptions+=t
    setlocal formatoptions+=n   " recognize numbered lists
    "setlocal formatoptions+=b   " investigate this
    "setlocal formatoptions+=m   " investigate this
    "setlocal formatoptions+=MB   " investigate this

    if g:pencil#cursorwrap
      setlocal whichwrap+=<,>,h,l,[,]
      set virtualedit+=onemore        " could break other plugins
    endif

    " clean out stuff we likely don't want
    setlocal formatoptions-=2
    setlocal formatoptions-=v
    setlocal formatoptions-=w   " trailing whitespace continues paragraph
  else
    setlocal autoindent< noautoindent<
    setlocal list< nolist<
    setlocal wrapmargin<
    setlocal display<
    setlocal formatoptions<
    setlocal whichwrap<
    setlocal virtualedit<
  endif

  if b:wrap_mode
    if g:pencil#joinspaces
      setlocal joinspaces         " two spaces after .!?
    else
      setlocal nojoinspaces       " only one space after a .!? (default)
    endif
  else
    setlocal joinspaces< nojoinspaces<
  endif

  if b:wrap_mode == s:WRAP_MODE_SOFT
    nnoremap <buffer> <silent> $ g$
    nnoremap <buffer> <silent> 0 g0
    vnoremap <buffer> <silent> $ g$
    vnoremap <buffer> <silent> 0 g0
    noremap  <buffer> <silent> <Home> g<Home>
    noremap  <buffer> <silent> <End>  g<End>
    inoremap <buffer> <silent> <Home> <C-o>g<Home>
    inoremap <buffer> <silent> <End>  <C-o>g<End>
  else
    silent! nunmap <buffer> $
    silent! nunmap <buffer> 0
    silent! vunmap <buffer> $
    silent! vunmap <buffer> 0
    silent! nunmap <buffer> <Home>
    silent! nunmap <buffer> <End>
    silent! iunmap <buffer> <Home>
    silent! iunmap <buffer> <End>
  endif

  if b:wrap_mode
    nnoremap <buffer> <silent> j gj
    nnoremap <buffer> <silent> k gk
    vnoremap <buffer> <silent> j gj
    vnoremap <buffer> <silent> k gk
    inoremap <buffer> <silent> <Up>   <C-o>g<Up>
    inoremap <buffer> <silent> <Down> <C-o>g<Down>
    noremap  <buffer> <silent> <Up>   gk
    noremap  <buffer> <silent> <Down> gj
  else
    silent! nunmap <buffer> j
    silent! nunmap <buffer> k
    silent! vunmap <buffer> j
    silent! vunmap <buffer> k
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! unmap  <buffer> <Up>
    silent! unmap  <buffer> <Down>
  endif

  " set undo points around common punctuation
  if b:wrap_mode
    inoremap <buffer> . .<C-g>u
    inoremap <buffer> ! !<C-g>u
    inoremap <buffer> ? ?<C-g>u
    inoremap <buffer> , ,<C-g>u
    inoremap <buffer> ; ;<C-g>u
  else
    silent! iunmap <buffer> .
    silent! iunmap <buffer> !
    silent! iunmap <buffer> ?
    silent! iunmap <buffer> ,
    silent! iunmap <buffer> ;
  endif
endfunction

" attempt to find a non-zero textwidth, etc.
fun! s:doOne(item) abort
  let l:matches = matchlist(a:item, '^\([a-z]\+\)=\([a-zA-Z0-9_\-.]\+\)$')
  if len(l:matches) > 1
    if l:matches[1] =~ 'textwidth\|tw'
      if l:matches[2] > b:max_textwidth
        let b:max_textwidth = l:matches[2]
      elseif l:matches[2] < b:min_textwidth
        let b:min_textwidth = l:matches[2]
      endif
    endif
    if l:matches[1] =~ 'wrapmargin\|wm'
      if l:matches[2] > b:max_wrapmargin
        let b:max_wrapmargin = l:matches[2]
      elseif l:matches[2] < b:min_wrapmargin
        let b:min_wrapmargin = l:matches[2]
      endif
    endif
  endif
endfun

" attempt to find a non-zero textwidth, etc.
fun! s:doModeline(line) abort
  let l:matches = matchlist(a:line, '\%(\S\@<!\%(vi\|vim\([<>=]\?\)\([0-9]\+\)\?\)\|\sex\):\s*\%(set\s\+\)\?\([^:]\+\):\S\@!')
  if len(l:matches) > 0
    for l:item in split(l:matches[3])
      call s:doOne(l:item)
    endfor
  endif
  let l:matches = matchlist(a:line, '\%(\S\@<!\%(vi\|vim\([<>=]\?\)\([0-9]\+\)\?\)\|\sex\):\(.\+\)')
  if len(l:matches) > 0
    for l:item in split(l:matches[3], '[ \t:]')
      call s:doOne(l:item)
    endfor
  endif
endfun

" Hat tip to https://github.com/ciaranm/securemodelines
fun! s:doModelines() abort
  if line("$") > &modelines
    let l:lines={ }
    call map(filter(getline(1, &modelines) +
          \ getline(line("$") - &modelines, "$"),
          \ 'v:val =~ ":"'), 'extend(l:lines, { v:val : 0 } )')
    for l:line in keys(l:lines)
      call s:doModeline(l:line)
    endfor
  else
    for l:line in getline(1, "$")
      call s:doModeline(l:line)
    endfor
  endif
endfun

" vim:ts=2:sw=2:sts=2
