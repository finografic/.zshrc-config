#! /bin/bash

export SUDO=''
if (( $EUID != 0 )); then
  export SUDO='sudo'
fi
