# 📒 **ZSHRC-CONFIG - `TODO:`**



## office - ERRORS on init

```sh
Last login: Wed Nov 27 08:45:01 on ttys007
/Users/REDACTED/.zshrc-config/_zsh-config.zsh:15: command not found: compinit
[oh-my-zsh] plugin 'fzf-zsh-plugin' not found
[oh-my-zsh] plugin 'zsh-history-substring-search' not found
[oh-my-zsh] plugin 'zsh-fzf-history-search' not found


env: node: No such file or directory
This `npx` version () is not supported.
The `npx` plugin is deprecated and will be removed soon. Please disable it.
The `osx` plugin is deprecated and has been renamed to `macos`.
Please update your .zshrc to use the `macos` plugin instead.
```

## office - STALLS + FREEZE on bootstrap, just after

```sh
 ✔ Starting ZSH: OFFICE-MACOS configuration...
```

/Users/REDACTED/.zshrc-config/\_zsh-config.zsh:source:134: no such file or directory: /Users/REDACTED/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[oh-my-zsh] plugin 'fd' not found

---

## home

 config ---------------------------------
[oh-my-zsh] plugin 'fzf-zsh-plugin' not found
[oh-my-zsh] plugin 'k' not found
[oh-my-zsh] plugin 'zsh-history-substring-search' not found
[oh-my-zsh] plugin 'zsh-fzf-history-search' not found

---

# PLUGINS

## PLUGINS - CORE CLI

fzf
fzf-tab-completion
fzf-zsh-plugin
k
zsh-autosuggestions
zsh-completions
zsh-fzf-history-search
zsh-history-substring-search
zsh-nvm
zsh-syntax-highlighting

Analysis & Recommendations

1. FZF-related plugins - You have several overlapping ones:
  fzf - core fuzzy finder
  fzf-tab-completion - might be redundant as fzf-tab is more commonly used now
  fzf-zsh-plugin - this is likely the oh-my-zsh plugin
  zsh-fzf-history-search - might overlap with history-substring-search
2. Core functionality plugins (these are solid choices):
  zsh-autosuggestions - very useful, keep
  zsh-completions - excellent for extended completions
  zsh-syntax-highlighting - essential, but load order matters
  zsh-history-substring-search - great for history navigation
3. Utility plugins:
  k - enhanced directory listings (still maintained)
  zsh-nvm - good if you use Node.js


# PLUGIN - NEEDED ??

git
github
node
npm
rsync
sudo
git-extras
git-prompt
vim-interaction
vscode
yarn
brew
emoji
grc
macos
npx
tig
vscode
zsh-nvm

Analysis by Category

1. Git-related:
git - Core git aliases and functions (worth keeping)
github - GitHub CLI helpers (less needed if you use modern gh CLI)
git-extras - Extra git utilities (check if you use any specific features)
git-prompt - Git status in prompt (might overlap with your mega-theme?)
2. Node/JavaScript:
node - Basic node helpers (minimal value)
npm - npm aliases (might be redundant with modern npm)
yarn - Yarn completions (useful if you use Yarn)
npx - Minimal value with modern Node
zsh-nvm - (Already covered in previous list)
3. Editor/IDE:
vim-interaction - Vim helpers (useful if you use vim heavily)
vscode - (listed twice) - VSCode CLI integration (minimal value if using recent VSCode)
4. macOS/System:
brew - Homebrew completions (useful)
macos - macOS-specific commands (check if you use any)
sudo - ESC ESC sudo prefix (quite useful)
rsync - Rsync aliases/completions
grc - Generic colourizer (nice for logs/output)
5. Misc:
emoji - Emoji completion (fun but not essential)
tig - Text-mode interface for git (only if you use tig)




