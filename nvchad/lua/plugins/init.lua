return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black", "isort" },
        nix = { "nixpkgs_fmt" },
      },
    },
  },


  -- GitHub Copilot
  {
    "github/copilot.vim",
    lazy = false,
  },

  -- Git blame
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
  },

  -- Diffview
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
  },

  -- Multi-cursor
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },

  -- Treesitter: ensure parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "bash",
        "nix",
        "rust",
        "markdown",
        "markdown_inline",
      },
    },
  },

  -- Telescope: show hidden files by default
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    },
  },
}
