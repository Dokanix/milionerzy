# Author           : Dominik Piotrowicz ( dom.piotrowicz@gmail.com )
# Created On       : 20.05.2020
# Last Modified By : Dominik Piotrowicz ( dom.piotrowicz@gmail.com )
# Last Modified On : 20.05.2020
# Version          : 2.1
#
# Description      : Gra milionerzy na bazie znanego teleturnieju
# Opis
#
# Licensed under GPL


add_question() {
    read -p "Pytanie: " Q
    echo $Q >> pytania.txt
    read -p "Odpowiedź A: " A1
    echo $A1 >> pytania.txt
    read -p "Odpowiedź B: " A2
    echo $A2 >> pytania.txt
    read -p "Odpowiedź C: " A3
    echo $A3 >> pytania.txt
    read -p "Odpowiedź D: " A4
    echo $A4 >> pytania.txt
    read -p "Poprawna odpowiedź: " A
    echo $A >> pytania.txt
}


if [ "$#" -gt 0 ]; then
    if [ "$1" == "-v" ]; then
        echo "Wersja 2.1"
    elif [ "$1" == "-a" ]; then
        add_question
    else
        echo "milionerzy [-v] [-a]"
    fi
    exit
fi

RED=$(tput setaf 1)
REDBG='\033[41m'
GREEN=$(tput setaf 2)
GREENBG='\033[42m'
NC=$(tput sgr0)
YELLOW=$(tput setaf 3)
BLUE='\033[94m'
BLUEBG='\033[44m'
GRAY='\033[90m'

FASTMODE=$(sed "1q;d" ustawienia.txt)
NARRATOR=$(sed "2q;d" ustawienia.txt)

FIFTY=1
PUBLIC=1
NEXT=1

CURR_ROUND=1
END=0
ROUNDS=12
SKIP=0

PREQ_M=""

print_money() {
    case "$CURR_ROUND" in
        "0") echo -e "${BLUEBG}0.5k${NC} -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k -> 1M";;
        "1") echo -e "${BLUEBG}0.5k${NC} -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k -> 1M";;
        "2") echo -e "${GREEN}0.5k${NC} -> ${BLUEBG}1k${NC} -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k -> 1M";;
        "3") echo -e "${GREEN}0.5k -> 1k${NC} -> ${BLUEBG}2k${NC} -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k -> 1M";;
        "4") echo -e "${GREEN}0.5k -> 1k -> 2k${NC} -> ${BLUEBG}5k${NC} -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 0.5kk -> 1M";;
        "5") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k${NC} -> $BLUEBG}10k${NC} -> 20k -> 40k -> 75k -> 125k -> 250k -> 0.5kk -> 1M";;
        "6") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k${NC} -> ${BLUEBG}20k${NC} -> 40k -> 75k -> 125k -> 250k -> 0.5kk -> 1M";;
        "7") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k${NC} -> ${BLUEBG}40k${NC} -> 75k -> 125k -> 250k -> 0.5kk -> 1M";;
        "8") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k${NC} -> ${BLUEBG}75k${NC} -> 125k -> 250k -> 0.5kk -> 1M";;
        "9") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k${NC} -> ${BLUEBG}125k${NC} -> 250k -> 0.5kk -> 1M";;
        "10") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k${NC} -> ${BLUEBG}250k${NC} -> 500k -> 1M";;
        "11") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k${NC} -> ${BLUEBG}500k${NC} -> 1M";;
        "12") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k${NC} -> ${BLUEBG}1M${NC}";;
        "13") echo -e "${GREEN}0.5k -> 1k -> 2k -> 5k -> 10k -> 20k -> 40k -> 75k -> 125k -> 250k -> 500k -> 1M${NC}";;
        *) echo "ERROR"; stty echo; exit;;
    esac
}

prompt_continue() {
    echo -e "${GRAY}Naciśnij enter by kontynuować...${NC}"
    stty echo
    read CONTINUE
}

