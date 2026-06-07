CONTAINER_HOME="/workspace"

function _dgo() {
  ./script/docker/start.sh --go
}

function _dclean() {
  ./script/docker/start.sh --clean --pull
}
