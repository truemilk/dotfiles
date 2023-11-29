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

set hidden

set shortmess+=c

set updatetime=100

set backspace=indent,eol,start

if has("syntax")
    syntax on
endif

set wildmenu
set showmatch
set is hls

set autoindent
filetype plugin indent on

set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

set number
"set relativenumber

set autoread
set autowriteall

set laststatus=2
"set noshowmode

set scrolloff=5

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

set timeout
set ttimeoutlen=100

let mapleader = " "

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'fatih/molokai'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
call plug#end()

set background=dark
colorscheme molokai
