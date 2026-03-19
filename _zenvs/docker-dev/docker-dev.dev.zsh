CONTAINER_HOME="/workspace"

_dgo() {
  ./script/docker/start.sh --go
}

_dclean() {
  ./script/docker/start.sh --clean --pull
}
