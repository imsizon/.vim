" imsizon's .vimrc file
"
" Maintainer: imsizon <xich@imsizon.com>
" URL:        http://github.com/imsizon/vimfiles

source ~/.vim/vundle.vim

" Multi-encoding setting
function! s:MultiEncodingSetting()
  if has('multi_byte')
    set fileencodings=ucs-bom,utf-8,chinese

    if &fileencoding == ''
      let can_set_fenc = 1
    else
      let can_set_fenc = 0
    endif

    set encoding=utf-8
    if v:lang =~ 'utf8$' || v:lang =~ 'UTF-8$'
      if has('unix')
        " Only use UTF-8 termencoding when we're in Linux/Unix, cause Windows
        " does not support UTF-8. Mac? I don't know :p
        set termencoding=utf-8
      end
      if can_set_fenc
        set fileencoding=utf-8
      endif
      set ambiwidth=double
    endif
  else
    echoerr 'Sorry, this version of (g)Vim was not compiled with "multi_byte"'
  endif
endfunction


" Toggle indent style smartly
function! s:ToggleIndentStyle(...)
  if a:0
    if a:1 == 8
      execute 'setlocal noexpandtab softtabstop=' . a:1 . ' shiftwidth=' . a:1
      if a:0 > 1
        echo 'Indent style changed to noexpandtab'
      endif
    else
      execute 'setlocal expandtab softtabstop=' . a:1 . ' shiftwidth=' . a:1
      if a:0 > 1
        echo 'Indent style changed to expandtab with ' . a:1 . ' spaces'
      endif
    endif
  else

    if &expandtab
      let b:previous_indent_width = &shiftwidth
      call s:ToggleIndentStyle(8, 1)
    else
      if !exists('b:previous_indent_width')
        let b:previous_indent_width = 4
      endif
      call s:ToggleIndentStyle(b:previous_indent_width, 1)
    endif
  endif
endfunction


" ----------------------------------------------------------------------------
" Initialization
" Commands only execute in Vim initialization
"
function! s:VimInit()
  set nocompatible
  call s:MultiEncodingSetting()
  source $VIMRUNTIME/mswin.vim
  behave xterm
  " Restore CTRL-A to increase number instead of Select All
  unmap <C-A>
  " Restore CTRL-V to Column Visual Mode instead of Paste
  unmap <C-V>
  " Restore CTRL-S to nop (will be used by vim-surround) instead of Save
  iunmap <C-S>
endfunction

" When Vim is booting, the winpos information is not available
if getwinposx() == -1
  call s:VimInit()
endif


" ----------------------------------------------------------------------------
" Primary settings
"

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has('gui_running')
  syntax on
  set hlsearch
  " let g:solarized_termcolors=256
  " set background=dark
  color solarized
endif

" Only do this part when compiled with support for autocommands.
if has('autocmd')

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    autocmd!

    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78

    autocmd FileType c compiler gcc
    autocmd FileType d compiler dmd
    autocmd FileType delphi compiler borland
    autocmd FileType ruby,eruby
          \ setlocal omnifunc=rubycomplete#Complete |
          \ setlocal tags+=~/.gem/tags |
          \ call s:ToggleIsKeyword(':,?,!', 1) |

    let s:indent2_regex = '^\%(cucumber\|e\=ruby\|[yh]aml\|delphi\|x\=html\|javascript\|coffee\|nsis\|sass\|vim\|scala\)$'
    let s:indent8_regex = '^\%(css\|gitconfig\)$'

    function! s:BufEnter()
      " Set indent style for diffent file type
      if &ft =~ s:indent2_regex
        call s:ToggleIndentStyle(2)
      elseif &ft =~ s:indent8_regex
        call s:ToggleIndentStyle(8)
      else
        call s:ToggleIndentStyle(4)
      endif

      " Change to directory of current file automatically when current file is not
      " on remote server nor inside an archive file like .zip/.tgz
      if bufname('%') !~ '::\|://'
        lcd %:p:h
      endif
    endfunction

    autocmd BufEnter * call s:BufEnter()

    " Apply file template if it exists
    autocmd BufNewFile *
          \ if &modifiable |
          \   set ff=unix |
          \   let s:Template = expand('~/.vim/template/template.' . substitute(bufname('%'), '.\{-\}\.*\([^.]*\)$', '\1', '')) |
          \   if filereadable(s:Template) |
          \     execute '0read ' . s:Template |
          \     normal Gdd |
          \   endif |
          \ endif |

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
          \ if line("'\"") > 0 && line("'\"") <= line('$') |
          \   execute 'normal g`"' |
          \ endif |

  augroup END
