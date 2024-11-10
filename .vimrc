vim9script
syntax enable
colorscheme xcode

# use `:G` to invoke `git` commands
command -nargs=* G echo system('git ' .. <q-args>)

# global variables
for [k, v] in items({ is_posix: 1, netrw_banner: 0 })
	execute $'g:{k} = {string(v)}'
endfor

# set options
for o in [
	'breakindent', 'cursorline', 'hlsearch', 'incsearch', 'noswapfile', 
	'number', 'relativenumber', 'regexpengine=0', 'shiftwidth=4',
	'smartcase', 'smartindent', 'tabstop=4', 'wildmenu'
]
	execute $'set {o}'
endfor

# transparent background and line numbers in file explorer
for g in ['EndOfBuffer', 'Normal', 'NonText']
	execute $'autocmd ColorScheme * hi {g} guibg=NONE ctermbg=NONE'
endfor
autocmd FileType netrw setlocal number relativenumber

# keymaps
for [k, v] in items({
	'<C-h>': '<cmd>wincmd h<cr>',
	'<C-j>': '<cmd>wincmd j<cr>',
	'<C-k>': '<cmd>wincmd k<cr>',
	'<C-l>': '<cmd>wincmd l<cr>',
	'<Esc>': '<cmd>nohlsearch<cr>',
	'<leader>a': '<cmd>LspCodeAction<cr>',
	'<leader>d': '<cmd>LspGotoDefinition<cr>',
	'<leader>e': '<cmd>Explore<cr>',
	'<leader>h': '<cmd>LspHover<cr>',
	'<leader>i': '<cmd>LspGotoImpl<cr>',
	'<leader>n': '<cmd>LspDiag nextWrap<cr>',
	'<leader>p': '<cmd>LspDiag prevWrap<cr>',
	'<leader>r': '<cmd>LspPeekReferences<cr>',
	'<leader>R': '<cmd>LspRename<cr>',
	'<leader>s': '<cmd>LspSymbolSearch<cr>',
	'<leader>t': '<cmd>LspGotoTypeDef<cr>'
})
  execute $'nnoremap {k} {v}'
endfor

# install vim-plug if missing
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
  		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

# plugin list
call plug#begin()
	Plug 'arzg/vim-colors-xcode'
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-rsi'
	Plug 'wellle/targets.vim'
	Plug 'yegappan/lsp'
call plug#end()

# lsp configuration
var lspConfiguration = {
	options: {
		usePopupInCodeAction: true,
	},
	servers: [
		{ 
			name: 'clang', 
			filetype: ['c'], 
			path: '/usr/bin/clangd' 
		},
		{ 
			name: 'typescript',
			filetype: ['typescript', 'typescriptreact', 'javascript'], 
			path: 'typescript-language-server', 
			args: ['--stdio'] 
		},
	]
}
autocmd User LspSetup call LspOptionsSet(lspConfiguration.options)
autocmd User LspSetup call LspAddServer(lspConfiguration.servers)
