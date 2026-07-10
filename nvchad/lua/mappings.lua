require "nvchad.mappings"

local map = vim.keymap.set

-- Clipboard
map("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("v", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Buffer navigation
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Save
map("n", "<C-s>", ":w<CR>", { desc = "Save file" })

-- Close current buffer (except NvimTree)
map("n", "<C-w>", function()
  local current_buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(current_buf) and vim.api.nvim_buf_is_loaded(current_buf) then
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    if not buf_name:match "NvimTree" then
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end
  end
end, { desc = "Close current buffer except NvimTree" })

-- Close all buffers (except NvimTree)
map("n", "<leader>w", function()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if not buf_name:match "NvimTree" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end, { desc = "Close all buffers except NvimTree" })

-- Helix-style motions
map("n", "ge", "G", { desc = "Go to file end" })
map("v", "ge", "G", { desc = "Go to file end" })
map("n", "gh", "0", { desc = "Go to line start" })
map("n", "gl", "$", { desc = "Go to line end" })
map("v", "gl", "$", { desc = "Go to line end" })

-- Helix-style delete/select
map("n", "d", "x", { desc = "Delete char" })
map("n", "x", "<S-v>", { desc = "Select entire line" })

-- LSP
map("n", "gr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Show docs under cursor" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Telescope
map("n", "<leader>f", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Telescope find files" })
map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "Telescope buffers" })
map("n", "<leader>g", "<cmd>Telescope live_grep<CR>", { desc = "Telescope live grep" })

-- Comment (NvChad uses Comment.nvim with gcc by default, add Ctrl-c mapping)
map("n", "<C-c>", "gcc", { remap = true, desc = "Toggle comment" })
