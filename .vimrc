set encoding=UTF-8
filetype on
syntax on
set ttyfast

set number
set relativenumber
set laststatus=2
set nobackup
set nowritebackup

set tabstop=4
set shiftwidth=4

inoremap jh <Esc>
cnoremap jh <Esc>
nnoremap ( $
vnoremap ( $

nnoremap <silent>/<CR> :noh<CR><CR>

nnoremap <CR> :noh<CR><CR>

nmap <S-CR> O<Esc>
nmap <CR> o<Esc>

set clipboard=unnamedplus
set laststatus=2

nnoremap * 0
cnoremap * 0
vnoremap * 0

nnoremap 0 *
cnoremap 0 *
vnoremap 0 *