print_helpers() {
    HELPERS[0]="1. 50/50"
    HELPERS[1]="2. Publiczność"
    HELPERS[2]="3. Zmiana"

    if [ "$FIFTY" == 1 ]; then
        COLORS[0]=${NC}
    else
        COLORS[0]=${RED}
    fi

    if [ "$PUBLIC" == 1 ]; then
        COLORS[1]=${NC}
    else
        COLORS[1]=${RED}
    fi

    if [ "$NEXT" == 1 ]; then
        COLORS[2]=${NC}
    else
        COLORS[2]=${RED}
    fi

    printf "%s%-20s%s %s%-20s%s %s%-20s%s\n" "${COLORS[0]}" "${HELPERS[0]}" "${NC}" "${COLORS[1]}" "${HELPERS[1]}" "${NC}" "${COLORS[2]}" "${HELPERS[2]}" "${NC}"
}

print_options() {
    printf "%-20s %-20s %-20s\n" "O - opcje" "Q - wyjśćie" "L - lista wygranych"
}

confirm_game() {
    while true; do
        echo -e "${RED}Uwaga! Rozpoczęcie gry spowoduje wyczyszczenie okna konsoli. Kontynuować? (t/n)${NC}"
        read CONFIRM
        case $CONFIRM in
            [Tt]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Odpowiedz Tak lub Nie";;
        esac
    done
}

welcome_message() {
    stty -echo
    clear

    echo -e "${YELLOW}WITAMY W MILIONERACH!\n"

    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    echo -e "${NC}Twoje zadanie polega na odpowiadaniu na kolejne pytania."
    echo -e "Jeśli uda ci się odpowiedzieć na wszystkie 9 czeka cię główna nagroda\n"

    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    echo -e "Pamiętaj, że masz do dyspozycji trzy koła ratunkowe:"
    echo -e "${YELLOW}Pół na pół${NC}: Wyrzuca dwie niepoprawne odpowiedzi"
    echo -e "${YELLOW}Zamiana${NC}: Dostajesz inne pytanie z naszej puli"
    echo -e "${YELLOW}Pytanie do publiczności:${NC} Pokazujemy ci jak na dane pytanie odpowiedzieli inni\n"

    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    echo -e "Pamiętaj, że każdego koła ratunkowego możesz uzyć tylko raz"
    echo -e "Jeśli się pomylisz - ${RED}Odpadasz!${NC}"
    echo -e "A teraz... Powodzenia!"

    prompt_continue
    stty -echo
}

before_question_message() {
    if [ "$NARRATOR" == 1 ]; then
        PREQ[0]="${BLUE}Czy nasz gość poradzi sobie z następnym pytaniem?${NC}"
        PREQ[1]="${BLUE}Wielu poległo w tym miejscu, myślisz, że podzielisz ich los?${NC}"
        PREQ[2]="${BLUE}Nie wiem kto wymyśla te pytania, no ale lecimy...${NC}"
        PREQ[3]="${BLUE}Wygląda na to, że trafiło ci się trudne pytanie${NC}"
        PREQ[4]="${BLUE}Nie wiem jakim cudem mógłbyś nie znać odpowiedzi na następne pytanie${NC}"
        PREQ[5]="${BLUE}Kolejne pytanie!${NC}"
        PREQ[6]="${BLUE}Oj głupio byłoby odpaść w rundzie numer ${CURR_ROUND}${NC}"
        PREQ[7]="${BLUE}Internauci nie mieli problemu z następnym pytaniem, a więc...${NC}"
        PREQ[8]="${BLUE}Wydaję mi się, że gdzieś już to słyszałem${NC}"
        PREQ[9]="${BLUE}Nawet nie próbuj używać googla do następnego pytania${NC}"
        PREQ[10]="${BLUE}Nie słyszałem jeszcze nic głupszego${NC}"
        PREQ[11]="${BLUE}Przed tobą kolejne pytanie, zobaczymy jak sobie poradzisz${NC}"
        PREQ[12]="${BLUE}Już za chwilę kolejne pytanie, jesteś gotów?${NC}"

        RAND=$((RANDOM % 13))
        PREQ_M=${PREQ[RAND]}
        echo -e ${PREQ_M}
    fi
}

