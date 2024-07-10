# 📒 **ZSHRC-CONFIG**

Superior ZSH configuration and startup, supporting multiple dynamic hosts and environments.

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

*Submitted by* **Justin Rankin**
[justin.blair.rankin@gmail.com](justin.blair.rankin@gmail.com)
