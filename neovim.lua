vim.opt.number = true

-- Mappings

local map = vim.keymap.set

vim.g.mapleader = " "
map('n', '<Tab>', ':bnext<CR>')
map('n', '<S-Tab>', ':bprevious<CR>')
map('n', '<C-s>', ':w<CR>')
map('n', 'ge', 'G', { desc = 'Go to file end' })
map('n', 'gh', '0', { desc = 'Go to file start' })
map('n', 'gl', '$', { desc = 'Go to line end' })
map('n', 'd', 'x', { desc = 'Delete' })
map('n', 'x', '<S-v>', { desc = 'Mark entire line' })
map('n', 'gr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
map('n', '<leader>k', vim.lsp.buf.hover, { desc = 'Show docs under cursor' })

-- Plugins

local builtin = require('telescope.builtin')
map('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })

-- vim.opt.termguicolors = true
require("bufferline").setup{
	options = {
		buffer_close_icon = 'x'
	}
}

require('nvim-treesitter.configs').setup({
	highlight = {
    		enable = true,
    		additional_vim_regex_highlighting = false,
		},
	})


-- disable netrw at the very start of init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- TODO: raises an error on start up
require('nvim-tree').setup()

require('Comment').setup()
map("n", "<C-c>", "gcc")

require('catppuccin').setup({
	flavour = "macchiato",
	})
vim.cmd.colorscheme "catppuccin"



-- LSP Config

local nvim_lsp = require('lspconfig')
nvim_lsp.pyright.setup{}