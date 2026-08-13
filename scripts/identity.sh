#!/bin/bash

setup_identity() {
  export USER="root"
  export HOME="/home/container"
  export TERM="xterm-256color"

  local prompt='\[\033[1m\033[38;2;166;227;161m\]root\[\033[0m\]\[\033[38;2;108;112;134m\]@\[\033[0m\]\[\033[1m\033[38;2;137;220;235m\]codex\[\033[0m\]\[\033[38;2;108;112;134m\]:\[\033[0m\]\[\033[38;2;203;166;247m\]\w\[\033[0m\]\[\033[38;2;250;179;135m\]\$\[\033[0m\] '

  export PS1="$prompt"
  export CODEX_PS1="$prompt"
}
