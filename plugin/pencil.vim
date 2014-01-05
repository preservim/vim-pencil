" ============================================================================
" File:        pencil.vim
" Description: vim-pencil plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Last Change: December 28, 2013
" License:     The MIT License (MIT)
" ============================================================================
"
if exists('g:loaded_pencil') || &cp | finish | endif
let g:loaded_pencil = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:pencil#wrapModeDefault')
  " user-overridable default, if detection fails
  " should be 'soft' or 'hard' or 'off'
  let g:pencil#wrapModeDefault = 'hard'
endif

if !exists('g:pencil#textwidth')
  " textwidth used when in hard linebreak mode
  let g:pencil#textwidth = 74
endif

if !exists('g:pencil#autoformat')
  " by default, automatically format text when in Insert mode
  " with hard wrap.
  let g:pencil#autoformat = 1
endif

if !exists('g:pencil#joinspaces')
  " by default, only one space after full stop (.)
  let g:pencil#joinspaces = 0
endif

" # Commands
command -nargs=0 PencilHard   call pencil#init({'wrap': 'hard'})
command -nargs=0 PencilSoft   call pencil#init({'wrap': 'soft'})
command -nargs=0 PencilOff    call pencil#init({'wrap': 'off' })
command -nargs=0 PencilToggle call pencil#init({'wrap': 'toggle' })

command -nargs=0 PencilFormatAuto   call pencil#setAutoFormat(1)
command -nargs=0 PencilFormatManual call pencil#setAutoFormat(0)
command -nargs=0 PencilFormatToggle call pencil#setAutoFormat(-1)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:ts=2:sw=2:sts=2
