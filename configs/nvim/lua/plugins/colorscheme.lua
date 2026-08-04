return {
  -- { "tanvirtin/monokai.nvim", priority = 1000 },
  -- { "folke/tokyonight.nvim", priority = 1000 },
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        filter = "spectrum", -- "spectrum" | "machine" | "ristretto" | "classic" | "octagon" | "pro"
      })
      vim.cmd.colorscheme("monokai-pro")
    end,
  },
}
