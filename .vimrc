" Vim Configuration - A symphony of keystrokes and code

" General Settings
syntax enable
if exists('+termguicolors')
    set termguicolors            " Enable 24-bit RGB colors
endif
colorscheme vesper               " Set custom colorscheme
let g:vesper_transparency = 1

" Editor behavior
set autoindent                   " Automatically indent new lines
set shiftwidth=4                 " Indentation width
set tabstop=4                    " Tab display width
set softtabstop=4                " Tab key behavior
set smartindent                  " Context-aware indenting
set backspace=indent,eol,start   " Sensible backspace
set formatoptions+=j             " Remove comment leaders when joining lines

" Visual enhancements
set number                       " Line numbers
set relativenumber               " Relative line numbers
set cursorline                   " Highlight current line
set showmatch                    " Highlight matching brackets
set signcolumn=yes               " Always show sign column
set scrolloff=8                  " Keep cursor away from edges
set sidescrolloff=8              " Horizontal scroll offset
set wrap                         " Wrap long lines
set linebreak                    " Break at word boundaries

" Search and navigation
set hlsearch                     " Highlight search results
set incsearch                    " Incremental search
set ignorecase                   " Case-insensitive search
set smartcase                    " Case-sensitive if uppercase present
set gdefault                     " Global replace by default
set shortmess-=S                 " Show search count

" File handling
set undofile                     " Persistent undo
set undodir=$HOME/.vim/undo      " Undo directory
set autoread                     " Auto-reload changed files

" Interface
set laststatus=2                 " Always show status line
set wildmenu                     " Enhanced command completion
set wildmode=longest:full,full   " Improve tab completion results
set splitright                   " Vertical splits to the right
set splitbelow                   " Horizontal splits below

" Performance
set timeoutlen=300               " Faster key sequences
set updatetime=250               " Faster updates
set lazyredraw                   " Don't redraw during macros
set re=0                         " Enable new regex engine

set backup
set backupdir=$HOME/.vim/backup//
set directory=$HOME/.vim/swap//
set undodir=$HOME/.vim/undo//

" Create all directories
for dir in ['backup', 'swap', 'undo']
    let path = $HOME . '/.vim/' . dir
    if !isdirectory(path)
        call mkdir(path, 'p', 0700)
    endif
endfor

" Netrw Configuration
let g:netrw_banner = 0
let g:netrw_liststyle = 3
autocmd FileType netrw setlocal nu rnu

" Auto-install LSP plugin if not found
if !isdirectory(expand('~/.vim/pack/plugins/start/lsp'))
    echo "Installing LSP plugin..."
    let lsp_pack_dir = expand('~/.vim/pack/plugins/start')
    if !isdirectory(lsp_pack_dir)
        call mkdir(lsp_pack_dir, 'p')
    endif
    let git_cmd = 'git clone https://github.com/yegappan/lsp.git ' . shellescape(lsp_pack_dir . '/lsp')
    let result = system(git_cmd)
    if v:shell_error == 0
        echo "LSP plugin installed successfully. Please restart Vim."
    else
        echoerr "Failed to install LSP plugin: " . result
    endif
endif

" LSP Configuration
silent! packadd lsp

