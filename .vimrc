vim9script

# ==============================================================================
# BASIC CONFIGURATION
# ==============================================================================

# Core settings
set autoindent            # Automatically indent new lines to match the previous line
set expandtab             # Convert tabs to spaces when inserting
set hlsearch              # Highlight all matches when searching
set ignorecase            # Ignore case when searching
set incsearch             # Show search matches as you type
set laststatus=2          # Always show the status line
set noswapfile            # Disable creation of swap files
set number                # Display line numbers on the left side
set relativenumber        # Show relative line numbers (distance from current line)
set scrolloff=999         # Keep cursor away from top/bottom edges
set shiftwidth=4          # Number of spaces used for each step of autoindent
set showbreak             # String to display at the beginning of wrapped lines
set smartcase             # Override ignorecase if search contains uppercase letters
set splitright            # Open new vertical splits to the right
set tabstop=4             # Number of spaces that a tab character represents
set timeoutlen=500        # Time in milliseconds to wait for mapped sequence to complete
set updatetime=250        # Time in milliseconds before swap file is written and CursorHold fires

# Colorscheme and transparency
colorscheme habamax

# ==============================================================================
# NETRW CONFIGURATION
# ==============================================================================

autocmd FileType netrw setlocal nu rnu
g:netrw_banner = 0
g:netrw_liststyle = 3

# ==============================================================================
# PLUGIN SETUP
# ==============================================================================

# Auto-install vim-plug
var data_dir = has('nvim') ? stdpath('data') .. '/site' : expand('~/.vim')
if empty(glob(data_dir .. '/autoload/plug.vim'))
  silent! execute '!curl -fLo ' .. data_dir .. '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

plug#begin()
  # Essential text manipulation
  Plug 'tpope/vim-surround'            # For surrounding text with characters
  Plug 'tpope/vim-commentary'          # For commenting/uncommenting lines
  Plug 'tpope/vim-rsi'                 # Readline-style key bindings
  Plug 'tpope/vim-repeat'              # Make . work with plugin commands
  Plug 'tpope/vim-unimpaired'          # Paired mappings for navigation
  Plug 'tpope/vim-fugitive'            # Simple git commands with :G

  # LSP and completion
  Plug 'yegappan/lsp'                  # LSP support

  # Fuzzy finding
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  # Fuzzy finder
  Plug 'junegunn/fzf.vim'              # Fzf Vim integration

  # Development tools
  Plug 'dense-analysis/ale'            # Async linting engine
  Plug 'airblade/vim-gitgutter'        # Git diff in gutter

  # Language-specific plugins
  Plug 'pangloss/vim-javascript'       # Better JavaScript syntax
  Plug 'leafgarland/typescript-vim'    # TypeScript syntax
  Plug 'rust-lang/rust.vim'            # Rust support
  Plug 'vim-python/python-syntax'      # Enhanced Python syntax
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }  # Go support
  Plug 'vim-php/vim-php'               # PHP syntax and support

  # UI improvements
  Plug 'itchyny/lightline.vim'         # Lightweight status line
  Plug 'machakann/vim-highlightedyank' # Highlight yanked text
plug#end()

# ==============================================================================
# LSP CONFIGURATION
# ==============================================================================

# LSP Options
var lspOpts = {
  autoHighlight: v:true,
  ignoreMissingServer: v:true,
  showDiagWithVirtualText: v:true,
  usePopupInCodeAction: v:true,
  completionMatcher: 'fuzzy',
  vsnipSupport: v:true,
}
autocmd User LspSetup call LspOptionsSet(lspOpts)

# LSP Servers
var lspServers = [
  {
    name: 'swift',
    filetype: ['swift'],
    path: '/usr/bin/xcrun',
    args: ['sourcekit-lsp']
  },
  {
    name: 'clangd',
    filetype: ['c', 'cpp', 'objc', 'objcpp'],
    path: '/usr/bin/clangd',
    args: ['--background-index', '--clang-tidy']
  },
  {
    name: 'typescript-language-server',
    filetype: ['javascript', 'typescript', 'typescriptreact', 'javascriptreact'],
    path: 'typescript-language-server',
    args: ['--stdio']
  },
  {
    name: 'pylsp',
    filetype: ['python'],
    path: 'pylsp',
    args: []
  },
  {
    name: 'rust-analyzer',
    filetype: ['rust'],
    path: 'rust-analyzer',
    args: []
  },
  {
    name: 'gopls',
    filetype: ['go'],
    path: 'gopls',
    args: ['--stdio']
  },
  {
    name: 'intelephense',
    filetype: ['php'],
    path: 'intelephense',
    args: ['--stdio']
  }
]
autocmd User LspSetup call LspAddServer(lspServers)

