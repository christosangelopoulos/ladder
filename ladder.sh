#! /bin/bash
# ╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮
# │ L ││ A ││ D ││ D ││ E ││ R │
# ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯
#A bash script written by Christos Angelopoulos, October 2023, under GPL v2
function load_colors()
{
 if [[ $STATS_COLOR == 'yes' ]]
 then
  R="\e[31m"
  G="\e[32m"
  Y="\e[33m"
  B="\e[34m"
  M="\e[35m"
  C="\e[36m"
  L="\e[37m"
  W="\e[38;5;242m" #Grid Color
 else
  R="";G=;Y="";B="";M="";C="";L="";W=""
 fi
 bold="\e[1m"
 n="\e[m"
}
function load_config(){
CONFIG_FILE=$HOME/.config/ladder/ladder.config
 config_fail=0
 [[ -z "$CONFIG_FILE" ]]&&config_fail=1||source "$CONFIG_FILE"
 [[ -z $STATS_COLOR ]]&&STATS_COLOR="yes"&&config_fail=1
 [[ -z $WORD_LIST ]]&&WORD_LIST="/usr/share/dict/words"&&config_fail=1
 [[ -z $PREFERRED_EDITOR ]]&&PREFERRED_EDITOR=nano &&config_fail=1
 [[ -z $PREFERRED_PNG ]]&&PREFERRED_PNG=$HOME/.local/share/ladder/png/l1.png &&config_fail=1
 [[ $config_fail == 1 ]]&&notify-send -t 9000 -i $HOME/.local/share/ladder/l1.png "Configuration file was not loaded properly.
Ladder is running with default configuration.";
 TOTAL_SOLUTIONS="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v 'xx'|grep -v 'vii'|grep -v '[^[:lower:]]'|grep -E ^....$)"
}

function quit_puzzle ()
{
 echo -e "     ${G}╭───╮ ${R}╭───╮╭───╮╭───╮╭───╮     \n     ${G}│ U │ ${R}│ Q ││ U ││ I ││ T │     \n     ${G}╰───╯ ${R}╰───╯╰───╯╰───╯╰───╯ ${n}    \n\n"
 echo "$TRY lose">>$HOME/.local/share/ladder/statistics.txt
 echo -e "\n${W}Press any key to return${n}"
 read -sN 1 v;clear;
}

function show_statistics () {
 echo -e "     ${Y}╭───╮╭───╮╭───╮╭───╮╭───╮     \n     │ S ││ T ││ A ││ T ││ S │     \n     ╰───╯╰───╯╰───╯╰───╯╰───╯ ${n}    \n\n"
 if [[ -f $HOME/.local/share/ladder/statistics.txt ]]&&[[ -n $(cat $HOME/.local/share/ladder/statistics.txt) ]]
 then
  PLAYED="$(cat $HOME/.local/share/ladder/statistics.txt|wc -l)"
  WON="$(grep 'win' $HOME/.local/share/ladder/statistics.txt|wc -l)"
  SUC_RATIO="$(echo "scale=2; $WON *100/ $PLAYED" | bc)"
  RECORD="$(grep 'win' $HOME/.local/share/ladder/statistics.txt|sort -h |head -1|awk '{print $1}')"
  MAX_ROW="$(awk '{print $2}' $HOME/.local/share/ladder/statistics.txt|uniq -c|grep 'win'|head -1|awk '{print $1}')"
  if [[ "$(tail -1 $HOME/.local/share/ladder/statistics.txt)" == "lose" ]]
  then
   CURRENT_ROW="0"
  else
   CURRENT_ROW="$(awk '{print $2}' $HOME/.local/share/ladder/statistics.txt|uniq -c|grep 'win'|tail -1|awk '{print $1}')"
  fi

  echo -e "${C} Games Played   : $PLAYED";sleep 0.3
  echo -e "${M} Games Won      : $WON";sleep 0.3
  echo -e "${G} Games Lost     : $(($PLAYED-$WON))";sleep 0.3
  echo -e "${Y} Success ratio  : $SUC_RATIO%";sleep 0.3
  echo -e "${R} Record Guesses : $RECORD";sleep 0.3
  echo -e "${B} Record streak  : $MAX_ROW wins";sleep 0.3
  echo -e "${L} Current streak : $CURRENT_ROW wins";sleep 0.3
 else
  echo -e "${W}No statistics available at the moment."
 fi

}

