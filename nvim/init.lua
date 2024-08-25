-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set global variables
for k, v in pairs({
	is_posix = 1,   -- Use POSIX-compatible behavior
	mapleader = ' ', -- Set the leader key
}) do
	vim.g[k] = v
end

-- Set Neovim options
for k, v in pairs({
	breakindent = true,   -- Preserve indentation on wrapped lines
	cursorline = true,    -- Highlight the current line
	hlsearch = true,      -- Highlight search results
	incsearch = true,     -- Show search matches as you type
	laststatus = 3,       -- Always show only one status line
	number = true,        -- Show line numbers
	relativenumber = true, -- Show relative line numbers
	scrolloff = 999,      -- Keep cursor centered vertically
	shiftwidth = 2,       -- Number of spaces for each indent level
	signcolumn = 'yes',   -- Always show the sign column
	smartcase = true,     -- Case-sensitive search if query has uppercase
	smartindent = true,   -- Smart autoindenting on new lines
	swapfile = false,     -- Disable swap file creation
	tabstop = 2,          -- Number of spaces a tab counts for
}) do
	vim.opt[k] = v
end

-- Set key mappings
for _, mapping in ipairs({
	-- General
	{ 'n', '<C-h>',      '<C-w>h' },             -- Move to left window
	{ 'n', '<C-j>',      '<C-w>j' },             -- Move to bottom window
	{ 'n', '<C-k>',      '<C-w>k' },             -- Move to top window
	{ 'n', '<C-l>',      '<C-w>l' },             -- Move to right window
	{ 'n', '<Esc>',      '<cmd>nohlsearch<CR>' }, -- Clear search highlight
	{ 'n', '<leader>e',  '<cmd>Oil<CR>' },       -- Open file explorer

	-- LSP
	{ 'n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>' },    -- Show code actions
	{ 'n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>' },     -- Go to definition
	{ 'n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>' },          -- Show hover information
	{ 'n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>' }, -- Go to implementation
	{ 'n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>' },     -- Find references
	{ 'n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>' }, -- Go to type definition

	-- Telescope
	{ "n", "<leader>u",  "<cmd>Telescope undo<cr>" },                -- Undo history
	{ 'n', '<leader>b',  '<cmd>Telescope buffers<CR>' },             -- Find Buffers
	{ 'n', '<leader>f',  '<cmd>Telescope find_files<CR>' },          -- Find Files
	{ 'n', '<leader>g',  '<cmd>Telescope live_grep<CR>' },           -- Find Text
	{ 'n', '<leader>s',  '<cmd>Telescope lsp_document_symbols<CR>' }, -- Find Symbols

	-- Yanky
	{ 'n', '<c-n>',      '<Plug>(YankyNextEntry)' },    -- Next yank
	{ 'n', '<c-p>',      '<Plug>(YankyPreviousEntry)' }, -- Previous yank
	{ 'n', 'P',          '<Plug>(YankyPutBefore)' },    -- Paste before
	{ 'n', 'gP',         '<Plug>(YankyGPutBefore)' },   -- Paste before and move cursor
	{ 'n', 'gp',         '<Plug>(YankyGPutAfter)' },    -- Paste after and move cursor
	{ 'n', 'p',          '<Plug>(YankyPutAfter)' },     -- Paste after
}) do
	vim.keymap.set(mapping[1], mapping[2], mapping[3], { noremap = true, silent = true })
end

