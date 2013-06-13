"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"                                 _                                             "
"                          _   __(_)___ ___  __________                         "
"                         | | / / / __ `__ \/ ___/ ___/                         "
"                         | |/ / / / / / / / /  / /__                           "
"                         |___/_/_/ /_/ /_/_/   \___/                           "
"                                                                               "
"                                                                               "
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50 " keep 50 lines of command line history
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch  " do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

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

  autocmd FileType text setlocal textwidth=200

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
  set autoindent    " always set autoindenting on
endif " has("autocmd")
"}}}

set nobackup
" 初回のみ読み込まれるデフォルト定義 {{{
if has('vim_starting')
  set tabstop=4
  set softtabstop=4
  set shiftwidth=4
  set noautoindent
  set nowrapscan
  set number
  set ruler
  set laststatus=2
  set cmdheight=2
  set showcmd
  set title
  " バックスペースでインデントや改行を削除できるようにする
  set backspace=2
endif
"}}}

nnoremap <Esc><Esc> :nohlsearch<CR>

"set tags {{{
if has("autochdir")
  set autochdir
  set tags=tags;
else
  set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
endif
nnoremap <C-]> g]
"}}}

let mapleader=","

" 検索などで飛んだらそこを真ん中に {{{
for maptype in ['n', 'N', '*', '#', 'g*', 'g#', 'G']
  execute 'nmap' maptype maptype . 'zz'
endfor
"}}}

" escape automatically / ? {{{
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'
"}}}

