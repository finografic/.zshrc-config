# ============================================================================ #
# NOTE: DOCKER-DEV BANNER - Docker Container Environment
echo -e "${_c}╔════════════════════════════════════════════════════════════╗${_0}"
echo -e "${_c}║              🐳 Docker Container Environment               ║${_0}"
echo -e "${_c}╚════════════════════════════════════════════════════════════╝${_0}"
echo -e ""
echo -e "${_b}Container ID:${_0}    $(hostname)"
echo -e "${_b}Architecture:${_0}   ${OS_ARCH}"
echo -e "${_b}OS:${_0}             ${OS_NAME} ${OS_VERSION}"
echo -e "${_b}Shell:${_0}          $(zsh --version | head -1)"
echo -e "${_b}Config Root:${_0}    ${ZSHRC_ROOT}"
echo -e ""