function win_game ()
{
 clear
 echo "$TRY win">>$HOME/.local/share/ladder/statistics.txt
 F[TRY]="GGGG"
 print_box
 MESSAGE="  You made it after ${R}$TRY ${Y}tries              "
 echo -e "${W}│${Y}       Congratulations!      ${W} │"
 echo -e "${W}│${Y}${bold}${MESSAGE:0:42}${W}│";
 echo -e "${W}╰──────────────────────────────╯"
 A=${PLACEHOLDER_STR^^}
 echo -e "\nPress any key to return${n}"
 read -sN 1 v;clear;
 db2="Q"
}


function check_guess ()
{
#echo "\$1: $1"
 F0=('C' 'C' 'C' 'C' )
 for q in {0..3}
 do
  if [[ ${1:q:1} == ${T:q:1} ]]
  then
   F0[q]="G"
  fi
 done
}

function enter_word () {
 if [[ ${#WORD_STR} -lt 4 ]]
 then COMMENT=" Word is too small!"
 elif [[ ${#WORD_STR} -gt 4 ]]
 then COMMENT=" Word too big!"
 elif [[ -z "$(echo $TOTAL_SOLUTIONS|sed 's/ /\n/g'|grep  -E ^"$WORD_STR"$)" ]]
 then COMMENT=" Invalid word "
 else
  CHANGES=0
  for z in {0..3}
  do
   if [[ ${WORD_STR:z:1} != ${GUESS[TRY-1]:z:1} ]]
   then ((CHANGES++))
   fi
  done
  if [[ $CHANGES -eq 0 ]]
  then   COMMENT=" Enter new word"
  elif [[ $CHANGES -gt 1 ]]
  then  COMMENT="Change ONLY ONE LETTER"
  else
   COMMENT=" Try $TRY: $WORD_STR"
   GUESS[$TRY]=$WORD_STR
   check_guess "$WORD_STR"
  #COMMENT=" Enter 4-letter word"
   F[TRY]=$(echo ${F0[@]}|sed 's/ //g')
   if [[ "${F[TRY]}" == "GGGG" ]]
   then
    win_game
    main_menu_reset
   else
    ((TRY++))
   fi
  fi
 fi
 WORD_STR="";PLACEHOLDER_STR="$WORD_STR""$PAD"
 COMMENT_STR="$COMMENT""$PAD"
}

function main_menu_reset ()
{
 for i in {0..10}
 do
  F[i]=""
 done
}

function print_box ()
{
 echo -e "${W}╭──────────────────────────────╮"
t=0
while [[ $t -lt $TRY ]]
 do
 A="${GUESS[$t]^^}"
 K0="${F[$t]}"
 for a in {0..3}
 do
  if [[ ${K0:a:1} == "C" ]];then K[a]="${C}";
  elif [[ ${K0:a:1} == "G" ]];then K[a]="${G}";fi
 done
 #echo "${K[@]}"
echo -e "${W}│     ${K[0]}╭───╮${K[1]}╭───╮${K[2]}╭───╮${K[3]}╭───╮${n}    ${W} │\n│     ${K[0]}│ ${A:0:1} │${K[1]}│ ${A:1:1} │${K[2]}│ ${A:2:1} │${K[3]}│ ${A:3:1} │${n}    ${W} │\n│     ${K[0]}╰───╯${K[1]}╰───╯${K[2]}╰───╯${K[3]}╰───╯${n}    ${W} │"
 ((t++))
done
if [[ ${F[TRY]} != "GGGG" ]]
then
 A=${PLACEHOLDER_STR^^}
 echo -e "${W}│     ╭───╮╭───╮╭───╮╭───╮     ${W}│\n│     │${n} ${A:0:1} ${W}││${n} ${A:1:1} ${W}││${n} ${A:2:1} ${W}││${n} ${A:3:1} ${W}│     │\n│     ╰───╯╰───╯╰───╯╰───╯     │"
fi
 echo -e "│     "${G}"╭───╮╭───╮╭───╮╭───╮"${n}"    ${W} │\n│     "${G}"│ ${T0:0:1} ││ ${T0:1:1} ││ ${T0:2:1} ││ ${T0:3:1} │     "${W}"│\n│     "${G}"╰───╯╰───╯╰───╯╰───╯    "${W}" │"
 echo -e "├──────────────────────────────┤"
}

function rules() {
 echo -e "
Your starting point is an initial four-letter word.
Your goal is to mutate this word, through other valid words,
and ${Y}tranform it to the target word${n}.
On each entry, you can change ${Y}ONLY ONE LETTER${n}. For instance,
     ${C}╭───╮╭───╮${G}╭───╮╭───╮    ${G}╭───╮╭───╮╭───╮╭───╮
     ${C}│ E ││ A │${G}│ S ││ T │    │ N ││ E ││ S ││ T │
${n}from ${C}╰───╯╰───╯${G}╰───╯╰───╯${n} to${G} ╰───╯╰───╯╰───╯╰───╯${n}, do:
${C} ╭───╮╭───╮${G}╭───╮╭───╮${n}
${C} │ E ││ A │${G}│ S ││ T │${n}
${C} ╰───╯╰───╯${G}╰───╯╰───╯${n}(Initial word)
${C} ╭───╮╭───╮${G}╭───╮╭───╮${n}
${C} │ P ││ A │${G}│ S ││ T │${n}
${C} ╰───╯╰───╯${G}╰───╯╰───╯${n}(Substitute E for P)
${C} ╭───╮${G}╭───╮╭───╮╭───╮${n}
${C} │ P │${G}│ E ││ S ││ T │${n}
${C} ╰───╯${G}╰───╯╰───╯╰───╯${n}(Substitute A for E)
 ${G}╭───╮╭───╮╭───╮╭───╮
 │ N ││ E ││ S ││ T │
 ╰───╯╰───╯╰───╯╰───╯${n}(Mission Accomplished)

${Y}${bold}GOOD LUCK!${n}
${W}Press any key to return${n}"
read -sN 1 v
clear
}

function new_game()
{
 PAD="                                      "
 COMMENT=" Enter 4 letter word"
 COMMENT_STR="$COMMENT"${PAD}
 PLACEHOLDER_STR="$WORD_STR${PAD}"
 #GUESS[0] is the STARTING WORD
 GUESS[0]="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v 'xx'|grep -v 'vii'|grep -v '[^[:lower:]]'|grep -E ^....$|shuf|head -1)"
 # T for TARGET WORD
 T="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v 'xx'|grep -v 'vii'|grep -v '[^[:lower:]]'|grep -E ^....$|shuf|head -1)"
 T0=${T^^}
 check_guess ${GUESS[0]}
 F[0]=$(echo ${F0[@]}|sed 's/ //g')
 TRY=1
}

function play_menu () {
 while [[ $db2 != "Q" ]]
 do
  print_box
  echo -en "│ ${Y}${bold}<enter>${n}       to ${G}${bold}ACCEPT word${W} │\n│ ${Y}${bold}<delete>${n}       to ${R}${bold}ABORT word${W} │\n│ ${Y}${bold}<backspace>${n} to ${R}${bold}DELETE letter${W} │\n├──────────────────────────────┤\n│ ${Y}${bold}W${n}          to show ${C}${bold}WORD LIST${W} │\n├──────────────────────────────┤\n│ ${Y}${bold}Q${n}               to ${R}${bold}QUIT GAME${W} │\n├──────────────────────────────┤\n│${Y}${COMMENT_STR:0:30}${W}│\n╰──────────────────────────────╯\n${n}"
  read -sn 1 db2;
  if [[ $(echo "$db2" | od) = "$backspace" ]]&&[[ ${#WORD_STR} -gt 0 ]];then  WORD_STR="${WORD_STR::-1}";PLACEHOLDER_STR="$WORD_STR""$PAD";fi;
  if [[ $(echo "$db2" | od) = "$delete" ]]&&[[ ${#WORD_STR} -gt 0 ]];then clear; WORD_STR="";PLACEHOLDER_STR="$WORD_STR""$PAD";fi;
  case $db2 in
   "Q") clear;quit_puzzle;db="";main_menu_reset;
   ;;
   [a-z]) clear;if [[ ${#WORD_STR} -le 5 ]];then WORD_STR="$WORD_STR""$db2";PLACEHOLDER_STR="$WORD_STR""$PAD";fi;
   ;;
   "") clear;enter_word;
   ;;
   "W") clear; echo -e "     ${Y}╭───╮╭───╮╭───╮╭───╮  ╭───╮╭───╮╭───╮╭───╮\n     │ W ││ O ││ R ││ D │  │ L ││ I ││ S ││ T │\n     ╰───╯╰───╯╰───╯╰───╯  ╰───╯╰───╯╰───╯╰───╯ ${n}\n\n"
   grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v 'xx'|grep -v 'vii'|grep -v '[^[:lower:]]'|grep -E ^....$|column -x -c 80;
   echo -e "${Y}${bold}Press any key to return${n}";read -sN 1 v;clear;
   ;;
  *)clear;
  esac
 done
 db2=""
}
function main_menu ()
{
 while [ "$db" != "5" ]
 do
  echo -e "${W}╭───────────────────────────────────╮"
  echo -e "${W}│  ${G}╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮   ${W}│\n│  ${G}│ L ││ A ││ D ││ D ││ E ││ R │   ${W}│\n│  ${G}╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯   ${W}│\n├───────────────────────────────────┤\n│   ${C}${bold}Transform one word to another ${W}  │"
  echo -en "├───────────────────────────────────┤\n│${n}Enter:                            ${W} │\n│ ${Y}${bold}1${n} to ${G}${bold}Play New Game.  ${W}             │\n│ ${Y}${bold}2${n} to ${C}${bold}Read the Rules.  ${W}            │\n│ ${Y}${bold}3"${n}" to ${C}${bold}Edit Preferences.  ${W}          │\n│ ${Y}${bold}4"${n}" to ${C}${bold}Show Statistics.  ${W}           │\n│ ${Y}${bold}5${n} to ${R}${bold}Exit. ${W}                       │\n"
  echo  -e "╰───────────────────────────────────╯\n${n}"
  read -sN 1  db
  case $db in
   1)clear;new_game;play_menu;clear;
   ;;
   2) clear;rules;
   ;;
   3) clear;eval "$PREFERRED_EDITOR" "$CONFIG_FILE"; load_config;load_colors;tput civis;clear
   ;;
   4) clear;show_statistics;echo -e "\n${W}Press any key to return${n}";read -sN 1 v;tput civis;clear;
   ;;
   5) clear;notify-send -t 5000 -i $PREFERRED_PNG "Exited Ladder";
   ;;
   *)clear;echo -e "\n😕 ${Y}${bold}$db${n} is an invalid key, please try again.\n"   ;
  esac
 done
}
function cursor_reappear() {
tput cnorm
exit
}
#===============================================================================
clear
#detect BACKSPACE, solution found https://stackoverflow.com/questions/4196161/bash-read-backspace-button-behavior-problem
backspace=$(cat << eof
0000000 005177
0000002
eof
)
delete=$(cat << eof
0000000 005033
0000002
eof
)
trap cursor_reappear HUP INT QUIT TERM EXIT ABRT
tput civis # make cursor invisible
load_config
load_colors
db=""
main_menu_reset
db2=""
main_menu
