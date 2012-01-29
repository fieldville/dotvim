" vim: foldmethod=marker
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
"if has('mouse')
"  set mouse=a
"endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
"{{{
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
"}}}

" Only do this part when compiled with support for autocommands.
"{{{
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
"}}}

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
      \ | wincmd p | diffthis
endif

if has('vim_starting')
  set tabstop=4
  set softtabstop=4
  set shiftwidth=4
endif

set noautoindent
set nobackup

" <Esc>連打で、強調表示を一時的に消す
nnoremap <Esc><Esc> :nohlsearch<CR>

" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set nowrapscan

" 行番号を非表示 (number:表示)
set number
" ルーラーを表示 (noruler:非表示)
set ruler
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2
" コマンドをステータス行に表示
set showcmd
" タイトルを表示
set title
" バックスペースでインデントや改行を削除できるようにする
set backspace=2

"set tags
if has("autochdir")
	set autochdir
	set tags=tags;
else
	set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
endif
"nnoremap <C-]> g]

" leaderを,に変更
let mapleader=","

" 検索などで飛んだらそこを真ん中に
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
nmap G Gzz

" escape automatically / ?
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

" fileencoding
"{{{
nmap <Leader>U :set fileencoding=utf-8<CR>
nmap <Leader>E :set fileencoding=euc-jp<CR>
nmap <Leader>S :set fileencoding=cp932<CR>

" 文字コードを指定して開き直す
nmap <Leader>u :e ++enc=utf-8 %<CR>
nmap <Leader>e :e ++enc=euc-jp %<CR>
nmap <Leader>s :e ++enc=cp932 %<CR>

command! Cp932     edit ++enc=cp932<CR>
command! Utf8      edit ++enc=utf-8<CR>
command! Eucjp     edit ++enc=euc-jp<CR>
command! Iso2022jp edit ++enc=iso2022jp<CR>
command! Jis       Iso2022jp
command! Sjis      Cp932
"}}}

" 文字コードの自動認識
"{{{
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    "let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = s:enc_jis .','. s:enc_euc
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
"}}}
" 日本語を含まない場合は fileencoding に encoding を使うようにする
"{{{
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
"}}}
" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase

" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" コマンドライン補間をシェルっぽく
set wildmode=list:longest

"検索後のスクロールから下の行がわかる
"set scrolloff=30
set scrolloff=5

"set background=dark
set background=light

" cf http://vimwiki.net/
"colorscheme elflord
"colorscheme torte
colorscheme desert

" CTRL-hjklでウィンドウ移動
"{{{
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>
nnoremap <silent> <C-h> :wincmd h<CR>
"}}}

" ウィンドウサイズの変更
"{{{
nnoremap <silent> <Up>    :2 wincmd -<CR>
nnoremap <silent> <Down>  :2 wincmd +<CR>
nnoremap <silent> <Left>  :5 wincmd <<CR>
nnoremap <silent> <Right> :5 wincmd ><CR>
"}}}

"set wrap のときに便利
"折れ曲がった行にも移動
nmap j gj
nmap k gk
vmap j gj
vmap k gk
"set showbreak=…

command! ToggleNumber  setlocal number!
nmap <Space>N :ToggleNumber<CR>
command! ToggleList  setlocal list!
nmap <Space>L :ToggleList<CR>
command! ToggleCursorLine  setlocal cursorline!
nmap <Space>C :ToggleCursorLine<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
set list
highlight NonText ctermfg=DarkBlue
highlight SpecialKey ctermfg=DarkBlue

"set wrap linebreak nolist
" cf http://vimcasts.org/episodes/soft-wrapping-text/
command! Wrap set wrap linebreak nolist

" Source the vimrc file after saving it
if has("autocmd")
  if has("gui_running")
    "autocmd BufWritePost *vimrc source $MYVIMRC | source $MYGVIMRC
    "autocmd BufWritePost *gvimrc source $MYVIMRC | source $MYGVIMRC
  else
    autocmd BufWritePost *vimrc source $MYVIMRC
  endif
