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
  'nocompatible',
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
  execute $'set {o}'
endfor

for o in ['EndOfBuffer', 'Normal', 'NonText']
  execute $'autocmd ColorScheme * hi {o} guibg=NONE ctermbg=NONE'
endfor

for [k, v] in items({
  '<C-h>': '<cmd>wincmd h<cr>',
  '<C-j>': '<cmd>wincmd j<cr>',
  '<C-k>': '<cmd>wincmd k<cr>',
  '<C-l>': '<cmd>wincmd l<cr>',
  '<Esc>': '<cmd>nohlsearch<cr>',
  '<leader>b': '<cmd>Buffers<cr>',
  '<leader>C': '<cmd>Commits<cr>',
  '<leader>D': '<cmd>GF?<cr>',
  '<leader>e': '<cmd>Explore<cr>',
  '<leader>f': '<cmd>Files<cr>',
  '<leader>F': '<cmd>LspFormat<cr>',
  '<leader>g': '<cmd>Rg<cr>',
  '<leader>R': '<cmd>LspRename<cr>',
  '<leader>a': '<cmd>LspCodeAction<cr>',
  '<leader>d': '<cmd>LspGotoDefinition<cr>',
  '<leader>h': '<cmd>LspHover<cr>',
  '<leader>i': '<cmd>LspGotoImpl<cr>',
  '<leader>n': '<cmd>LspDiag nextWrap<cr>',
  '<leader>p': '<cmd>LspDiag prevWrap<cr>',
  '<leader>r': '<cmd>LspPeekReferences<cr>',
  '<leader>s': '<cmd>LspSymbolSearch<cr>',
  '<leader>t': '<cmd>LspGotoTypeDef<cr>'
})
  execute $'nnoremap {k} {v}'
endfor

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  Plug 'arzg/vim-colors-xcode'
  Plug 'Eliot00/auto-pairs'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'mattn/emmet-vim'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-surround'
  Plug 'wellle/targets.vim'
  Plug 'yegappan/lsp'
call plug#end()

colorscheme xcode

var lspConfiguration = {
  options: {
    autoHighlightDiags: true,
    diagVirtualTextAlign: 'after',
    highlightDiagInline: true,
    ignoreMissingServer: true,
    outlineOnRight: true,
    showDiagWithVirtualText: true,
    usePopupInCodeAction: true,
  },
  servers: [
    {
      name: 'clang',
      filetype: ['c'],
      path: '/usr/bin/clangd',
    },
    {
      name: 'swift',
      filetype: ['swift'],
      path: '/usr/bin/sourcekit-lsp',
    },
    {
      name: 'typescript',
      filetype: ['typescript', 'typescriptreact', 'javascript'],
      path: 'deno',
      args: ['lsp'],
    },
  ]
}

for [k, v] in items({
  'ColorScheme': ['EndOfBuffer', 'Normal', 'NonText'],
  'FileType': ['netrw setlocal number relativenumber'],
  'User': [ 'LspOptionsSet(lspConfiguration.options)', 'LspAddServer(lspConfiguration.servers)'],
  'BufWritePre': ['LspFormat'],
})
  for w in v
    if k == 'BufWritePre'
      execute $'autocmd {k} * {w}'
    elseif k == 'ColorScheme'
      execute $'autocmd {k} hi {w} guibg=NONE ctermbg=NONE'
    elseif k == 'User'
      execute $'autocmd {k} LspSetup call {w}'
    else
      execute $'autocmd {k} {w}'
    endif
  endfor
endfor
