# vim-pencil

- - -
![demo](screenshots/demo.gif)
- - -

# Features

This plugin focuses on the fundamentals of word processing in Vim:

* Use for editing markdown, textile, documentation, etc.
* Configures wrap mode for buffer, auto-detecting via modeline if present
* Adjusts navigation key mappings to suit the wrap mode
* For hard line break mode, enables Insert-mode only autoformat
* Creates undo points on common punctuation

Why such a minimalistic approach? There are several Vim plugins for
writing that offer a comprehensive solution, including changing not only
the functional behavior of the editor, but also visual aspects such as
colorscheme and font. This plugin heads in the opposite direction,
focusing narrowly on the few tweaks needed to smooth the path to writing
prose in Vim. Where you need more features, you can tailor your
environment by installing those plugins that meet your specific needs.

## Why use Vim for writing?

While programmers will extol the many virtues of Vim in writing code, few
will appreciate its powerful text manipulation capabilities for writing
documentation and prose.

But with plenty of word processing tools available, including those which
specifically cater to writers, why use a programmer’s editor like Vim for
writing?

There are good reasons NOT to use Vim for writing:

* Primitive in certain respects (no WYSIWYG or proportionally spaced
  characters, e.g.)
* A modal editor with a steep learning curve
* Time and effort to configure to your needs

But then again Vim offers a unique editing environment not matched by
other writing tools:

* Hands rest in a neutral ‘home’ position, only rarely straying to reach
  for mouse, track pad, or arrow keys
* Minimal chording, with many mnemonic-friendly commands
* Sophisticated capabilities for navigating and manipulating text
* Highly configurable to suit your needs, with many plugins available

## Installation

Install using Pathogen, Vundle, Neobundle, or your favorite Vim package
manager.

(For those new to Vim: you should first work through one of the many Vim
tutorials available. Then, once you are comfortable with the basics of
Vim, consider installing this plugin.)

## Configuration

### Hard line breaks or soft line wrapping?

Coders will have the most experience with the former, and writers the
latter. But whatever your background, chances are that you are living in
a mixed environment where you must contend with both. This plugin doesn't
force you to choose a side—each buffer can be configured independently.

In most cases you can set a default to suit your preference and let
auto-detection figure out what to do. Add to your `.vimrc`:

```vim
let g:pencil#wrapModeDefault = 'hard'   " or 'soft'
augroup pencil
  autocmd!
  autocmd FileType markdown call pencil#init()
  autocmd FileType textile call pencil#init()
  autocmd FileType text call pencil#init({'wrap': 'hard'})
augroup END
```

In the example above, for files of type `markdown` and `textile`, this
plugin will auto-detect the wrapping approach, with `hard` as the default.
But for files of type `text`, it will *always* use hard line endings.

### Commands

Because auto-detect doesn’t always work correctly, you can invoke commands
to set the behavior for the current buffer:

* `SoftPencil` - configure for soft line wrapping
* `HardPencil` - configure for hard line endings
* `TogglePencil` - if off, enables with detection; if on, turns off
* `NoPencil` - removes navigation mappings and restores global settings

Optionally, you can map to keys in your `.vimrc`:

```vim
nmap <silent> <leader>ps :SoftPencil<cr>
nmap <silent> <leader>ph :HardPencil<cr>
nmap <silent> <leader>pn :NoPencil<cr>
nmap <silent> <leader>pp :TogglePencil<cr>
```

Also, more commands in ‘Automatic Formatting’ below.

### Additional settings

You can configure the default `textwidth` for Hard mode, when none is set
or available via modeline:

```vim
let g:pencil#textwidth = 74
```

`joinspaces` determines number of spaces after period (`0`=1 space, `1`=2 spaces)

```vim
let g:pencil#joinspaces = 0
```

## Automatic formatting

_This ‘autoformat’ feature affects ‘hard’ line break mode only._

When using hard line breaks, Vim’s autoformat feature can offer many of
the same benefits as soft wrapping lines. But autoformat can cause havoc
when editing outside of paragraphs of sentences, such as when editing
a table or code block. In these cases you will need to disable it.

To set the default behavior, add to your `.vimrc`:

```vim
let g:pencil#autoformat = 1      " 1=auto, 0=manual
```

You can override this default during initialization, as in:

```vim
let g:pencil#wrapModeDefault = 'soft'
augroup pencil
  autocmd!
  autocmd FileType text call pencil#init({'wrap': 'hard', 'autoformat': 0})
  ...
augroup END
```

You can also toggle it as needed with a command:

* `AutoPencil` - enables autoformat
* `ManualPencil` - disables autoformat
* `ToggleAutoPencil` - enables if disabled, etc.

Or bind to keys in your `.vimrc`:

```vim
nnoremap <silent> <leader>pa :AutoPencil<cr>
nnoremap <silent> <leader>pm :ManualPencil<cr>
nnoremap <silent> <leader>pt :ToggleAutoPencil<cr>
```

Note that you don’t have to rely on autoformat and can alway reformat your
paragraphs manually with the standard Vim commands:

* `gqip` - manual format
* `vipJ` - manual unformat

Optionally, you can map these to underutilized keys in your `.vimrc`:

```vim
nnoremap <silent> Q gqip
nnoremap <silent> K vipJ
```

## Auto-detection via modeline

Will the wrapping mode be detected automatically? Maybe. But you can
improve its chances by giving it a hint.

At the bottom of this document is a strange code:

```
<!-- vim: set tw=74 :-->
```

This is a ‘modeline’ that tells Vim to run the following command upon
loading this file into a buffer:

```vim
:set textwidth=74
```

That’s a strong hint to this plugin that we should assume hard line
endings, regardless of whether or not soft wrapping is the default editing
mode for files of type ‘markdown’.

If it’s 0, then pencil assumes you want soft line wrapping.

```
<!-- vim: set tw=0 :-->
```

To provide a hint for detection, you can add a modeline to the last line
of your documents. For more details:

```vim
:help modeline
```

Note that even if the modelines feature is disabled (such as for security
reasons) the textwidth will still be set by this plugin.

## See also

* [Vim for Writers](http://therandymon.com/woodnotes/vim-for-writers/vimforwriters.html) - guide to the basics geared to writers
* [Vim-related books](http://iccf-holland.org/click5.html)
* [Vim Training Class - Basic motions and commands](https://www.youtube.com/watch?v=Nim4_f5QUxA) - video tutorial by Shawn Biddle

If you like this plugin, you might like these others from the same author:

* [vim-lexical](http://github.com/reedes/vim-lexical) - Building on Vim’s spell-check and thesaurus/dictionary completion
* [vim-litecorrect](http://github.com/reedes/vim-litecorrect) - Lightweight auto-correction for Vim
* [vim-quotable](http://github.com/reedes/vim-quotable) - extends Vim to support typographic (‘curly’) quotes
* [vim-thematic](http://github.com/reedes/vim-thematic) — Conveniently manage Vim’s appearance to suit your task and environment
* [vim-colors-pencil](http://github.com/reedes/vim-colors-pencil) — A color scheme for Vim inspired by IA Writer

## Future development

If you’ve spotted a problem or have an idea on improving this plugin,
please post it to the github project issue page.

```
<!-- vim: set tw=74 :-->
```
