" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" pathogen.vim
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set sw=4
set ts=4
set nobackup
set nu
set nows

" ウィンドウサイズの変更
nmap <Up>    2<C-w>-
nmap <Down>  2<C-w>+
nmap <Left>  5<C-w><
nmap <Right> 5<C-w>>

nmap <Esc><Esc> :nohlsearch<CR><Esc>


"カーソル位置の単語検索
" 外部grep
set grepprg=find\ .\ -type\ f\ -name\ '*.*'\ -a\ -not\ -regex\ '.*\\\.svn.*'\ -a\ -not\ -regex\ '.*\\\.git.*'\ -a\ -not\ -regex\ '.*\.swp$'\ -a\ -not\ -regex\ '^\\\./\\\..*'\ -a\ -not\ -regex\ '^\\\./work.*'\ -a\ -not\ -regex\ '^\\\./cpan.*'\ -a\ -not\ -regex\ '^\\\./etc.*'\ -a\ -not\ -regex\ '.*\\\.bak$\ '\ -a\ -not\ -regex\ '.*\\\.bk$'\ -a\ -not\ -regex\ '.*_$'\ -a\ -not\ -regex\ '.*\\\.gz$'\ -a\ -not\ -regex\ '.*\\\.gif$'\ -a\ -not\ -regex\ '.*\\\.png$'\ -a\ -not\ -regex\ '.*_latest$'\ -a\ -not\ -regex\ '.*gomi.*'\ -a\ -not\ -regex\ '.*/eigyo/.*'\ -a\ -not\ -regex\ '.*/alias/.*'\ -a\ -not\ -regex\ '.*hoge$'\ -a\ -not\ -regex\ '.*/ext/js/.*'\ -a\ -not\ -regex\ '.*log$'\ -a\ -not\ -regex\ '.*schema.rb$'\ -a\ -not\ -regex\ '.*/images/.*'\ -a\ -not\ -regex\ '.*\\\.class$'\ -a\ -not\ -regex\ './tmp/.*'\ -a\ -not\ -regex\ './coverage/.*'\ -print0\\\|\ xargs\ -0\ grep\ -nH

" カーソル直下の単語(Word)
nmap <C-g><C-w> :grep "<C-R><C-W>" \| cw<CR>
" カーソル直下の単語(WORD)(C-aはscreenとバッティングするためC-eに)
nmap <C-g><C-e> :grep "<C-R><C-A>" \| cw<CR>
" 最後に検索した単語
nmap <C-g><C-h> :grep "<C-R>/" \| cw<CR>

nmap <C-n> :cn<CR>
nmap <C-p> :cp<CR>

