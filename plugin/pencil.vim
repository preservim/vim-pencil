" ============================================================================
" File:        pencil.vim
" Description: vim-pencil plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Created:     December 28, 2013
" License:     The MIT License (MIT)
" ============================================================================
"
if exists('g:loaded_pencil') || &cp | fini | en
let g:loaded_pencil = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpo = &cpo
set cpo&vim

let s:WRAP_MODE_DEFAULT = -1
let s:WRAP_MODE_OFF     = 0
let s:WRAP_MODE_HARD    = 1
let s:WRAP_MODE_SOFT    = 2

fun! s:unicode_enabled()
  retu &encoding ==# 'utf-8'
endf

" helper for statusline
"
" Note that it shouldn't be dependent on init(), which
" won't have been called for non-prose modules.
fun! PencilMode()
  if exists('b:pencil_wrap_mode')
    if b:pencil_wrap_mode ==# s:WRAP_MODE_SOFT
      return get(g:pencil#mode_indicators, 'soft', 'sp')
    elsei b:pencil_wrap_mode ==# s:WRAP_MODE_HARD
      return get(g:pencil#mode_indicators, 'hard', 'hp')
    el
      return get(g:pencil#mode_indicators, 'off', '')
    en
  else
    return ''
  en
endf

if !exists('g:pencil#wrapModeDefault')
  " user-overridable default, if detection fails
  " should be 'soft' or 'hard' or 'off'
  let g:pencil#wrapModeDefault = 'hard'
en

if !exists('g:pencil#textwidth')
  " textwidth used when in hard linebreak mode
  let g:pencil#textwidth = 74
en

if !exists('g:pencil#autoformat')
  " by default, automatically format text when in Insert mode
  " with hard wrap.
  let g:pencil#autoformat = 1
en

if !exists('g:pencil#autoformat_blacklist')
  " by default, pencil does NOT start autoformat if inside any of
  " the following syntax groups
  "
  "'markdownCode', 'markdownUrl', 'markdownIdDeclaration',
  "'markdownLinkDelimiter', 'markdownHighlight[A-Za-z0-9]+' (tpope/vim-markdown)
  "'mkdCode', 'mkdIndentCode' (plasticboy/vim-markdown)
  "'markdownFencedCodeBlock', 'markdownInlineCode' (gabrielelana/vim-markdown)
  "'mmdTable[A-Za-z0-9]*' (mattly/vim-markdown-enhancements)
  "'txtCode' (timcharper/textile.vim)
  let g:pencil#autoformat_blacklist = [
        \ 'markdownCode',
        \ 'markdownUrl',
        \ 'markdownIdDeclaration',
        \ 'markdownLinkDelimiter',
        \ 'markdownHighlight[A-Za-z0-9]+',
        \ 'mkdCode',
        \ 'mkdIndentCode',
        \ 'markdownFencedCodeBlock',
        \ 'markdownInlineCode',
        \ 'mmdTable[A-Za-z0-9]*',
        \ 'txtCode',
        \ ]
en
let g:pencil#autoformat_blacklist_re =
  \ '\v(' . join(g:pencil#autoformat_blacklist, '|') . ')'

if !exists('g:pencil#joinspaces')
  " by default, only one space after full stop (.)
  let g:pencil#joinspaces = 0
en

if !exists('g:pencil#cursorwrap')
  " by default, h/l and cursor keys will wrap around hard
  " linebreaks. Set to 0 if you don't want this behavior
  let g:pencil#cursorwrap = 1
en

if !exists('g:pencil#conceallevel')
  " by default, concealing capability in your syntax plugin
  " will be enabled. See tpope/vim-markdown for example.
  " 0=disable, 1=onechar, 2=hidecust, 3=hideall
  let g:pencil#conceallevel = 3
en
if !exists('g:pencil#concealcursor')
  " n=normal, v=visual, i=insert, c=command
  let g:pencil#concealcursor = 'c'
en

if !exists('g:pencil#softDetectSample')
  " if no modeline, read as many as this many lines at
  " start of file in attempt to detect at least one line
  " whose byte count exceeds g:pencil#softDetectThreshold
  let g:pencil#softDetectSample = 20
en

if !exists('g:pencil#softDetectThreshold')
  " if the byte count of at least one sampled line exceeds
  " this number, then pencil assumes soft line wrapping
  let g:pencil#softDetectThreshold = 130
en

if !exists('g:pencil#mode_indicators')
  " used to set PencilMode() for statusline
  if s:unicode_enabled()
    let g:pencil#mode_indicators = {'hard': 'h✎ ', 'soft': 's✎ ', 'off': '×✎ ',}
  el
    let g:pencil#mode_indicators = {'hard': 'hp', 'soft': 'sp', 'off': '',}
  en
en

" # coms
com -nargs=0 HardPencil    call pencil#init({'wrap': 'hard'})
com -nargs=0 SoftPencil    call pencil#init({'wrap': 'soft'})
com -nargs=0 DropPencil    call pencil#init({'wrap': 'off' })
com -nargs=0 NoPencil      call pencil#init({'wrap': 'off' })
com -nargs=0 TogglePencil  call pencil#init({'wrap': 'toggle'})

com -nargs=0 AutoPencil    call pencil#setAutoFormat(1)
com -nargs=0 ManualPencil  call pencil#setAutoFormat(0)
com -nargs=0 ShiftPencil   call pencil#setAutoFormat(-1)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:ts=2:sw=2:sts=2
