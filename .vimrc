" Vim Configuration

" Basic Configuration
set autoindent            " Automatically indent new lines to match the previous line
set expandtab             " Convert tabs to spaces when inserting
set hlsearch              " Highlight all matches when searching
set ignorecase            " Ignore case when searching
set incsearch             " Show search matches as you type
set laststatus=2          " Always show the status line
set noswapfile            " Disable creation of swap files
set number                " Display line numbers on the left side
set relativenumber        " Show relative line numbers (distance from current line)
set scrolloff=999         " Keep cursor away from top/bottom edges
set shiftwidth=4          " Number of spaces used for each step of autoindent
set signcolumn=yes        " Ensure signcolumn is always visible
set smartcase             " Override ignorecase if search contains uppercase letters
set splitright            " Open new vertical splits to the right
set tabstop=4             " Number of spaces that a tab character represents
set timeoutlen=500        " Time to wait for mapped sequence to complete
set updatetime=250        " Time before swap file is written and CursorHold fires
colorscheme habamax       " Set colorscheme

" Netrw Configuration
autocmd FileType netrw setlocal nu rnu
let g:netrw_banner = 0
let g:netrw_liststyle = 3

" Transparent Background
augroup colors
    autocmd!
    autocmd VimEnter,ColorScheme * hi Normal guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi NonText guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi LineNr guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi SignColumn guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi VertSplit guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi StatusLine guibg=NONE ctermbg=NONE
    autocmd VimEnter,ColorScheme * hi StatusLineNC guibg=NONE ctermbg=NONE
augroup END
