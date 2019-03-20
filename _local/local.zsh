# UNIVERSAL 
alias repos="cd $HOME/repos && l"
alias devil="cd $HOME/repos/devilbox && l"
alias www="cd /var/www && l"

# A2 HOSTING
# alias a2="ssh -p 7822 REDACTED-IP -l ubuntu"
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l ubuntu"

# DEV
alias da2="cd $HOME/repos/da2 && l"
function aws-up(){
  sudo rsync -azvv -e "ssh -i $HOME/.ssh/STD-Exoticca-key.pem" $1 ubuntu@ec2-18-196-31-66.eu-central-1.compute.amazonaws.com:/home/ubuntu;
}

alias cv="cd $HOME/repos/cv && l"

# DEVILBOX
dev() { 

  PWD=`pwd`

  if [[ $@ = "ini" ]] then

    cd $HOME/repos/devilbox && ll
    service apache2 stop
    service mysql stop
    docker-compose up httpd php mysql

  elif [[ $@ = "cli" ]] then

    cd $HOME/repos/devilbox && ll
    ./shell.sh

  else
    echo "args required."
  fi

}