vim9script
syntax enable

# clone `xcode` colorscheme if missing then set
if !filereadable(expand('~/.vim/colors/xcode.vim'))
  silent !mkdir -p ~/.vim/colors
  silent !cp ~/.config/xcode.vim ~/.vim/colors
endif
colorscheme xcode

# use `:G` to invoke `git` commands
command -nargs=* G echo system('git ' .. <q-args>)

# global variables
for [k, v] in items({ is_posix: 1, netrw_banner: 0 })
  execute $'g:{k} = {string(v)}'
endfor

# set options
for o in [
  'breakindent', 'cursorline', 'hlsearch', 'incsearch', 'noswapfile', 
	'number', 'relativenumber', 'regexpengine=0', 'scrolloff=999',
	'shiftwidth=2', 'smartcase', 'smartindent', 'tabstop=2', 'wildmenu'
]
  execute $'set {o}'
endfor

# transparent background and line numbers in file explorer
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
})
  execute $'nnoremap {k} {v}'
endfor

# command mode mappings
for [k, v] in items({
	'<C-a>': '<Home>',
	'<C-e>': '<End>',
	'<C-b>': '<Left>',
	'<C-f>': '<Right>',
	'<C-d>': '<Del>',
	'<M-b>': '<Shift-Left>', # TODO: Figure out why the Meta based keys just cancel command mode
  '<M-f>': '<Shift-Right>'
})
	execute $'cnoremap {k} {v}'
endfor
