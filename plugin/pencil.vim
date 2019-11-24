" ============================================================================
" File:        pencil.vim
" Description: vim-pencil plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Created:     December 28, 2013
" License:     The MIT License (MIT)
" ============================================================================

scriptencoding utf-8

if exists('g:loaded_pencil') || &compatible | fini | en
let g:loaded_pencil = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

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
      return get(g:pencil#mode_indicators, 'soft', 'S')
    elsei b:pencil_wrap_mode ==# s:WRAP_MODE_HARD
      if &formatoptions =~# 'a'
        return get(g:pencil#mode_indicators, 'auto', 'A')
      el
        return get(g:pencil#mode_indicators, 'hard', 'H')
      en
    el
      return get(g:pencil#mode_indicators, 'off', '')
    en
  else
    return ''   " should be blank for non-prose modes
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

if !exists('g:pencil#autoformat_config')
  " Do not activate autoformat if entering Insert mode when
  " the cursor is inside any of the following syntax groups.
  "
  " markdown* (tpope/vim-markdown)
  " mkd*, htmlH[0-9] (plasticboy/vim-markdown)
  " markdownFencedCodeBlock, markdownInlineCode, markdownRule, markdownH[0-9] (gabrielelana/vim-markdown)
  " mmdTable[A-Za-z0-9]* (mattly/vim-markdown-enhancements)
  " txtCode (timcharper/textile.vim)
  " rst*,tex*,asciidoc* (syntax file shipped with vim)
  let g:pencil#autoformat_config = {
        \   'markdown': {
        \     'black': [
        \       'htmlH[0-9]',
        \       'markdown(Code|H[0-9]|Url|IdDeclaration|Link|Rule|Highlight[A-Za-z0-9]+)',
        \       'markdown(FencedCodeBlock|InlineCode)',
        \       'mkd(Code|Rule|Delimiter|Link|ListItem|IndentCode|Snippet)',
        \       'mmdTable[A-Za-z0-9]*',
        \     ],
        \     'white': [
        \      'markdown(Code|Link)',
        \     ],
        \   },
        \   'asciidoc': {
        \     'black': [
        \       'asciidoc(AttributeList|AttributeEntry|ListLabel|Literal|SideBar|Source|Sect[0-9])',
        \       'asciidoc[A-Za-z]*(Block|Macro|Title)',
        \     ],
        \     'white': [
        \      'asciidoc(AttributeRef|Macro)',
        \     ],
        \     'enforce-previous-line': 1,
        \   },
        \   'rst': {
        \     'black': [
        \       'rst(CodeBlock|Directive|ExDirective|LiteralBlock|Sections)',
        \       'rst(Comment|Delimiter|ExplicitMarkup|SimpleTable)',
        \     ],
        \   },
        \   'tex': {
        \     'black': [
        \       'tex(BeginEndName|Delimiter|DocType|InputFile|Math|RefZone|Statement|Title)',
        \       'texSection$',
        \     ],
        \     'enforce-previous-line': 1,
        \   },
        \   'textile': {
        \     'black': [
        \       'txtCode',
        \     ],
        \   },
        \   'pandoc': {
        \     'black': [
        \       '^pandoc.*Code.*',
        \       'pandocHTML',
        \       'pandocLaTeXMathBlock',
        \       '^pandoc.*List.*',
        \       '^pandoc.*Table.*',
        \       'pandocYAMLHeader',
        \     ],
        \   }
        \ }
en
if !exists('g:pencil#autoformat_aliases')
  " Aliases used exclusively for autoformat config.
  " Pencil will NOT modify the filetype setting.
  let g:pencil#autoformat_aliases = {
        \    'md': 'markdown',
        \    'mkd': 'markdown',
        \  }
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

if !exists('g:pencil#mode_indicators')
  " used to set PencilMode() for statusline
  if s:unicode_enabled()
    let g:pencil#mode_indicators = {'hard': '␍', 'auto': 'ª', 'soft': '⤸', 'off': '',}
  el
    let g:pencil#mode_indicators = {'hard': 'H', 'auto': 'A', 'soft': 'S', 'off': '',}
  en
en

" Commands

com -nargs=0 Pencil         call pencil#init({'wrap': 'on' })
com -nargs=0 PencilOff      call pencil#init({'wrap': 'off' })
com -nargs=0 NoPencil       call pencil#init({'wrap': 'off' })
com -nargs=0 HardPencil     call pencil#init({'wrap': 'hard'})
com -nargs=0 PencilHard     call pencil#init({'wrap': 'hard'})
com -nargs=0 SoftPencil     call pencil#init({'wrap': 'soft'})
com -nargs=0 PencilSoft     call pencil#init({'wrap': 'soft'})
com -nargs=0 PencilToggle   call pencil#init({'wrap': 'toggle'})
com -nargs=0 TogglePencil   call pencil#init({'wrap': 'toggle'})
com -nargs=0 PFormat        call pencil#setAutoFormat(1)
com -nargs=0 PFormatOff     call pencil#setAutoFormat(0)
com -nargs=0 PFormatToggle  call pencil#setAutoFormat(-1)

" NOTE: legacy commands have been disabled by default as of 31-Dec-15
"       These will be removed entirely on 31-Dec-16
if !exists('g:pencil#legacyCommands')
  let g:pencil#legacyCommands = 0
en
if g:pencil#legacyCommands
  com -nargs=0 DropPencil    call pencil#init({'wrap': 'off' })
  com -nargs=0 AutoPencil    call pencil#setAutoFormat(1)
  com -nargs=0 ManualPencil  call pencil#setAutoFormat(0)
  com -nargs=0 ShiftPencil   call pencil#setAutoFormat(-1)
en

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" vim:ts=2:sw=2:sts=2
