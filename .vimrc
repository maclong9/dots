vim9script
syntax enable
&t_EI = "\e[2 q"
&t_SI = "\e[6 q"

for [k, v] in items({
  is_posix: 1,
  mapleader: ' ',
  netrw_banner: 0,
})
  execute $'g:{k} = {string(v)}'
endfor

for o in [
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
  'shiftwidth=3',
  'signcolumn=no',
  'smartcase',
  'smartindent',
  'tabstop=2',
  'wildmenu'
]
  execute $'set {o}'
endfor

for [k, v] in items({
  '<C-h>': '<cmd>wincmd h<cr>',
  '<C-j>': '<cmd>wincmd j<cr>',
  '<C-k>': '<cmd>wincmd k<cr>',
  '<C-l>': '<cmd>wincmd l<cr>',
  '<Esc>': '<cmd>nohlsearch<cr>'
})
  execute $'nnoremap {k} {v}'
endfor

for [k, v] in items({
	'(': '()<Left>',
	'{': '{}<Left>',
	'[': '[]<Left>',
	'"': '""<Left>',
	"'": "''<Left>",
  '<C-a>': '<Home>',
	'<C-e>': '<End>',
	'<C-b>': '<Left>',
	'<C-f>': '<Right>',
	'<C-d>': '<Del>',
	'<C-h>': '<BS>'
})
	execute $'inoremap {k} {v}'
endfor

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'arzg/vim-colors-xcode'
  Plug 'mattn/emmet-vim'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'wellle/targets.vim'
call plug#end()

colorscheme xcode

for [k, c] in items({
  'ColorScheme': ['EndOfBuffer', 'Normal', 'NonText'],
  'FileType': ['netrw setlocal number relativenumber'],
  'BufWritePre': ['LspFormat'],
})
  for v in c
    if k == 'BufWritePre'
      execute $'autocmd {k} * {v}'
    elseif k == 'ColorScheme'
      execute $'autocmd {k} * hi {v} guibg=NONE ctermbg=NONE'
      execute $'autocmd {k} {v}'
    endif
  endfor
endfor
