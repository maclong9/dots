vim9script

# OS Detection
var is_mac = has('mac') || has('macunix') || system('uname') =~? 'darwin'

# Basic Configuration
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
set signcolumn=yes        # Ensure signcolumn is always visible
set smartcase             # Override ignorecase if search contains uppercase letters
set splitright            # Open new vertical splits to the right
set tabstop=4             # Number of spaces that a tab character represents
set timeoutlen=500        # Time to wait for mapped sequence to complete
set updatetime=250        # Time before swap file is written and CursorHold fires
colorscheme habamax       # Set colorscheme

# Netrw Configuration
autocmd FileType netrw setlocal nu rnu
g:netrw_banner = 0
g:netrw_liststyle = 3

# Plugin Setup
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
  Plug 'tpope/vim-unimpaired'          # Paired mappings for navigation
  Plug 'tpope/vim-fugitive'            # Simple git commands with :G

  # Fuzzy finding
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  # Fuzzy finder
  Plug 'junegunn/fzf.vim'              # Fzf Vim integration

  # Development tools
  Plug 'yegappan/lsp'                  # Built-in LSP client
  Plug 'airblade/vim-gitgutter'        # Git diff in gutter

  # Language-specific plugins (conditional based on OS)
  if is_mac
    # macOS-specific plugins
    Plug 'rhysd/vim-clang-format'      # C formatting
    Plug 'keith/swift.vim'             # Swift syntax and support
  else
    # Linux-specific plugins
    Plug 'pangloss/vim-javascript'     # Better JavaScript syntax
    Plug 'leafgarland/typescript-vim'  # TypeScript syntax
    Plug 'rust-lang/rust.vim'          # Rust support
    Plug 'vim-python/python-syntax'    # Enhanced Python syntax
    Plug 'udalov/kotlin-vim'           # Kotlin syntax support
  endif

  # UI improvements
  Plug 'itchyny/lightline.vim'         # Lightweight status line
  Plug 'machakann/vim-highlightedyank' # Highlight yanked text
plug#end()

# LSP Configuration
var lspOpts = {
  autoHighlight: v:true,
  showDiagWithVirtualText: v:true,
  usePopupInCodeAction: v:true,
}
autocmd User LspSetup silent! call LspOptionsSet(lspOpts)

# Deno detection helper (Linux only)
def IsDeno(): bool
  return filereadable('deno.json') || filereadable('deno.jsonc')
enddef

# LSP Servers Configuration
var lspServers = []

if is_mac
  # macOS LSP servers
  lspServers = [{
    name: 'clangd',
    filetype: ['c'],
    path: 'clangd',
    args: ['--background-index']
  }, {
    name: 'sourcekit',
    filetype: ['swift'],
    path: 'sourcekit-lsp',
    args: []
  }]
else
  # Linux LSP servers
  lspServers = [
    # JavaScript/TypeScript - Deno or TypeScript LSP
    {
      name: 'deno',
      filetype: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
      path: '/home/mac/.deno/bin/deno',
      args: ['lsp'],
    },
    {
      name: 'typescript-language-server',
      filetype: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
      path: 'typescript-language-server',
      args: ['--stdio'],
      syncInit: v:true
    },
    # Rust
    {
      name: 'rust-analyzer',
      filetype: ['rust'],
      path: '/home/mac/.cargo/bin/rust-analyzer',
      args: [],
      syncInit: v:true
    },
    # Python
    {
      name: 'pylsp',
      filetype: ['python'],
      path: 'pylsp',
      args: [],
      syncInit: v:true
    },
    # Go
    {
      name: 'gopls',
      filetype: ['go', 'gomod'],
      path: '/home/mac/go/bin/gopls',
      args: [],
      syncInit: v:true
    },
    # C/C++
    {
      name: 'ccls',
      filetype: ['c', 'cpp'],
      path: 'ccls',
      args: [],
      syncInit: v:true
    },
    # Kotlin
    {
      name: 'kotlin-language-server',
      filetype: ['kotlin'],
      path: '/home/mac/.local/share/kotlin-language-server/server/bin/kotlin-language-server',
      args: [],
      syncInit: v:true
    },
    # Java
    {
      name: 'eclipse.jdt.ls',
      filetype: ['java'],
      path: 'java',
      args: ['-Declipse.application=org.eclipse.jdt.ls.core.id1',
             '-Dosgi.bundles.defaultStartLevel=4',
             '-Declipse.product=org.eclipse.jdt.ls.core.product',
             '-Dlog.protocol=true',
             '-Dlog.level=ALL',
             '-Xms1g',
             '-Xmx2G',
             '--add-modules=ALL-SYSTEM',
             '--add-opens', 'java.base/java.util=ALL-UNNAMED',
             '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
             '-jar', '/home/mac/.local/share/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_*.jar',
             '-configuration', '/home/mac/.local/share/eclipse.jdt.ls/config_linux',
             '-data', '/tmp/jdtls-workspace'],
      syncInit: v:true
    },
    # PHP
    {
      name: 'phpactor',
      filetype: ['php'],
      path: '/home/mac/.composer/vendor/bin/phpactor',
      args: ['language-server'],
      syncInit: v:true
    },
    # Ruby
    {
      name: 'solargraph',
      filetype: ['ruby'],
      path: 'solargraph',
      args: ['stdio'],
      syncInit: v:true
    },
    # Shell/Bash
    {
      name: 'bash-language-server',
      filetype: ['sh', 'bash'],
      path: 'bash-language-server',
      args: ['start'],
      syncInit: v:true
    },
    # YAML
    {
      name: 'yaml-language-server',
      filetype: ['yaml', 'yml'],
      path: 'yaml-language-server',
      args: ['--stdio'],
      syncInit: v:true
    },
    # JSON
    {
      name: 'vscode-json-language-server',
      filetype: ['json'],
      path: 'vscode-json-language-server',
      args: ['--stdio'],
      syncInit: v:true
    },
    # HTML/CSS
    {
      name: 'vscode-html-language-server',
      filetype: ['html'],
      path: 'vscode-html-language-server',
      args: ['--stdio'],
      syncInit: v:true
    },
    {
      name: 'vscode-css-language-server',
      filetype: ['css', 'scss', 'sass'],
      path: 'vscode-css-language-server',
      args: ['--stdio'],
      syncInit: v:true
    },
    # Dockerfile
    {
      name: 'docker-langserver',
      filetype: ['dockerfile'],
      path: 'docker-langserver',
      args: ['--stdio'],
      syncInit: v:true
    },
    # Lua
    {
      name: 'lua-language-server',
      filetype: ['lua'],
      path: 'lua-language-server',
      args: [],
      syncInit: v:true
    }
  ]
