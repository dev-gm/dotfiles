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

autocmd FocusLost * if &filetype == "vlang" | silent! wa | endif
autocmd BufLeave * if &filetype == "vlang" | silent! w | endif

inoremap jh <Esc>
cnoremap jh <Esc>

autocmd VimEnter * nnoremap ( $
autocmd VimEnter * vnoremap ( $

nnoremap <silent><C-Tab> gt
nnoremap <silent><C-S-Tab> gT

nnoremap <silent>/<CR> :noh<CR><CR>
nnoremap <CR> :noh<CR><CR>

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
set completeopt=menu,menuone,noselect
set rtp^="/home/gavin/.opam/default/share/ocp-indent/vim"

" HIGHLIGHT ON YANK
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

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

" TERM
set splitright
set splitbelow

tnoremap <Esc> <C-\><C-n>
tnoremap jh <C-\><C-n>

au BufEnter * if &buftype == 'terminal' | :startinsert | endif

function! OpenTerminal()
    split term://fish
    resize10
endfunction

nnoremap <silent><C-n> :call OpenTerminal()<CR>

call plug#begin()
Plug 'ayu-theme/ayu-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'lewis6991/gitsigns.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'tmsvg/pear-tree'
Plug 'sar/AutoSave.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'cheap-glitch/vim-v'
Plug 'edKotinsky/Arduino.nvim'
call plug#end()

" THEME
if (has("termguicolors"))
    set termguicolors
	let ayucolor="dark"
	colorscheme ayu
endif

" AIRLINE
let g:airline#extensions#tabline#formatter = 'default'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

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
" GITGUTTER
function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
    return printf('+%d ~%d -%d', a, m, r)
endfunction
set statusline+=%{GitStatus()}

" VSNIP
" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

" PEAR TREE
let g:pear_tree_smart_openers = 0
let g:pear_tree_smart_closers = 0
let g:pear_tree_smart_backspace = 0
let g:pear_tree_repeatable_expand = 0

lua << EOF
-- AUTOSAVE
require('autosave').setup({
	enabled = true,
	execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
	events = {"InsertLeave", "TextChanged"},
	conditions = {
		exists = true,
		filename_is_not = {},
		filetype_is_not = {"vlang"},
		modifiable = true
	},
	write_all_buffers = false,
	on_off_commands = true,
	clean_command_line_interval = 0,
	debounce_delay = 135
})

-- TREESITTER
require'nvim-treesitter.configs'.setup({
	ensure_installed = { "c" },
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = { "vlang" }
	}
})

-- LSPCONFIG
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

lspconfig.clangd.setup{ capabilities = capabilities }
lspconfig.rust_analyzer.setup{ capabilities = capabilities }
lspconfig.vls.setup{ capabilities = capabilities }
lspconfig.ocamllsp.setup{ capabilities = capabilities }

-- CMP
local cmp = require('cmp')
local types = require('cmp.types')
cmp.setup({
    snippet = {
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
	formatting = {},
	sources = {
		{ name = "nvim_lsp"},
		{ name = "path" },
		{ name = "buffer" , keyword_length = 5},
	},
	experimental = {
		ghost_text = true
	}
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

-- ARDUINO
local arduino = require('arduino')

arduino.setup {
	default_fqbn = "esp32:esp32:esp32da",
    clangd = "/home/gavin/.guix-profile/bin/clangd",
	arduino = "/home/gavin/.guix-profile/bin/arduino-cli",
	arduino_config_dir = "/home/gavin/.arduino15"
}

lspconfig.arduino_language_server.setup{
	on_new_config = arduino.on_new_config,
	cmd = { "arduino-language-server", "-clangd", "/home/gavin/.guix-profile/bin/clangd", "-cli", "/home/gavin/.guix-profile/bin/arduino-cli" },
	capabilities = capabilities
}
EOF
