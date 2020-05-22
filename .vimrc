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

set viminfo+=n~/.vim/viminfo

set backspace=indent,eol,start

set nocompatible

syntax on           " enable syntax processing
set wildmenu        " visual autocomplete for command menu
set showmatch       " highlight matching [{()}]
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

"set cursorline
"set cursorcolumn

set autoindent
filetype plugin indent on

set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

set number
set relativenumber

"set colorcolumn=80,100,120

let mapleader = " "

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'NLKNguyen/papercolor-theme'
call plug#end()

let g:airline#extensions#tabline#enabled = 1

"map <leader>; :bp<CR>
"map <leader>' :bn<CR>

set laststatus=2
set noshowmode

set mouse=a
set clipboard=unnamed

if has("gui_running")
    set guifont=FiraCode-Retina:h15
    set guioptions=
    set background=light
    colorscheme PaperColor
    let g:airline_theme='sol'
else
    set background=dark
    colorscheme PaperColor
    let g:airline_theme='sol'
    let g:airline_powerline_fonts = 1
endif

set splitbelow splitright
