vim9script

syntax enable
colorscheme xcode

var globals = {
  is_posix: 1,
  mapleader: ' ',
  netrw_banner: 0,
}

var options = [
  'breakindent', 'cursorline', 'hlsearch', 'incsearch', 'noswapfile',
	'number', 'relativenumber', 'scrolloff=999', 'shiftwidth=2',
  'smartcase', 'smartindent', 'tabstop=2', 'wildmenu'
]

var normal_mappings = {
  '<C-h>': '<cmd>wincmd h<cr>',
  '<C-j>': '<cmd>wincmd j<cr>',
  '<C-k>': '<cmd>wincmd k<cr>',
  '<C-l>': '<cmd>wincmd l<cr>',
  '<Esc>': '<cmd>nohlsearch<cr>'
}

var insert_mappings = {
  '<C-a>': '<Home>',
  '<C-e>': '<End>',
  '<C-b>': '<Left>',
  '<C-f>': '<Right>',
  '<C-d>': '<Del>',
  '<C-h>': '<BS>'
}

var auto_commands = {
  'ColorScheme': ['EndOfBuffer', 'Normal', 'NonText'],
  'FileType': ['netrw setlocal number relativenumber'],
}

var text_objects = ['()', '{}', '[]', '<>', "''", '""', '``']

command -nargs=* G echo system('git ' .. <q-args>)

for [k, v] in items(globals)
  execute $'g:{k} = {string(v)}'
endfor

for o in options
  execute $'set {o}'
endfor

for [k, v] in items(normal_mappings)
  execute $'nnoremap {k} {v}'
endfor

for obj in text_objects
  execute $'onoremap in{obj[0]} :<c-u>normal! f{obj[0]}vi{obj[0]}<cr>'
  execute $'onoremap an{obj[0]} :<c-u>normal! f{obj[0]}va{obj[0]}<cr>'
  execute $'onoremap il{obj[0]} :<c-u>normal! F{obj[1]}vi{obj[0]}<cr>'
  execute $'onoremap al{obj[0]} :<c-u>normal! F{obj[1]}va{obj[0]}<cr>'
  execute $'inoremap {obj[0]} {obj}<Left>'
endfor

for [k, v] in items(insert_mappings)
  execute $'inoremap {k} {v}'
endfor

for [k, v] in items(auto_commands)
  for w in v
    if k == 'ColorScheme'
      execute $'autocmd {k} * hi {w} guibg=NONE ctermbg=NONE'
    else
      execute $'autocmd {k} {w}'
    endif
  endfor
endfor