after_answer_message() {
    if [ "$NARRATOR" == 1 ]; then
        AFTA[0]="${BLUE}Wybrałeś odpowiedź, jednak za chwilę dowiemy się czy miałeś racje...${NC}"
        AFTA[1]="${BLUE}Ryzykowny wybór, ale...${NC}"
        AFTA[2]="${BLUE}Co za emocje, a werdykt brzmi...${NC}"
        AFTA[3]="${BLUE}Nie jestem pewien czy publiczność zgadza się z twoim wyborem, ale to...${NC}"
        AFTA[4]="${BLUE}To co za tobą nie ma znaczenia, liczy się tylko to, że jest to...${NC}"
        AFTA[5]="${BLUE}Współczuję ci stresu, ale muszę ci powiedzieć, że to...${NC}"
        AFTA[6]="${BLUE}Nie wiem jakim cudem jeszcze tu jesteś, ale to...${NC}"
        AFTA[7]="${BLUE}Chciałbym widzieć twoją minę gdy to powiem...${NC}"
        AFTA[8]="${BLUE}Wybrałeś swoją odpowiedź i jest to...${NC}"
        AFTA[9]="${BLUE}Mam wrażenie, że strzelałeś, ale...${NC}"
        AFTA[10]="${BLUE}Twój wybór to...${NC}"
        AFTA[11]="${BLUE}Muszę ci powiedzieć, że jest to...${NC}"
        AFTA[12]="${BLUE}Właśnie mogłeś wszystko stracić. Twój wybór to...${NC}"
        RAND=$((RANDOM % 13))
        echo -e ${AFTA[RAND]}
        if [ "$FASTMODE" == 0 ]; then sleep 3; fi
    fi
}

add_winner() {
    clear

    print_money
    echo -e "${BLUE}Jak się nazywasz?${NC}"
    read NAME
    echo -e "${BLUE}Gratuluję, ${YELLOW}${NAME}!${BLUE} Zostałeś dodany do listy zwycięzców!${NC}"
    DATE=$(date)

    echo "${NAME} / ${DATE}" >> 'wygrani.txt'
}

print_ui() {
    clear
    print_money
    print_options
    print_helpers
    echo -e ${PREQ_M}
    echo -e "${YELLOW}$QUESTION${NC}"
    echo -e "${YELLOW}A:${NC} $ANSWER_A"
    echo -e "${YELLOW}B:${NC} $ANSWER_B"
    echo -e "${YELLOW}C:${NC} $ANSWER_C"
    echo -e "${YELLOW}D:${NC} $ANSWER_D"
}

print_question() {
    clear
    print_money
    print_options
    print_helpers
    
    echo -e ${PREQ_M}
    
    echo -e "${YELLOW}$QUESTION${NC}"

    if [ "$ANSWER" == "A" ]; then
        if [ "$ANSWER" == "$ANSWER_GOOD" ]; then
            echo -e "${GREENBG}A: $ANSWER_A${NC}"
        else
            echo -e "${REDBG}A: $ANSWER_A${NC}"
        fi
    else
        echo -e "${YELLOW}A:${NC} $ANSWER_A"
    fi
    if [ "$ANSWER" == "B" ]; then
        if [ "$ANSWER" == "$ANSWER_GOOD" ]; then
            echo -e "${GREENBG}B: $ANSWER_B${NC}"
        else
            echo -e "${REDBG}B: $ANSWER_B${NC}"
        fi
    else
        echo -e "${YELLOW}B:${NC} $ANSWER_B"
    fi
    if [ "$ANSWER" == "C" ]; then
        if [ "$ANSWER" == "$ANSWER_GOOD" ]; then
            echo -e "${GREENBG}C: $ANSWER_C${NC}"
        else
            echo -e "${REDBG}C: $ANSWER_C${NC}"
        fi
    else
        echo -e "${YELLOW}C:${NC} $ANSWER_C"
    fi
    if [ "$ANSWER" == "D" ]; then
        if [ "$ANSWER" == "$ANSWER_GOOD" ]; then
            echo -e "${GREENBG}D: $ANSWER_D${NC}"
        else
            echo -e "${REDBG}D: $ANSWER_D${NC}"
        fi
    else
        echo -e "${YELLOW}D:${NC} $ANSWER_D"
    fi
    
    echo -e ${AFTQ_M}

    if [ "$ANSWER" == "$ANSWER_GOOD" ]; then
        echo -e "${GREEN}PRAWIDŁOWA ODPOWIEDŹ!${NC}"

        if [ "$CURR_ROUND" == $ROUNDS ]; then
            echo -e "${BLUE}Proszę państwa... MAMY ZWYCIĘZCĘ!${NC}"
            prompt_continue
            CURR_ROUND=$((CURR_ROUND+1))
            stty echo
            add_winner
            exit
        fi

        CURR_ROUND=$((CURR_ROUND+1))
    else
        echo -e "${RED}ZŁA ODPOWIEDŹ!${NC}"
        stty echo
        exit
    fi

    prompt_continue
}

