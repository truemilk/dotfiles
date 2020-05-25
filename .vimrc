set nocompatible

set viminfo+='1000,n~/.vim/viminfo

if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup

if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

if exists("+undofile")
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif
    
set encoding=utf8

set backspace=indent,eol,start

syntax on           " enable syntax processing
set wildmenu        " visual autocomplete for command menu
set showmatch       " highlight matching [{()}]
set incsearch       " search as characters are entered
set hlsearch        " highlight matches


set autoindent
filetype plugin indent on

set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

set number
set relativenumber

let mapleader = " "

set autowrite

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'djoshea/vim-autoread'
Plug 'farmergreg/vim-lastplace'
Plug 'terryma/vim-multiple-cursors'
Plug 'machakann/vim-highlightedyank'
call plug#end()

set laststatus=2
set noshowmode

set mouse=a
set clipboard=unnamed

set splitbelow splitright

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

set cursorline
augroup CursorLineOnlyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

set background=dark
colorscheme industry
highlight LineNr ctermfg=238
highlight VertSplit ctermfg=black ctermbg=238 term=NONE
highlight CursorLine cterm=NONE ctermbg=238 ctermfg=white
highlight CursorLineNR cterm=NONE ctermbg=235 ctermfg=245