endif


" ----------------------------------------------------------------------------
" My customizations
"
" Set options
set autoindent
set background=dark
set backspace=indent,eol,start
set completeopt=menuone,longest,preview
set directory=~/.tmp,.,/var/tmp,/tmp
set fileformats=unix,dos
set guicursor=a:blinkon0
set grepprg=grep\ -nH\ $*
set helplang=CN
set history=50
set ignorecase smartcase smartcase
set incsearch
set laststatus=2
set linebreak
set list
set listchars=tab:>-,trail:-,nbsp:%
set modeline
set number
set ruler
" set showbreak=>>
set shellslash
set showcmd
set smartindent
if v:version > 702
  set undodir=~/.tmp/undodir,.
  set undofile
else
  " for system crontab -e (still using vim72)
  color desert
endif
set viminfo=!,'1000,<100,c,f1,h,s10,rA:,rB:,n~/.viminfo
set virtualedit=block
set visualbell
set wildmenu

set diffopt=filler,iwhite
set diffexpr=MyDiff()
function! MyDiff()
  let opt = ' -a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let diffprg = $VIMRUNTIME . '/diff'
  if !executable(diffprg)
    let diffprg = 'diff'
  endif
  silent execute '!' . diffprg . opt . arg1 . ' ' . arg2 . ' > ' . arg3
endfunction

" Force read viminfo
try
  rviminfo ~/.viminfo
catch
endtry

" Customizing status line
function! CustomStatusLineBufSize()
  let BufSize = line2byte(line('$') + 1) - 1
  if BufSize < 0
    let BufSize = 0
  endif
  " Add commas
  let Remain = BufSize
  let BufSize = ''
  while strlen(Remain) > 3
    let BufSize = ',' . strpart(Remain, strlen(Remain) - 3) . BufSize
    let Remain = strpart(Remain, 0, strlen(Remain) - 3)
  endwhile
  let BufSize = Remain . BufSize
  let BufSize = BufSize . ' byte'
  return BufSize
endfunction

if has('gui_running')
  execute 'set statusline=%<%1*%f\ %{fugitive#statusline()}%h%m%r%2*\|' .
        \ '%3*%{&ff}%2*:%3*%{&fenc}%2*:%3*%{&ft}%2*\|' .
        \ '%{CustomStatusLineBufSize()}' .
        \ '%=%b\ 0x%B\ \ \|' .
        \ '%1*sts%2*:%3*%{&sts}%2*:%1*sw%2*:%3*%{&sw}%2*:' .
        \ '%1*ts%2*:%3*%{&ts}%2*:%1*tw%2*:%3*%{&tw}%2*\|' .
        \ '%06(%l%),%03(%v%)\ %1*%4.4P'
else
  execute 'set statusline=%<%1*%f\ %{fugitive#statusline()}%h%m%r%2*\|' .
        \ '%3*%{&ff}%2*:%3*%{&fenc}%2*:%3*%{&ft}%2*\|' .
        \ '%{CustomStatusLineBufSize()}' .
        \ '%=%b\ 0x%B\ \ ' .
        \ '%06(%l%),%03(%v%)\ %1*%4.4P'
endif


