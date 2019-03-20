# BAT
https://github.com/sharkdp/bat
https://github.com/sharkdp/bat/releases/download/v0.9.0/bat_0.9.0_amd64.deb
sudo dpkg -i bat_0.9.0_amd64.deb 

# COLORS - colorls
https://github.com/athityakumar/colorls
gem install colorls

# COLORS - rouge
http://rouge.jneen.net/
https://guides.rubygems.org/command-reference/#gem-install
gem install rouge

# COLORS - grc
https://github.com/garabik/grc

# DISK - pydf
sudo apt-get install pydf

# DISK - ncdu 
sudo apt-get install ncdu

# COLORS -exa 
cd $HOME/bin
FILENAME="exa-linux-x86_64-0.8.0"
wget "https://github.com/ogham/exa/releases/download/v0.8.0/${FILENAME}.zip"
unzip "${FILENAME}.zip"
rm "${FILENAME}.zip"
mv $FILENAME exa
env EXA_COLORS="da=1;34" # brighter blues
# exa --all --group-directories-first --long --group --modified --time-style long-iso --git






