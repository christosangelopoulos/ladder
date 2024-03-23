#! /bin/bash
#make sh executable, copy it to the $PATH
chmod +x ladder.sh
cp ladder.sh $HOME/.local/bin/
# create the necessary directories and files:
mkdir $HOME/.cache/ladder/ ~/.config/ladder/
touch $HOME/.cache/ladder/statistics.txt
cp -r png/ $HOME/.config/ladder/
echo "STATS_COLOR yes
WORD_LIST /usr/share/dict/words
PREF_PNG $HOME/.config/ladder/png/l1.png
PREF_EDITOR nano">$HOME/.config/ladder/ladder.config
