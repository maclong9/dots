" Vim Configuration

" General Settings
syntax enable
if exists('+termguicolors')
    set termguicolors            " Enable 24-bit RGB colors
endif
colorscheme vesper               " Set custom colorscheme

" Editor behavior
set autoindent                   " Automatically indent new lines
set expandtab                    " Convert tabs to spaces
set shiftwidth=4                 " Indentation width
set tabstop=4                    " Tab display width
set softtabstop=4                " Tab key behavior
set smartindent                  " Context-aware indenting
set backspace=indent,eol,start   " Sensible backspace

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
set mouse=a                      " Enable mouse support

" Performance
set timeoutlen=500               " Faster key sequences
set updatetime=250               " Faster updates
set lazyredraw                   " Don't redraw during macros
set re=0                         " Enable new regex engine

" Create undo directory if it doesn't exist
if !isdirectory($HOME . '/.vim/undo')
    call mkdir($HOME . '/.vim/undo', 'p')
endif

" Netrw Configuration
let g:netrw_banner = 0
let g:netrw_liststyle = 3
autocmd FileType netrw setlocal nu rnu

" Key Mappings

" Clear search highlighting
nnoremap <C-[> :nohlsearch<CR>
nnoremap <leader>/ :nohlsearch<CR>

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

" Git integration - simple git command
command! -nargs=* -complete=file G !git <args>

" File type specific settings
augroup filetypes
    autocmd!
    autocmd FileType javascript,typescript,json setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType yaml,yml setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType swift setlocal shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType markdown setlocal wrap linebreak spell
augroup END

" Transparent background and cursor line styling
augroup colors
    autocmd!
    autocmd VimEnter,ColorScheme * hi LineNr guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi NonText guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi Normal guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi SignColumn guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi VertSplit guibg=NONE ctermbg=NONE
augroup END

" Auto-commands for productivity
augroup productivity
    autocmd!
    " Return to last edit position
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    " Auto-save when focus is lost
    autocmd FocusLost * silent! wa
    " Trim trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
augroup END

" Improve Shell File Tooling
augroup shell
    autocmd FileType sh syntax clear shCommandSub
augroup END
