#!/bin/zsh

# Docker Container Environment Banner
echo "${_c}╔════════════════════════════════════════════════════════════╗${_0}"
echo "${_c}║              🐳 Docker Container Environment              ║${_0}"
echo "${_c}╚════════════════════════════════════════════════════════════╝${_0}"
echo ""
echo "${_b}Container ID:${_0}    $(hostname)"
echo "${_b}Architecture:${_0}   ${OS_ARCH}"
echo "${_b}OS:${_0}             ${OS_NAME} ${OS_VERSION}"
echo "${_b}Shell:${_0}          $(zsh --version | head -1)"
echo "${_b}Config Root:${_0}    ${ZSHRC_ROOT}"
echo ""
