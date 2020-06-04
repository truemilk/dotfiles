set nocompatible

set shortmess+=A

if exists('$SUDO_USER')
    set noswapfile
    set nobackup
    set nowritebackup
    set noundofile
    set viminfo=
else
    if isdirectory($HOME . '/.vim/swap') == 0
        :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
    endif
    set directory=./.vim-swap//
    set directory+=~/.vim/swap//
    set directory+=~/tmp//
    set directory+=.
    if isdirectory($HOME . '/.vim/backup') == 0
        :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
    endif
    set backupdir-=.
    set backupdir+=.
    set backupdir-=~/
    set backupdir^=~/.vim/backup/
    set backupdir^=./.vim-backup/
    set backup
    if exists("+undofile")
        if isdirectory($HOME . '/.vim/undo') == 0
            :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
        endif
        set undodir=./.vim-undo//
        set undodir+=~/.vim/undo//
        set undofile
    endif
    if isdirectory($HOME . '/.vim/view') == 0
        :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
    endif
    set viewdir=$HOME/.vim/view//
    if has('nvim')
        set viminfo+=n$HOME/.vim/nviminfo
    else
        set viminfo+=n$HOME/.vim/viminfo
    endif
endif

set encoding=utf8

set updatetime=100

set backspace=indent,eol,start

if has("syntax")
    syntax on
endif

set wildmenu
set showmatch
set incsearch
set hlsearch

set autoindent
filetype plugin indent on

set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

set number
set relativenumber

set autoread
set autowriteall

set laststatus=2
set noshowmode

set scrolloff=10

set mouse=a
set clipboard=unnamed

set splitbelow splitright

set cursorline
augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

augroup AutoSaveAndLoadWithFocus
    au!
    au FocusGained,BufEnter * :silent! !
    au FocusLost,WinLeave * :silent! w
augroup end

augroup remember_folds
    autocmd!
    autocmd BufWinLeave * mkview
    autocmd BufWinEnter * silent! loadview
augroup end

let mapleader = " "

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

nnoremap <silent> <leader>/ <Esc>:nohlsearch<CR><Esc>

if has("gui")
    set guioptions-=m
    set guioptions-=T
    set guioptions-=r
    set guifont=Fira\ Code:h17
endif

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'agude/vim-eldar'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vimwiki/vimwiki'
Plug 'tpope/vim-fugitive'
call plug#end()

silent! colorscheme eldar
highlight LineNr ctermfg=240
highlight VertSplit ctermfg=black ctermbg=235 term=NONE
highlight CursorLine cterm=NONE ctermbg=235
highlight CursorLineNR cterm=NONE ctermbg=235 ctermfg=245

let g:lightline = {
            \ 'colorscheme': 'powerline',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'FugitiveHead'
            \ },
            \ }

let g:fzf_preview_window = 'right:50%'
map <C-p> :GFiles<CR>

let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