" fileencoding "{{{
for [enc, cmds, key] in [
  \ ['utf-8'      , ['Utf8']            , 'u'],
  \ ['euc-jp'     , ['Eucjp']           , 'e'],
  \ ['cp932'      , ['Cp932', 'Sjis']   , 's'],
  \ ['iso-2022-jp', ['Iso2022jp', 'Jis'], 'j'],
  \]
  for cmd in cmds
    execute 'command! -bang -bar -complete=file -nargs=?' cmd 'edit<bang> ++enc=' . enc '<args>'
  endfor
  execute 'nmap <Leader>' . key          ':' . cmds[0] . '<CR>'
  execute 'nmap <Leader>' . toupper(key) ':set fileencoding=' . enc . '<CR>'
endfor
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
  unlet s:enc_euc
  unlet s:enc_jis
endif
"}}}
" 日本語を含まない場合は fileencoding に encoding を使うようにする
"{{{
function! AU_ReCheck_FENC()
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding=&encoding
  endif
endfunction
autocmd BufReadPost * call AU_ReCheck_FENC()
set fileencodings -=latin1
set fileencodings +=cp932
"}}}
" 改行コードの自動認識 {{{
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif
"}}}

" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase

" コマンドライン補完 {{{
set wildmenu
set wildmode=list:longest
"}}}

"検索後のスクロールから下の行がわかる
set scrolloff=5

" window movement
"{{{
for key in ['h', 'j', 'k', 'l']
  execute 'nnoremap <silent> <C-' . key . '> :wincmd' key . '<CR>'
endfor
"}}}

" change window size
"{{{
nnoremap <silent> <Up>    :2 wincmd -<CR>
nnoremap <silent> <Down>  :2 wincmd +<CR>
nnoremap <silent> <Left>  :5 wincmd <<CR>
nnoremap <silent> <Right> :5 wincmd ><CR>
"}}}

"折れ曲がった行にも移動 {{{
"set wrap のときに便利
for key in ['j', 'k']
  execute 'nmap' key 'g' . key
  execute 'vmap' key 'g' . key
endfor
"set showbreak=…
"}}}

" toggle command {{{
for [cmd_name, opt_name, key] in [
  \ ['ToggleNumber'      , 'number'      , 'N'],
  \ ['ToggleList'        , 'list'        , 'L'],
  \ ['ToggleWrap'        , 'wrap'        , 'W'],
  \ ['ToggleCursorLine'  , 'cursorline'  , 'cl'],
  \ ['ToggleCursorColumn', 'cursorcolumn', 'cc'],
  \]
  execute 'command!' cmd_name 'setlocal' opt_name . '!'
  execute 'nmap <Space>'. key ':' . cmd_name . '<CR>'
endfor

" cf http://vimcasts.org/episodes/soft-wrapping-text/
command! Wrap set wrap linebreak nolist
"}}}

" for set list {{{
" Use the same symbols as TextMate for tabstops and EOLs
try
  "set listchars=tab:▸\ ,eol:¬
  "set listchars=tab:»\ ,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
  set listchars=tab:￫\ ,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
  set list
catch
endtry
highlight NonText ctermfg=DarkBlue
highlight SpecialKey ctermfg=DarkBlue
"}}}

nnoremap <Leader>v :split $MYVIMRC<CR>
nnoremap <Leader>gv :split $MYGVIMRC<CR>

nnoremap <Leader>ev :e $MYVIMRC<CR>
nnoremap <Leader>egv :e $MYGVIMRC<CR>

if has("gui_running")
  nnoremap <Leader>so :source $MYVIMRC \| source $MYGVIMRC<CR>
else
  nnoremap <Leader>so :source $MYVIMRC<CR>
endif
"}}}

" FileType Indent "{{{
augroup auto_filetype_indent
autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs     setlocal sw=4 sts=4 ts=4 noet
autocmd FileType c          setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp        setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs         setlocal sw=4 sts=4 ts=4 et
autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
autocmd FileType diff       setlocal sw=4 sts=4 ts=4 noet
autocmd FileType eruby      setlocal sw=2 sts=2 ts=2 et
autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
autocmd FileType jsp        setlocal sw=2 sts=2 ts=2 et
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
autocmd FileType python     setlocal sw=4 sts=4 ts=4 et
autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
autocmd FileType cucumber   setlocal sw=2 sts=2 ts=2 et
autocmd FileType haml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType sh         setlocal sw=4 sts=4 ts=4 et
autocmd FileType sql        setlocal sw=4 sts=4 ts=4 et
autocmd FileType vb         setlocal sw=4 sts=4 ts=4 noet
autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
autocmd FileType wsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType xhtml      setlocal sw=2 sts=2 ts=2 et
autocmd FileType xml        setlocal sw=2 sts=2 ts=2 et
autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType scala      setlocal sw=2 sts=2 ts=2 et
augroup END
"}}}

" for grep {{{
"{{{ 外部grep
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
              \ -a -not -regex '.*\\.min\\.js$'
              \ -a -not -regex '.*\\.min\\.css$'
              \ -a -not -regex '.*schema.rb$'
              \ -print0 \\| xargs -0 grep -nH"
"}}}

" カーソル直下の単語(Word)
nmap <C-g><C-w> :grep "<C-R><C-W>" \| bot cw<CR>
" カーソル直下の単語(WORD)(C-aはscreenとバッティングするためC-eに)
nmap <C-g><C-e> :grep "<C-R><C-A>" \| bot cw<CR>
" 最後に検索した単語
nmap <C-g><C-h> :grep "<C-R>/" \| bot cw<CR>
nmap <C-g><C-j> :vim /<C-R>// ## \| bot cw<CR>

nmap <silent> <C-n> :<C-u>cnext<CR>
nmap <silent> <C-p> :<C-u>cprevious<CR>

"}}}

" コマンドを実行 {{{
"nnoremap <Leader>ex :execute '!' &ft ' %'<CR>
nnoremap <silent> <Leader>ex :execute 'set makeprg=' . expand(&ft) . '\ ' . expand('%')<CR>:make \| cw \| if len(getqflist()) != 0 \| bot copen \| endif<CR>
"}}}

" Ctrl+Nでコマンドライン履歴を一つ進む(前方一致)
cnoremap <C-P> <UP>
" Ctrl+Pでコマンドライン履歴を一つ戻る(前方一致)
cnoremap <C-N> <DOWN>

" 全選択
nnoremap <Leader>a ggVG

" color {{{
set background=light

" cf http://vimwiki.net/
colorscheme desert

" 色番号  :help ctermbg(NR-8)
highlight Pmenu     ctermbg=4
highlight PmenuSel  ctermbg=5
highlight PmenuSbar ctermbg=0

highlight clear Folded
highlight clear FoldColumn
"}}}

" 全角スペースの表示 {{{
highlight ZenkakuSpace cterm=underline ctermfg=White
try
  match ZenkakuSpace /　/
catch
endtry
"}}}

" カーソル行 {{{
"{{{
if has("gui_running")
  " カーソル行をハイライト
  set cursorline

  " カレントウィンドウにのみ罫線を引く
  augroup cch
    autocmd! cch
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
  augroup END
end
"}}}

highlight clear CursorLine
highlight CursorLine cterm=underline gui=underline
"}}}

" コマンド実行中は再描画しない
"set lazyredraw
" 高速ターミナル接続を行う
set ttyfast

" Visually select the text that was last edited/pasted
nmap gV `[v`]

" F1 for help {{{
" <F1>でヘルプ
nnoremap <F1>  :<C-u>help<Space>
" カーソル下のキーワードをヘルプでひく
nnoremap <F1><F1> :<C-u>help<Space><C-r><C-w><Enter>
"}}}

" map for buffer {{{
nnoremap <Leader>bp :bprevious<CR>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bd :bdelete<CR>
nmap <silent> <C-b><C-n> :<C-u>bnext<CR>
nmap <silent> <C-b><C-p> :<C-u>bprevious<CR>
"}}}

" map for syntastic, etc {{{
nmap <silent> <C-g><C-n> :<C-u>lnext<CR>
nmap <silent> <C-g><C-p> :<C-u>lprevious<CR>
"}}}

" native2ascii {{{
function! s:jproperties_filetype_settings()
  augroup jprop
    autocmd! jprop
    command! -range Native2Ascii :<line1>,<line2>!native2ascii -encoding utf8 -reverse
    nnoremap <Leader>na :%Native2Ascii<CR>
    vnoremap <Leader>na :Native2Ascii<CR>
  augroup END
endfunction
autocmd FileType jproperties call s:jproperties_filetype_settings()
"}}}

" Ctrl + jでescape
inoremap <C-j> <ESC>

"カーソル上の言葉をclipboardへヤンク "{{{
function! s:yank_to_clipboard()
  if &clipboard =~# 'unnamed'
    normal! yiw
  else
    set clipboard +=unnamed
    normal! yiw
    set clipboard -=unnamed
  endif
endfunction
nmap tt :call <SID>yank_to_clipboard()<CR>
"}}}

" 単語境界に-を追加 {{{
setlocal iskeyword +=-
function! s:toggle_is_key_word_hyphen() "{{{
  if &iskeyword =~# ',-'
    set iskeyword -=-
  else
    set iskeyword +=-
  endif
  echo &iskeyword
endfunction "}}}
command! ToggleIsKeyWordHyPhen  call s:toggle_is_key_word_hyphen()
nnoremap <Space>K :call <SID>toggle_is_key_word_hyphen()<CR>
"}}}

" clipboardにunnamedを追加 {{{
function! s:toggle_clipboard_unnamed() "{{{
  if &clipboard =~# 'unnamed'
    set clipboard -=unnamed
    echo 'clipboard mode OFF'
  else
    set clipboard +=unnamed
    echo 'clipboard mode ON'
  endif
endfunction "}}}
command! ToggleClipboardUnnamed call s:toggle_clipboard_unnamed()
nnoremap <Space>P :call <SID>toggle_clipboard_unnamed()<CR>
"}}}

" 折り畳み列幅 "{{{
function! s:toggle_fold_column()
  if &foldcolumn
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=4
  endif
endfunction
command! ToggleFoldColumn  call s:toggle_fold_column()
nnoremap <Space>G :call <SID>toggle_fold_column()<CR>
"}}}

" 末尾空白削除 " {{{
"autocmd FileType cpp,python,perl,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e
function! s:trim_last_white_space() range
  execute a:firstline . ',' . a:lastline . 's/\s\+$//e'
endfunction
command! -range=% Trim :<line1>,<line2>call <SID>trim_last_white_space()
nnoremap <Leader>tr :%Trim<CR>
vnoremap <Leader>tr :Trim<CR>
nnoremap <Space>Y :ToggleBadWhitespace<CR>
"}}}

" タブ移動 {{{
noremap gh gT
noremap gl gt
"}}}

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
function! s:quick_fix_toggle()
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    cwindow
  endif
endfunction
nnoremap <silent> <Space>: :call <SID>quick_fix_toggle()<CR>
"}}}

" ChangeCurrentDir {{{
command! -nargs=? -complete=dir -bang CD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd ' . a:directory
  endif

  if a:bang == ''
    pwd
  endif
endfunction

" Change current directory.
nnoremap <silent> <Space>cd :<C-u>CD<CR>
"}}}

" for perl {{{
function! s:check_perl_critic()
  setlocal makeprg=perlcritic\ -verbose\ 1\ -5\ %
  make
  cwindow
endfunction

function! s:perl_writing_mode_settings()
  augroup perlwritingmode
    autocmd! perlwritingmode
    autocmd BufWritePost <buffer>  call s:check_perl_critic()
  augroup END
endfunction

function! s:perl_filetype_settings()
  compiler perlcritic
  command! PerlCritic           call s:check_perl_critic()
  nnoremap <silent> <Leader>pc :call <SID>check_perl_critic()<CR>

  command! SetPerlWritingMode  call s:perl_writing_mode_settings()
  nnoremap <Space>P :call <SID>perl_writing_mode_settings()<CR>

  " perltidy
  nnoremap <Leader>pt :%!perltidy<CR>
  vnoremap <Leader>pt :!perltidy<CR>
endfunction

augroup perl_filetype
  autocmd! FileType perl call s:perl_filetype_settings()
  autocmd! BufNewFile,BufRead *.tmpl setf tt2html
augroup END
"}}}

" skelton {{{
augroup SkeletonAu
  autocmd!
  for ext in ['pl', 'pm', 'rb', 't', 'html', 'css', 'js', 'vim', 'c']
    execute 'autocmd BufNewFile *.' . ext . ' 0r ~/.vim/skel/skel.' . ext
  endfor
augroup END
"}}}

" 括弧までを消したり置き換えたりする "{{{
" http://vim-users.jp/2011/04/hack214/
onoremap ) t)
onoremap ( t(
vnoremap ) t)
vnoremap ( t(
"}}}

" Map semicolon to colon {{{
nnoremap ; :
"}}}

" 矩形選択で行末を超えてブロックを選択できるようにする "{{{
set virtualedit+=block
"}}}

" argdoの時の警告を無視 "{{{
" http://vimcasts.org/episodes/using-argdo-to-change-multiple-files/
set hidden
"}}}

"================================================================================
" for plugin settings
"================================================================================
" neobundle
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/neobundle/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" original repos on github
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"{{{
NeoBundle 'https://github.com/vim-jp/vimdoc-ja'
NeoBundle 'https://github.com/Shougo/neocomplcache'
NeoBundle 'https://github.com/Shougo/neosnippet'
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
NeoBundle 'https://github.com/plasticboy/vim-markdown'
NeoBundle 'https://github.com/rgo/taglist.vim'
NeoBundle 'https://github.com/scrooloose/nerdtree'
NeoBundle 'https://github.com/scrooloose/syntastic'
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
NeoBundle 'https://github.com/tpope/vim-repeat'
NeoBundle 'https://github.com/tsaleh/vim-matchit'
NeoBundle 'https://github.com/vim-ruby/vim-ruby'
NeoBundle 'https://github.com/taku-o/vim-toggle'
NeoBundle 'https://github.com/h1mesuke/unite-outline'
NeoBundle 'https://github.com/h1mesuke/vim-alignta'
NeoBundle 'https://github.com/ujihisa/unite-locate'
NeoBundle 'https://github.com/ujihisa/unite-gem'
NeoBundle 'https://github.com/ujihisa/shadow.vim'
NeoBundle 'https://github.com/ujihisa/unite-rake'
NeoBundle 'https://github.com/ujihisa/unite-colorscheme'
NeoBundle 'https://github.com/tacroe/unite-mark'
NeoBundle 'https://github.com/sgur/unite-qf'
NeoBundle 'https://github.com/choplin/unite-vim_hacks'
NeoBundle 'https://github.com/koron/chalice'
NeoBundle 'https://github.com/tyru/open-browser.vim'
NeoBundle 'https://github.com/hail2u/vim-css3-syntax'
NeoBundle 'https://github.com/cakebaker/scss-syntax.vim'
NeoBundle 'https://github.com/othree/html5.vim'
NeoBundle 'https://github.com/kana/vim-textobj-user'
NeoBundle 'https://github.com/kana/vim-textobj-indent'
NeoBundle 'https://github.com/tsukkee/unite-tag'
NeoBundle 'https://github.com/sjl/gundo.vim'
NeoBundle 'https://github.com/bitc/vim-bad-whitespace'
NeoBundle 'https://github.com/petdance/vim-perl'
NeoBundle 'https://github.com/pasela/unite-webcolorname'
NeoBundle 'https://github.com/taichouchou2/alpaca_powertabline'
"NeoBundle 'https://github.com/Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}
NeoBundle 'https://github.com/Lokaltog/powerline'
NeoBundle 'https://github.com/Lokaltog/vim-powerline'
NeoBundle 'https://github.com/t9md/vim-surround_custom_mapping'
NeoBundle 'https://github.com/einars/js-beautify'
NeoBundle 'https://github.com/maksimr/vim-jsbeautify'
NeoBundle 'https://github.com/chaquotay/ftl-vim-syntax'
NeoBundle 'https://github.com/nelstrom/vim-qargs'
NeoBundle 'https://github.com/nelstrom/vim-visual-star-search'
NeoBundle 'https://github.com/groenewege/vim-less'
"}}}

"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" vim-scripts repos
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"{{{
NeoBundle 'https://github.com/vim-scripts/JavaDecompiler.vim'
NeoBundle 'https://github.com/vim-scripts/SQLUtilities'
NeoBundle 'https://github.com/vim-scripts/svn-diff.vim'
NeoBundle 'https://github.com/vim-scripts/wombat256.vim'
NeoBundle 'https://github.com/vim-scripts/yanktmp.vim'
NeoBundle 'https://github.com/vim-scripts/sudo.vim'
NeoBundle 'https://github.com/vim-scripts/perlcritic-compiler-script'
NeoBundle 'https://github.com/vim-scripts/Align'
"}}}

"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" non github repos
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"{{{
NeoBundle 'http://repo.or.cz/r/vcscommand.git'
"}}}

filetype plugin indent on     " required!

"----------------------------------------
" NERDTree.vim "{{{
"nnoremap <silent> <F7> :NERDTreeToggle<CR>
" always on but not focused
" autocmd VimEnter * NERDTree
" autocmd VimEnter * wincmd p
" autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()

" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
"function! s:CloseIfOnlyNerdTreeLeft()
"  if exists("t:NERDTreeBufName")
"    if bufwinnr(t:NERDTreeBufName) != -1
"      if winnr("$") == 1
"        q
"      endif
"    endif
"  endif
"endfunction
"}}}

"----------------------------------------
" taglist.vim "{{{
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 40
"}}}

"----------------------------------------
" neocomplcache.vim {{{
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

inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
"inoremap <expr><CR>  neocomplcache#close_popup() . "\<CR>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

" AutoComplPop like behavior.
let g:neocomplcache_enable_auto_select = 1
" 一部除きたい...
"autocmd! FileType gitcommit NeoComplCacheDisable

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
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
"let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

if !exists('g:neocomplcache_delimiter_patterns')
  let g:neocomplcache_delimiter_patterns= {}
endif
let g:neocomplcache_delimiter_patterns.vim = ['#']
let g:neocomplcache_delimiter_patterns.cpp = ['::']

command! ToggleNeoComplCache  NeoComplCacheToggle
nmap <Space>H :ToggleNeoComplCache<CR>
"}}}

"----------------------------------------
" neosnippet.vim "{{{
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

let g:neosnippet#snippets_directory=$HOME.'/.vim/snippets'
noremap es :<C-u>NeoSnippetEdit<CR>
"}}}

"----------------------------------------
" yanktmp.vim "{{{
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>
"}}}

"----------------------------------------
"rails.vim + nerdtree.vim "{{{
nnoremap <Leader>p :Rtree<CR>
"}}}

"----------------------------------------
" syntastic {{{
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['java', 'perl', 'xml'] }

let g:syntastic_auto_loc_list=1
let g:syntastic_auto_jump=0
let g:syntastic_javascript_checker = 'gjslint'
"let g:syntastic_javascript_checker = 'jshint'
"let g:syntastic_javascript_checker = 'jslint'
"let g:syntastic_javascript_jslint_conf = "--white --undef --nomen --regexp --plusplus --bitwise --newcap --sloppy --vars"
"let g:syntastic_javascript_jslint_conf = "--white=false --indent=2 --undef=false --nomen=false --regexp --plusplus=false --bitwise=false --newcap=false --vars=false --es5=false"
"let g:syntastic_javascript_jslint_conf = "--white=true --indent=2 --undef=false --nomen=false --regexp --plusplus=false --bitwise=false --newcap=false --vars=true --es5=false"
" }}}

"----------------------------------------
" vim-quickrun "{{{
let g:quicklaunch_no_default_key_mappings = 1

let g:quickrun_config = {}
"let g:quickrun_config['ruby'] = {'command' : 'reek', 'exec' : ['%c %s']}
let g:quickrun_config['coffee'] = {'command' : 'coffee', 'exec' : ['%c -cbp %s']}
let g:quickrun_config['css'] = {'command' : 'recess', 'exec' : ['%c --stripColors=true --noIDs=false --noOverqualifying=false --noUniversalSelectors=false %s']}
"let g:quickrun_config['css'] = {'command' : 'recess', 'exec' : ['%c --stripColors=true %s']}
let g:quickrun_config['javascript'] = {'command' : 'jsl', 'exec' : ['%c -process %s']}
"let g:quickrun_config['javascript'] = {'command' : 'jshint', 'exec' : ['%c %s']}
"let g:quickrun_config['javascript'] = {'command' : 'jslint', 'exec' : ['%c '. g:syntastic_javascript_jslint_conf .' %s']}

" 出力先別にショートカットキーを設定する
for [key, out] in items({
  \   '<Leader>w' : '>buffer',
  \   '<Leader>q' : '>>buffer',
  \ })
  execute 'nnoremap <silent>' key ':QuickRun' out '-mode n<CR>'
  execute 'vnoremap <silent>' key ':QuickRun' out '-mode v<CR>'
endfor
"nnoremap <silent> <Leader>j :QuickRun >quickfix -mode n<CR>:bot copen<CR>
"}}}

"----------------------------------------
" rubytest.vim "{{{
let g:rubytest_cmd_spec = "spec %p"
let g:rubytest_cmd_example = "spec %p -l %c"
let g:rubytest_in_quickfix = 1
"}}}

"----------------------------------------
" vim-coffee-script.vim "{{{
autocmd BufWritePost *.coffee silent CoffeeMake! -cb | cwindow
"}}}

"----------------------------------------
" unite.vim "{{{
let g:unite_source_grep_default_opts = '--color=never -Hn'

" unite-outline
call unite#set_buffer_name_option('outline', 'ignorecase', 1)
call unite#set_buffer_name_option('outline', 'smartcase',  1)

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " 単語単位からパス単位で削除するように変更
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
endfunction

nnoremap [unite] :<C-u>Unite<Space>
nmap f [unite]

nnoremap <C-f> :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
inoremap <C-f> <ESC>:<C-u>UniteWithBufferDir -buffer-name=files file<CR>

nnoremap [unite]a   :<C-u>UniteWithBufferDir -buffer-name=files mark buffer file_mru bookmark file<CR>
nnoremap [unite]c   :<C-u>Unite change<CR>
nnoremap [unite]f   :<C-u>UniteWithBufferDir -buffer-name=files file -start-insert<CR>
nnoremap [unite]g   :<C-u>Unite grep:%::<C-R>=expand('<cword>')<CR><CR>
nnoremap [unite]h   :<C-u>Unite history/command -vertical -direction=topleft<CR>
nnoremap [unite]j   :<C-u>Unite mark buffer file_mru -start-insert<CR>
nnoremap [unite]l   :<C-u>Unite locate -start-insert<CR>
nnoremap [unite]m   :<C-u>Unite mapping -start-insert -vertical -direction=topleft<CR>
nnoremap [unite]n   :<C-u>Unite neobundle<CR>
nnoremap [unite]o   :<C-u>Unite -buffer-name=outline -winwidth=40 -no-quit outline -vertical -direction=topleft<CR>
nnoremap [unite]p   :<C-u>Unite snippet -start-insert -vertical -direction=topleft<CR>
nnoremap [unite]r   :<C-u>UniteResume<CR>
nnoremap [unite]s   :<C-u>Unite history/search -vertical -direction=topleft<CR>
nnoremap [unite]v   :<C-u>Unite output:version -start-insert<CR>
nnoremap [unite]y   :<C-u>Unite history/yank<CR>
nnoremap [unite]A   :<C-u>Unite output:autocmd -vertical -direction=topleft<CR>
nnoremap [unite]F   :<C-u>UniteWithCursorWord line -vertical -direction=topleft<CR>
nnoremap [unite]G   :<C-u>Unite grep<CR>
nnoremap [unite]J   :<C-u>Unite jump<CR>
nnoremap [unite]I   :<C-u>Unite neobundle/install:!<CR>
nnoremap [unite]L   :<C-u>Unite launcher<CR>
nnoremap [unite]M   :<C-u>Unite output:messages -vertical -direction=topleft<CR>
nnoremap [unite]N   :<C-u>Unite neobundle -input=Not<CR>
nnoremap [unite]P   :<C-u>Unite process -start-insert<CR>
nnoremap [unite]R   :<C-u>Unite -buffer-name=register register -vertical -direction=topleft<CR>
nnoremap [unite]S   :<C-u>Unite output:scriptnames -vertical -direction=topleft<CR>
"}}}

"----------------------------------------
" vimshell "{{{
let g:vimshell_interactive_update_time = 10
let g:vimshell_prompt = $USERNAME."% "

" alias
autocmd FileType vimshell
\ call vimshell#altercmd#define('g', 'git')
\| call vimshell#altercmd#define('l', 'll')
\| call vimshell#altercmd#define('ll', 'ls -ltr')
\| call vimshell#altercmd#define('la', 'ls -ltra')
"}}}
"----------------------------------------
" migemo割り当て "{{{
if !has("gui_running")
  noremap  g/ :<C-u>Migemo<CR>
endif
"}}}

"----------------------------------------
" open-browser "{{{
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
nmap gl <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
vmap gl <Plug>(openbrowser-smart-search)
"}}}

"----------------------------------------
" vimfiler "{{{
nnoremap <silent> <F7> :VimFiler -buffer-name=explorer -split -simple -winwidth=35 -toggle -no-quit<CR>
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_execute_file_list = {
  \ 'vim' : 'vim',
  \ 'c' : 'open',
  \ 'h' : 'open',
  \ 'rb' : 'open',
  \ 'pl' : 'open',
  \ 'java' : 'open',
  \ 'js' : 'open',
  \ 'css' : 'open',
  \ 'html' : 'open',
  \ 'txt' : 'open',
  \ 'pdf' : 'open',
  \ 'jpg' : 'open',
  \ 'png' : 'open',
  \ 'xlsx' : 'open',
  \ 'xls' : 'open',
  \ 'docx' : 'open',
  \ 'doc' : 'open',
  \ }
"}}}

"----------------------------------------
" Gundo "{{{
nnoremap <F5> :GundoToggle<CR>
"}}}

"----------------------------------------
" shadow "{{{
let g:shadow_debug = 1
"}}}

"----------------------------------------
"EnhancedCommentify {{{
let g:EnhCommentifyBindInInsert = 'no'
"}}}

"----------------------------------------
" vim-powerline {{{
let g:Powerline_symbols = 'unicode'
" }}}

"----------------------------------------
" vim-surround {{{
"let g:surround_106 = "$('\r')"  " 106 = j
"let g:surround_74 = "$j('\r')"  " 74 = J
" }}}

"----------------------------------------
" vim-surround_custom_mapping {{{
let g:surround_custom_mapping = {}
let g:surround_custom_mapping._ = {
            \ 'p':  "<pre> \r </pre>",
            \ }
let g:surround_custom_mapping.help = {
            \ 'p':  "> \r <",
            \ }
let g:surround_custom_mapping.ruby = {
            \ '-':  "<% \r %>",
            \ '=':  "<%= \r %>",
            \ '9':  "(\r)",
            \ '5':  "%(\r)",
            \ '%':  "%(\r)",
            \ 'w':  "%w(\r)",
            \ '#':  "#{\r}",
            \ '3':  "#{\r}",
            \ 'e':  "begin \r end",
            \ 'E':  "<<EOS \r EOS",
            \ 'i':  "if \1if\1 \r end",
            \ 'u':  "unless \1unless\1 \r end",
            \ 'c':  "class \1class\1 \r end",
            \ 'm':  "module \1module\1 \r end",
            \ 'd':  "def \1def\1\2args\r..*\r(&)\2 \r end",
            \ 'p':  "\1method\1 do \2args\r..*\r|&| \2\r end",
            \ 'P':  "\1method\1 {\2args\r..*\r|&|\2 \r }",
            \ }
let g:surround_custom_mapping.perl = {
            \ 'i':  "if (\1if\1) {\r }",
            \ 'u':  "unless (\1unless\1) {\r }",
            \ 's':  "sub \1sub\1 { \r }",
            \ 'S':  "sub \1sub\1 { \r }",
            \ }
let g:surround_custom_mapping.javascript = {
            \ 'f':  "function () { \r }",
            \ 'j':  "$('\r')",
            \ 'J':  "$j('\r')",
            \ }
let g:surround_custom_mapping.vim = {
            \'f':  "function! \r endfunction",
            \'z':  "\"{{{ \r \"}}}",
            \ }
" }}}

"----------------------------------------
" vim-jsbeautify {{{
"let s:rootDir = fnamemodify(expand("<sfile>"), ":h")."/.vim/"
"let g:jsbeautify_file = fnameescape(s:rootDir."/bundle/js-beautify/beautify.js")
"let g:htmlbeautify_file = fnameescape(s:rootDir."/bundle/js-beautify/beautify-html.js")
"let g:cssbeautify_file = fnameescape(s:rootDir."/bundle/js-beautify/beautify-css.js")
"
""let g:jsbeautify = {'indent_size': 2, 'indent_char': ' ', 'jslint_happy': 'true', 'keep_array_indentation': 'true' }
"let g:jsbeautify = {'indent_size': 2, 'indent_char': ' ', 'keep_array_indentation': 'true' }
"let g:htmlbeautify = {'indent_size': 2, 'indent_char': ' ', 'max_char': 78, 'brace_style': 'expand', 'unformatted': ['a', 'sub', 'sup', 'b', 'i', 'u']}
"let g:cssbeautify = {'indent_size': 2, 'indent_char': ' '}

autocmd FileType javascript noremap <buffer> <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
autocmd FileType css vnoremap <buffer> <c-f> :call <SID>css_beautify()<cr>
function! s:css_beautify() range
  call CSSBeautify(a:firstline, a:lastline)
endfunction
" }}}

" vim: foldmethod=marker
