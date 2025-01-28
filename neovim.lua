vim.opt.number = true

-- Tab settings
vim.opt.expandtab = true      -- Convert tabs to spaces
vim.opt.tabstop = 4           -- Number of spaces tabs count for
vim.opt.softtabstop = 4       -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.shiftwidth = 4        -- Number of spaces used for autoindent

-- Mappings

local map = vim.keymap.set

vim.g.mapleader = " "
map('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Yank selection to system clipboard' })
map('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map('n', '<Tab>', ':bnext<CR>')
map('n', '<S-Tab>', ':bprevious<CR>')
map('n', '<C-s>', ':w<CR>')
map('n', '<C-w>', function()
    local current_buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(current_buf) and vim.api.nvim_buf_is_loaded(current_buf) then
        local buf_name = vim.api.nvim_buf_get_name(current_buf)
        if not buf_name:match("NvimTree") then
            vim.api.nvim_buf_delete(current_buf, { force = true })
        end
    end
end, { desc = 'Close current buffer except NvimTree' })
map('n', '<leader>w', function()
    local buffers = vim.api.nvim_list_bufs() 
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if not buf_name:match("NvimTree") then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end
end, { desc = 'Close all buffers except NvimTree' })
map('n', 'ge', 'G', { desc = 'Go to file end' })
map('v', 'ge', 'G', { desc = 'Go to file end' })
map('n', 'gh', '0', { desc = 'Go to line start' })
map('n', 'gl', '$', { desc = 'Go to line end' })
map('v', 'gl', '$', { desc = 'Go to line end' })
map('n', 'd', 'x', { desc = 'Delete' })
map('n', 'x', '<S-v>', { desc = 'Mark entire line' })
map('n', 'gr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
map('n', '<leader>k', vim.lsp.buf.hover, { desc = 'Show docs under cursor' })
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
map('n', '<C-n>', '<C-c>', { desc = 'Multi-line change' })

-- Plugins

require('telescope').setup{
	pickers = {
		find_files = {
			hidden = true
		}
	}
}
local builtin = require('telescope.builtin')
map('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>g', builtin.live_grep, { desc = 'Telescope live grep' })

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

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    }),
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
            })[entry.source.name]
            return vim_item
        end
    },
})
require('avante_lib').load()
require('avante').setup ({
  -- Your config here!
})


-- disable netrw at the very start of init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('nvim-tree').setup({
    filters = {
        exclude = { ".env" }
    }
})

require('Comment').setup()
map("n", "<C-c>", "gcc")

require('catppuccin').setup({
	flavour = "macchiato",
	})
vim.cmd.colorscheme "catppuccin"

require('gitblame')

-- LSP Config
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local nvim_lsp = require('lspconfig')
nvim_lsp.pyright.setup{
    capabilities = capabilities
}
nvim_lsp.ts_ls.setup{
    capabilities = capabilities
}