" ----------------------------------------------------------------------------
" Key mappings
"
" Up & Down is display line upward & downward
map <Up> gk
map <Down> gj
imap <Up> <Esc><Up>a
imap <Down> <Esc><Down>a

" F1 is toggle indent style smartly
map <F1> :call <SID>ToggleIndentStyle()<CR>
imap <F1> :call <Esc><F1>a

" Shift-F1 is Toggle iskeyword contain or not contain '_'
map <S-F1> :call <SID>ToggleIsKeyword('_')<CR>
imap <S-F1> <Esc><S-F1>a

function! s:ToggleIsKeyword(...)
  " Second param means 'force add', not 'toggle'
  if a:0 > 1 || stridx(&iskeyword, a:1) < 0
    exec 'setlocal iskeyword+=' . a:1
  else
    exec 'setlocal iskeyword-=' . a:1
  endif
endfunction

" F2 is Toggle wrap
" Code moved to .gvimrc

" F3 is Reverse hlsearch
map <F3> :set hlsearch!<CR>
imap <F3> <Esc><F3>a

" F4 is Toggle Tag List
" Rails Tag List will config this
"
map <F4> :TlistToggle<CR>
imap <F4> <Esc><F4>a

" F5 is Toggle Mini Buffer Explorer
map <F5> :BufExplorer<CR>
imap <F5> <Esc><F5>

" F6 is Open NERDTree
map <F6> :NERDTreeToggle<CR>
imap <F6> <Esc><F6>a

" F7 is Toggle spell check
map <F7> :set spell!<CR>
imap <F7> <Esc><F7>a

" F8 is Change GUI font
" Code moved to .gvimrc

" CTRL-[JKHL] is jump between windows
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-H> <C-W>h
noremap <C-L> <C-W>l

" CTRL-Tab is Next tab
map <C-Tab> gt
imap <C-Tab> <Esc>gt
cmap <C-Tab> <Esc>gt
nmap tn :tabnext<CR>

" CTRL-SHIFT-Tab is Previous tab
map <C-S-Tab> gT
imap <C-S-Tab> <Esc>gT
cmap <C-S-Tab> <Esc>gT
nmap tp :tabprevious<CR>

" ALT-[1-9] is switch to specified tab
for i in [1, 2, 3, 4, 5, 6, 7, 8, 9]
  execute 'map <M-' . i . '> ' . i . 'gt'
  execute 'imap <M-' . i . '> <Esc>' . i . 'gt'
  execute 'cmap <M-' . i . '> <Esc>' . i . 'gt'
endfor

" ,* is Substitute(Replace)
nmap ,* :%s/<C-R><C-W>/

" ,bi is :BundleInstall
nmap ,bi :BundleInstall<CR>

" ,bs is :BundleSearch
nmap ,bs :BundleSearch<Space>

" NERD commenter mappings
nmap ,cc        <Plug>NERDCommenterComment
vmap ,cc        <Plug>NERDCommenterComment
nmap ,c<Space>  <Plug>NERDCommenterToggle
vmap ,c<Space>  <Plug>NERDCommenterToggle
nmap ,cm        <Plug>NERDCommenterMinimal
vmap ,cm        <Plug>NERDCommenterMinimal
nmap ,cs        <Plug>NERDCommenterSexy
vmap ,cs        <Plug>NERDCommenterSexy
nmap ,cn        <Plug>NERDCommenterNest
vmap ,cn        <Plug>NERDCommenterNest
nmap ,cu        <Plug>NERDCommenterUncomment
vmap ,cu        <Plug>NERDCommenterUncomment

" ,ff is format code
nmap ,ff :set ff=unix<CR>:%!fromdos<CR>gg=G:%s/\s\+$//ge<CR>

" ,fc is clean code
nmap ,fc :set ff=unix<CR>:%!fromdos<CR>:%s/\s\+$//ge<CR>

" Make it easy to update/reload .vimrc
nmap ,s :source $HOME/.vimrc<CR>
nmap ,v :e $HOME/.vimrc<CR>

