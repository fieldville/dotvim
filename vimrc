"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"                                 _                                             "
"                          _   __(_)___ ___  __________                         "
"                         | | / / / __ `__ \/ ___/ ___/                         "
"                         | |/ / / / / / / / /  / /__                           "
"                         |___/_/_/ /_/ /_/_/   \___/                           "
"                                                                               "
"                                                                               "
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"{{{
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=1000 " keep n lines of command line history
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch  " do incremental searching
set nobackup

let mapleader=","
"}}}
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo, {{{
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
"}}}
" Switch syntax highlighting on, when the terminal has colors {{{
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
nnoremap <Esc><Esc> :nohlsearch<CR>
"}}}
" Only do this part when compiled with support for autocommands. {{{
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
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

  augroup END
else
  set autoindent    " always set autoindenting on
endif
"}}}
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
  " 分割幅を均等でなくする。<C-W>=で均等に、<C-W>|で最大化
  set noequalalways
endif
"}}}
"set tags {{{
if has("autochdir")
  set autochdir
  set tags=tags;
else
  set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
endif
"nnoremap <C-]> g]
"}}}
" 検索などで飛んだらそこを真ん中に {{{
for maptype in ['n', 'N', '*', '#', 'g*', 'g#', 'G'] | execute 'nmap' maptype maptype . 'zz' | endfor
"}}}
" escape automatically / ? {{{
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'
"}}}
" Mappings for command-line mode. {{{
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>
cnoremap <C-p> <Up>
cnoremap <Up> <C-p>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ?
      \ '' : getcmdline()[:getcmdpos()-2]<CR>
"}}}
" vimgrep後にcwinを表示 {{{
autocmd QuickFixCmdPost make,grep,grepadd,vimgrep,vimgrepadd cwin
"}}}
" fileencoding {{{
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
" 文字コードの自動認識 {{{
if filereadable(expand("$HOME/.vim/_auto_fileencoding.vim"))
  source $HOME/.vim/_auto_fileencoding.vim
endif
"}}}
" 改行コードの自動認識 {{{
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif
"}}}
" 大文字小文字の両方が含まれている場合は大文字小文字を区別 {{{
set smartcase
"}}}
" コマンドライン補完 {{{
set wildmenu
set wildmode=list:longest
"}}}
" 検索後、画面の端でスクロールするのではなく、数行余裕があるうちにスクロールする {{{
set scrolloff=5
"}}}
" window movement {{{
for key in ['h', 'j', 'k', 'l'] | execute 'nnoremap <silent> <C-' . key . '> :wincmd' key . '<CR>' | endfor
"}}}
" remap for split, vsplit {{{
nnoremap <C-w>- :<C-u>sp<CR>
nnoremap <C-w>\ :<C-u>vs<CR>
"}}}
" change window size {{{
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
" folding shortcut {{{
noremap [space] <nop>
nmap <Space> [space]

noremap [space]j zj   " カーソルより下方の折畳へ移動する
noremap [space]k zk   " カーソルより上方の折畳へ移動する
noremap [space]n ]z   " 現在の開いている折畳の末尾へ移動する
noremap [space]p [z   " 現在の開いている折畳の先頭へ移動する
noremap [space]h zc   " カーソルの下の折畳を一段階閉じる
noremap [space]l zo   " カーソルの下の折畳を一段階開く
noremap [space]a za   " 折畳が閉じていた場合: それを開く
noremap [space]m zM   " 全ての折畳を閉じる
noremap [space]i zMzv " 全ての折畳を閉じる => カーソル行を表示する
noremap [space]r zR   " 全ての折畳を開く
noremap [space]f zf   " 折畳を作成する操作
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
" edit vimrc {{{
nnoremap <Leader>v :tabnew $MYVIMRC<CR>     " vimrcを開く
nnoremap <Leader>gv :tabnew $MYVIMRC<CR>     " gvimrcを開く

if has("gui_running")
  nnoremap <Leader>so :source $MYVIMRC \| source $MYGVIMRC<CR>  " vimrcをリロード
else
  nnoremap <Leader>so :source $MYVIMRC<CR>  " vimrcをリロード
endif
"}}}
" FileType Indent {{{
set et
augroup auto_filetype_indent
autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs     setlocal sw=4 sts=4 ts=4 noet
autocmd FileType c          setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp        setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs         setlocal sw=4 sts=4 ts=4 et
autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
autocmd FileType less       setlocal sw=2 sts=2 ts=2 et
autocmd FileType diff       setlocal sw=4 sts=4 ts=4 noet
autocmd FileType eruby      setlocal sw=2 sts=2 ts=2 et
autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
autocmd FileType jsp        setlocal sw=2 sts=2 ts=2 et
autocmd FileType javascript setlocal sw=4 sts=4 ts=4 et
autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
autocmd FileType python     setlocal sw=4 sts=4 ts=4 et
autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
autocmd FileType cucumber   setlocal sw=2 sts=2 ts=2 et
autocmd FileType haml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType sh         setlocal sw=4 sts=4 ts=4 et
autocmd FileType sql        setlocal sw=2 sts=2 ts=2 et
autocmd FileType vb         setlocal sw=4 sts=4 ts=4 noet
autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
autocmd FileType wsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType xhtml      setlocal sw=2 sts=2 ts=2 et
autocmd FileType xml        setlocal sw=2 sts=2 ts=2 et
autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType scala      setlocal sw=2 sts=2 ts=2 et
autocmd FileType mkd        setlocal sw=4 sts=4 ts=4 noet si nofen
autocmd FileType text       setlocal et si
autocmd FileType aws.json   setlocal sw=2 sts=2 ts=2 et fdm=indent nowrap
autocmd FileType json       setlocal sw=2 sts=2 ts=2 et fdm=indent nowrap
augroup END
"}}}
" for grep {{{
"{{{ 外部grep
let &grepprg="find . -type f -name '*.*'
              \ -a -not -regex '.*/HTML/.*'
              \ -a -not -regex '.*\\.swp$'
              \ -a -not -regex '.*\\.gz$'
              \ -a -not -regex '.*\\.gif$'
              \ -a -not -regex '.*\\.png$'
              \ -a -not -regex '.*\\.jpg$'
              \ -a -not -regex '.*\\.bak$'
              \ -a -not -regex '.*\\.bk$'
              \ -a -not -regex '.*\\.class$'
              \ -a -not -regex '.*\\.db$'
              \ -a -not -regex '.*\\.example.*'
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
nmap <C-g><C-w> :grep "<C-R><C-W>"<CR>
nmap <C-g><C-g> :Gtags -g <C-R><C-W><CR>
nmap <C-g><C-r> :Gtags -r <C-R><C-W><CR>
" カーソル直下の単語(WORD)(C-aはscreenとバッティングするためC-eに)
nmap <C-g><C-e> :grep "<C-R><C-A>"<CR>
" 最後に検索した単語
nmap <C-g><C-h> :grep "<C-R>/"<CR>
nmap <C-g><C-j> :vim /<C-R>// ##<CR>

nmap <silent> <C-n> :<C-u>cnext<CR>
nmap <silent> <C-p> :<C-u>cprevious<CR>

"}}}
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
" map for buffer {{{
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
" 折り畳み列幅 {{{
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
" 末尾空白削除 {{{
"autocmd FileType cpp,python,perl,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e
" cf: vim-bad-whitespace
function! s:trim_last_white_space() range
  execute a:firstline . ',' . a:lastline . 's/\s\+$//e'
endfunction
command! -range=% Trim :<line1>,<line2>call <SID>trim_last_white_space()
nnoremap <Leader>tr :%Trim<CR>
vnoremap <Leader>tr :Trim<CR>
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
" LocationListToggle {{{
function! s:location_list_toggle()
  let _ = winnr('$')
  lclose
  if _ == winnr('$')
    lwindow
  endif
endfunction
nnoremap <silent> <Space>; :call <SID>location_list_toggle()<CR>
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
  for ext in ['pl', 'pm', 'rb', 't', 'html', 'css', 'js', 'vim', 'c', 'mk']
    execute 'autocmd BufNewFile *.' . ext . ' 0r ~/.vim/skel/skel.' . ext
  endfor
augroup END
"}}}
" Map semicolon to colon {{{
nnoremap ; :
"}}}
" *,#をg*,g#に入れ替え {{{
nnoremap * g*
nnoremap g* *
nnoremap # g#
nnoremap g# #
"}}}
" 矩形選択で行末を超えてブロックを選択できるようにする {{{
set virtualedit+=block
"}}}
" argdoの時の警告を無視 {{{
" http://vimcasts.org/episodes/using-argdo-to-change-multiple-files/
set hidden
"}}}
" diffoff! {{{
nmap <Leader>d :diffoff!<CR>
"}}}
" tab function {{{
nnoremap [Tab] <Nop>
nmap t [Tab]

for n in range(1, 9) | execute 'nnoremap <silent> [Tab]'.n  ':<C-u>tabnext'.n.'<CR>' | endfor
map <silent> [Tab]c :tablast <bar> tabnew<CR>
map <silent> [Tab]d :tabclose<CR>
map <silent> [Tab]n :tabnext<CR>
map <silent> [Tab]p :tabprevious<CR>
noremap gh gT   " Tab move to left
noremap gl gt   " Tab move to right
"}}}
" shellpipe {{{
" no buffering, to utf8
if $LANG =~# 'UTF'
  set shellpipe=2>\&1\|nkf\ -uw>%s
endif
"}}}
" temporary workaround for previm {{{
fun! ChangeFileTypeToMarkDown(ft)
  let &ft = a:ft
endfun
au FileType mkd call ChangeFileTypeToMarkDown('markdown')
"}}}
" not to use undofile after 7.4.227 {{{
set noundofile
"}}}
" jq {{{
set noundofile
if executable('jq')
  function! s:jq(...)
    execute '%!jq' (a:0 == 0 ? '.' : a:1)
  endfunction
  command! -bar -nargs=? Jq call s:jq(<f-args>)
endif
"}}}
" helpをtab helpに {{{
cabbrev help tab help
"}}}
" 行頭行末の連続移動 {{{
"set ww+=h,l
"}}}
"======================================== for plugin settings ======================================== {{{
"}}}
" dein.vim {{{
" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
  set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " プラグインリストを収めた TOML ファイル
  let s:toml      = '~/.vim/rc/dein.toml'
  let s:lazy_toml = '~/.vim/rc/dein_lazy.toml'

  " プラグインリストを収めた TOML ファイル
  "let s:toml      = g:rc_dir . '/dein.toml'
  "let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

filetype plugin indent on
"}}}
" taglist.vim {{{
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 40
"}}}
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
" neosnippet.vim {{{
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
" yanktmp.vim {{{
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>
"}}}
" syntastic {{{
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': ['perl'],
                           \ 'passive_filetypes': ['java', 'xml'] }

let g:syntastic_enable_perl_checker=1
let g:syntastic_perl_checkers = ['perl', 'podchecker']
let g:syntastic_auto_loc_list=1
let g:syntastic_auto_jump=0
let g:syntastic_javascript_checkers = ['gjslint']
"let g:syntastic_javascript_checkers = ['jshint']
"let g:syntastic_javascript_checkers = ['jslint']
"let g:syntastic_javascript_jslint_conf = "--white --undef --nomen --regexp --plusplus --bitwise --newcap --sloppy --vars"
"let g:syntastic_javascript_jslint_conf = "--white=false --indent=2 --undef=false --nomen=false --regexp --plusplus=false --bitwise=false --newcap=false --vars=false --es5=false"
"let g:syntastic_javascript_jslint_conf = "--white=true --indent=2 --undef=false --nomen=false --regexp --plusplus=false --bitwise=false --newcap=false --vars=true --es5=false"
"}}}
" vim-quickrun {{{
let g:quicklaunch_no_default_key_mappings = 1

let g:quickrun_config = {}
"let g:quickrun_config.ruby = {'command' : 'reek', 'exec' : ['%c %s']}
let g:quickrun_config.css = {'command' : 'recess', 'exec' : ['%c --stripColors=true --noIDs=false --noOverqualifying=false --noUniversalSelectors=false %s']}
"let g:quickrun_config.css = {'command' : 'recess', 'exec' : ['%c --stripColors=true %s']}
let g:quickrun_config.javascript = {'command' : 'jsl', 'exec' : ['%c -process %s']}
"let g:quickrun_config.javascript = {'command' : 'jshint', 'exec' : ['%c %s']}
"let g:quickrun_config.javascript = {'command' : 'jslint', 'exec' : ['%c '. g:syntastic_javascript_jslint_conf .' %s']}
let g:quickrun_config.json = {'command' : 'jq', 'exec' : "%c '.' %s"}

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
" unite.vim {{{
let g:unite_source_grep_default_opts = '--color=never -Hn'
"call unite#custom_default_action('file', 'tabopen')

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
nnoremap [unite]f   :<C-u>UniteWithBufferDir -buffer-name=files file file/new<CR>
nnoremap [unite]g   :<C-u>Unite grep:%::<C-R>=expand('<cword>')<CR><CR>
nnoremap [unite]h   :<C-u>Unite history/command -vertical -direction=topleft<CR>
nnoremap [unite]j   :<C-u>Unite mark buffer file_mru<CR>
nnoremap [unite]m   :<C-u>Unite mapping -start-insert -vertical -direction=topleft<CR>
nnoremap [unite]r   :<C-u>UniteResume<CR>
nnoremap [unite]s   :<C-u>Unite history/search -vertical -direction=topleft<CR>
nnoremap [unite]v   :<C-u>Unite output:version -start-insert<CR>
nnoremap [unite]A   :<C-u>Unite output:autocmd -vertical -direction=topleft<CR>
nnoremap [unite]F   :<C-u>UniteWithCursorWord line -vertical -direction=topleft<CR>
nnoremap [unite]G   :<C-u>Unite grep<CR>
nnoremap [unite]J   :<C-u>Unite jump<CR>
nnoremap [unite]L   :<C-u>Unite launcher<CR>
nnoremap [unite]M   :<C-u>Unite output:messages -vertical -direction=topleft<CR>
nnoremap [unite]P   :<C-u>Unite process -start-insert<CR>
nnoremap [unite]R   :<C-u>Unite -buffer-name=register register -vertical -direction=topleft<CR>
nnoremap [unite]S   :<C-u>Unite output:scriptnames -vertical -direction=topleft<CR>

" <C-h> で unite-history/command を起動
" 選択するとコマンドラインに選択したコマンドが挿入される
cnoremap <C-t> :<C-u>Unite history/command -start-insert -default-action=edit<CR>
"}}}
" open-browser {{{
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
"}}}
" vimfiler {{{
nnoremap <silent> <F7> :VimFilerExplore -find<CR>
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_edit_action='vsplit'
let g:vimfiler_execute_file_list={}
let g:vimfiler_execute_file_list["_"]="open"
"}}}
" vim-bad-whitespace {{{
nnoremap <Space>Y :ToggleBadWhitespace<CR>
nnoremap <Leader>y :%EraseBadWhitespace<CR>
vnoremap <Leader>y :EraseBadWhitespace<CR>
autocmd FileType mail exe ':HideBadWhitespace'
autocmd FileType markdown exe ':HideBadWhitespace'
let b:bad_whitespace_show = 0
"}}}
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
"}}}
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
"}}}
" over.vim {{{
" over.vimの起動
nnoremap <silent> <Leader>m :OverCommandLine<CR>

" カーソル下の単語をハイライト付きで置換
nnoremap sub :OverCommandLine<CR>%s/<C-r><C-w>//g<Left><Left>

" コピーした文字列をハイライト付きで置換
nnoremap subp y:OverCommandLine<CR>%s!<C-r>=substitute(@0, '!', '\\!', 'g')<CR>!!gI<Left><Left><Left>
"}}}
" uncrustify {{{
" see http://stackoverflow.com/questions/12374200/using-uncrustify-with-vim/15513829#15513829

" 例: Shift-Fでコードのフォーマットを行う．
nnoremap <S-f> :call UncrustifyAuto()<CR>

" 例: 保存時に自動フォーマット
" autocmd BufWritePre <buffer> :call UncrustifyAuto()

" uncrustifyの設定ファイル
let g:uncrustify_cfg_file_path = '~/.dotfiles/.uncrustify.cfg'

" uncrustifyでフォーマットする言語
let g:uncrustify_lang = ""
autocmd FileType c let g:uncrustify_lang = "c"
autocmd FileType cpp let g:uncrustify_lang = "cpp"
autocmd FileType java let g:uncrustify_lang = "java"
autocmd FileType objc let g:uncrustify_lang = "oc"
autocmd FileType cs let g:uncrustify_lang = "cs"

" Restore cursor position, window position, and last search after running a
" command.
function! Preserve(command)
    " Save the last search.
    let search = @/
    " Save the current cursor position.
    let cursor_position = getpos('.')
    " Save the current window position.
    normal! H
    let window_position = getpos('.')
    call setpos('.', cursor_position)
    " Execute the command.
    execute a:command
    " Restore the last search.
    let @/ = search
    " Restore the previous window position.
    call setpos('.', window_position)
    normal! zt
    " Restore the previous cursor position.
    call setpos('.', cursor_position)
endfunction

" Don't forget to add Uncrustify executable to $PATH (on Unix) or
" %PATH% (on Windows) for this command to work.
function! Uncrustify(language)
    call Preserve(':silent %!uncrustify'.' -q '.' -l '.a:language.' -c '.
                \shellescape(fnamemodify(g:uncrustify_cfg_file_path, ':p')))
endfunction

function! UncrustifyAuto()
    if g:uncrustify_lang != ""
        call Uncrustify(g:uncrustify_lang)
    endif
endfunction
"}}}
" calendar.vim {{{
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1
"}}}
" vim-colors-solarized {{{
syntax enable
set background=dark
let g:solarized_termcolors=256
" colorscheme solarized
"}}}
" gtags.vim {{{
" Note) Overriding ctags mapping
map <C-]> :GtagsCursor<CR>

" Manually set according to context
"map <C-h> :Gtags -f %<CR>
"map <C-j> :GtagsCursor<CR>
"}}}
" {{{
" vim: foldmethod=marker:foldcolumn=3:nowrap
"}}}