set_options() {
    stty echo

    while true; do
        read -p "Czy chcesz włączyć tryb szybki? (t/n) " OPTION
        case $OPTION in
            [Tt]* ) echo "1" > 'ustawienia.txt'; FASTMODE=1; break;;
            [Nn]* ) echo "0" > 'ustawienia.txt'; FASTMODE=0; break;;
            * ) echo "Wybierz Tak lub Nie";
        esac
    done

        while true; do
        read -p "Czy chcesz włączyć narratora? (t/n) " OPTION
        case $OPTION in
            [Tt]* ) echo "1" >> 'ustawienia.txt'; NARRATOR=1; break;;
            [Nn]* ) echo "0" >> 'ustawienia.txt'; NARRATOR=0; break;;
            * ) echo "Wybierz Tak lub Nie";
        esac
    done

    print_ui
}

print_winners() {
    cat wygrani.txt

    prompt_continue

    print_ui
}

use_half() {
    print_ui

    echo -e "${YELLOW}Użyto 50/50!${NC}"
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    if [[ "$ANSWER_GOOD" == "A" || "$ANSWER_GOOD" == "B" ]]; then
        echo -e "${YELLOW}A:${NC} $ANSWER_A"
        echo -e "${YELLOW}B:${NC} $ANSWER_B"
    elif [[ "$ANSWER_GOOD" == "C" || "$ANSWER_GOOD" == "D" ]]; then
        echo -e "${YELLOW}C:${NC} $ANSWER_C"
        echo -e "${YELLOW}D:${NC} $ANSWER_D"
    fi

    prompt_continue
    print_ui
}

