#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0);pwd)

export LANG="ja_JP.UTF-8"
export PATH="$HOME/.anyenv/bin:$PATH:$HOME/bin"
eval "$(anyenv init -)"

cd ${SCRIPT_DIR}
bundle exec ruby hagibis.rb $@
