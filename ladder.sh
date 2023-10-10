#! /bin/bash
#					╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮
#     │ W ││ E ││ A ││ V ││ E ││ R │
#     ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯
#A bash script written by Christos Angelopoulos, October 2023, under GPL v2
Y="\033[1;33m"
G="\033[1;32m"
C="\033[1;36m"
M="\033[1;35m"
R="\033[1;31m"
B="\033[1;34m"
W="\033[1;37m"
bold=`tput bold`
n=`tput sgr0`
#LINE 17 contains the address of the word list. .
#Each user is free to modify this line in order to play the game using the word list of their liking.
WORD_LIST="/usr/share/dict/words"
TOTAL_SOLUTIONS="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v '[^[:lower:]]'|grep -E ^....$)"


function quit_puzzle ()
{
	echo -e "     ${G}╭───╮${R}╭───╮╭───╮╭───╮╭───╮     \n     ${G}│ U │${R}│ Q ││ U ││ I ││ T │     \n     ${G}╰───╯${R}╰───╯╰───╯╰───╯╰───╯ ${n}    \n\n"
	echo "$TRY lose">>$HOME/.cache/ladder/statistics.txt
	echo -e "\nPress any key to return"
	read -sN 1 v;clear;
}

function show_statistics () {
	echo -e "     ${Y}╭───╮╭───╮╭───╮╭───╮╭───╮     \n     │ S ││ T ││ A ││ T ││ S │     \n     ╰───╯╰───╯╰───╯╰───╯╰───╯ ${n}    \n\n"
	PLAYED="$(cat $HOME/.cache/ladder/statistics.txt|wc -l)"
	WON="$(grep 'win' $HOME/.cache/ladder/statistics.txt|wc -l)"
	SUC_RATIO="$(echo "scale=2; $WON *100/ $PLAYED" | bc)"
	RECORD="$(grep 'win' $HOME/.cache/ladder/statistics.txt|sort -h |head -1|awk '{print $1}')"
	MAX_ROW="$(awk '{print $2}' $HOME/.cache/ladder/statistics.txt|uniq -c|grep 'win'|head -1|awk '{print $1}')"
	if [[ "$(tail -1 $HOME/.cache/ladder/statistics.txt)" == "lose" ]]
	then
		CURRENT_ROW="0"
	else
		CURRENT_ROW="$(awk '{print $2}' $HOME/.cache/ladder/statistics.txt|uniq -c|grep 'win'|tail -1|awk '{print $1}')"
	fi
	echo -e " Games Played   : $PLAYED\n Games Won      : $WON\n Games Lost     : $(($PLAYED-$WON))\n Success ratio  : $SUC_RATIO%\n Record Guesses : $RECORD\n Record streak  : $MAX_ROW wins\n Current streak : $CURRENT_ROW wins"|lolcat -p 3000 -a -s 40 -F 0.3 -S 18
}

