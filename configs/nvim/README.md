# neovim

Here's a quick reference for everything you've installed. A few of these (nvim-tree, neo-tree) already have the keymaps we set; the rest either work automatically or need a keymap added — I've flagged those.

| Plugin             | Shortcut                             | Action                                                     | Status                           |
| ------------------ | ------------------------------------ | ---------------------------------------------------------- | -------------------------------- |
| **nvim-tree**      | `<leader>e`                          | Toggle file sidebar                                        | ✅ configured                    |
| **neo-tree**       | `<leader>n`                          | Toggle file sidebar                                        | ✅ configured                    |
| **telescope**      | _(none yet)_                         | Fuzzy find files / grep                                    | ⚠️ needs keymap                  |
| **treesitter**     | _(none needed)_                      | Better syntax highlighting — runs automatically            | ✅ automatic                     |
| **gitsigns**       | _(none yet)_                         | Git change markers in the gutter                           | ⚠️ needs keymap for hunk actions |
| **lualine**        | _(none needed)_                      | Statusline — just displays, no shortcut                    | ✅ automatic                     |
| **nvim-lspconfig** | _(none yet)_                         | Go-to-definition, hover, rename, etc.                      | ⚠️ needs keymaps                 |
| **nvim-cmp**       | `<Tab>` / `<C-n>` / `<C-p>` / `<CR>` | Autocomplete: cycle & confirm suggestion                   | ⚠️ needs mapping (not wired yet) |
| **nvim-autopairs** | _(none needed)_                      | Auto-closes `()`, `""`, `{}` as you type                   | ✅ automatic                     |
| **Comment.nvim**   | `gcc`                                | Toggle comment on current line                             | ✅ default mapping               |
| **Comment.nvim**   | `gc` (visual mode)                   | Toggle comment on selection                                | ✅ default mapping               |
| **which-key**      | _(none needed)_                      | Popup showing available keybindings as you type `<leader>` | ✅ automatic                     |

**Not yet wired up (need keymaps added if you want to use them):**

For **telescope**, add to its plugin file:

```lua
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
```

For **gitsigns**, the plugin has built-in hunk navigation but it's opt-in — I can give you a keymap block for `]c` / `[c` (next/prev hunk) and `<leader>hp` (preview hunk) if you want it.

For **nvim-cmp**, the setup snippet I gave earlier only listed dependencies — it needs a `config` block wiring up `<Tab>`/`<CR>` before autocomplete actually works.

For **nvim-lspconfig**, keymaps like `gd` (go to definition), `K` (hover docs), `<leader>rn` (rename) typically get set inside an `LspAttach` autocommand.

Want me to fill in the missing configs for any of these (telescope, gitsigns, cmp, lsp) so the whole kitchen sink is actually functional, not just installed?
