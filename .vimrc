vim9script
syntax enable

# use `:G` to invoke `git` commands
command -nargs=* G echo system('git ' .. <q-args>)

# global variables
for [k, v] in items({ 
	is_posix: 1, 
	netrw_banner: 0 
})
	execute $'g:{k} = {string(v)}'
endfor

# set options
for o in [
	'breakindent', 'cursorline', 'hlsearch', 'incsearch', 
	'noswapfile', 'number', 'relativenumber', 'regexpengine=0', 
	'shiftwidth=4', 'smartcase', 'smartindent', 'splitbelow', 
	'splitright', 'tabstop=4', 'wildmenu'
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
    '<leader>t': '<cmd>LspGotoTypeDef<cr>',
    '<leader>f': '<cmd>Files<cr>',
    '<leader>b': '<cmd>Buffers<cr>',
    '<leader>g': '<cmd>Rg<cr>',
    '<leader>c': '<cmd>Commits<cr>',
    '<leader>m': '<cmd>Maps<cr>',
    '<leader>/': '<cmd>Commands<cr>'
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
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
	Plug 'mattn/emmet-vim'
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-obsession'
	Plug 'tpope/vim-rsi'
	Plug 'tpope/vim-surround'
	Plug 'wellle/targets.vim'
	Plug 'yegappan/lsp'
call plug#end()
colorscheme xcode

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
			name: 'css',
			filetype: ['css', 'scss', 'less'],
			path: 'vscode-css-language-server',
			args: ['--stdio'],
			initializationOptions: {
				provideFormatter: true,
				css: { validate: true },
			},
		},
		{
			name: 'tailwind',
			filetype: ['typescriptreact'],
			path: 'tailwindcss-language-server',
			args: ['--stdio'],
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
