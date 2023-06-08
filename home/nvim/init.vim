set encoding=UTF-8
syntax on
filetype plugin indent on

let mapleader = ' '
let maplocalleader = ','
set number
set relativenumber
set laststatus=2
set nobackup
set nowritebackup

set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

autocmd FileType * set noexpandtab
autocmd FileType haskell set expandtab
autocmd FileType python set expandtab

inoremap jh <Esc>
cnoremap jh <Esc>
autocmd VimEnter * nnoremap ( $
autocmd VimEnter * vnoremap ( $

nnoremap <silent><C-Tab> gt

nnoremap <silent><C-S-Tab> gT

nnoremap <silent>/<CR> :noh<CR><CR>

nnoremap <CR> :noh<CR><CR>

nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

nnoremap > >>
nnoremap < <<

nnoremap * 0
cnoremap * 0
vnoremap * 0

nnoremap 0 *
cnoremap 0 *
vnoremap 0 *

set clipboard=unnamedplus
set laststatus=2

set mouse=a

" Install vim-plug if not found
if empty(glob('~/.local/share/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
Plug 'ayu-theme/ayu-vim'
Plug 'tmsvg/pear-tree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'lewis6991/gitsigns.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'Pocco81/auto-save.nvim'
" Plug 'gpanders/nvim-parinfer'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-cmdline'
Plug 'jcorbin/vim-lobster'
call plug#end()

" THEME
if (has("termguicolors"))
    set termguicolors
	let ayucolor="dark"
	colorscheme ayu
endif

set completeopt=menu,menuone,noselect

lua << EOF
require'lspconfig'.clangd.setup{}
require'lspconfig'.rust_analyzer.setup{}

local cmp = require('cmp')
local types = require('cmp.types')
cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = cmp.mapping.preset.insert({
	  ['<C-j>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
	  ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
	  ['<C-y>'] = cmp.mapping.confirm({ select = false }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
	formatting = {
	},

	sources = {
		{ name = "nvim_lsp"},
		{ name = "path" },
		{ name = "buffer" , keyword_length = 5},
	},
	experimental = {
		ghost_text = true
	}
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
	  { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
	}, {
	  { name = 'buffer' },
	})
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
	  { name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
	  { name = 'path' }
	}, {
	  { name = 'cmdline' }
	})
})

require'auto-save'.setup{}
EOF

" NERDTREE
let g:NERDTreeWinSize=22
let g:NERDTreeShowHidden=1
let g:NERDTreeMinimalUI=1
let g:NERDTreeIgnore=[]
let g:NERDTreeStatusline=''

nnoremap <silent> <leader>n :NERDTreeFocus<CR>
nnoremap <silent> <C-b> :NERDTreeToggle<CR>
nnoremap <silent> <C-f> :NERDTreeFind<CR>

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" TERM
set splitright
set splitbelow

tnoremap <Esc> <C-\><C-n>
tnoremap jh <C-\><C-n>

au BufEnter * if &buftype == 'terminal' | :startinsert | endif

function! OpenTerminal()
    split term://bash
    resize10
endfunction

nnoremap <silent><C-n> :call OpenTerminal()<CR>

" PANEL NAVIGATION
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-w> :q<CR>

" AIRLINE
let g:airline#extensions#tabline#formatter = 'default' " f/p/file-name.js

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" OTHER

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

" GITGUTTER

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
    return printf('+%d ~%d -%d', a, m, r)
endfunction
set statusline+=%{GitStatus()}

" PEAR TREE

let g:pear_tree_smart_openers = 0
let g:pear_tree_smart_closers = 0
let g:pear_tree_smart_backspace = 0
let g:pear_tree_repeatable_expand = 0
