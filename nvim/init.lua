-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set colorscheme
vim.cmd('colorscheme vesper')

-- Set cursor shape
vim.opt.guicursor = {
  'n-v-c:block-Cursor/lCursor-blinkon0',
  'i-ci:ver25-Cursor/lCursor',
  'r-cr:hor20-Cursor/lCursor'
}

-- Set global variables
local globals = {
  indentLine_char = '│',
  is_posix = 1,
  mapleader = ';',
}

for k, v in pairs(globals) do
  vim.g[k] = v
end

-- Set various options
local options = {
  breakindent = true,
  cursorline = true,
  hlsearch = true,
  incsearch = true,
  showmode = false,
  swapfile = false,
  number = true,
  relativenumber = true,
  regexpengine = 0,
  scrolloff = 999,
  shiftwidth = 2,
  signcolumn = 'yes',
  smartcase = true,
  smartindent = true,
  tabstop = 2,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

local mappings = {
  {'n', '<C-h>', '<C-w>h'},
  {'n', '<C-j>', '<C-w>j'},
  {'n', '<C-k>', '<C-w>k'},
  {'n', '<C-l>', '<C-w>l'},
  {'n', '<Esc>', '<cmd>nohlsearch<CR>'},
  {'n', '<leader>e', '<cmd>Oil<CR>'},
  {'n', '<leader>b', '<cmd>Telescope buffers<CR>'},
  {'n', '<leader>f', '<cmd>Telescope find_files<CR>'},
  {'n', '<leader>g', '<cmd>Telescope live_grep<CR>'},
  {'n', '<leader>s', '<cmd>Telescope lsp_document_symbols<CR>'},
}

for _, mapping in ipairs(mappings) do
  keymap(mapping[1], mapping[2], mapping[3], opts)
end

-- Bootstrap Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specification
require("lazy").setup({
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "github/copilot.vim" },
  { "datsfilipe/vesper.nvim" },
  { "nvim-telescope/telescope.nvim", tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { "mattn/emmet-vim" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "tpope/vim-commentary" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-rsi" },
  { "tpope/vim-surround" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "lewis6991/gitsigns.nvim" },
  { "wellle/targets.vim" },
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  }
})

-- LSP setup
require('mason').setup()
require('mason-lspconfig').setup()

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Add the LSP servers you want to use
local servers = { 'deno', 'tsserver', 'rust_analyzer' }

-- LSP keymaps
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

-- Setup gitsigns
require('gitsigns').setup()

-- Setup indent-blankline
require('ibl').setup()

-- Setup Telescope
require('telescope').setup{}

-- Setup Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
}
