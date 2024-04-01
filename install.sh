#! /bin/bash
#make sh executable, copy it to the $PATH
chmod +x ladder.sh
[[ -d $HOME/.local/bin/ ]]&&cp ladder.sh $HOME/.local/bin/&&INSTALL_MESSAGE="The script was copied to\n\e[33m $HOME/.local/bin/\e[m\nProvided that this directory is included in the '\$PATH', the user can run the script with\n\e[33m$ ladder.sh\e[m\nfrom any directory.\nAlternatively, the script can be run with\n\e[33m$ ./ladder.sh\e[m\nfrom the ladder/ directory."||INSTALL_MESSAGE="The script has been made executable and the user can run it with:\n\e[33m$ ./ladder.sh\e[m\nfrom the ladder/ directory."

# create the necessary directories and files:
mkdir -p $HOME/.local/share/ladder $HOME/.config/ladder/
cp -r png/ $HOME/.local/share/ladder/

echo -e "STATS_COLOR=yes
WORD_LIST=/usr/share/dict/words
PREFERRED_PNG=$HOME/.local/share/ladder/png/l1.png
PREFERRED_EDITOR=${EDITOR-nano}">$HOME/.config/ladder/ladder.config
echo -e "$INSTALL_MESSAGE"
