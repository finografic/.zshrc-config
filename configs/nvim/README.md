# neovim

Kitchen-sink config for now — most plugins are wired up and working; a couple
still need LSP servers/keymaps before they do anything.

| Plugin             | Shortcut                                   | Action                                                     | Status                                     |
| ------------------ | ------------------------------------------ | ---------------------------------------------------------- | ------------------------------------------ |
| **nvim-tree**      | `<leader>e`                                | Toggle file sidebar                                        | ✅ configured                              |
| **neo-tree**       | `<leader>n`                                | Toggle file sidebar                                        | ✅ configured                              |
| **telescope**      | `<leader>ff` / `<leader>fg` / `<leader>fb` | Fuzzy find files / grep / open buffers                     | ✅ configured                              |
| **treesitter**     | _(none needed)_                            | Better syntax highlighting + indent — runs automatically   | ✅ automatic                               |
| **gitsigns**       | _(none yet)_                               | Git change markers in the gutter                           | ⚠️ signs on, needs keymap for hunk actions |
| **lualine**        | _(none needed)_                            | Statusline — just displays, no shortcut                    | ✅ automatic                               |
| **nvim-lspconfig** | _(none yet)_                               | Go-to-definition, hover, rename, etc.                      | ⚠️ needs a server + keymaps                |
| **nvim-cmp**       | _(none yet)_                               | Autocomplete                                               | ⚠️ needs mapping (not wired yet)           |
| **nvim-autopairs** | _(none needed)_                            | Auto-closes `()`, `""`, `{}` as you type                   | ✅ automatic                               |
| **Comment.nvim**   | `gcc`                                      | Toggle comment on current line                             | ✅ configured                              |
| **Comment.nvim**   | `gc` (visual mode)                         | Toggle comment on selection                                | ✅ configured                              |
| **which-key**      | _(none needed)_                            | Popup showing available keybindings as you type `<leader>` | ✅ automatic                               |

**Not yet wired up:**

For **gitsigns**, hunk navigation/preview is opt-in — add a keymap block for
`]c` / `[c` (next/prev hunk) and `<leader>hp` (preview hunk) if you want it.

For **nvim-cmp**, the plugin spec only lists dependencies — it needs a
`config` block wiring up `<Tab>`/`<CR>` before autocomplete actually works.

For **nvim-lspconfig**, install a language server (e.g. via Mason, not yet
added) and set keymaps like `gd` (go to definition), `K` (hover docs),
`<leader>rn` (rename) inside an `LspAttach` autocommand.
