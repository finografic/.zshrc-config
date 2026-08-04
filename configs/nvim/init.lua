-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- basic sane defaults
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.g.mapleader = " "
