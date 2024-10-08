vim9script
syntax enable
colorscheme xcode

# use `:G` to invoke `git` commands
command -nargs=* G echo system('git ' .. <q-args>)

# global variables
for [k, v] in items({ is_posix: 1, mapleader: ' ', netrw_banner: 0 })
  execute $'g:{k} = {string(v)}'
endfor

# set options
for o in [
  'breakindent', 'cursorline', 'hlsearch', 'incsearch', 'noswapfile', 'number', 'relativenumber', 
	'scrolloff=999', 'shiftwidth=2', 'smartcase', 'smartindent', 'tabstop=2', 'wildmenu'
]
  execute $'set {o}'
endfor

# autocommand for transparent background and line numbers in file explorer
for g in ['EndOfBuffer', 'Normal', 'NonText']
  execute $'autocmd ColorScheme * hi {g} guibg=NONE ctermbg=NONE'
endfor
autocmd FileType netrw setlocal number relativenumber

# normal mode mappings
for [k, v] in items({
  '<C-h>': '<cmd>wincmd h<cr>',
  '<C-j>': '<cmd>wincmd j<cr>',
  '<C-k>': '<cmd>wincmd k<cr>',
  '<C-l>': '<cmd>wincmd l<cr>',
  '<Esc>': '<cmd>nohlsearch<cr>',
  '<leader>e': '<cmd>Explore<cr>'
})
  execute $'nnoremap {k} {v}'
endfor

# insert mode mappings
for [k, v] in items({
  '<C-a>': '<Home>',
  '<C-e>': '<End>',
  '<C-b>': '<Left>',
  '<C-f>': '<Right>',
  '<C-d>': '<Del>',
  '<C-h>': '<BS>'
})
  execute $'inoremap {k} {v}'
endfor
