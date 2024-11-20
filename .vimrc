vim9script
syntax enable

# global variables
for [k, v] in items({ is_posix: 1, netrw_banner: 0 })
	execute $'g:{k} = {string(v)}'
endfor

# set options
for o in [
	'breakindent',
	'cursorline',
	'hlsearch',
	'incsearch',
	'noswapfile',
	'number',
	'regexpengine=0',
	'relativenumber',
	'shiftwidth=4',
	'smartcase',
	'smartindent',
	'splitbelow',
	'splitright',
	'tabstop=4',
	'wildmenu',
]
	execute $'set {o}'
endfor

# transparent background
for g in ['EndOfBuffer', 'Normal', 'NonText']
	execute $'autocmd ColorScheme * hi {g} guibg=NONE ctermbg=NONE'
endfor

# add line numbers to explorer
autocmd FileType netrw setlocal number relativenumber

# keymaps
for [k, v] in items({
	# Clear highlights from search
	'<Esc>': '<cmd>nohlsearch<cr>', 
	# Quicker Pane Switching
	'<C-h>': '<cmd>wincmd h<cr>',
	'<C-j>': '<cmd>wincmd j<cr>',
	'<C-k>': '<cmd>wincmd k<cr>',
	'<C-l>': '<cmd>wincmd l<cr>',
	# Tab Switching
	'<S-h>': '<cmd>tabp<cr>',
	'<S-l>': '<cmd>tabn<cr>',
	'<leader>1': '1gt',
	'<leader>2': '2gt',
	'<leader>3': '3gt',
	'<leader>4': '4gt',
	'<leader>5': '5gt',
	# LSP Mappings
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
	# Fuzzy Finder
	'<leader>f': '<cmd>Files<cr>',
	'<leader>b': '<cmd>Buffers<cr>',
	'<leader>c': '<cmd>Commits<cr>',
	'<leader>m': '<cmd>Maps<cr>',
	'<leader>/': '<cmd>Commands<cr>',
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
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } # Fuzzy Finder CLI
	Plug 'junegunn/fzf.vim' # In Editor Fuzzy Finder
	Plug 'junegunn/gv.vim' # Git Commit Viewer
	Plug 'lunacookies/vim-colors-xcode' # Colorscheme
	Plug 'mattn/emmet-vim' # HTML Shorthand Syntax 
	Plug 'tpope/vim-commentary' # Quickly Toggle Comments
	Plug 'tpope/vim-fugitive' # Perform Git Commands in Editor
	Plug 'tpope/vim-obsession' # Automatically Track Vim Session
	Plug 'tpope/vim-rhubarb' # Open Files and Lines on GitHub
	Plug 'tpope/vim-rsi' # Readline Commands in Command Mode
	Plug 'tpope/vim-sleuth' # Automatic Indentation Detection
	Plug 'tpope/vim-surround' # Quick Edit Surrounding Pairs
	Plug 'wellle/targets.vim' # Additional Text Objects
	Plug 'yegappan/lsp' # Language Server Implementation
call plug#end()
colorscheme xcode

# lsp configuration
var lspConfiguration = {
	options: {
		usePopupInCodeAction: true,
	},
	servers: [
		{ # C
			name: 'clang', 
			filetype: ['c'], 
			path: '/usr/bin/clangd' 
		},
		{ # CSS
			name: 'css',
			filetype: ['css', 'scss', 'less'],
			path: 'vscode-css-language-server',
			args: ['--stdio'],
			initializationOptions: {
				provideFormatter: true,
				css: { validate: true },
			},
		},
		{ # TailwindCSS
			name: 'tailwind',
			filetype: ['typescriptreact'],
			path: 'tailwindcss-language-server',
			args: ['--stdio'],
		},
		{  # TypeScript
			name: 'typescript',
			filetype: ['typescript', 'typescriptreact', 'javascript'], 
			path: 'typescript-language-server', 
			args: ['--stdio'] 
		},
		{ # Deno TypeScript
			name: 'deno',
			filetype: ['typescript', 'typescriptreact'],
			path: 'deno',
			args: ['lsp'],
			root: 'deno.json'
		},
		{ # ESLint
			name: 'eslint',
			filetype: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
			path: 'vscode-eslint-language-server',
			args: ['--stdio'],
			initializationOptions: {
				validate: 'on',
				packageManager: 'yarn',
				codeActionOnSave: true,
				format: true,
				autoFixOnSave: true,
			},
		},
	]
}
autocmd User LspSetup call LspOptionsSet(lspConfiguration.options)
autocmd User LspSetup call LspAddServer(lspConfiguration.servers)
autocmd CursorHold * silent! write