endif

nnoremap <Leader>v :split $MYVIMRC<CR>
nnoremap <Leader>gv :split $MYGVIMRC<CR>

nnoremap <Leader>ev :e $MYVIMRC<CR>
nnoremap <Leader>egv :e $MYGVIMRC<CR>

if has("gui_running")
  nnoremap <Leader>so :source $MYVIMRC \| source $MYGVIMRC<CR>
else
  nnoremap <Leader>so :source $MYVIMRC<CR>
endif


" Indent
"{{{
autocmd FileType apache setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs setlocal sw=4 sts=4 ts=4 noet
autocmd FileType c setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs setlocal sw=4 sts=4 ts=4 et
autocmd FileType css setlocal sw=4 sts=4 ts=4 noet
autocmd FileType diff setlocal sw=4 sts=4 ts=4 noet
autocmd FileType eruby setlocal sw=4 sts=4 ts=4 noet
autocmd FileType html setlocal sw=2 sts=2 ts=2 et
autocmd FileType java setlocal sw=4 sts=4 ts=4 noet
autocmd FileType jsp setlocal sw=4 sts=4 ts=4 et
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
autocmd FileType perl setlocal sw=4 sts=4 ts=4 et
autocmd FileType php setlocal sw=4 sts=4 ts=4 et
autocmd FileType python setlocal sw=4 sts=4 ts=4 et
autocmd FileType ruby setlocal sw=2 sts=2 ts=2 et
autocmd FileType cucumber setlocal sw=2 sts=2 ts=2 et
autocmd FileType haml setlocal sw=2 sts=2 ts=2 et
autocmd FileType sh setlocal sw=4 sts=4 ts=4 et
autocmd FileType sql setlocal sw=4 sts=4 ts=4 et
autocmd FileType vb setlocal sw=4 sts=4 ts=4 noet
autocmd FileType vim setlocal sw=2 sts=2 ts=2 et
autocmd FileType wsh setlocal sw=4 sts=4 ts=4 et
autocmd FileType xhtml setlocal sw=2 sts=2 ts=2 et
autocmd FileType xml setlocal sw=4 sts=4 ts=4 noet
autocmd FileType yaml setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh setlocal sw=4 sts=4 ts=4 et
autocmd FileType scala setlocal sw=2 sts=2 ts=2 et
"}}}

"----------------------------------------
"カーソル位置の単語検索
" 外部grep
"{{{
let &grepprg="find . -type f -name '*.*'
              \ -a -not -regex '.*\\.swp$'
              \ -a -not -regex '.*\\.gz$'
              \ -a -not -regex '.*\\.gif$'
              \ -a -not -regex '.*\\.png$'
              \ -a -not -regex '.*\\.jpg$'
              \ -a -not -regex '.*\\.bak$'
              \ -a -not -regex '.*\\.bk$'
              \ -a -not -regex '.*\\.class$'
              \ -a -not -regex '.*\\.db$'
              \ -a -not -regex '.*\\.properties$'
              \ -a -not -regex '.*_$'
              \ -a -not -regex '.*log$'
              \ -a -not -regex '.*gomi.*'
              \ -a -not -regex '.*hoge.*'
              \ -a -not -regex '.*/\\.svn/.*'
              \ -a -not -regex '.*/\\.git/.*'
              \ -a -not -regex '.*/tmp/.*'
              \ -a -not -regex '.*/resources/.*'
              \ -a -not -regex '.*/images/.*'
              \ -a -not -regex '.*/plugins/.*'
              \ -a -not -regex '.*/coverage/.*'
              \ -a -not -regex '.*/alias/.*'
              \ -a -not -regex '.*/ext/.*'
              \ -a -not -regex '.*_compress/.*'
              \ -a -not -regex '^\\./\\..*'
              \ -a -not -regex '^\\./work.*'
              \ -a -not -regex '^\\./cpan.*'
              \ -a -not -regex '^\\./etc.*'
              \ -a -not -regex '.*schema.rb$'
              \ -print0 \\| xargs -0 grep -nH"
