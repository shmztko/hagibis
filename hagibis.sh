#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0);pwd)

export PATH="$HOME/.anyenv/bin:$PATH:$HOME/bin"
eval "$(anyenv init -)"

cd ${SCRIPT_DIR}
bundle exec ruby hagibis.rb save `date +%Y` `date +%m`