# ==============================================================================
# ALE CONFIGURATION
# ==============================================================================

# Deno detection helper
def IsDeno(): bool
  return filereadable('deno.json') || filereadable('deno.jsonc')
enddef

g:ale_linters_explicit = 1
g:ale_linters = {
  'javascript': IsDeno() ? ['deno'] : ['eslint'],
  'typescript': IsDeno() ? ['deno'] : ['eslint', 'tslint'],
  'python': ['flake8', 'mypy'],
  'rust': ['cargo'],
  'c': ['clang'],
  'cpp': ['clang++'],
  'go': ['gopls', 'golangci-lint'],
  'php': ['phpstan', 'psalm'],
}
g:ale_fixers = {
  '*': ['remove_trailing_lines', 'trim_whitespace'],
  'javascript': IsDeno() ? ['deno'] : ['prettier', 'eslint'],
  'typescript': IsDeno() ? ['deno'] : ['prettier', 'eslint'],
  'python': ['black', 'isort'],
  'rust': ['rustfmt'],
  'c': ['clang-format'],
  'cpp': ['clang-format'],
  'go': ['gofmt', 'goimports'],
  'php': ['php-cs-fixer'],
}
g:ale_fix_on_save = 1

# ==============================================================================
# UI PLUGIN CONFIGURATION
# ==============================================================================

# Lightline configuration
g:lightline = {
  'colorscheme': 'wombat',
  'active': {
    'left': [['mode', 'paste'],
             ['gitbranch', 'readonly', 'filename', 'modified']],
    'right': [['lineinfo'],
              ['percent'],
              ['fileformat', 'fileencoding', 'filetype']]
  },
  'component_function': {
    'gitbranch': 'FugitiveHead'
  },
}

# Highlighted yank settings
g:highlightedyank_highlight_duration = 200

# Git gutter settings
g:gitgutter_enabled = 1
g:gitgutter_map_keys = 0
g:gitgutter_sign_added = '│'
g:gitgutter_sign_modified = '│'
g:gitgutter_sign_removed = '│'
g:gitgutter_sign_removed_first_line = '│'
g:gitgutter_sign_removed_above_and_below = '│'
g:gitgutter_sign_modified_removed = '│'

# ==============================================================================
# KEY MAPPINGS
# ==============================================================================

# Tab navigation
nnoremap <C-t> :tabnew<CR>
nnoremap <C-w> :tabclose<CR>
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-l> :tabnext<CR>

# Window navigation
var direction_keys = ['h', 'j', 'k', 'l']
for key in direction_keys
  execute "nnoremap <C-" .. key .. "> <C-w>" .. key
endfor

# LSP mappings
nnoremap <leader>ca :LspCodeAction<CR>
vnoremap <leader>ca :LspCodeAction<CR>
nnoremap <leader>l :LspCodeLens<CR>
nnoremap <leader>h :LspHover<CR>
nnoremap <leader>r :LspRename<CR>
nnoremap <leader>o :LspOutline<CR>
nnoremap [d :LspDiagPrevWrap<CR>
nnoremap ]d :LspDiagNextWrap<CR>
nnoremap gd :LspGotoDefinition<CR>
nnoremap gi :LspGotoImpl<CR>
nnoremap gr :LspShowReferences<CR>

# FZF commands
command! F Files
command! B Buffers
command! C Commits

# Git gutter mappings
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

# ==============================================================================
# AUTO-COMMANDS
# ==============================================================================

augroup colors
    autocmd VimEnter,ColorScheme * {
      hi Normal guibg=NONE ctermbg=NONE
      hi NonText guibg=NONE ctermbg=NONE
      hi LineNr guibg=NONE ctermbg=NONE
      hi SignColumn guibg=NONE ctermbg=NONE
      hi VertSplit guibg=NONE ctermbg=NONE
      hi StatusLine guibg=NONE ctermbg=NONE
      hi StatusLineNC guibg=NONE ctermbg=NONE
    }
augroup END

augroup programming
  autocmd!
  # Auto-format on save for specific filetypes
  autocmd BufWritePre *.py,*.js,*.ts,*.jsx,*.tsx,*.rs,*.c,*.cpp,*.go,*.php,*.kt ALEFix
  # Enable spell check for documentation
  autocmd FileType markdown,text,gitcommit setlocal spell
augroup END