" LSP server configurations - each language server a digital oracle
let lspServers = [
    \ {
    \     'name': 'sourcekit-lsp',
    \     'filetype': ['swift'],
    \     'path': 'sourcekit-lsp',
    \     'args': [],
    \     'syncInit': v:true
    \ },
    \ {
    \     'name': 'typescript-language-server',
    \     'filetype': ['javascript', 'typescript', 'javascriptreact', 'typescriptreact'],
    \     'path': 'typescript-language-server',
    \     'args': ['--stdio'],
    \     'rootSearch': ['package.json', 'tsconfig.json', 'jsconfig.json', '.git']
    \ },
    \ {
    \     'name': 'tailwindcss-language-server',
    \     'filetype': ['html', 'css', 'scss', 'sass', 'less', 'vue', 'svelte', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact'],
    \     'path': 'tailwindcss-language-server',
    \     'args': ['--stdio'],
    \     'rootSearch': ['tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'tailwind.config.mjs']
    \ },
    \ {
    \     'name': 'marksman',
    \     'filetype': ['markdown'],
    \     'path': 'marksman',
    \     'args': ['server'],
    \     'rootSearch': ['.marksman.toml', '.git']
    \ },
    \ {
    \     'name': 'vscode-json-language-server',
    \     'filetype': ['json', 'jsonc'],
    \     'path': 'vscode-json-language-server',
    \     'args': ['--stdio'],
    \     'initializationOptions': {
    \         'provideFormatter': v:true
    \     }
    \ },
    \ {
    \     'name': 'vscode-html-language-server',
    \     'filetype': ['html'],
    \     'path': 'vscode-html-language-server',
    \     'args': ['--stdio'],
    \     'initializationOptions': {
    \         'provideFormatter': v:true,
    \         'embeddedLanguages': {
    \             'css': v:true,
    \             'javascript': v:true
    \         }
    \     }
    \ },
    \ {
    \     'name': 'vscode-css-language-server',
    \     'filetype': ['css', 'scss', 'sass', 'less'],
    \     'path': 'vscode-css-language-server',
    \     'args': ['--stdio'],
    \     'initializationOptions': {
    \         'provideFormatter': v:true
    \     }
    \ },
    \ {
    \     'name': 'vscode-eslint-language-server',
    \     'filetype': ['javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue'],
    \     'path': 'vscode-eslint-language-server',
    \     'args': ['--stdio'],
    \     'rootSearch': ['.eslintrc.js', '.eslintrc.json', '.eslintrc.yml', '.eslintrc.yaml', 'package.json'],
    \     'workspaceConfig': {
    \         'eslint': {
    \             'validate': ['javascript', 'typescript', 'javascriptreact', 'typescriptreact'],
    \             'run': 'onType',
    \             'autoFixOnSave': v:true
    \         }
    \     }
    \ },
    \ {
    \     'name': 'yaml-language-server',
    \     'filetype': ['yaml', 'yml'],
    \     'path': 'yaml-language-server',
    \     'args': ['--stdio'],
    \     'initializationOptions': {
    \         'yaml': {
    \             'validate': v:true,
    \             'hover': v:true,
    \             'completion': v:true,
    \             'format': {'enable': v:true}
    \         }
    \     }
    \ }
    \ ]

" Initialize LSP servers
call LspAddServer(lspServers)

" LSP Options - fine-tuning the symphony
let lspOptions = {
    \ 'autoHighlight': v:true,
    \ 'autoHighlightDiags': v:true,
    \ 'autoPopulateDiags': v:true,
    \ 'completionMatcher': 'fuzzy',
    \ 'completionMatcherValue': 1,
    \ 'diagSignErrorText': '✗',
    \ 'diagSignHintText': '💡',
    \ 'diagSignInfoText': 'ℹ',
    \ 'diagSignWarningText': '⚠',
    \ 'highlightDiagInline': v:true,
    \ 'keepFocusInDiags': v:true,
    \ 'keepFocusInReferences': v:true,
    \ 'completionTextEdit': v:true,
    \ 'diagVirtualTextAlign': 'above',
    \ 'diagVirtualTextWrap': 'default',
    \ 'outlineOnRight': v:false,
    \ 'outlineWinSize': 20,
    \ 'semanticHighlight': v:true,
    \ 'showDiagInBalloon': v:true,
    \ 'showDiagInPopup': v:true,
    \ 'showDiagWithSign': v:true,
    \ 'showDiagWithVirtualText': v:false,
    \ 'showInlayHints': v:false,
    \ 'showSignature': v:true,
    \ 'snippetSupport': v:false,
    \ 'ultisnipsSupport': v:false,
    \ 'useBufferCompletion': v:false,
    \ 'usePopupInCodeAction': v:false,
    \ 'useQuickfixForLocations': v:false,
    \ 'vsnipSupport': v:false,
    \ 'bufferCompletionTimeout': 100,
    \ 'customCompletionKinds': v:false
    \ }

call LspOptionsSet(lspOptions)

" Prettier integration
augroup prettier_format
    autocmd!
    autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.json,*.css,*.scss,*.html,*.md,*.yaml,*.yml call s:prettier_format()
augroup END

function! s:prettier_format() abort
    if executable('prettier')
        let l:save_cursor = getcurpos()
        silent! %!prettier --stdin-filepath=%
        call setpos('.', l:save_cursor)
    endif
endfunction

" Key Mappings

" Clear search highlighting
nnoremap <C-[> :nohlsearch<CR>

" Better command line editing
cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" LSP Mappings
augroup lsp_keymaps
    autocmd!
    autocmd User LspAttached call s:lsp_buffer_mappings()
augroup END

function! s:lsp_buffer_mappings() abort
    " Navigation - traverse the codebase like wind through digital trees
    nnoremap <buffer> gd <Cmd>LspGoToDefinition<CR>
    nnoremap <buffer> gD <Cmd>LspGoToDeclaration<CR>
    nnoremap <buffer> gr <Cmd>LspShowReferences<CR>
    nnoremap <buffer> gi <Cmd>LspGoToImplementation<CR>
    nnoremap <buffer> gt <Cmd>LspGoToTypeDef<CR>

    " Information - whispers of wisdom from the language server
    nnoremap <buffer> K <Cmd>LspHover<CR>
    nnoremap <buffer> <C-k> <Cmd>LspShowSignature<CR>
    nnoremap <buffer> <leader>rn <Cmd>LspRename<CR>

    " Diagnostics - healing the wounds in your code
    nnoremap <buffer> ]d <Cmd>LspDiagNext<CR>
    nnoremap <buffer> [d <Cmd>LspDiagPrev<CR>
    nnoremap <buffer> <leader>d <Cmd>LspDiagShow<CR>

    " Code actions - the power to transform
    nnoremap <buffer> <leader>ca <Cmd>LspCodeAction<CR>
    vnoremap <buffer> <leader>ca <Cmd>LspCodeAction<CR>

    " Formatting - beauty in structure
    nnoremap <buffer> <leader>f <Cmd>LspFormat<CR>
    vnoremap <buffer> <leader>f <Cmd>LspFormat<CR>

    " Symbols - the architecture of understanding
    nnoremap <buffer> <leader>s <Cmd>LspDocumentSymbol<CR>
    nnoremap <buffer> <leader>S <Cmd>LspWorkspaceSymbol<CR>

    " Outline - the skeleton of structure
    nnoremap <buffer> <leader>o <Cmd>LspOutline<CR>
endfunction

" Git integration
command! -nargs=* -complete=file G !git <args>

" Auto-commands for productivity
augroup productivity
    autocmd!

    " Return to last edit position when opening a file
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \     exe "normal! g'\"" |
        \ endif

    " Auto-save when focus is lost
    autocmd FocusLost * silent! wa

    " Trim trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e

    " Clear commandline after delay
    autocmd CursorHold * echo ""
augroup END

" Improve Shell File Tooling
augroup shell
    autocmd FileType sh syntax clear shCommandSub
augroup END
