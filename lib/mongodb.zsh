##################################
############  MONGODB   ##########
##################################

# OLD / ORIG
# alias mstart="sudo systemctl start mofind . -mtime -1 -printodb"
# alias mstop="sudo systemctl stop mongfind . -mtime -1 -printb"
# alias mrs="sudo systemctl restart mongodb"
# alias mstat="sudo systemctl status mongodb"
# alias mlog="sudo cat /var/log/mongodb/mongod.log"

# SERVICE or SYSTEMCTL - DEPENDING ON OS + MONGO VERSIONS
# NOTE: --shutdown RECOMMENDED over "stop"

# OPTION B: >= UBUNTU 16.04 + NEWER MONGO VERSIONS
# alias mstart="sudo systemctl start mongod";
# alias mstop="sudo systemctl stop mongod && ports";
# alias mrs="sudo systemctl restart mongod";
# alias mstat="sudo systemctl status mongod";

# OPTION C: OLDER UBUNTU + MONGO VERSIONS
# alias mstart="sudo service mongod start";
# alias mstop="sudo service mongod stop && ports";
# alias mrs="sudo service mongod restart";
# alias mstat="sudo service mongod status";

# NEW
alias mlog="sudo cat /var/log/mongodb/mongod.log"
alias mconf="sudo vim /etc/mongod.conf"
alias mconfig="code /etc/mongod.conf"

# mongod --dbpath /data/db_3.2.21
# mongod --dbpath /data/db_3.4.18

function mverGet() {
  echo "\e[96mMongoDB version \e[97mv$MONGO_VERSION\e[0m"
}

function mverSet() {
  MONGO_VERSION=$(mongod --version | grep -oP '\d{1,2}[.]\d{1,2}[.]\d{1,2}')
}

function mstart() {
  mverGet
  echo "\e[32m✔ running"
  # sudo mongod --config /etc/mongod.conf --auth --logpath /var/log/mongodb.log --dbpath "/data/db_$MONGO_VERSION"
  sudo mongod --config /etc/mongod.conf --logpath /var/log/mongodb.log --dbpath "/data/db_$MONGO_VERSION"
}

function mstop() {
  sudo mongod --shutdown --dbpath "/data/db_$MONGO_VERSION"
  ports
}

alias mrs=''                 # NO RESTART FOR THIS METHOD ?? MUST BE MANUAL ??
alias mstat='sudo mongostat' # REQUIRES enabledLocalhostAuthBypass TO CREATE FIRST USER (i think!)

# INI MONGO_VERSION
mverSet

function mbak() {
  cd /data
  sudo mongod --shutdown
  ports
  sudo tar zcvf "db-BAK-$(date +%F).tar.gz"
  l
  server
}

# OWN USING mongodb USER
mown() {
  sudo chown -R mongodb:mongodb $1
}
