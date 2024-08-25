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
	'conceallevel=0',
  'cursorline',
  'hlsearch',
  'incsearch',
  'noswapfile',
  'number',
  'regexpengine=0',
  'relativenumber',
  'scrolloff=999',
  'shiftwidth=2',
  'signcolumn=yes',
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
  '<leader>e': '<cmd>Explore<cr>',
  '<leader>b': '<cmd>Buffers<cr>',
  '<leader>f': '<cmd>Files<cr>',
  '<leader>g': '<cmd>Rg<cr>',
})
  execute 'nnoremap ' .. key .. ' ' .. cmd
endfor

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'Eliot00/auto-pairs'
  Plug 'github/copilot.vim'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-surround'
  Plug 'yggdroot/indentline'
  Plug 'airblade/vim-gitgutter'
  Plug 'wellle/targets.vim'
	Plug 'junegunn/goyo.vim'
	Plug 'junegunn/limelight.vim'
call plug#end()

autocmd VimEnter * Goyo | Limelight
