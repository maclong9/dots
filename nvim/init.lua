-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set global variables
local globals = {
	is_posix = 1,    -- Use POSIX-compatible behavior
	mapleader = ';', -- Set the leader key to semicolon
}

-- Apply global variables
for k, v in pairs(globals) do
	vim.g[k] = v
end

-- Set Neovim options
local options = {
	breakindent = true,    -- Preserve indentation on wrapped lines
	cursorline = true,     -- Highlight the current line
	hlsearch = true,       -- Highlight search results
	incsearch = true,      -- Show search matches as you type
	showmode = false,      -- Don't show the mode in the last line
	swapfile = false,      -- Disable swap file creation
	number = true,         -- Show line numbers
	relativenumber = true, -- Show relative line numbers
	regexpengine = 0,      -- Use automatic regexp engine selection
	scrolloff = 999,       -- Keep cursor centered vertically
	shiftwidth = 2,        -- Number of spaces for each indent level
	signcolumn = 'yes',    -- Always show the sign column
	smartcase = true,      -- Case-sensitive search if query has uppercase
	smartindent = true,    -- Smart autoindenting on new lines
	tabstop = 2,           -- Number of spaces a tab counts for
}

-- Apply Neovim options
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Set up key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

local mappings = {
	-- General
	{ 'n', '<C-h>',             '<C-w>h' },                                  -- Move to left window
	{ 'n', '<C-j>',             '<C-w>j' },                                  -- Move to bottom window
	{ 'n', '<C-k>',             '<C-w>k' },                                  -- Move to top window
	{ 'n', '<C-l>',             '<C-w>l' },                                  -- Move to right window
	{ 'n', '<Esc>',             '<cmd>nohlsearch<CR>' },                     -- Clear search highlight

	-- Telescope
	{ 'n', '<leader>b',         '<cmd>Telescope buffers<CR>' },              -- Find Buffers
	{ 'n', '<leader>f',         '<cmd>Telescope find_files<CR>' },           -- Find Files
	{ 'n', '<leader>g',         '<cmd>Telescope live_grep<CR>' },            -- Find Text
	{ 'n', '<leader>s',         '<cmd>Telescope lsp_document_symbols<CR>' }, -- Find Symbols

	-- LSP Mappings
	{ 'n', '<leader>lh',        '<cmd>lua vim.lsp.buf.hover()<CR>' },        -- Show hover information
	{ 'n', '<leader>la',        '<cmd>lua vim.lsp.buf.code_action()<CR>' },  -- Show code actions
	{ 'n', '<leader>ld',        '<cmd>lua vim.lsp.buf.definition()<CR>' },   -- Go to definition
	{ 'n', '<leader>li',        '<cmd>lua vim.lsp.buf.implementation()<CR>' }, -- Go to implementation
	{ 'n', '<leader>lt',        '<cmd>lua vim.lsp.buf.type_definition()<CR>' }, -- Go to type definition
	{ 'n', '<leader>lr',        '<cmd>lua vim.lsp.buf.references()<CR>' },   -- Find references
}

-- Apply key mappings
for _, mapping in ipairs(mappings) do
	keymap(mapping[1], mapping[2], mapping[3], opts)
end

-- Setup LSP Signs with Nerd Fonts
local signs = { Error = "", Warn = "", Hint = "", Info = " " }

-- Apply signs
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Bootstrap Lazy plugin manager
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
	{ "windwp/nvim-autopairs" }, -- Autoclose brackets
	{ "williamboman/mason.nvim" },          -- LSP package manager
	{ "williamboman/mason-lspconfig.nvim" }, -- mason.nvim bridge
	{ "neovim/nvim-lspconfig" },            -- LSP configuration
	{ "hrsh7th/nvim-cmp" },                 -- Autocompletion plugin
	{ "hrsh7th/cmp-nvim-lsp" },             -- LSP source for cmp
	{ "hrsh7th/cmp-buffer" },               -- Buffer source for cmp
	{ "hrsh7th/cmp-path" },                 -- Path source for cmp
	{ "L3MON4D3/LuaSnip" },                 -- Snippet engine
	{ "saadparwaiz1/cmp_luasnip" },         -- Luasnip source for cmp
	{ "tpope/vim-commentary" },    -- Commenting support
	{ "tpope/vim-fugitive" },      -- Git integration
	{ "tpope/vim-rsi" },           -- Readline-style keys
	{ "tpope/vim-surround" },      -- Surround text objects
	{ "chrisgrieser/nvim-spider" }, -- Move through camelCase
	{ "wellle/targets.vim" },     -- Additional text objects
	{ "folke/neodev.nvim", opts = {} }, -- Neovim Lua development
  { -- Git signs
    "lewis6991/gitsigns.nvim", 
    opts = {} 
  }, 
	{                           -- Fuzzy finder
		"nvim-telescope/telescope.nvim",
		tag = '0.1.5',
		dependencies = { 'nvim-lua/plenary.nvim' },
	},
	{                                       -- Treesitter integration
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
    opts = {
      ensure_installed = "all", -- or a list of languages
    	highlight = {
    		enable = true,         -- false will disable the whole extension
    		additional_vim_regex_highlighting = false,
    	},
    	indent = {
    		enable = true
    	},
    },
	},
	{                              -- Indentation guides
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
    opts = {
      indent = { char = "│" },
    }, 
	},
	{                             -- File explorer
		'stevearc/oil.nvim',
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ -- Formatting
		'stevearc/conform.nvim',
		opts = {
			formatters_by_ft = {
				markdown = { "deno" },
				html = { "deno" },
				typescript = { "deno" },
				yaml = { "deno" },
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	}
})

-- LSP setup
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = {
		'cssls',
		'denols',
		'eslint',
		'html',
		'lua_ls',
		'marksman',
		'tailwindcss',
		'tsserver'
	},
	automatic_installation = true,
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Set up each LSP server
for _, lsp in ipairs({
	'cssls',
	'denols',
	'eslint',
	'html',
	'lua_ls',
	'marksman',
	'tailwindcss',
	'tsserver'
}) do
	lspconfig[lsp].setup {
		on_attach = function(client, bufnr)
			-- Key mappings for LSP-related commands can be added here
		end,
		capabilities = capabilities,
	}
end

-- Set up nvim-cmp for autocompletion
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
