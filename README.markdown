# vim-pencil

> Rethinking Vim as a tool for writers

<br/>

- - -
![demo](http://i.imgur.com/0KYl5vU.gif)
- - -

# Features

The _pencil_ plugin aspires to make Vim as powerful a tool for writers as
it is for coders by focusing narrowly on the handful of tweaks needed to
smooth the path to writing prose.

* For editing prose-oriented file types such as _text_, _markdown_,
  _mail_, _rst_, _tex_, _textile_, and _asciidoc_
* Agnostic on soft line wrap _versus_ hard line breaks, supporting both
* Auto-detects wrap mode via `modeline` and sampling
* Adjusts navigation key mappings to suit the wrap mode
* Creates undo points on common punctuation during Insert mode, including
  deletion via line `<C-U>` and word `<C-W>`
* When using hard line breaks, _pencil_ enables Vim’s autoformat while
  inserting text, except for tables and code blocks where you won’t want
  it
* Buffer-scoped configuration (with a few minor exceptions, _pencil_ preserves
  your global settings)
* Support for Vim’s Conceal feature to hide markup defined by Syntax plugins
  (e.g., `_` and `*` markup for styled text in \_*Markdown*\_)
* Support for display of mode indicator (`␍` and `⤸`, e.g.) in the status line
* Pure Vimscript with no dependencies

Need spell-check, distraction-free editing, and other features? Vim is about
customization. To complete your editing environment, learn to configure Vim and
draw upon its rich ecosystem of plugins.

# Why use Vim for writing?

With plenty of word processing applications available, including those
that specifically cater to writers, why use a modal editor like Vim?
Several reasons have been offered:

* Your hands can rest in a neutral ‘home’ position, only rarely straying
  to reach for mouse, track pad, or arrow keys
* Minimal chording, with many mnemonic-friendly commands
* Sophisticated capabilities for navigating and manipulating text
* Highly configurable, enabling you to build a workflow that suits your
  needs, with many great plugins available
* No proprietary format lock-in

But while such reasons might be sound, they remain scant justification to
switch away from the familiar word processor. Instead, you need
a compelling reason—one that can appeal to a writer’s love for language
and the tools of writing.

You can find that reason in Vim's mysterious command sequences. Take `cas`
for instance. You might see it as a mnemonic for _Change Around Sentence_
to replace an existing sentence. But dig a bit deeper to discover that
such commands have a grammar of their own, comprised of nouns, verbs, and
modifiers. Think of them as the composable building blocks of a _domain
specific language_ for manipulating text, one that can become a powerful
tool in expressing yourself. For more details on vi-style editing, see...

* [Learn to speak vim – verbs, nouns, and modifiers!][ls] (December 2011)
* [Your problem with Vim is that you don't grok vi][gv] (December 2011)
* [Intro to Vim's Grammar][ig] (January 2013)
* [Why Atom Can’t Replace Vim, Learning the lesson of vi][wa] (March 2014)

[ls]: http://yanpritzker.com/2011/12/16/learn-to-speak-vim-verbs-nouns-and-modifiers/
[gv]: http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118
[ig]: http://takac.github.io/2013/01/30/vim-grammar/
[wa]: https://medium.com/p/433852f4b4d1

# Installation

_pencil_ is best installed using a Vim package manager, such as
[Vundle][vnd], [Plug][plg], [NeoBundle][nbn], or [Pathogen][pth].

_For those new to Vim: before installing this plugin, consider getting
comfortable with the basics of Vim by working through one of the many
tutorials available._

[vnd]: https://github.com/gmarik/Vundle.vim
[plg]: https://github.com/junegunn/vim-plug
[nbn]: https://github.com/Shougo/neobundle.vim
[pth]: https://github.com/tpope/vim-pathogen

#### Vundle

Add to your `.vimrc` and save:

```vim
Plugin 'reedes/vim-pencil'
```

…then run the following in Vim:

```vim
:source %
:PluginInstall
```

#### Plug

Add to your `.vimrc` and save:

```vim
Plug 'reedes/vim-pencil'
```

…then run the following in Vim:

```vim
:source %
:PlugInstall
```

#### NeoBundle

Add to your `.vimrc` and save:

```vim
NeoBundle 'reedes/vim-pencil'
```

…then run the following in Vim:

```vim
:source %
:NeoBundleInstall
```

#### Pathogen

Run the following in a terminal:

```bash
cd ~/.vim/bundle
git clone https://github.com/reedes/vim-pencil
```

# Configuration

## Basic initialization

Initializing _pencil_ by `FileType` is _optional_, though doing so will
automatically set up your buffers for editing prose.

Add support for your desired filetypes to your `.vimrc`:

```vim
set nocompatible
filetype plugin on       " may already be in your .vimrc

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
augroup END
```

You can initialize several prose-oriented plugins together:

```vim
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
                            \ | call lexical#init()
                            \ | call litecorrect#init()
                            \ | call textobj#quote#init()
                            \ | call textobj#sentence#init()
augroup END
```

For a list of other prose-oriented plugins, consult the [See
also](#see-also) section below.

## Hard line breaks or soft line wrap?

Coders will have the most experience with the former, and writers the
latter. But whatever your background, chances are that you must contend
with both conventions. This plugin doesn't force you to choose a side—you
can configure each buffer independently.

In most cases you can set a default to suit your preference and let
auto-detection figure out what to do.

```vim
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init({'wrap': 'hard'})
augroup END
```

In the example above, for files of type `markdown` this plugin will
auto-detect the line wrap approach, with soft line wrap as the default.

For files of type `text`, it will initialize with hard line breaks, even
if auto-detect might suggest soft line wrap.

## Commands

You can enable, disable, and toggle _pencil_ as a command:

* `Pencil` - initialize _pencil_ with auto-detect for the current buffer
* `NoPencil` (or `PencilOff`) - removes navigation mappings and restores buffer to global settings
* `TogglePencil` (or `PencilToggle`) - if on, turns off; if off, initializes with auto-detect

Because auto-detect might not work as intended, you can invoke a command
to set the behavior for the current buffer:

* `SoftPencil` (or `PencilSoft`) - initialize _pencil_ with soft line wrap mode
* `HardPencil` (or `PencilHard`) - initialize _pencil_ with hard line break mode (and Vim’s autoformat)

## Automatic formatting

_The ‘autoformat’ feature affects *HardPencil* (hard line break) mode
only._

When inserting text while in *HardPencil* mode, Vim’s autoformat feature
will be enabled by default and can offer many of the same benefits as
soft line wrap.

One useful exception (aka 'blacklisting'): if used with popular
prose-oriented syntax plugins, _pencil_ will **not** enable autoformat when
you enter Insert mode from inside a code block or table. (See the
advanced section below for more details on the blacklisting feature.)

Where you need to manually enable/disable autoformat for the current
buffer, you can do so with a command:

* `PFormat` - allows autoformat to be enabled (if not blacklisted)
* `PFormatOff` - prevents autoformat from enabling (blacklist all)
* `PFormatToggle` - toggle to allow if off, etc.

To set the default behavior, add to your `.vimrc`:

```vim
let g:pencil#autoformat = 1      " 0=manual, 1=auto (def)
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

Optionally, you can map a key in your `.vimrc` to toggle Vim's autoformat:

```vim
noremap <buffer> <silent> <F7> :<C-u>PFormatToggle<cr>
inoremap <buffer> <silent> <F7> <C-o>:PFormatToggle<cr>
```

## Manual formatting

Note that you need not rely on Vim’s autoformat exclusively and can
manually reformat paragraphs with standard Vim commands:

* `gqip` or `gwip` - format current paragraph
* `vipJ` - unformat (i.e., join all lines with hard line breaks) in current paragraph
* `ggVGgq` or `:g/^/norm gqq` - format all paragraphs in buffer
* `:%norm vipJ` - unformat all paragraphs in buffer

Optionally, you can map these operations to underutilized keys in your
`.vimrc`:

```vim
nnoremap <silent> Q gwip
```

## Default textwidth

You can configure the textwidth to be used in **HardPencil** mode when no
textwidth is set globally, locally, or available via modeline. It
defaults to `74`, but you can change that value in your `.vimrc`:

```vim
let g:pencil#textwidth = 74
```

## Sentence spacing

By default, when formatting text (through `gwip`, e.g.) only one space
will be inserted after a period(`.`), exclamation point(`!`), or question
mark(`?`). You can change this default:

```vim
let g:pencil#joinspaces = 0     " 0=one_space (def), 1=two_spaces
```

## Cursor wrap

By default, `h`/`l` and the left/right cursor keys will move to the
previous/next line after reaching first/last character in a line with
a hard break. If you wish to retain the default Vim behavior, set the
`cursorwrap` value to `0` in your `.vimrc`:

```vim
let g:pencil#cursorwrap = 1     " 0=disable, 1=enable (def)
```

## Concealing \_\_markup\_\_

_pencil_ enables Vim's powerful Conceal feature, although support among
Syntax and Colorscheme plugins is currently spotty.

You can change _pencil’s_ default settings for conceal in your `.vimrc`:

```vim
let g:pencil#conceallevel = 3     " 0=disable, 1=onechar, 2=hidechar, 3=hideall (def)
let g:pencil#concealcursor = 'c'  " n=normal, v=visual, i=insert, c=command (def)
```

For more details on Vim’s Conceal feature, see:

```vim
:help conceallevel
:help concealcursor
```

### Concealing styled text in Markdown

Syntax plugins such as [tpope/vim-markdown][tm] support concealing the
markup characters when displaying \_*italic*\_, \*\*__bold__\*\*, and
\*\*\*___bold italic___\*\*\* styled text.

To use Vim’s Conceal feature with Markdown, you will need to install:

1. [tpope/vim-markdown][tm] as it’s currently the only Markdown syntax
   plugin that supports conceal.

2. a monospaced font (such as [Cousine][co]) featuring the _italic_,
   **bold**, and ***bold italic*** style variant for styled text.

3. a colorscheme (such as [reedes/vim-colors-pencil][cp]) which supports
   the Markdown-specific highlight groups for styled text.

You should then only see the `_` and `*` markup for the cursor line and in
visual selections.

**Terminal users:** consult your terminal’s documentation to configure your
terminal to support **bold** and _italic_ styles.

[co]: http://www.google.com/fonts/specimen/Cousine
[tm]: http://github.com/tpope/vim-markdown

## Status line indicator

Your status line can reflect the wrap mode for _pencil_ buffers. For
example, `␍` to represent `HardPencil` (hard line break) mode.  To
configure your status line and ruler, add to your `.vimrc`:

```vim
set statusline=%<%f\ %h%m%r%w\ \ %{PencilMode()}\ %=\ col\ %c%V\ \ line\ %l\,%L\ %P
set rulerformat=%-12.(%l,%c%V%)%{PencilMode()}\ %P
```

or if using [bling/vim-airline][va]:

```vim
let g:airline_section_x = '%{PencilMode()}'
```

The default indicators now include ‘auto’ for when Vim’s autoformat is
activated in hard line break mode.

```vim
let g:pencil#mode_indicators = {'hard': 'H', 'auto': 'A', 'soft': 'S', 'off': '',}
```

If Unicode is detected, the default indicators are:

```vim
let g:pencil#mode_indicators = {'hard': '␍', 'auto': 'ª', 'soft': '⤸', 'off': '',}
```

If you don’t like the default indicators, you can specify your own in
your `.vimrc`.

Note that `PencilMode()` will return blank for buffers in which _pencil_
has not been initialized.

[va]: http://github.com/bling/vim-airline

## Advanced pencil

### Advanced initialization

Configurable options for `pencil#init()` include: `autoformat`,
`concealcursor`, `conceallevel`, `cursorwrap`, `joinspaces`, `textwidth`,
and `wrap`. These are detailed above.

You can override _pencil_ and other configuration settings when initializing:

```vim
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
                            \ | call litecorrect#init()
                            \ | setl spell spl=en_us fdl=4 noru nonu nornu
                            \ | setl fdo+=search
  autocmd Filetype git,gitsendemail,*commit*,*COMMIT*
                            \   call pencil#init({'wrap': 'hard', 'textwidth': 72})
                            \ | call litecorrect#init()
                            \ | setl spell spl=en_us et sw=2 ts=2 noai
  autocmd Filetype mail         call pencil#init({'wrap': 'hard', 'textwidth': 60})
                            \ | call litecorrect#init()
                            \ | setl spell spl=en_us et sw=2 ts=2 noai nonu nornu
  autocmd Filetype html,xml     call pencil#init({'wrap': 'soft'})
                            \ | call litecorrect#init()
                            \ | setl spell spl=en_us et sw=2 ts=2
augroup END
```

Alternatives include `after/ftplugin` modules as well as refactoring initialization
statements into a function.

### Autoformat blacklisting (and whitelisting)

_The ‘autoformat’ feature affects *HardPencil* (hard line break) mode
only._

When editing formatted text, such as a table or code block, Vim’s
autoformat will wreak havoc with the formatting. In these cases you will
want to temporarily deactivate autoformat, such as with the `PFormatOff`
or `PFormatToggle` commands described above. However, in most cases, you
won’t need to do this.

_pencil_ will detect the syntax highlight group at the cursor position to
determine whether or not autoformat should be activated.

If you haven’t explicitly disabled autoformat, it will be activated at
the time you enter Insert mode provided that the syntax highlighting
group at the cursor position is _not_ in the blacklist.

Blacklists are now declared by file type. The default blacklists (and
whitelists) are declared in the `plugin/pencil.vim` module. Here’s an
excerpt showing the configuration for the ‘markdown’ file type:

```vim
  let g:pencil#autoformat_config = {
        \   'markdown': {
        \     'black': [
        \       'htmlH[0-9]',
        \       'markdown(Code|H[0-9]|Url|IdDeclaration|Link|Rule|Highlight[A-Za-z0-9]+)',
        \       'markdown(FencedCodeBlock|InlineCode)',
        \       'mkd(Code|Rule|Delimiter|Link|ListItem|IndentCode)',
        \       'mmdTable[A-Za-z0-9]*',
        \     ],
        \     'white': [
        \      'markdown(Code|Link)',
        \     ],
        \   },
        [snip]
        \ }
```

For example, if editing a file of type ‘markdown’ and you enter Insert
mode from inside a `markdownFencedCodeBlock` highlight group, then Vim’s
autoformat will _not_ be activated.

The whitelist will override the blacklist and allow Vim’s autoformat to
be activated if text that would normally be blacklisted doesn’t dominate
the entire line. This allows autoformat to work with `inline` code and
links.

### Auto-detecting wrap mode

If you didn't explicitly specify a wrap mode during initialization,
_pencil_ will attempt to detect it.

It will first look for a `textwidth` (or `tw`) specified in a modeline.
Failing that, _pencil_ will then sample lines from the start of the file.

#### Detect via modeline

Will the wrap mode be detected accurately? Maybe. But you can improve its
chances by giving _pencil_ an explicit hint.

At the bottom of this document is a odd-looking code:

```html
<!-- vim: set tw=73 :-->
```

This is an **optional** ‘modeline’ that tells Vim to run the following
command upon loading the file into a buffer:

```vim
:set textwidth=73
```

It tells _pencil_ to assume hard line breaks, regardless of whether or
not soft line wrap is the default editing mode for files of type ‘markdown’.

You explicitly specify soft wrap mode by specifying a textwidth of `0`:

```html
<!-- vim: set tw=0 :-->
```

Note that if the modelines feature is disabled (such as for security
reasons) the textwidth will still be set by this plugin.

#### Detect via sampling

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

If no such lines found, _pencil_ falls back to the default wrap mode.

# See also

* [To Vim][tv] - Writer and psychologist Ian Hocking on using Vim for writing
* [Vim Training Class - Basic motions and commands][tc] - video tutorial by Shawn Biddle
* [Vim for Writers][vw] - guide to the basics geared to writers

Bloggers and developers discuss _pencil_ and its brethern:

* [Reed Esau's growing list of Vim plugins for writers][regl] (2014) - by @pengwynn
* [Distraction Free Writing in Vim][dfwiv] (2014) - by @tlattimore
* [Safari Blog: Turning vim into an IDE through vim plugins][tviai] (2014) - by @jameydeorio
* [Quick tops for writing prose with Vim][qtfwp] (2014) - by @benoliver999
* [UseVim: Reed Esau's Writing Plugins][rewp] (2015) - by @alexyoung
* [Tomasino Labs: Vim in Context][vic] (2015) - by @jamestomasino
* [Writing with Vim][wwv] (2015) - by Pat Ambrosio 

Other plugins of specific interest to writers:

* [tpope/vim-abolish][ab] - search for, substitute, and abbr. multiple variants of a word
* [tommcdo/vim-exchange][ex] - easy text exchange operator for Vim
* [junegunn/limelight.vim][jl] - focus mode that brightens current paragraph
* [junegunn/goyo.vim][jg] - distraction-free editing mode

[qtfwp]: http://benoliver999.com/technology/2014/12/06/vimforprose/
[wwv]: https://lilii.co/aardvark/writing-with-vim
[vic]: https://labs.tomasino.org/vim-in-context.html
[rewp]: http://usevim.com/2015/05/27/reedes/
[tviai]: https://www.safaribooksonline.com/blog/2014/11/23/way-vim-ide/
[regl]: http://wynnnetherland.com/journal/reed-esau-s-growing-list-of-vim-plugins-for-writers/
[dfwiv]: http://tlattimore.com/blog/distraction-free-writing-in-vim/
[ab]: http://github.com/tpope/vim-abolish
[ex]: http://github.com/tommcdo/vim-exchange
[jl]: http://github.com/junegunn/limelight.vim
[jg]: http://github.com/junegunn/goyo.vim

Markdown syntax plugins

* [tpope/vim-markdown][tvm] - the latest version of the syntax plugin that ships with Vim
* [plasticboy/vim-markdown][pvm]
* [gabrielelana/vim-markdown][gvm]
* [mattly/vim-markdown-enhancements][mvme] - highlighting for tables and footnotes

[tvm]: http://github.com/tpope/vim-markdown
[pvm]: http://github.com/plasticboy/vim-markdown
[gvm]: http://github.com/gabrielelana/vim-markdown
[mvme]: http://github.com/mattly/vim-markdown-enhancements

If you find the _pencil_ plugin useful, check out these others by [@reedes][re]:

* [vim-colors-pencil][cp] - color scheme for Vim inspired by IA Writer
* [vim-lexical][lx] - building on Vim’s spell-check and thesaurus/dictionary completion
* [vim-litecorrect][lc] - lightweight auto-correction for Vim
* [vim-one][vo] - make use of Vim’s _+clientserver_ capabilities
* [vim-textobj-quote][qu] - extends Vim to support typographic (‘curly’) quotes
* [vim-textobj-sentence][ts] - improving on Vim's native sentence motion command
* [vim-thematic][th] - modify Vim’s appearance to suit your task and environment
* [vim-wheel][wh] - screen-anchored cursor movement for Vim
* [vim-wordy][wo] - uncovering usage problems in writing

Unimpressed by _pencil_? [vim-pandoc][vp] offers prose-oriented features
with its own Markdown variant.

[cp]: http://github.com/reedes/vim-colors-pencil
[lc]: http://github.com/reedes/vim-litecorrect
[lx]: http://github.com/reedes/vim-lexical
[qu]: http://github.com/reedes/vim-textobj-quote
[re]: http://github.com/reedes
[tc]: https://www.youtube.com/watch?v=Nim4_f5QUxA
[th]: http://github.com/reedes/vim-thematic
[ts]: http://github.com/reedes/vim-textobj-sentence
[tv]: http://ianhocking.com/2013/11/17/to-vim/
[vo]: http://github.com/reedes/vim-one
[vw]: http://therandymon.com/woodnotes/vim-for-writers/vimforwriters.html
[wh]: http://github.com/reedes/vim-wheel
[wo]: http://github.com/reedes/vim-wordy
[vp]: http://github.com/vim-pandoc/vim-pandoc

# Future development

If you’ve spotted a problem or have an idea on improving _pencil_,
please report it as an issue, or better yet submit a pull request.

```
<!-- vim: set tw=73 :-->
```
