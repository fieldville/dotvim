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

set tabstop=4
set softtabstop=4
set shiftwidth=4

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
nnoremap <C-]> g]

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
nmap <Leader>U :set fileencoding=utf-8<CR>
nmap <Leader>E :set fileencoding=euc-jp<CR>
nmap <Leader>S :set fileencoding=cp932<CR>

nmap <Leader>u :e ++enc=utf-8 %<CR>
nmap <Leader>e :e ++enc=euc-jp %<CR>
nmap <Leader>s :e ++enc=cp932 %<CR>


" 文字コードの自動認識
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
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
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
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" ウィンドウサイズの変更
nmap <Up>    2<C-w>-
nmap <Down>  2<C-w>+
nmap <Left>  5<C-w><
nmap <Right> 5<C-w>>

"set wrap のときに便利
"折れ曲がった行にも移動
nmap j gj
nmap k gk
vmap j gj
vmap k gk
"set showbreak=…

" Shortcut to rapidly toggle `set list`
nmap <leader>ls :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
set list
highlight NonText ctermfg=DarkBlue
highlight SpecialKey ctermfg=DarkBlue

"set wrap linebreak nolist
" cf http://vimcasts.org/episodes/soft-wrapping-text/
command! -nargs=* Wrap set wrap linebreak nolist


" Source the vimrc file after saving it
"if has("autocmd")
"  autocmd bufwritepost .vimrc source $MYVIMRC
"endif
nnoremap <Leader>v :split $MYVIMRC<CR>
nnoremap <Leader>so :source $MYVIMRC<CR>



" Indent
autocmd FileType apache setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs setlocal sw=4 sts=4 ts=4 noet
autocmd FileType c setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs setlocal sw=4 sts=4 ts=4 et
autocmd FileType css setlocal sw=4 sts=4 ts=4 noet
autocmd FileType diff setlocal sw=4 sts=4 ts=4 noet
autocmd FileType eruby setlocal sw=4 sts=4 ts=4 noet
autocmd FileType html setlocal sw=2 sts=2 ts=2 et
autocmd FileType java setlocal sw=4 sts=4 ts=4 et
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


"----------------------------------------
"カーソル位置の単語検索
" 外部grep
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
nnoremap <silent> <Leader>e :execute 'set makeprg=' . expand(&ft) . '\ ' . expand('%')<CR>:make \| cw \| if len(getqflist()) != 0 \| bot copen \| endif<CR>


" Ctrl+Nでコマンドライン履歴を一つ進む(前方一致)
cnoremap <C-P> <UP>
" Ctrl+Pでコマンドライン履歴を一つ戻る(前方一致)
cnoremap <C-N> <DOWN>


" 全選択
nnoremap <Leader>a ggVG


" color
" 色番号	:help ctermbg(NR-8)
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=5
highlight PmenuSbar ctermbg=0


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
set lazyredraw
" 高速ターミナル接続を行う
set ttyfast


" Visually select the text that was last edited/pasted
nmap gV `[v`]


" <F1>でヘルプ
nnoremap <F1>  :<C-u>help<Space>
" カーソル下のキーワードをヘルプでひく
nnoremap <F1><F1> :<C-u>help<Space><C-r><C-w><Enter>


nnoremap <Space> :bn<CR>
nnoremap <Leader><Space> :bp<CR>



"----------------------------------------
" pathogen.vim
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype on


"----------------------------------------
" NERDTree.vim
nnoremap <silent> <F7> :NERDTreeToggle<CR>
"let g:NERDTreeWinPos = "right"
"let g:NERDTreeWinSize = 40
" always on but not focused
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()

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


"----------------------------------------
" taglist.vim
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 40


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


"----------------------------------------
" FuzzyFinder.vim
let g:fuf_modesDisable = ['mrucmd']
let g:fuf_file_exclude = '\v\~$|\.(o|exe|bak|swp|gif|jpg|png)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
let g:fuf_mrufile_exclude = '\v\~$|\.bak$|\.swp|\.howm$|\.(gif|jpg|png)$'
let g:fuf_mrufile_maxItem = 10000
"let g:fuf_enumeratingLimit = 20
let g:fuf_keyPreview = '<C-]>'
let g:fuf_previewHeight = 0

"nmap bg :FufBuffer<CR>
"nmap bG :FufFile <C-r>=expand('%:~:.')[:-1-len(expand('%:~:.:t'))]<CR><CR>
"nmap gb :FufFile **/<CR>
"nmap br :FufMruFile<CR>
"nmap bq :FufQuickfix<CR>
"nmap bl :FufLine<CR>
"nnoremap <silent> <C-]> :FufTag! <C-r>=expand('<cword>')<CR><CR>
nnoremap <silent> <leader>fb :FufBuffer<CR>
nnoremap <silent> <leader>fF :FufFile <C-r>=expand('%:~:.')[:-1-len(expand('%:~:.:t'))]<CR><CR>
nnoremap <silent> <leader>ff :FufFile **/<CR>
nnoremap <silent> <leader>fr :FufMruFile<CR>
nnoremap <silent> <leader>fq :FufQuickfix<CR>
nnoremap <silent> <leader>fl :FufLine<CR>


"----------------------------------------
" yanktmp.vim
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>


"----------------------------------------
"rails.vim + nerdtree.vim
nnoremap <Leader>p :Rtree<CR>


"----------------------------------------
" vim-quickrun
let g:quicklaunch_no_default_key_mappings = 1


"----------------------------------------
" rubytest.vim
let g:rubytest_cmd_spec = "spec %p"
let g:rubytest_cmd_example = "spec %p -l %c"
let g:rubytest_in_quickfix = 1

"----------------------------------------
" Align.vim
let g:Align_xstrlen=3
