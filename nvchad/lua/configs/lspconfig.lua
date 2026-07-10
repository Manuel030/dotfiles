require("nvchad.configs.lspconfig").defaults()

local servers = { "pyright", "ts_ls", "nil_ls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