"}}}

" カーソル直下の単語(Word)
nmap <C-g><C-w> :grep "<C-R><C-W>" \| bot cw<CR>
" カーソル直下の単語(WORD)(C-aはscreenとバッティングするためC-eに)
nmap <C-g><C-e> :grep "<C-R><C-A>" \| bot cw<CR>
" 最後に検索した単語
nmap <C-g><C-h> :grep "<C-R>/" \| bot cw<CR>

nmap <C-n> :cn<CR>
nmap <C-p> :cp<CR>

" 文字エンコーディング＆改行コード取得
function! GetStatusEx()
    let str = &fileformat
    if has('multi_byte') && &fileencoding != ''
        let str = &fileencoding . ':' . str
    endif
    return '[' . str . ']'
endfunction
set statusline=%y%{GetStatusEx()}%F%m%r\ [%c,%l](%P)%=%{strftime(\"%Y/%m/%d(%a)\ %H:%M\")}


" コマンドを実行
"nnoremap <Leader>e :execute '!' &ft ' %'<CR>
"nnoremap <silent> <Leader>e :execute 'set makeprg=' . expand(&ft) . '\ ' . expand('%')<CR>:make \| cw \| if len(getqflist()) != 0 \| bot copen \| endif<CR>


" Ctrl+Nでコマンドライン履歴を一つ進む(前方一致)
cnoremap <C-P> <UP>
" Ctrl+Pでコマンドライン履歴を一つ戻る(前方一致)
cnoremap <C-N> <DOWN>


" 全選択
nnoremap <Leader>a ggVG

" for clipboard
"set clipboard=unnamed,autoselect

" color
" 色番号	:help ctermbg(NR-8)
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=5
highlight PmenuSbar ctermbg=0

highlight clear Folded
highlight clear FoldColumn


" 全角スペースの表示
highlight ZenkakuSpace cterm=underline ctermfg=White
match ZenkakuSpace /　/

" カーソル行をハイライト
set cursorline


" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END

highlight clear CursorLine
highlight CursorLine cterm=underline gui=underline

" コマンド実行中は再描画しない
"set lazyredraw
" 高速ターミナル接続を行う
set ttyfast


" Visually select the text that was last edited/pasted
nmap gV `[v`]


" <F1>でヘルプ
nnoremap <F1>  :<C-u>help<Space>
" カーソル下のキーワードをヘルプでひく
nnoremap <F1><F1> :<C-u>help<Space><C-r><C-w><Enter>


"nnoremap <Space> :bnext<CR>
"nnoremap <Leader><Space> :bprevious<CR>
nnoremap <Leader>bp :bprevious<CR>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bd :bdelete<CR>
nmap <silent> <C-b><C-n> :<C-u>bnext<CR>
nmap <silent> <C-b><C-p> :<C-u>bprevious<CR>


nmap <Leader>na :%!native2ascii -encoding utf8 -reverse<CR>
vmap <Leader>na :!native2ascii -encoding utf8 -reverse<CR>

" Ctrl + jでescape
inoremap <C-j> <ESC>

"カーソル上の言葉をヤンク
nmap tt yiw

" 単語境界に-を追加
setlocal iskeyword +=-
function! ToggleIsKeyWordHyPhen() "{{{
  if &iskeyword =~# ',-'
    set iskeyword -=-
  else
    set iskeyword +=-
  endif
  echo &iskeyword
endfunction "}}}
command! ToggleIsKeyWordHyPhen  call ToggleIsKeyWordHyPhen()
nnoremap <Space>K :call ToggleIsKeyWordHyPhen()<CR>


" 自動で末尾空白削除
autocmd FileType cpp,python,perl,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e

" タブ移動
noremap gh gT
noremap gl gt

" -----------------------------------------------------------------------
" HTML Key Mappings for Typing Character Codes: {{{
"
" |--------------------------------------------------------------------
" |Keys    |Insert   |For  |Comment
" |--------|---------|-----|-------------------------------------------
" |\&      |&amp;    |&    |ampersand
" |\<      |&lt;     |<    |less-than sign
" |\>      |&gt;     |>    |greater-than sign
" |\.      |&middot; |・   |middle dot (decimal point)
" |\?      |&#8212;  |?    |em-dash
" |\2      |&#8220;  |“   |open curved double quote
" |\"      |&#8221;  |”   |close curved double quote
" |\`      |&#8216;  |‘   |open curved single quote
" |\'      |&#8217;  |’   |close curved single quote (apostrophe)
" |\`      |`        |`    |OS-dependent open single quote
" |\'      |'        |'    |OS-dependent close or vertical single quote
" |\<Space>|&nbsp;   |     |non-breaking space
" |---------------------------------------------------------------------
"
" > http://www.stripey.com/vim/html.html
"
"
autocmd BufEnter * if &filetype == "html" | call MapHTMLKeys() | endif
function! MapHTMLKeys(...)
  if a:0 == 0 || a:1 != 0
    inoremap \\ \
    inoremap \& &amp;
    inoremap \< &lt;
    inoremap \> &gt;
    inoremap \. ・
    inoremap \- &#8212;
    inoremap \<Space> &nbsp;
    inoremap \` &#8216;
    inoremap \' &#8217;
    inoremap \2 &#8220;
    inoremap \" &#8221;
    autocmd! BufLeave * call MapHTMLKeys(0)
  else
    iunmap \\
    iunmap \&
    iunmap \<
    iunmap \>
    iunmap \-
    iunmap \<Space>
    iunmap \`
    iunmap \'
    iunmap \2
    iunmap \"
    autocmd! BufLeave *
  endif " test for mapping/unmapping
endfunction " MapHTMLKeys()
"}}}

" QuickFixToggle {{{
function! QuickFixToggle()
    let _ = winnr('$')
    cclose
    if _ == winnr('$')
        cwindow
    endif
endfunction
nnoremap <Space>: :call QuickFixToggle()<CR>
"}}}

"----------------------------------------
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/neobundle/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

" original repos on github
"{{{
NeoBundle 'https://github.com/Shougo/neocomplcache'
NeoBundle 'https://github.com/Shougo/unite.vim'
NeoBundle 'https://github.com/Shougo/vimshell'
NeoBundle 'https://github.com/Shougo/vimproc'
NeoBundle 'https://github.com/Shougo/vimfiler'
NeoBundle 'https://github.com/corntrace/bufexplorer'
NeoBundle 'https://github.com/hrp/EnhancedCommentify'
NeoBundle 'https://github.com/janx/vim-rubytest'
NeoBundle 'https://github.com/kchmck/vim-coffee-script'
NeoBundle 'https://github.com/mattn/webapi-vim'
NeoBundle 'https://github.com/mattn/zencoding-vim'
NeoBundle 'https://github.com/mileszs/ack.vim'
NeoBundle 'https://github.com/msanders/cocoa.vim'
NeoBundle 'https://github.com/msanders/snipmate.vim'
NeoBundle 'https://github.com/plasticboy/vim-markdown'
NeoBundle 'https://github.com/rgo/taglist.vim'
NeoBundle 'https://github.com/scrooloose/nerdtree'
NeoBundle 'https://github.com/thinca/vim-quickrun'
NeoBundle 'https://github.com/thinca/vim-ref'
NeoBundle 'https://github.com/thinca/vim-qfreplace'
NeoBundle 'https://github.com/thinca/vim-unite-history'
NeoBundle 'https://github.com/thinca/vim-openbuf'
NeoBundle 'https://github.com/tpope/vim-cucumber'
NeoBundle 'https://github.com/tpope/vim-endwise'
NeoBundle 'https://github.com/tpope/vim-fugitive'
NeoBundle 'https://github.com/tpope/vim-haml'
NeoBundle 'https://github.com/tpope/vim-rails'
NeoBundle 'https://github.com/tpope/vim-surround'
NeoBundle 'https://github.com/tpope/vim-unimpaired'
NeoBundle 'https://github.com/tpope/vim-abolish'
NeoBundle 'https://github.com/tsaleh/vim-matchit'
NeoBundle 'https://github.com/vim-ruby/vim-ruby'
NeoBundle 'https://github.com/taku-o/vim-toggle'
NeoBundle 'https://github.com/ecomba/vim-ruby-refactoring'
NeoBundle 'https://github.com/h1mesuke/unite-outline'
NeoBundle 'https://github.com/h1mesuke/vim-alignta'
NeoBundle 'https://github.com/ujihisa/unite-locate'
NeoBundle 'https://github.com/ujihisa/unite-gem'
NeoBundle 'https://github.com/tacroe/unite-mark'
NeoBundle 'https://github.com/sgur/unite-qf'
NeoBundle 'https://github.com/choplin/unite-vim_hacks'
NeoBundle 'https://github.com/koron/chalice'
NeoBundle 'https://github.com/tyru/open-browser.vim'
NeoBundle 'https://github.com/hail2u/vim-css3-syntax'
NeoBundle 'https://github.com/cakebaker/scss-syntax.vim'
NeoBundle 'https://github.com/othree/html5.vim'
NeoBundle 'https://github.com/basyura/jslint.vim'
NeoBundle 'https://github.com/kana/vim-textobj-user'
NeoBundle 'https://github.com/kana/vim-textobj-indent'
NeoBundle 'https://github.com/tsukkee/unite-tag.git'
"}}}

" vim-scripts repos
"{{{
NeoBundle 'https://github.com/vim-scripts/JavaDecompiler.vim'
NeoBundle 'https://github.com/vim-scripts/SQLUtilities'
NeoBundle 'https://github.com/vim-scripts/svn-diff.vim'
NeoBundle 'https://github.com/vim-scripts/wombat256.vim'
NeoBundle 'https://github.com/vim-scripts/yanktmp.vim'
NeoBundle 'https://github.com/vim-scripts/sudo.vim'
"}}}

" non github repos
"{{{
NeoBundle 'http://repo.or.cz/r/vcscommand.git'
"}}}

filetype plugin indent on     " required! 

"----------------------------------------
" NERDTree.vim
"{{{
"nnoremap <silent> <F7> :NERDTreeToggle<CR>
"let g:NERDTreeWinPos = "right"
"let g:NERDTreeWinSize = 40
" always on but not focused
" autocmd VimEnter * NERDTree
" autocmd VimEnter * wincmd p
" autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()

" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
function! s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      if winnr("$") == 1
        q
      endif
    endif
  endif
endfunction
"}}}

"----------------------------------------
" taglist.vim
"{{{
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 40
"}}}

"----------------------------------------
" neocomplcache.vim
"Setting examples:
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" SuperTab like snippets behavior.
"imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

" Recommended key-mappings.
" <CR>: close popup and save indent.
"inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
"" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y>  neocomplcache#close_popup()
"inoremap <expr><C-e>  neocomplcache#cancel_popup()

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<TAB>"
"inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"

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
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

nnoremap <Leader>nce :NeoComplCacheEnable<CR>
nnoremap <Leader>ncd :NeoComplCacheDisable<CR>
nnoremap <Leader>nt :NeoComplCacheToggle<CR>


"----------------------------------------
" yanktmp.vim
"{{{
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>
"}}}

"----------------------------------------
"rails.vim + nerdtree.vim
"{{{
nnoremap <Leader>p :Rtree<CR>
"}}}

"----------------------------------------
" vim-quickrun
"{{{
let g:quicklaunch_no_default_key_mappings = 1

let g:quickrun_config = {}
let g:quickrun_config['coffee'] = {'command' : 'coffee', 'exec' : ['%c -cbp %s']}
"}}}

"----------------------------------------
" rubytest.vim
"{{{
let g:rubytest_cmd_spec = "spec %p"
let g:rubytest_cmd_example = "spec %p -l %c"
let g:rubytest_in_quickfix = 1
"}}}

"----------------------------------------
" vim-coffee-script.vim
"{{{
autocmd BufWritePost *.coffee silent CoffeeMake! -cb | cwindow
"}}}

"----------------------------------------
" unite.vim
"{{{
" 入力モードで開始する
"let g:unite_enable_start_insert=1

"nnoremap [unite] <Nop>
nnoremap [unite] :<C-u>Unite<Space>
"nmap ,u [unite]
nmap f [unite]

" mark一覧
" バッファ一覧
" 最近使用したファイル一覧
nnoremap [unite]b :<C-u>Unite mark buffer file_mru<CR>
"nnoremap <C-b> :<C-u>Unite mark buffer file_mru<CR>
"inoremap <C-b> <ESC>:<C-u>Unite mark buffer file_mru<CR>
" ファイル一覧
nnoremap [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <C-f> :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
inoremap <C-f> <ESC>:<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" 全部乗せ
nnoremap [unite]a :<C-u>UniteWithBufferDir -buffer-name=files mark buffer file_mru bookmark file<CR>
" レジスタ一覧
"nnoremap [unite]r :<C-u>Unite -buffer-name=register register<CR>

nnoremap [unite]r :<C-u>UniteResume<CR>

" unite-grep(unite.vim)
nnoremap <silent> [unite]g :<C-u>Unite grep<CR>
let g:unite_source_grep_default_opts = '--color=never -Hn'

" NeoBundle
nnoremap [unite]nb :<C-u>Unite neobundle<CR>
nnoremap [unite]nbi :<C-u>Unite neobundle/install:!<CR>
nnoremap [unite]nbn :<C-u>Unite neobundle -input=Not<CR>

" unite-outline
nnoremap [unite]o :<C-u>Unite -buffer-name=outline -auto-preview outline<CR>

call unite#set_buffer_name_option('outline', 'ignorecase', 1)
call unite#set_buffer_name_option('outline', 'smartcase',  1)

" unite-mark
nnoremap [unite]m :<C-u>Unite mark<CR>

" unite-history
nnoremap [unite]h :<C-u>Unite history/command<CR>
nnoremap [unite]hc :<C-u>Unite history/command<CR>
nnoremap [unite]hs :<C-u>Unite history/search<CR>
nnoremap [unite]hy :<C-u>Unite history/yank<CR>

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " 単語単位からパス単位で削除するように変更
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
endfunction
"}}}

"----------------------------------------
" vimshell
"{{{
let g:vimshell_interactive_update_time = 10
let g:vimshell_prompt = $USERNAME."% "

" map
nnoremap vs :VimShell<CR>
nnoremap vsc :VimShellCreate<CR>
nnoremap vp :VimShellPop<CR>

" alias
autocmd FileType vimshell
\ call vimshell#altercmd#define('g', 'git')
\| call vimshell#altercmd#define('l', 'll')
\| call vimshell#altercmd#define('ll', 'ls -ltr')
\| call vimshell#altercmd#define('la', 'ls -ltra')
"}}}

"----------------------------------------
" Chalice
"{{{
set fileencodings=usc-bom,usc-21e,usc-2,iso-2022-jp-3,utf-8
set fileencodings+=cp932
"}}}

"----------------------------------------
" migemo割り当て
"{{{
if !has("gui_running")
  noremap  g/ :<C-u>Migemo<CR>
endif
"}}}

"----------------------------------------
" open-browser
"{{{
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
"}}}

"----------------------------------------
" vimfiler
"{{{
nnoremap <silent> <F7> :VimFiler -buffer-name=explorer -split -simple -winwidth=35 -toggle -no-quit<CR>
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_safe_mode_by_default = 0
"}}}

"----------------------------------------
" jslint
"{{{
"http://blog.monoweb.info/article/2011042918.html
function! s:javascript_filetype_settings()
  autocmd BufLeave     <buffer> call jslint#clear()
  autocmd BufWritePost <buffer> call jslint#check()
  autocmd CursorMoved  <buffer> call jslint#message()
endfunction
autocmd FileType javascript call s:javascript_filetype_settings()
"}}}
