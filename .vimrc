vim9script
syntax enable
&t_EI = "\e[2 q"
&t_SI = "\e[6 q"
colorscheme habamax
highlight Normal guibg=NONE ctermbg=NONE

for [var, val] in items({
  is_posix: 1,
  mapleader: ' ',
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
  'signcolumn=yes',
  'smartcase',
  'smartindent',
]
  execute 'set ' .. option
endfor

for [key, cmd] in items({
  '<C-h>': '<cmd>wincmd h<cr>',
  '<C-j>': '<cmd>wincmd j<cr>',
  '<C-k>': '<cmd>wincmd k<cr>',
  '<C-l>': '<cmd>wincmd l<cr>',
  '<Esc>': '<cmd>nohlsearch<cr>',
  '<leader>C': '<cmd>Commits<cr>',
  '<leader>D': '<cmd>GF?<cr>',
  '<leader>F': '<cmd>LspFormat<cr>',
  '<leader>R': '<cmd>LspRename<cr>',
  '<leader>a': '<cmd>LspCodeAction<cr>',
  '<leader>b': '<cmd>Buffers<cr>',
  '<leader>d': '<cmd>LspGotoDefinition<cr>',
  '<leader>e': '<cmd>Explore<cr>',
  '<leader>f': '<cmd>Files<cr>',
  '<leader>g': '<cmd>Rg<cr>',
  '<leader>h': '<cmd>LspHover<cr>',
  '<leader>i': '<cmd>LspGotoImpl<cr>',
  '<leader>n': '<cmd>LspDiag nextWrap<cr>',
  '<leader>p': '<cmd>LspDiag prevWrap<cr>',
  '<leader>r': '<cmd>LspPeekReferences<cr>',
  '<leader>s': '<cmd>LspSymbolSearch<cr>',
  '<leader>t': '<cmd>LspGotoTypeDef<cr>'
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
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-surround'
  Plug 'yegappan/lsp'
call plug#end()


var lspOptions = { 
  autoHighlightDiags: v:true,
  outlineOnRight: v:true,
  usePopupInCodeAction: v:true,
  ignoreMissingServer: v:true
}

var lspServers = [
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

autocmd User LspSetup call LspOptionsSet(lspOptions)
autocmd User LspSetup call LspAddServer(lspServers)
