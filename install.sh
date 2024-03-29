#! /bin/bash
#make sh executable, copy it to the $PATH
chmod +x ladder.sh&&cp ladder.sh $HOME/.local/bin/
# create the necessary directories and files:
mkdir -p $HOME/.local/share/ladder $HOME/.config/ladder/
cp -r png/ $HOME/.local/share/ladder/

echo -e "STATS_COLOR=yes
WORD_LIST=/usr/share/dict/words
PREFERRED_PNG=$HOME/.local/share/ladder/png/l1.png
PREFERRED_EDITOR=${EDITOR-nano}">$HOME/.config/ladder/ladder.config
