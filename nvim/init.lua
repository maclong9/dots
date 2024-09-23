-- Basic settings
vim.cmd('syntax enable')

-- Global variables
for k, v in pairs({
  is_posix = 1,
  mapleader = ' ',
}) do
  vim.g[k] = v
end

-- Options
for k, v in pairs({
  breakindent = true,
  cursorline = true,
  hlsearch = true,
  incsearch = true,
  number = true,
  regexpengine = 0,
  relativenumber = true,
  scrolloff = 999,
  shiftwidth = 2,
  showmode = false,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  swapfile = false,
  tabstop = 2,
}) do
  vim.opt[k] = v
end

-- Keymap utility
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Keymaps
map('n', '<C-h>', '<cmd>wincmd h<cr>')
map('n', '<C-j>', '<cmd>wincmd j<cr>')
map('n', '<C-k>', '<cmd>wincmd k<cr>')
map('n', '<C-l>', '<cmd>wincmd l<cr>')
map('n', '<Esc>', '<cmd>nohlsearch<cr>')
map('n', '<leader>C', '<cmd>Telescope git_commits<cr>')
map('n', '<leader>F', '<cmd>lua vim.lsp.buf.formatting()<cr>')
map('n', '<leader>R', '<cmd>lua vim.lsp.buf.rename()<cr>')
map('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<cr>')
map('n', '<leader>b', '<cmd>Telescope buffers<cr>')
map('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>')
map('n', '<leader>e', '<cmd>Oil<cr>')
map('n', '<leader>f', '<cmd>Telescope find_files<cr>')
map('n', '<leader>g', '<cmd>Telescope live_grep<cr>')
map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>')
map('n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<cr>')
map('n', '<leader>n', '<cmd>lua vim.diagnostic.goto_next()<cr>')
map('n', '<leader>p', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
map('n', '<leader>r', '<cmd>Telescope lsp_references<cr>')
map('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<cr>')
map('n', '<leader>t', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

-- Plugin manager install
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin list
require("lazy").setup({
  { 'windwp/nvim-autopairs', opts = {} },
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'mattn/emmet-vim' },
  { 'sheerun/vim-polyglot' },
  { 'numToStr/Comment.nvim', opts = {} },
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-rsi' },
  { 'tpope/vim-surround' },
  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        show_hidden = true,
      }
    },
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
  { 
    'arzg/vim-colors-xcode',
    config = function()
  	  vim.cmd('colorscheme xcode')
  	  vim.cmd('highlight Normal guibg=NONE ctermbg=NONE')
  	  vim.cmd('highlight StatusLine guibg=NONE ctermbg=NONE guifg=#fefefe ctermfg=white')
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  },
  { 
    'neovim/nvim-lspconfig',
    config = function()
      local nvim_lsp = require('lspconfig')
      
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      end
      
      local lsp_flags = {
        debounce_text_changes = 150,
      }
      
      nvim_lsp.sourcekit.setup{
          on_attach = on_attach,
          flags = lsp_flags,
      }
      
      nvim_lsp.denols.setup{
          on_attach = on_attach,
          flags = lsp_flags,
          root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
      }
      
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = false,
      })
    end,
  },
})
