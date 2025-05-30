vim9script

# ==============================================================================
# BASIC CONFIGURATION
# ==============================================================================

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
set smartcase             # Override ignorecase if search contains uppercase letters
set splitright            # Open new vertical splits to the right
set tabstop=4             # Number of spaces that a tab character represents
set timeoutlen=500        # Time in milliseconds to wait for mapped sequence to complete
set updatetime=250        # Time in milliseconds before swap file is written and CursorHold fires

colorscheme habamax       # Set colorscheme

# ==============================================================================
# NETRW CONFIGURATION
# ==============================================================================

autocmd FileType netrw setlocal nu rnu
g:netrw_banner = 0
g:netrw_liststyle = 3

# ==============================================================================
# PLUGIN SETUP
# ==============================================================================

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

  # Fuzzy finding
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  # Fuzzy finder
  Plug 'junegunn/fzf.vim'              # Fzf Vim integration

  # Development tools
  Plug 'yegappan/lsp'                  # Built-in LSP client
  Plug 'airblade/vim-gitgutter'        # Git diff in gutter

  # Language-specific plugins
  Plug 'pangloss/vim-javascript'       # Better JavaScript syntax
  Plug 'leafgarland/typescript-vim'    # TypeScript syntax
  Plug 'rust-lang/rust.vim'            # Rust support
  Plug 'vim-python/python-syntax'      # Enhanced Python syntax

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
  showDiagWithVirtualText: v:true,
  usePopupInCodeAction: v:true,
}
autocmd User LspSetup silent! call LspOptionsSet(lspOpts)

# Deno detection helper
def IsDeno(): bool
  return filereadable('deno.json') || filereadable('deno.jsonc')
enddef

# LSP Servers
var lspServers = [{
  name: 'deno',
  filetype: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
  path: 'deno',
  args: ['lsp']
}, {
  name: 'rust-analyzer',
  filetype: ['rust'],
  path: 'rust-analyzer',
  args: []
}, {
  name: 'pylsp',
  filetype: ['python'],
  path: 'pylsp',
  args: []
}]
autocmd User LspSetup call LspAddServer(lspServers)

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
cnoremap <leader>ca :LspCodeAction<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>l :LspCodeLens<CR>
nnoremap <leader>h :LspHover<CR>
nnoremap <leader>r :LspRename<CR>
nnoremap <leader>o :LspOutline<CR>
nnoremap [d :LspDiagPrevWrap<CR>
nnoremap ]d :LspDiagNextWrap<CR>
nnoremap gd :LspGotoDefinition<CR>
nnoremap gi :LspGotoImpl<CR>

# Clear Highlight Search
nnoremap <silent> <Esc> <Cmd>nohlsearch<CR>

# Git gutter mappings
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

# FZF Commands
command! F Files
command! B Buffers
command! C Commits

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
