vim9script
syntax enable
colorscheme habamax

for [var, val] in items({
        indentLine_char: '│',
        is_posix: 1,
        mapleader: ';',
})
    execute 'g:' .. var .. ' = ' .. string(val)
endfor

for option in [
        'breakindent',
        'cursorline',
        'hlsearch',
        'incsearch',
        'noshowmode',
        'noswapfile',
        'number',
        'regexpengine=0',
        'relativenumber',
        'scrolloff=999',
        'shiftwidth=2',
        'signcolumn=no',
        'smartcase',
        'smartindent',
        'tabstop=2',
]
    execute 'set ' .. option
endfor

for [key, cmd] in items({
        '<C-h>': '<C-w>h',
        '<C-j>': '<C-w>j',
        '<C-k>': '<C-w>k',
        '<C-l>': '<C-w>l',
        '<Esc>': '<cmd>nohlsearch<cr>',
        '<leader>f': '<cmd>Files<cr>',
        '<leader>b': '<cmd>Buffers<cr>',
        '<leader>g': '<cmd>Rg<cr>',
        '<leader>a': '<plug>(lsp-code-action)',
        '<leader>d': '<plug>(lsp-definition)',
        '<leader>F': '<cmd>LspDocumentFormat<cr>',
        '<leader>h': '<plug>(lsp-hover)',
        '<leader>i': '<plug>(lsp-implementation)',
        '<leader>n': '<cmd>LspNextDiagnostic<cr>',
        '<leader>p': '<cmd>LspPreviousDiagnostic<cr>',
        '<leader>r': '<plug>(lsp-references)',
        '<leader>R': '<plug>(lsp-rename)',
        '<leader>s': '<plug>(lsp-document-symbol-search)',
        '<leader>t': '<plug>(lsp-type-definition)'
})
    execute 'nnoremap ' .. key .. ' ' .. cmd
endfor

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
    Plug 'Eliot00/auto-pairs'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'mattn/emmet-vim'
    Plug 'mattn/vim-lsp-settings'
    Plug 'mityu/vim-wispath'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/vim-lsp'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-rsi'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-vinegar'
    Plug 'yggdroot/indentline'
    Plug 'github/copilot.vim'
call plug#end()
