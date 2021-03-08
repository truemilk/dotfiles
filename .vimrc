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
set incsearch

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
Plug 'gruvbox-community/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'SirVer/ultisnips'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
"Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'fatih/molokai'
call plug#end()

set background=dark
silent! colorscheme gruvbox
highlight Normal ctermbg=black

"let g:rehash256 = 1
"let g:molokai_original = 1
"colorscheme molokai

"colorscheme elflord
"highlight LineNr ctermfg=240
"highlight VertSplit ctermfg=black ctermbg=235 term=NONE
"highlight CursorLine cterm=NONE ctermbg=235
"highlight CursorLineNR cterm=NONE ctermbg=235 ctermfg=245

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

let g:go_auto_type_info = 1

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd FileType go nmap <Leader>ct <Plug>(go-coverage-toggle)

au BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

autocmd FileType go nmap <leader>t  <Plug>(go-test)







autocmd FileType go nmap <leader>r  <Plug>(go-run)

map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

let g:go_list_type = "quickfix"

let g:go_fmt_command = "goimports"

autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

autocmd FileType go nmap <Leader>i <Plug>(go-info)
let g:go_auto_type_info = 1

let g:go_auto_sameids = 1







nnoremap <C-p> :GFiles<Cr>
nnoremap <C-g> :Rg<Cr>
nnoremap <silent><leader>l :Buffers<CR>




"au filetype go inoremap <buffer> . .<C-x><C-o>


