vim9script
syntax enable

# Global Variables
for [k, v] in items({ 
	is_posix: 1,
	netrw_banner: 0,
})
	execute $'g:{k} = {string(v)}'
endfor

# Set Options
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
	'signcolumn=yes',
	'smartcase',
	'smartindent',
	'splitbelow',
	'splitright',
	'tabstop=4',
	'wildmenu',
]
	execute $'set {o}'
endfor

# Add Line Numbers To Explorer
autocmd FileType netrw setlocal number relativenumber

# Keymaps
for [k, v] in items({
	# Clear Highlights From Search
	'<Esc>': '<cmd>nohlsearch<cr>', 
	# Open File Explorer
	'<leader>e': '<cmd>Explore<cr>',
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
	# Fuzzy Finder
	'<leader>f': '<cmd>Files<cr>',
	'<leader>b': '<cmd>Buffers<cr>',
	'<leader>c': '<cmd>Commits<cr>',
	'<leader>m': '<cmd>Maps<cr>',
	'<leader>/': '<cmd>Commands<cr>',
	# LSP
	'<leader>a': '<plug>(lsp-code-action)',
	'<leader>d': '<plug>(lsp-definition)',
	'<leader>h': '<plug>(lsp-hover)',
	'<leader>i': '<plug>(lsp-implementation)',
	'<leader>n': '<plug>(lsp-next-diagnostic)<cr>',
	'<leader>p': '<plug>(lsp-previous-diagnostic)<cr>',
	'<leader>r': '<plug>(lsp-references)',
	'<leader>R': '<plug>(lsp-rename)',
	'<leader>s': '<plug>(lsp-document-symbol-search)',
	'<leader>t': '<plug>(lsp-type-definition)',
})
  execute $'nnoremap {k} {v}'
endfor

# Install vim-plug If Missing
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
  		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

# Plugin List
call plug#begin()
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } # Fuzzy Finder CLI
	Plug 'junegunn/fzf.vim' # In Editor Fuzzy Finder
	Plug 'junegunn/gv.vim' # Git Commit Viewer
	Plug 'lunacookies/vim-colors-xcode' # Xcode Style Colorscheme
	Plug 'mattn/emmet-vim' # HTML Shorthand Syntax 
	Plug 'tpope/vim-commentary' # Quickly Toggle Comments
	Plug 'tpope/vim-fugitive' # Perform Git Commands in Editor
	Plug 'tpope/vim-obsession' # Automatically Track Vim Session
	Plug 'tpope/vim-rhubarb' # Open Files and Lines on GitHub
	Plug 'tpope/vim-rsi' # Readline Commands in Command Mode
	Plug 'tpope/vim-sleuth' # Automatic Indentation Detection
	Plug 'tpope/vim-surround' # Quick Edit Surrounding Pairs
	Plug 'wellle/targets.vim' # Additional Text Objects
	Plug 'prabirshrestha/vim-lsp' # LSP Client
	Plug 'mattn/vim-lsp-settings' # LSP Setup
	Plug 'prabirshrestha/asyncomplete.vim' # Autocompletion
	Plug 'prabirshrestha/asyncomplete-lsp.vim' # LSP Autocomplete
	Plug 'github/copilot.vim' # AI Copilot 
	Plug 'sheerun/vim-polyglot' # Syntax Highlighting
call plug#end()

# Apply Colorscheme
colorscheme xcode

# Enforce Transparent Background
for g in ['EndOfBuffer', 'Normal', 'NonText']
	execute $'autocmd ColorScheme * hi {g} guibg=NONE ctermbg=NONE'
endfor

# Auto Format on Save
autocmd  BufWritePre * LspDocumentFormat 