function win_game ()
{
	clear
	((TRY++))
	echo "$TRY win">>$HOME/.cache/ladder/statistics.txt
	F[TRY]="GGGG"
	print_box
	MESSAGE="  You made it after ${R}$TRY ${Y}tries              "
	echo -e "│${Y}       Congratulations!      ${n} │"
	echo -e "│${Y}${bold}${MESSAGE:0:50}${n}│";
	echo "╰──────────────────────────────╯"
	A=${PLACEHOLDER_STR^^}
	#echo -e "${Y}${bold}Congratulations!"
	#echo -e "${Y}${bold}You made it after ${R}$TRY ${Y}tries!${n}\n"
	echo -e "\nPress any key to return"
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
		then 		COMMENT=" Enter new word"
		elif [[ $CHANGES -gt 1 ]]
		then  COMMENT="Change ONLY ONE LETTER"
		else
			COMMENT=" Last word: $WORD_STR"
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
	echo "╭──────────────────────────────╮"
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
echo -e "│     ${K[0]}╭───╮${K[1]}╭───╮${K[2]}╭───╮${K[3]}╭───╮${n}     │\n│     ${K[0]}│ ${A:0:1} │${K[1]}│ ${A:1:1} │${K[2]}│ ${A:2:1} │${K[3]}│ ${A:3:1} │${n}     │\n│     ${K[0]}╰───╯${K[1]}╰───╯${K[2]}╰───╯${K[3]}╰───╯${n}     │"
	((t++))
done
if [[ ${F[TRY]} != "GGGG" ]]
then
	A=${PLACEHOLDER_STR^^}
	echo -e "│     ╭───╮╭───╮╭───╮╭───╮     │\n│     │ ${A:0:1} ││ ${A:1:1} ││ ${A:2:1} ││ ${A:3:1} │     │\n│     ╰───╯╰───╯╰───╯╰───╯     │"
fi
	echo -e "│     "${G}"╭───╮╭───╮╭───╮╭───╮"${n}"     │\n│     "${G}"│ ${T0:0:1} ││ ${T0:1:1} ││ ${T0:2:1} ││ ${T0:3:1} │     "${n}"│\n│     "${G}"╰───╯╰───╯╰───╯╰───╯    "${n}" │"
	echo  "├──────────────────────────────┤"
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
${C}	╭───╮╭───╮${G}╭───╮╭───╮${n}
${C}	│ E ││ A │${G}│ S ││ T │${n}
${C}	╰───╯╰───╯${G}╰───╯╰───╯${n}(Initial word)
${C}	╭───╮╭───╮${G}╭───╮╭───╮${n}
${C}	│ P ││ A │${G}│ S ││ T │${n}
${C}	╰───╯╰───╯${G}╰───╯╰───╯${n}(Substitute E for P)
${C}	╭───╮${G}╭───╮╭───╮╭───╮${n}
${C}	│ P │${G}│ E ││ S ││ T │${n}
${C}	╰───╯${G}╰───╯╰───╯╰───╯${n}(Substitute A for E)
	${G}╭───╮╭───╮╭───╮╭───╮
	│ N ││ E ││ S ││ T │
	╰───╯╰───╯╰───╯╰───╯${n}(Mission Accomplished)

${Y}${bold}GOOD LUCK!${n}
Press any key to return"
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
	GUESS[0]="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v '[^[:lower:]]'|grep -E ^....$|shuf|head -1)"
	# T for TARGET WORD
	T="$(grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v '[^[:lower:]]'|grep -E ^....$|shuf|head -1)"
	T0=${T^^}
	check_guess ${GUESS[0]}
	F[0]=$(echo ${F0[@]}|sed 's/ //g')
	TRY=1
}

function play_menu () {
	while [[ $db2 != "Q" ]]
	do
		print_box
		echo -en "│ ${Y}${bold}<enter>${n}       to ${G}${bold}ACCEPT word${n} │\n│ ${Y}${bold}<delete>${n}       to ${R}${bold}ABORT word${n} │\n│ ${Y}${bold}<backspace>${n} to ${R}${bold}DELETE letter${n} │\n├──────────────────────────────┤\n│ ${Y}${bold}W${n}          to show ${C}${bold}WORD LIST${n} │\n├──────────────────────────────┤\n│ ${Y}${bold}Q${n}               to ${R}${bold}QUIT GAME${n} │\n├──────────────────────────────┤\n│${COMMENT_STR:0:30}│\n╰──────────────────────────────╯\n"
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
			grep -v "'" "$WORD_LIST"|grep -v -E [ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]|grep -v '[^[:lower:]]'|grep -E ^.....$|column -x -c 80;
			echo -e "${Y}${bold}Press any key to return${n}";read -sN 1 v;clear;
			;;
		*)clear;
		esac
	done
	db2=""
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
db=""
main_menu_reset
db2=""
while [ "$db" != "4" ]
do
	echo "${n}╭───────────────────────────────────╮"
	echo -e "${n}│  ${G}╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮   ${n}│\n│  ${G}│ L ││ A ││ D ││ D ││ E ││ R │   ${n}│\n│  ${G}╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯   ${n}│\n├───────────────────────────────────┤\n│   ${C}${bold}Transform one word to another ${n}  │"
	echo -en "├───────────────────────────────────┤\n│Enter:                             │\n│ ${Y}${bold}1${n} to ${G}${bold}Play New Game.  ${n}             │\n│ ${Y}${bold}2${n} to ${C}${bold}Read the Rules.  ${n}            │\n│ ${Y}${bold}3"${n}" to ${C}${bold}Show Statistics.  ${n}           │\n│ ${Y}${bold}4${n} to ${R}${bold}Exit. ${n}                       │\n"
	echo  -e "╰───────────────────────────────────╯\n"
	read -sN 1  db
	case $db in
		1)clear;new_game;play_menu;clear;
		;;
		2) clear;rules;
		;;
		3) clear;show_statistics;echo -e "\nPress any key to return";read -sN 1 v;clear;
		;;
		4) clear;notify-send -t 5000 -i $HOME/.cache/ladder/ladder.png "🅴🆇🅸🆃🅴🅳
🅻🅰🅳🅳🅴🅡";
		;;
		*)clear;echo -e "\n😕 ${Y}${bold}$db${n} is an invalid key, please try again.\n"			;
	esac
done
