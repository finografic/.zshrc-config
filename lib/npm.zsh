##################################
##############  NPM   ############
##################################

alias ngl="npm list -g --depth 0"

# write global packages to file
# (useful when switching node version via NVM)
npm list -g --depth 0 > $HOME/.npm-globals

# ANY WAY TO USE CONTENTS OF $HOME/npm-globals for ARRAY ??

function ngi() {
  npm i -g @roarr/cli chalk checkout-branch concurrently core-js create-react-app cross-env eslint eslint-plugin-import eslint-watch frontail fd-find git-auto grunt grunt-cli gulp gulp-cli jscs jmate jshint jsome n node-gyp node-pre-gyp node-inspect node-sass@latest nodemon npm@6.4.0 npm-check-updates npx nti ntl ora pm2 react-create-app react-scripts slap select-branch vtop yarn
}






