#! /bin/sh

set -e

progress_bar()
{
    local DURATION=$1
    local INT=0.25      # refresh interval

    local TIME=0
    local CURLEN=0
    local SECS=0
    local FRACTION=0

    local FB=2588       # full block

    trap "echo -e $(tput cnorm); trap - SIGINT; return" SIGINT

    echo -ne "$(tput civis)\r$(tput el)│"                # clean line

    local START=$( date +%s%N )

    while [ $SECS -lt $DURATION ]; do
    local COLS=$( tput cols )

    # main bar
    local L=$( bc -l <<< "( ( $COLS - 5 ) * $TIME  ) / ($DURATION-$INT)" | awk '{ printf "%f", $0 }' )
    local N=$( bc -l <<< $L                                              | awk '{ printf "%d", $0 }' )

    [ $FRACTION -ne 0 ] && echo -ne "$( tput cub 1 )"  # erase partial block

    if [ $N -gt $CURLEN ]; then
        for i in $( seq 1 $(( N - CURLEN )) ); do
            if [ $FB -eq 2588 ]; then
                printf '\xE2\x96\x88'
            else
                printf '\xE2\x96\x8F'
            fi
        done
        CURLEN=$N
    fi

    # partial block adjustment
    FRACTION=$( bc -l <<< "( $L - $N ) * 8" | awk '{ printf "%.0f", $0 }' )

    if [ $FRACTION -ne 0 ]; then
        local PB=$( printf %x $(( 0x258F - FRACTION + 1 )) )
        if [ $FB -eq 2588 ]; then
            printf '\xE2\x96\x88'
        else
            printf '\xE2\x96\x8F'
        fi
    fi

    # percentage progress
    local PROGRESS=$( bc -l <<< "( 100 * $TIME ) / ($DURATION-$INT)" | awk '{ printf "%.0f", $0 }' )
    echo -ne "$( tput sc )"                            # save pos
    echo -ne "\r$( tput cuf $(( COLS - 6 )) )"         # move cur
    echo -ne "│ $PROGRESS%"
    echo -ne "$( tput rc )"                            # restore pos

    TIME=$( bc -l <<< "$TIME + $INT" | awk '{ printf "%f", $0 }' )
    SECS=$( bc -l <<<  $TIME         | awk '{ printf "%d", $0 }' )

    # take into account loop execution time
    local END=$( date +%s%N )
    local DELTA=$( bc -l <<< "$INT - ( $END - $START )/1000000000" \
                   | awk '{ if ( $0 > 0 ) printf "%f", $0; else print "0" }' )
    sleep $DELTA
    START=$( date +%s%N )
    done

    echo $(tput cnorm)
    trap - SIGINT

    # License
    #
    # This script is free software; you can redistribute it and/or modify it
    # under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.
    #
    # This script is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.
    #
    # You should have received a copy of the GNU General Public License
    # along with this script; if not, write to the
    # Free Software Foundation, Inc., 59 Temple Place, Suite 330,
    # Boston, MA  02111-1307  USA
}

function run()
{
    chmod +x ./submit.sh
    ./submit.sh $tower_number
    echo -e "\n-----------------------------------------------"
    echo -e "\nThis process is intentionally delayed for 10 seconds\n"
    progress_bar 10

    chmod 755 manage_number.sh
    nohup ./manage_number.sh $manage_start_tower
    echo -e "\n-----------------------------------------------"
    echo -e "\nManaging script runs in the background.\n"
}

function set_numbers()
{
    echo -e
    read -p "Tower # you want to start with : " start_tower

    echo -e "\nRun batch jobs : starting from tower $start_tower"
    echo -e "\n-----------------------------------------------\n"
    echo "If the above description is correct, select Run, otherwise select Quit"
    PS3="Select: "
    options=("Run" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Run")
            run
            echo -e "-----------------------------------------------"
            echo -e "\nJob submit complete.\n"
            echo -e "-----------------------------------------------"
            break;;

            "Quit")
            echo -e "\n-----------------------------------------------"
            echo -e "\nExit the program.\n"
            echo -e "###############################################"
            echo -e "#                                             #"
            echo -e "#           Automation script ended           #"
            echo -e "#                                             #"
            echo -e "###############################################"
            exit;;

            *) echo "$REPLY is an invalid option.";;
        esac
    done
}

function set_env()
{
    export BATCH_SYS=${options[$(($REPLY-1))]}
    export INSTALLED_DIR=`pwd`

    echo -e "\n-----------------------------------------------"
    echo -e "\nSetting env. It takes few seconds."

    source ./setenv-cc7-gcc8.sh

    echo "Environment variables are successfully set."
    echo -e "\nNow you should type in the followings.\n"
    echo -e "-----------------------------------------------"
    set_numbers

}

function the_main()
{
    echo -e "###############################################"
    echo -e "#                                             #"
    echo -e "#   Automation script for Calibration (EIC)   #"
    echo -e "#                                             #"
    echo -e "###############################################"

    echo -e "\nRun calibration script?"
    PS3="Select: "
    options=("Yes" "No")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
            set_env
            echo -e "\nYou may now close the terminal.\n"

            echo -e "###############################################"
            echo -e "#                                             #"
            echo -e "#           Automation script ended           #"
            echo -e "#                                             #"
            echo -e "###############################################"

            break;;

            "No")
            echo -e "\nYou should use proper script.\n"

            echo -e "###############################################"
            echo -e "#                                             #"
            echo -e "#           Automation script ended           #"
            echo -e "#                                             #"
            echo -e "###############################################"
            exit;;

            *) echo "$REPLY is an invalid option.";;
        esac
    done
}

the_main