endif

autocmd User LspSetup call LspAddServer(lspServers)

# Formatting functions (Linux only)
if !is_mac
  def FormatBuffer()
    var ft = &filetype
    if ft == 'python'
      silent! execute '%!black --quiet -'
    elseif ft == 'rust'
      silent! execute '%!rustfmt'
    elseif ft == 'go'
      silent! execute '%!goimports'
    elseif ft == 'javascript' || ft == 'typescript' || ft == 'json' || ft == 'css' || ft == 'html'
      silent! execute '%!prettier --stdin-filepath=' .. expand('%')
    elseif ft == 'c' || ft == 'cpp'
      silent! execute '%!clang-format'
    elseif ft == 'sh' || ft == 'bash'
      silent! execute '%!shfmt -i 4'
    elseif ft == 'kotlin'
      # Note: ktlint doesn't support stdin formatting, so we format the file directly
      silent! execute '!ktlint -F %'
      edit!
    endif
  enddef

  # Auto-format on save for supported filetypes (Linux only)
  augroup AutoFormat
    autocmd!
    autocmd BufWritePre *.py,*.rs,*.go,*.js,*.ts,*.json,*.css,*.html,*.c,*.cpp,*.sh,*.kt call FormatBuffer()
  augroup END
endif

# Language-specific settings (Linux only)
if !is_mac
  augroup LanguageSettings
    autocmd!
    # Python: Use ruff for linting
    autocmd FileType python setlocal makeprg=ruff\ check\ %
    
    # Go: Set tab width to match Go conventions
    autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab
    
    # YAML: Use 2 spaces
    autocmd FileType yaml,yml setlocal tabstop=2 shiftwidth=2
    
    # JSON: Use 2 spaces
    autocmd FileType json setlocal tabstop=2 shiftwidth=2
    
    # Shell scripts: Use 4 spaces
    autocmd FileType sh,bash setlocal tabstop=4 shiftwidth=4
    
    # Kotlin: Use 4 spaces (standard Kotlin style)
    autocmd FileType kotlin setlocal tabstop=4 shiftwidth=4
  augroup END
endif

# Lightline configuration
g:lightline = {
  'colorscheme': 'wombat',
  'active': {
    'left': [['mode', 'paste'],
             ['gitbranch', 'readonly', 'filename', 'modified']],
    'right': [['lineinfo'],
              ['percent'],
              is_mac ? [] : ['filetype']]
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

# Key Mappings

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
if is_mac
  cnoremap <leader>ca :LspCodeAction<CR>
endif
nnoremap <leader>f :Files<CR>
if !is_mac
  nnoremap <leader>F :call FormatBuffer()<CR>
endif
nnoremap <leader>l :LspCodeLens<CR>
nnoremap <leader>h :LspHover<CR>
nnoremap <leader>r :LspRename<CR>
nnoremap <leader>o :LspOutline<CR>
nnoremap [d :LspDiagPrevWrap<CR>
nnoremap ]d :LspDiagNextWrap<CR>
nnoremap gd :LspGotoDefinition<CR>
nnoremap gi :LspGotoImpl<CR>
if !is_mac
  nnoremap gr :LspShowReferences<CR>
endif

# Clear Highlight Search
nnoremap <silent> <Esc> <Cmd>nohlsearch<CR>

# Git gutter mappings
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

# FZF Commands
command! F Files
command! B Buffers
command! C Commits

# Auto-Commands
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
