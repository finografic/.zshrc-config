# 📒 **ZSHRC-CONFIG**

## Cross-Platform Zsh Environment Orchestrator

Superior ZSH configuration and startup, dynamic support for multiple dynamic hosts and environments.

**Backup your current `~/.zshrc` file and leave new/current version containing only:**

```sh
source "$HOME/.zshrc-config/main.zsh";
```

**Fixing the `zsh compinit: insecure directories` error/warning message on macOS:**
<https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-390600994>

```sh
compaudit # list directories thought unsecure
sudo chown -R username TARGET_DIRECTORY
sudo chmod -R 755 TARGET_DIRECTORY
```

---

## Antidote setup

```sh
# 1. Clone Antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# 2. Add to .zshrc
echo 'source ${ZDOTDIR:-~}/.antidote/antidote.zsh' >> ${ZDOTDIR:-~}/.zshrc

# 3. Create initial plugins file
touch ${ZDOTDIR:-~}/.zsh_plugins.txt

# 4. Add plugin load command to .zshrc
echo 'antidote load ${ZDOTDIR:-~}/.zsh_plugins.txt' >> ${ZDOTDIR:-~}/.zshrc


# THEN..
# 1. Set up preferred plugins in .zsh_plugins.txt
# 2. Configure how to integrate .zsh-config
# 3. Consider static loading for better performance
# 4. Explore plugin update strategies

```


## Profiling

**basic:**

```sh
# Before static loading
time zsh -i -c exit

# After static loading
time zsh -i -c exit
```

**detailed (saved in `.zshrc`):**

```sh
# Add this to the very top:
zmodload zsh/zprof

# And this at the very bottom:
zprof
```

## `hyperfine` - for MORE profiling

```sh
# Install hyperfine
brew install hyperfine

# Then test
hyperfine 'zsh -i -c exit'
```

---


*Submitted by* **Justin Rankin**
[justin.blair.rankin@gmail.com](justin.blair.rankin@gmail.com)
