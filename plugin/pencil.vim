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
