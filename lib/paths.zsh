################################
###########  PATHS  ############
################################

export PATH=$PATH:$HOME/bin:/usr/local/bin

# SSH PATH
export SSH_KEY_PATH="~/.ssh/rsa_id"

# SYS PATHS
export PATH=$PATH:$HOME/.npm-global/bin
export PATH=$PATH:/usr/local/lib/node_modules
export PATH=$PATH:$HOME/.eslintrc
export PATH=$PATH:$HOME/bin:/usr/local/bin

# MISC PROGRAMS
export PATH=$PATH:/snap/bin

#########################################
################  NVM  ##################
#########################################

if [[ $NVM = "true" ]];  then 
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# RUBY PATHS
export PATH=$PATH:$HOME/bin/caddy
# export PATH="$HOME/.rvm/gems/ruby-2.4.0/bin:$HOME/.rvm/gems/ruby-2.4.0@global/bin$HOME/.rvm/rubies/ruby-2.4.0/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/.npm-global/bin:/usr/local/lib/node_modules:$HOME/.eslintrc:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.fzf/bin:$HOME/.rvm/bin:$HOME/.vimpkg/bin"

# export PATH="/home/usuario/.rvm/gems/ruby-2.4.0/bin:/home/usuario/.rvm/gems/ruby-2.4.0@global/bin/home/usuario/.rvm/rubies/ruby-2.4.0/bin:/home/usuario/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/usuario/.npm-global/bin:/usr/local/lib/node_modules:/home/usuario/.eslintrc:/home/usuario/.yarn/bin:/home/usuario/.config/yarn/global/node_modules/.bin:/home/usuario/.fzf/bin:/home/usuario/.rvm/bin:/home/usuario/.vimpkg/bin:/home/usuario/.rbenv/bin:/home/usuario/.vimpkg/bin"

# YARN
export PATH=$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin

# RUBY SIMPLE 
export PATH=$PATH:$HOME/.rbenv/bin

# CADDY
export PATH=$PATH:$HOME/bin

# GO PATHS
export PATH=$PATH:/usr/local/go/bin
export GOPATH="$HOME/go_projects"
export GOBIN="$GOPATH/bin"

# REMOVE DUPLICATES FROM PATH
export PATH=$(printf %s "$PATH" | awk -vRS=: '!a[$0]++' | paste -s -d:)
