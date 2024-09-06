vim9script
syntax enable
colorscheme habamax
&t_EI = "\e[2 q"
&t_SI = "\e[6 q"

for [var, val] in items({
  indentLine_char: '│',
  is_posix: 1,
  mapleader: ';',
  gitgutter_sign_added: '│',
  gitgutter_sign_modified: '│',
  gitgutter_sign_removed: '│',

})
  execute 'g:' .. var .. ' = ' .. string(val)
endfor

for [group, colors] in items({
  'GitGutterAdd':    ['#00ff00', 2],
  'GitGutterChange': ['#ffff00', 3],
  'GitGutterDelete': ['#d75f5f', 1],
})
  execute 'highlight ' .. group .. ' guifg=' .. colors[0] .. ' ctermfg=' .. colors[1]
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
  Plug 'airblade/vim-gitgutter'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'mattn/emmet-vim'
  Plug 'mityu/vim-wispath'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-surround'
  Plug 'wellle/targets.vim'
  Plug 'yegappan/lsp'
  Plug 'yggdroot/indentline'
call plug#end()

autocmd User LspSetup call LspOptionsSet({autoHighlightDiags: v:true, outlineOnRight: v:true, usePopupInCodeAction: v:true, ignoreMissingServer: v:true})
var lspServers = [
    {
        name: 'clang',
        filetype: ['c', 'cpp'],
        path: '/usr/bin/clangd',
        args: ['--background-index'],
        
    },
    {
      name: 'swift',
      filetype: ['swift'],
      path: 'sourcekit-lsp',
    },
    {
      name: 'typescript',
      filetype: ['typescript', 'typescriptreact'],
      path: 'deno',
      args: ['lsp'],
    },
    {
      name: 'ziglang',
      filetype: ['zig'],
      path: '/usr/local/bin/zls'
    },
]
autocmd User LspSetup call LspAddServer(lspServers)