-- Set LSP signs
for type, icon in pairs({
	Error = "",
	Hint = "",
	Info = " ",
	Warn = "",
}) do
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
	{ "neovim/nvim-lspconfig" },                                  -- LSP configuration
	{ "williamboman/mason-lspconfig.nvim" },                      -- mason.nvim bridge
	{ "williamboman/mason.nvim" },                                -- LSP package manager
	{ "folke/neodev.nvim",                opts = {} },            -- Neovim Lua development
	{ "kylechui/nvim-surround",           opts = {} },            -- Edit surrounding pairs
	{ "L3MON4D3/LuaSnip",                 event = "InsertEnter" }, -- Snippet engine
	{ "hrsh7th/cmp-buffer",               event = "InsertEnter" }, -- Buffer source for cmp
	{ "hrsh7th/cmp-nvim-lsp",             event = "InsertEnter" }, -- LSP source for cmp
	{ "hrsh7th/cmp-path",                 event = "InsertEnter" }, -- Path source for cmp
	{ "hrsh7th/nvim-cmp",                 event = "InsertEnter" }, -- Autocompletion plugin
	{ "saadparwaiz1/cmp_luasnip",         event = "InsertEnter" }, -- Luasnip source for cmp
	{ "windwp/nvim-autopairs",            event = "InsertEnter" }, -- Autoclose brackets
	{ "chrisgrieser/nvim-spider",         event = "VeryLazy" },   -- Move through camelCase
	{ "github/copilot.vim",               event = "VeryLazy" },   -- Code completion
	{ "sindrets/diffview.nvim",           event = "VeryLazy" },   -- Git Diff Viewer
	{ "tpope/vim-commentary",             event = "VeryLazy" },   -- Commenting support
	{ "tpope/vim-fugitive",               event = "VeryLazy" },   -- Git integration
	{ "tpope/vim-rsi",                    event = "VeryLazy" },   -- Readline-style keys
	{ "wellle/targets.vim",               event = "VeryLazy" },   -- Additional text objects
	{                                                             -- AI Pair Programmer
		"yetone/avante.nvim",
		event = "VeryLazy",
		build = "make",
		opts = {},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{ -- Git signs
		"lewis6991/gitsigns.nvim",
		opts = {},
		event = "VeryLazy"
	},
	{ -- Fuzzy finder
		"nvim-telescope/telescope.nvim",
		tag = '0.1.5',
		dependencies = {
			'nvim-lua/plenary.nvim',
			"debugloop/telescope-undo.nvim",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					undo = {},
				},
			})
			require("telescope").load_extension("undo")
			-- optional: vim.keymap.set(
		end,
		event = "VeryLazy"
	},
	{ -- Treesitter integration
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"css",
				"html",
				"javascript",
				"json",
				"jsx",
				"lua",
				"rust",
				"tsx",
				"typescript",
				"yaml",
			},
			highlight = {
				enable = true, -- false will disable the whole extension
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true
			},
		},
	},
	{ -- Indentation guides
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		main = "ibl",
		opts = {
			indent = { char = "│" },
		},
	},
	{ -- File explorer
		'stevearc/oil.nvim',
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ -- Formatting
		'stevearc/conform.nvim',
		event = "BufWritePre",
		opts = {
			formatters_by_ft = {
				markdown = { "deno" },
				typescript = { "deno" },
				yaml = { "deno" },
				css = { "deno" },
				html = { "deno" },
				json = { "deno" },
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
	{ -- Tailwind CSS support
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {}
	},
	{ -- LSP Garbage Collection
		"zeioth/garbage-day.nvim",
		dependencies = "neovim/nvim-lspconfig",
		event = "VeryLazy",
		opts = {}
	},
	{ -- Highlight undo changes
		'tzachar/highlight-undo.nvim',
		opts = {},
	},
	{ -- Breadcrumbs
		'Bekaboo/dropbar.nvim',
		dependencies = {
			'nvim-telescope/telescope-fzf-native.nvim'
		}
	},
	{ -- Yank history
		"gbprod/yanky.nvim",
		opts = {},
	},
	{ -- Automatic session management
		'rmagatti/auto-session',
		lazy = false,
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
		opts = {
			auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
		}
	},
	{ -- Instills good vim habits
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {}
	},
})

local servers = {
	'denols',
	'lua_ls',
	'marksman',
	'tailwindcss',
}

-- LSP setup
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = servers,
	automatic_installation = true,
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Set up each LSP server
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup {
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

-- Statusline
do
	local colors = {
		normal = "#61afef",
		insert = "#98c379",
		visual = "#c678dd",
		replace = "#e5c07b",
		command = "#56b6c2",
		inactive = "#4b5263",
		bg = "#282c34",
		fg = "#abb2bf",
	}

	local mode_names = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		[""] = "V-BLOCK",
		c = "COMMAND",
		R = "REPLACE",
		t = "TERMINAL",
	}

	local function get_mode()
		local mode = vim.api.nvim_get_mode().mode
		return string.format(" %s ", mode_names[mode] or mode:upper())
	end

	local function get_filename()
		local filename = vim.fn.expand("%:t")
		return filename == "" and "[No Name]" or filename
	end

	local function get_filetype()
		return vim.bo.filetype
	end

	_G.statusline = function()
		local mode = get_mode()
		local filename = get_filename()
		local filetype = get_filetype()

		return table.concat {
			"%#StatusLine#",
			mode,
			"%#StatusLineNC#",
			" %f",  -- Full path
			"%m",   -- Modified flag
			"%=",   -- Right align
			filetype,
			" %l:%c ", -- Line and column
			"%p%%", -- Percentage through file
		}
	end

	vim.api.nvim_create_autocmd({ "ModeChanged", "VimEnter" }, {
		callback = function()
			local mode = vim.api.nvim_get_mode().mode
			local color = colors[mode] or colors.normal
			vim.api.nvim_command("hi StatusLine guifg=" .. color .. " guibg=" .. colors.bg)
		end
	})

	vim.o.statusline = "%!v:lua.statusline()"
end

-- Add autocommand to run TailwindSort on save for .tsx files
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.tsx",
	callback = function()
		vim.cmd("TailwindSort")
	end,
})
