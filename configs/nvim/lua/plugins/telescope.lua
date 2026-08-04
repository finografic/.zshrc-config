return {
    -- fuzzy finder for files/grep, near essential
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({})
    vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
    vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
    vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
  end,
}