use_public() {
    print_ui

    echo -e "${YELLOW}Użyto Publiczności!${NC}"
    SUM=0

    NUMBERS[0]=$((55+RANDOM%45))
    ((SUM+=NUMBERS[0]))
    NUMBERS[1]=$((RANDOM%100))
    ((SUM+=NUMBERS[1]))
    NUMBERS[2]=$((RANDOM%100))
    ((SUM+=NUMBERS[2]))
    NUMBERS[3]=$((RANDOM%100))
    ((SUM+=NUMBERS[3]))

    NUMBERS[0]=$((100*${NUMBERS[0]}/SUM))
    NUMBERS[1]=$((100*${NUMBERS[1]}/SUM))
    NUMBERS[2]=$((100*${NUMBERS[2]}/SUM))
    NUMBERS[3]=$((100*${NUMBERS[3]}/SUM))
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    if [ "$ANSWER_GOOD" == "A" ]; then
        echo -e "${YELLOW}A:${NC} ${NUMBERS[0]}%"
        echo -e "${YELLOW}B:${NC} ${NUMBERS[1]}%"
        echo -e "${YELLOW}C:${NC} ${NUMBERS[2]}%"
        echo -e "${YELLOW}D:${NC} ${NUMBERS[3]}%"
    elif [ "$ANSWER_GOOD" == "B" ]; then
        echo -e "${YELLOW}A:${NC} ${NUMBERS[3]}%"
        echo -e "${YELLOW}B:${NC} ${NUMBERS[0]}%"
        echo -e "${YELLOW}C:${NC} ${NUMBERS[1]}%"
        echo -e "${YELLOW}D:${NC} ${NUMBERS[2]}%"
    elif [ "$ANSWER_GOOD" == "B" ]; then
        echo -e "${YELLOW}A:${NC} ${NUMBERS[2]}%"
        echo -e "${YELLOW}B:${NC} ${NUMBERS[3]}%"
        echo -e "${YELLOW}C:${NC} ${NUMBERS[0]}%"
        echo -e "${YELLOW}D:${NC} ${NUMBERS[1]}%"
    elif [ "$ANSWER_GOOD" == "B" ]; then
        echo -e "${YELLOW}A:${NC} ${NUMBERS[1]}%"
        echo -e "${YELLOW}B:${NC} ${NUMBERS[2]}%"
        echo -e "${YELLOW}C:${NC} ${NUMBERS[3]}%"
        echo -e "${YELLOW}D:${NC} ${NUMBERS[0]}%"
    fi

    prompt_continue
    print_ui
}

use_next() {
    print_ui
    echo -e "${YELLOW}Użyto Zmiany pytania!${NC}"
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi

    prompt_continue
    print_ui
}

ask_question() {
    clear
    print_money
    print_options
    print_helpers
    stty -echo

    # Reads question and answers from file
    QUESTION=$(sed "1q;d" pytania.txt)
    ANSWER_A=$(sed "2q;d" pytania.txt)
    ANSWER_B=$(sed "3q;d" pytania.txt)
    ANSWER_C=$(sed "4q;d" pytania.txt)
    ANSWER_D=$(sed "5q;d" pytania.txt)
    ANSWER_GOOD=$(sed "6q;d" pytania.txt)

    sed '1,6{1h;1!H;d};$G' pytania.txt | tee 'pytania.txt' > /dev/null
    
    # Prints question and answers on screen
    before_question_message
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi
    echo -e "${YELLOW}$QUESTION${NC}"
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi
    echo -e "${YELLOW}A:${NC} $ANSWER_A"
    if [ "$FASTMODE" == 0 ]; then sleep 1; fi
    echo -e "${YELLOW}B:${NC} $ANSWER_B"
    if [ "$FASTMODE" == 0 ]; then sleep 1; fi
    echo -e "${YELLOW}C:${NC} $ANSWER_C"
    if [ "$FASTMODE" == 0 ]; then sleep 1; fi
    echo -e "${YELLOW}D:${NC} $ANSWER_D"
    if [ "$FASTMODE" == 0 ]; then sleep 1; fi

    stty echo

    while true; do
        read -p "> " ANSWER
        case $ANSWER in
            [Qq]* ) echo -e "${BLUE}Do zobaczenia!${NC}"; exit;;
            [Oo]* ) set_options;;
            [Ll]* ) print_winners;;
            [Aa]* ) ANSWER="A"; break;;
            [Bb]* ) ANSWER="B"; break;;
            [Cc]* ) ANSWER="C"; break;;
            [Dd]* ) ANSWER="D"; break;;
            [1]* ) if [ "$FIFTY" == 1 ]; then FIFTY=0; use_half; fi;;
            [2]* ) if [ "$PUBLIC" == 1 ]; then PUBLIC=0; use_public; fi;;
            [3]* ) if [ "$NEXT" == 1 ]; then NEXT=0; use_next; fi; SKIP=1; break;;
            * ) echo "Niepoprawna komenda";;
        esac
    done

    stty -echo
    after_answer_message
    if [ "$FASTMODE" == 0 ]; then sleep 2; fi
    if [ "$SKIP" == 0 ]; then print_question; fi
    SKIP=0
}

confirm_game

welcome_message

while true; do
    ask_question
done