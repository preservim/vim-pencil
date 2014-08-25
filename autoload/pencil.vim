" ============================================================================
" File:        pencil.vim
" Description: autoload functions for vim-pencil plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Created:     December 28, 2013
" License:     The MIT License (MIT)
" ============================================================================

if exists("autoloaded_pencil") | fini | en
let autoloaded_pencil = 1

let s:WRAP_MODE_DEFAULT = -1
let s:WRAP_MODE_OFF     = 0
let s:WRAP_MODE_HARD    = 1
let s:WRAP_MODE_SOFT    = 2

" Wrap-mode detector
" Scan lines at end and beginning of file to determine the wrap mode.
" Modelines has priority over long lines found.
fun! s:detect_wrap_mode() abort

  let b:max_textwidth = -1      " assume no relevant modeline
  call s:doModelines()

  if b:max_textwidth > 0
    " modelines(s) found with positive textwidth, so hard line breaks
    return s:WRAP_MODE_HARD
  en

  if b:max_textwidth == 0 || g:pencil#wrapModeDefault ==# 'soft'
    " modeline(s) found only with zero textwidth, so it's soft line wrap
    " or, the user wants to default to soft line wrap
    return s:WRAP_MODE_SOFT
  en

  " attempt to rule out soft line wrap
  " scan initial lines in an attempt to detect long lines
  for l:line in getline(1, g:pencil#softDetectSample)
    if len(l:line) > g:pencil#softDetectThreshold
      return s:WRAP_MODE_SOFT
    en
  endfo

  " punt
  return s:WRAP_MODE_DEFAULT
endf

fun! s:imap(preserve_completion, key, icmd)
  if a:preserve_completion
    exe ":ino <silent> <expr> " . a:key . " pumvisible() ? \"" . a:key . "\" : \"" . a:icmd . "\""
  el
    exe ":ino <silent> " . a:key . " " . a:icmd
  en
endf

fun! s:enable_autoformat(mode)
  " mode=1  InsertEnter
  " mode=0  InsertLeave
  if a:mode
    " don't enable autoformat if in a code block (or table)
    let l:okay_to_enable = 1
    for l:sid in synstack(line('.'), col('.'))
      if match(synIDattr(l:sid, 'name'),
             \ g:pencil#autoformat_exclude_re) == -1
        let l:okay_to_enable = 0
        break
      en
    endfo
    if l:okay_to_enable
      set formatoptions+=a
    en
  el
    set formatoptions-=a
  en
endf

fun! pencil#setAutoFormat(mode)
  " 1=auto, 0=manual, -1=toggle
  if !exists('b:last_autoformat')
    let b:last_autoformat = 0
  en
  let b:last_autoformat = a:mode == -1 ? !b:last_autoformat : a:mode
  if b:last_autoformat
    aug pencil_autoformat
      au InsertEnter <buffer> call s:enable_autoformat(1)
      au InsertLeave <buffer> call s:enable_autoformat(0)
    aug END
  el
    sil! au! pencil_autoformat * <buffer>
  en
endf

" Create mappings for word processing
" args:
"   'wrap': 'detect|off|hard|soft|toggle'
fun! pencil#init(...) abort
  let l:args = a:0 ? a:1 : {}

  if !exists('b:wrap_mode')
    let b:wrap_mode = s:WRAP_MODE_OFF
  en
  if !exists("b:max_textwidth")
    let b:max_textwidth = -1
  en

  " If user explicitly requested wrap_mode thru args, go with that.
  let l:wrap_arg = get(l:args, 'wrap', 'detect')

  if (b:wrap_mode && l:wrap_arg ==# 'toggle') ||
   \ l:wrap_arg =~# '^\(0\|off\|disable\|false\)$'
    let b:wrap_mode = s:WRAP_MODE_OFF
  elsei l:wrap_arg ==# 'hard'
    let b:wrap_mode = s:WRAP_MODE_HARD
  elsei l:wrap_arg ==# 'soft'
    let b:wrap_mode = s:WRAP_MODE_SOFT
  elsei l:wrap_arg ==# 'default'
    let b:wrap_mode = s:WRAP_MODE_DEFAULT
  el
    " this can return s:WRAP_MODE_ for soft, hard or default
    let b:wrap_mode = s:detect_wrap_mode()
  en

  " translate default(-1) to soft(1) or hard(2) or off(0)
  if b:wrap_mode == s:WRAP_MODE_DEFAULT
    if g:pencil#wrapModeDefault =~# '^\(0\|off\|disable\|false\)$'
      let b:wrap_mode = s:WRAP_MODE_OFF
    elsei g:pencil#wrapModeDefault ==# 'soft'
      let b:wrap_mode = s:WRAP_MODE_SOFT
    el
      let b:wrap_mode = s:WRAP_MODE_HARD
    en
  en

  " autoformat is only used in Hard mode, and then only during
  " Insert mode
  call pencil#setAutoFormat(
        \ b:wrap_mode == s:WRAP_MODE_HARD &&
        \ get(l:args, 'autoformat', g:pencil#autoformat))

  if b:wrap_mode == s:WRAP_MODE_HARD
    if &modeline == 0 && b:max_textwidth > 0
      " Compensate for disabled modeline
      exe 'setl textwidth=' . b:max_textwidth
    elsei &textwidth == 0
      exe 'setl textwidth=' . g:pencil#textwidth
    el
      setl textwidth<
    en
    setl nowrap
  elsei b:wrap_mode == s:WRAP_MODE_SOFT
    setl textwidth=0
    setl wrap
    setl linebreak
    setl colorcolumn=0      " doesn't align as expected
  el
    setl textwidth<
    setl wrap< nowrap<
    setl linebreak< nolinebreak<
    setl colorcolumn<
  en

  " global settings
  if b:wrap_mode
    set display+=lastline
    set backspace=indent,eol,start
    if g:pencil#joinspaces
      set joinspaces         " two spaces after .!?
    el
      set nojoinspaces       " only one space after a .!? (default)
    en

    "if b:wrap_mode == s:WRAP_MODE_SOFT
    "  " augment with additional chars
    "  " TODO not working yet with n and m-dash
    "  set breakat=\ !@*-+;:,./?([{
    "en
  en

  " because ve=onemore is relatively rare and could break
  " other plugins, restrict its presence to buffer
  " Better: restore ve to original setting
  if b:wrap_mode && g:pencil#cursorwrap
    set whichwrap+=<,>,b,s,h,l,[,]
    aug pencil_cursorwrap
      au BufEnter <buffer> set virtualedit+=onemore
      au BufLeave <buffer> set virtualedit-=onemore
    aug END
  el
    sil! au! pencil_cursorwrap * <buffer>
  en

  " window/buffer settings
  if b:wrap_mode
    setl nolist
    setl wrapmargin=0
    setl autoindent         " needed by formatoptions=n
    setl nosmartindent      " avoid c-style indents in prose
    setl formatoptions+=n   " recognize numbered lists
    setl formatoptions+=1   " don't break line before 1 letter word
    setl formatoptions+=t   " autoformat of text (vim default)
    setl formatoptions+=c   " autoformat of comments (vim default)

    " clean out stuff we likely don't want
    setl formatoptions-=2   " use indent of 2nd line for rest of paragraph
    setl formatoptions-=v   " only break line at blank entered during insert
    setl formatoptions-=w   " avoid erratic behavior if mixed spaces
    setl formatoptions-=a   " autoformat will turn on with Insert in HardPencil mode
    setl formatoptions-=r   " don't insert comment leader
    setl formatoptions-=o   " don't insert comment leader

    if has('conceal')
      exe ':setl conceallevel=' . g:pencil#conceallevel
      exe ':setl concealcursor=' . g:pencil#concealcursor
    en
  el
    setl smartindent< nosmartindent<
    setl autoindent< noautoindent<
    setl list< nolist<
    setl wrapmargin<
    setl formatoptions<
    if has('conceal')
      setl conceallevel<
      setl concealcursor<
    en
  en

  if b:wrap_mode == s:WRAP_MODE_SOFT
    nn <buffer> <silent> $ g$
    nn <buffer> <silent> 0 g0
    vn <buffer> <silent> $ g$
    vn <buffer> <silent> 0 g0
    no <buffer> <silent> <Home> g<Home>
    no <buffer> <silent> <End>  g<End>

    " preserve behavior of home/end keys in popups
    call s:imap(1, '<Home>', '<C-o>g<Home>')
    call s:imap(1, '<End>' , '<C-o>g<End>' )
  el
    sil! nun <buffer> $
    sil! nun <buffer> 0
    sil! vu  <buffer> $
    sil! vu  <buffer> 0
    sil! nun <buffer> <Home>
    sil! nun <buffer> <End>
    sil! iu  <buffer> <Home>
    sil! iu  <buffer> <End>
  en

  if b:wrap_mode
    nn <buffer> <silent> j gj
    nn <buffer> <silent> k gk
    vn <buffer> <silent> j gj
    vn <buffer> <silent> k gk
    no <buffer> <silent> <Up>   gk
    no <buffer> <silent> <Down> gj

    " preserve behavior of up/down keys in popups
    call s:imap(1, '<Up>'  , '<C-o>g<Up>'  )
    call s:imap(1, '<Down>', '<C-o>g<Down>')
  el
    sil! nun <buffer> j
    sil! nun <buffer> k
    sil! vu  <buffer> j
    sil! vu  <buffer> k
    sil! unm <buffer> <Up>
    sil! unm <buffer> <Down>

    sil! iu <buffer> <Up>
    sil! iu <buffer> <Down>
  en

  " set undo points around common punctuation,
  " line <c-u> and word <c-w> deletions
  if b:wrap_mode
    ino <buffer> . .<c-g>u
    ino <buffer> ! !<c-g>u
    ino <buffer> ? ?<c-g>u
    ino <buffer> , ,<c-g>u
    ino <buffer> ; ;<c-g>u
    ino <buffer> : :<c-g>u
    ino <buffer> <c-u> <c-g>u<c-u>
    ino <buffer> <c-w> <c-g>u<c-w>
    ino <buffer> <cr> <c-g>u<cr>
  el
    sil! iu <buffer> .
    sil! iu <buffer> !
    sil! iu <buffer> ?
    sil! iu <buffer> ,
    sil! iu <buffer> ;
    sil! iu <buffer> :
    sil! iu <buffer> <c-u>
    sil! iu <buffer> <c-w>
    sil! iu <buffer> <cr>
  en
endf

" attempt to find a non-zero textwidth, etc.
fun! s:doOne(item) abort
  let l:matches = matchlist(a:item, '^\([a-z]\+\)=\([a-zA-Z0-9_\-.]\+\)$')
  if len(l:matches) > 1
    if l:matches[1] =~ 'textwidth\|tw'
      let l:tw = str2nr(l:matches[2])
      if l:tw > b:max_textwidth
        let b:max_textwidth = l:tw
      en
    en
  en
endf

" attempt to find a non-zero textwidth, etc.
fun! s:doModeline(line) abort
  let l:matches = matchlist(a:line, '\%(\S\@<!\%(vi\|vim\([<>=]\?\)\([0-9]\+\)\?\)\|\sex\):\s*\%(set\s\+\)\?\([^:]\+\):\S\@!')
  if len(l:matches) > 0
    for l:item in split(l:matches[3])
      call s:doOne(l:item)
    endfo
  en
  let l:matches = matchlist(a:line, '\%(\S\@<!\%(vi\|vim\([<>=]\?\)\([0-9]\+\)\?\)\|\sex\):\(.\+\)')
  if len(l:matches) > 0
    for l:item in split(l:matches[3], '[ \t:]')
      call s:doOne(l:item)
    endfo
  en
endf

" sample lines for detection, capturing both
" modeline(s) and max line length
" Hat tip to https://github.com/ciaranm/securemodelines
fun! s:doModelines() abort
  if line("$") > &modelines
    let l:lines={ }
    call map(filter(getline(1, &modelines) +
          \ getline(line("$") - &modelines, "$"),
          \ 'v:val =~ ":"'), 'extend(l:lines, { v:val : 0 } )')
    for l:line in keys(l:lines)
      call s:doModeline(l:line)
    endfo
  el
    for l:line in getline(1, "$")
      call s:doModeline(l:line)
    endfo
  en
endf

" vim:ts=2:sw=2:sts=2