" ,> ,< is next or prev error
nmap ,> :cnext<CR>
nmap ,< :cNext<CR>

" \date \time Insert current date & time
nmap <Leader>date :call <SID>InsertDate(0)<CR>
nmap <Leader>time :call <SID>InsertDate(1)<CR>

function! s:InsertDate(Also_Time)
  let Fmt = '%x'
  if a:Also_Time
    let Fmt .= ' %X'
  endif
  let Time = strftime(Fmt)
  execute 'normal a' . Time
endfunction

" \tu \tg Convert to UTF-8, Convert to GBK
nmap <Leader>tu   :set fenc=utf8<CR>:w<CR>
nmap <Leader>tg   :set fenc=gbk<CR>:w<CR>

" \sym String to Symbol for Ruby
nmap <Leader>sym :%s/[\\]\@<!\(['"]\)\(\w\+\)\1/:\2/gce<CR>
vmap <Leader>sym :s/[\\]\@<!\(['"]\)\(\w\+\)\1/:\2/gce<CR>

" Don't use Ex mode, use Q for formatting
nmap Q gq

" Emacs-style editing on the command-line
" start of line
cnoremap <C-A>         <Home>
" back one character
cnoremap <C-B>         <Left>
" delete character under cursor
cnoremap <C-D>         <Del>
" end of line
cnoremap <C-E>         <End>
" forward one character
cnoremap <C-F>         <Right>
" recall newer command-line
cnoremap <C-N>         <Down>
" recall previous (older) command-line
cnoremap <C-P>         <Up>
" back one word
cnoremap <Esc><C-B>    <S-Left>
" forward one word
cnoremap <Esc><C-F>    <S-Right>


" ----------------------------------------------------------------------------
" Configurations for plugins
"
" NERD commenter
let g:NERDDefaultNesting = 1
let g:NERDShutUp = 1
let g:NERDSpaceDelims = 1

" surround
"
" Work with gettext easier
let g:surround_45 = "_('\r')"
let g:surround_95 = "_(\"\r\")"


" speeddating
let g:speeddating_no_mappings = 1
nmap  <C-A>     <Plug>SpeedDatingUp
nmap  <C-X>     <Plug>SpeedDatingDown
nmap d<C-A>     <Plug>SpeedDatingNowUTC
nmap d<C-X>     <Plug>SpeedDatingNowLocal

" ctags
" set tags=~/.tags/

" Optional, handy TagList settings
nnoremap <silent> <F4> :Tlist<CR>
inoremap <F4> <Esc><F4>a

let Tlist_Compact_Format = 1
let Tlist_Ctags_Cmd = 'ctags --fields=+lS'
let Tlist_File_Fold_Auto_Close = 1

let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1

let Tlist_WinWidth = 40

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache in non-python files, use Pydiction in python files.
let pydict = $HOME.'/.vim/bundle/Pydiction/complete-dict'
if (has('win32') || has('win64'))
  let pydict = substitute(pydict, '/', '\\', 'g')
endif
au BufRead,BufNewFile,BufEnter * if &ft != "python" | let g:neocomplcache_enable_at_startup = 1 |
      \ let g:pydiction_location = '' |
      \ else | let g:pydiction_location = pydict |
      \ endif
autocmd FileType python let g:pydiction_location = pydict
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
" 禁用自动完成
let g:NeoComplCache_disable_auto_complete = 1
" 启用自动代码提示
map <Leader>en :NeoComplCacheEnable<CR>
" 禁用自动代码提示
map <Leader>dis :NeoComplCacheDisable<CR>

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<TAB>"

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
      \ 'default' : '',
      \ 'python' : ''
      \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'

" haskell
au BufEnter *.hs compiler ghc
" Configure browser for haskell_doc.vim
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"

" vim IM cloud input
let g:vimim_cloud="sogou"
" let g:vimim_cloud=-1

" vim: set sts=2 sw=2:
