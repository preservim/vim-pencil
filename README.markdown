# vim-pencil

> Rethinking Vim as a tool for writers

<br/>

- - -
![demo](screenshots/demo.gif)
- - -

# Features

The _pencil_ plugin aspires to make Vim as powerful a tool for writers as
it is for coders by focusing narrowly on the handful of tweaks needed to
smooth the path to writing prose.

* For editing files in _text_, _markdown_, _textile_, and other
  prose-oriented file types
* Agnostic on soft line wrap _versus_ hard line breaks, supporting both
* Auto-detects wrap mode via modeline and sampling
* Adjusts navigation key mappings to suit the wrap mode
* Creates undo points on common punctuation
* When using hard line breaks, enables autoformat while inserting text
* Buffer-scoped configuration (with a few minor exceptions, _pencil_
  preserves your global settings)
* Pure Vimscript with no dependencies

Need spell-check and other features? Vim is about customization. To
complete your editing environment, learn to configure Vim and draw upon
its rich ecosystem of plugins.

## Why use Vim for writing?

With plenty of word processing applications available, including those
that specifically cater to writers, why use a programmer’s editor like Vim
for writing?

There are good reasons NOT to use Vim for writing:

* Primitive in certain respects (no WYSIWYG or proportionally spaced
  characters, e.g.)
* A modal editor with a relatively steep learning curve
* Time and effort to configure to your needs

But Vim offers a unique editing environment not matched by other writing
tools:

* Hands rest in a neutral ‘home’ position, only rarely straying to reach
  for mouse, track pad, or arrow keys
* Minimal chording, with many mnemonic-friendly commands
* Sophisticated capabilities for navigating and manipulating text
* Highly configurable to suit your needs, with many great plugins available

## Installation

Install using Pathogen, Vundle, Neobundle, or your favorite Vim package
manager.

_For those new to Vim: before installing this plugin, consider getting
comfortable with the basics of Vim by working through one of the many
tutorials available._

## Configuration

### Hard line breaks or soft line wrap?

Coders will have the most experience with the former, and writers the
latter. But whatever your background, chances are that you must contend
with both conventions. This plugin doesn't force you to choose a side—you
can configure each buffer independently.

In most cases you can set a default to suit your preference and let
auto-detection figure out what to do. Add to your `.vimrc`:

```vim
" standard vim command to enable loading the plugin files
" (and their indent support) for specific file types.
" It may already be in your .vimrc!
filetype plugin indent on

let g:pencil#wrapModeDefault = 'hard'   " or 'soft'

augroup pencil
  autocmd!
  autocmd FileType markdown call pencil#init()
  autocmd FileType textile call pencil#init()
  autocmd FileType text call pencil#init({'wrap': 'hard'})
augroup END
```

In the example above, for files of type `markdown` and `textile`, this
plugin will auto-detect the line wrap approach, with `hard` as the
default. But for files of type `text`, it will *always* initialize with
hard line break mode.

### Commands

Because auto-detect might not work as intended, you can invoke a command
to set the behavior for the current buffer:

* `SoftPencil` - enable soft line wrap mode
* `HardPencil` - enable hard line break mode
* `NoPencil` - removes navigation mappings and restores buffer to global settings
* `TogglePencil` - if on, turns off; if off, enables with detection

Optionally, you can map to keys in your `.vimrc`:

```vim
nnoremap <silent> <leader>ps :SoftPencil<cr>
nnoremap <silent> <leader>ph :HardPencil<cr>
nnoremap <silent> <leader>pn :NoPencil<cr>
nnoremap <silent> <leader>pt :TogglePencil<cr>
```

### Automatic formatting

_This ‘autoformat’ feature affects *HardPencil* mode only._

When in *HardPencil* mode, Vim’s autoformat feature will be enabled by
default in Insert mode and can offer many of the same benefits as soft
line wrap. But autoformat will cause havoc when editing anything but
paragraphs of words, such as a code block or table. In these cases you
will need to disable it, at least temporarily, via a command:

* `AutoPencil` - enables autoformat
* `ManualPencil` - disables autoformat
* `ShiftPencil` - toggle to enable if disabled, etc.

Or optionally map to keys in your `.vimrc`:

```vim
nnoremap <silent> <leader>pa :AutoPencil<cr>
nnoremap <silent> <leader>pm :ManualPencil<cr>
nnoremap <silent> <leader>pp :ShiftPencil<cr>
```

To set the default behavior, add to your `.vimrc`:

```vim
let g:pencil#autoformat = 1      " 0=manual, 1=auto
```

You can override this default during initialization, as in:

```vim
augroup pencil
  autocmd!
  autocmd FileType text call pencil#init({'wrap': 'hard', 'autoformat': 0})
  ...
augroup END
```

...where by default, files of type `text` will use hard line endings, but
with autoformat disabled.

### Manual formatting

Note that you need not rely on autoformat exclusively and can manually
reformat paragraphs with standard Vim commands:

* `gqip` or `gwip` - format current paragraph
* `vipJ` - unformat current paragraph
* `ggVGgq` or `:g/^/norm gqq` - format all paragraphs in buffer
* `:%norm vipJ` - unformat all paragraphs in buffer

Optionally, you can map these operations to underutilized keys in your
`.vimrc`:

```vim
nnoremap <silent> Q gwip
nnoremap <silent> K vipJ
nnoremap <silent> <leader>Q ggVGgq
nnoremap <silent> <leader>K :%norm vipJ<cr>
```

### Default textwidth

You can configure the textwidth to be used in **HardPencil** mode when no
textwidth is set globally, locally, or available via modeline. It defaults
to `74`, but you can change that value in your `.vimrc`:

```vim
let g:pencil#textwidth = 74
```

### Sentence spacing

By default, when formatting only one space will be inserted after
a period(`.`), exclamation point(`!`), or question mark(`?`). You can
change this default:

```vim
let g:pencil#joinspaces = 0     " 0=one_space, 1=two_spaces
```

### Cursor wrap

By default, `h`/`l` and the left/right cursor keys will move to the
previous/next line after reaching first/last character in a line with
a hard break. If you wish to retain the default Vim behavior, set the
`cursorwrap` value to `0` in your `.vimrc`:

```vim
let g:pencil#cursorwrap = 1     " 0=disable, 1=enable
```

## Auto-detecting wrap mode

If you didn't explicitly specify a wrap mode during initialization,
_pencil_ will attempt to detect it.

It will first look for a `textwidth` (or `tw`) specified in a modeline.
Failing that, _pencil_ will then sample lines from the start of the file.

### Detect via modeline

Will the wrap mode be detected accurately? Maybe. But you can improve its
chances by giving _pencil_ an explicit hint.

At the bottom of this document is a odd-looking code:

```
<!-- vim: set tw=74 :-->
```

This is an **optional** ‘modeline’ that tells Vim to run the following
command upon loading the file into a buffer:

```vim
:set textwidth=74
```

It tells _pencil_ to assume hard line breaks, regardless of whether or
not soft line wrap is the default editing mode for files of type ‘markdown’.

You explicitly specify soft wrap mode by specifying a textwidth of `0`:

```
<!-- vim: set tw=0 :-->
```

Note that if the modelines feature is disabled (such as for security
reasons) the textwidth will still be set by this plugin.

### Detect via sampling

If no modeline with a textwidth is found, _pencil_ will sample the initial
lines from the file, looking for those excessively-long.

There are two settings you can add to your `.vimrc` to tweak this behavior.

The maximum number of lines to sample from the start of the file:

```vim
let g:pencil#softDetectSample = 20
```

Set that value to `0` to disable detection via line sampling.

When the number of bytes on a sampled line per exceeds this next value,
then _pencil_ assumes soft line wrap.

```vim
let g:pencil#softDetectThreshold = 130
```

If no such lines found, _pencil_ falls back to the default mentioned earlier:

```vim
let g:pencil#wrapModeDefault = 'hard'   " or 'soft'
```

## See also

* [To Vim][tv] - Writer and psychologist Ian Hocking on using Vim for writing
* [Vim Training Class - Basic motions and commands][tc] - video tutorial by Shawn Biddle
* [Vim for Writers][vw] - guide to the basics geared to writers

Other plugins of specific interest to writers:

* [tpope/vim-abolish][ab] - easily search for, substitute, and abbreviate multiple variants of a word
* [tommcdo/vim-exchange][ex] - easy text exchange operator for Vim

If you find the _pencil_ plugin useful, check out these others by [@reedes][re]:

* [vim-colors-pencil][cp] - color scheme for Vim inspired by IA Writer
* [vim-lexical][lx] - building on Vim’s spell-check and thesaurus/dictionary completion
* [vim-litecorrect][lc] - lightweight auto-correction for Vim
* [vim-quotable][qu] - extends Vim to support typographic (‘curly’) quotes
* [vim-textobj-sentence][ts] - improving on Vim's native sentence motion command
* [vim-thematic][th] - modify Vim’s appearance to suit your task and environment
* [vim-wheel][wh] - screen-anchored cursor movement for Vim
* [vim-wordy][wo] - uncovering usage problems in writing

[ab]: http://github.com/tpope/vim-abolish
[ex]: http://github.com/tommcdo/vim-exchange
[tv]: http://ianhocking.com/2013/11/17/to-vim/
[tc]: https://www.youtube.com/watch?v=Nim4_f5QUxA
[vw]: http://therandymon.com/woodnotes/vim-for-writers/vimforwriters.html
[re]: http://github.com/reedes
[cp]: http://github.com/reedes/vim-colors-pencil
[lx]: http://github.com/reedes/vim-lexical
[lc]: http://github.com/reedes/vim-litecorrect
[qu]: http://github.com/reedes/vim-quotable
[ts]: http://github.com/reedes/vim-textobj-sentence
[th]: http://github.com/reedes/vim-thematic
[wh]: http://github.com/reedes/vim-wheel
[wo]: http://github.com/reedes/vim-wordy

## Future development

If you’ve spotted a problem or have an idea on improving this plugin,
please post it to the github project issue page.

```
<!-- vim: set tw=74 :-->
```
