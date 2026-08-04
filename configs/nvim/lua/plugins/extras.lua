return {
  -- syntax highlighting done right (treesitter, replaces old regex highlighting)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- git gutter (added/changed/removed line markers)
  "lewis6991/gitsigns.nvim",

  -- status line
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- LSP + autocomplete
  "neovim/nvim-lspconfig",
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" } },

  -- auto-close brackets/quotes
  "windwp/nvim-autopairs",

  -- comment toggling (gcc, gc in visual mode)
  "numToStr/Comment.nvim",

  -- which-key popup, shows available keybindings as you type
  "folke/which-key.nvim",
}
