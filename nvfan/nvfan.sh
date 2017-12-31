#!/bin/bash
#------------------------------------------# Settings #--------------------------------------------#
#Logger flag. When 1, every call is logged to journalctl
log=0 #default

#Number of seconds between updates
polltime=2

# range[i]: Temperature range 'i' at which to set a fan speed
# speed[i]: Speed of fans (%) on temperature range 'i'
range[0]="0 29"
speed[0]=0
range[1]="30 40"
speed[1]=50
range[2]="41 50"
speed[2]=70
range[3]="51 58"
speed[3]=85
range[4]="59 200"
speed[4]=100

#------------------------------------------# Constants #-------------------------------------------#
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m' # reset colour

WARNING=${YELLOW}'[Warning]'${RESET}
ERROR=${RED}'[Error]'${RESET}
OK=${GREEN}'(!)'${RESET}
EXEC=${BLUE}'(!)'${RESET}
KILL=${YELLOW}'(!)'${RESET}

#-------------------------------------------# Methods #--------------------------------------------#
usage () {
    echo "|================= NVIDIA GPU Fan Controller v1.0 ==================|"
    echo "|······· Made by An7ar35, 2017 · https://an7ar35.bitbucket.io ······|"
    echo "|===================================================================|"
    echo "  Description:"
    echo "    Script controlling the fan speed of an NVIDIA card based on temperatures"
    echo "    To be used by the systemd service of the same name."
    echo "    Adapted from Artem S. Tashkinov adaptive fan speed management script."
    echo "  Usage:"
    echo "    ./nvfan [-a] [-s <speed of fan in %>] [-r]"
    echo "  Options:"
    echo "    -a  Start the automatic fan speed controller process based on the presets."
    echo "    -s  Set % speed of fan <speed>. Kills the auto fan speed process."
    echo "    -r  Reset the GPU fan management. Kills the auto fan speed process.";
}

############################################################
# Checks that fan speed management is supported on the GPU #
############################################################
checkGPU() {
    result='nvidia-settings -a [gpu:0]/GPUFanControlState=1 | grep "assigned value 1"'
    test -z "$result" && echo "NVIDIA Fan speed management is not supported on this GPU." | systemd-cat -t nvfan -p err && return 0
    return 1
}

##################################################################
# Kills all 'nvfan' running processes that are not this instance #
##################################################################
killProcesses() {
    pids=`/bin/ps -fu ${USER}| awk '/nvfan/ && /-a/ && !/awk/ && !/grep/ {print $2 " " $3}'`

    if [ $(echo ${#pids}) -gt 0 ]; then
        if (("${log}" == 1)); then
            echo "Terminating running fan management processes..." | systemd-cat -t nvfan -p info
        else
            printf "${EXEC} Terminating running fan management processes...\n"
        fi

        while read -r pid ppid; do
            if [ "${pid}" -ne "$$" ] && [ ${ppid} -ne "$$" ]; then
                if (("${log}" == 1)); then
                    echo "Killing nvfan process [PID: ${pid}, PPID: ${ppid}]." | systemd-cat -t nvfan -p info
                else
                    printf "${KILL} Killing nvfan process [PID: ${pid}, PPID: ${ppid}].\n"
                fi
                kill ${pid}
            fi
        done <<< "${pids}"
    fi
}

#############################
# Resets the GPU management #
#############################
reset() {
    if (nvidia-settings -a [gpu:0]/GPUFanControlState=0 &>/dev/null); then
        if (("${log}" == 1)); then
            echo "Resetting GPU fan management: Success." | systemd-cat -t nvfan -p info
        else
            printf "${OK} Resetting GPU fan management: Success.\n"
        fi
        return 0
    else
        if (("${log}" == 1)); then
            echo "Resetting GPU fan management: Failed." | systemd-cat -t nvfan -p crit
        else
            printf "${ERROR} Resetting GPU fan management: Failed.\n"
        fi
        return 1
    fi
}

########################################
# Sets fan speed based on passed value #
########################################
setCustomSpeed() {
    temp=`nvidia-settings -q GPUCoreTemp -t | head -1`
    echo "${EXEC} [GPU: ${temp}°C] Setting GPU fan speed to $1%." | systemd-cat -t nvfan -p info
    nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$1" &> /dev/null
}

#########################################
# Sets fan speed based on preset values #
#########################################
startPresetController() {
    while :; do
        temp=`nvidia-settings -q GPUCoreTemp -t | head -1`

        i=0
        while [ "x${range[i]}" != "x" ]; do
            read lo hi <<<$(echo ${range[$i]})

            if [ $temp -ge $lo -a $temp -le $hi ]; then
                if (("${log}" == 1)); then
                    echo "[GPU: ${temp}°C] Setting Fan speed to ${speed[$i]}% using preset values." | systemd-cat -t nvfan -p info
                fi

                nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=${speed[$i]}" &> /dev/null
            fi

            i=$((i+1))
        done

        sleep $polltime
    done
}


#---------------------------------------------# Main # --------------------------------------------#
if checkGPU; then
    printf "${ERROR} NVIDIA Fan speed management is not supported on this GPU."
    exit 1
fi

#echo "Parent PID: $$"

while getopts "ahs:r" opt; do
    case $opt in
        a)  killProcesses
            printf "${EXEC} Starting auto fan speed based on presets...\n" >&2
            startPresetController &
            exit 0
            ;;
        h)  usage
            exit 0
            ;;
        s)  killProcesses
            if (($OPTARG > 100)); then
                printf "${ERROR} Speed must be between 0-100%%\n" >&2
                exit 1
            elif (($OPTARG >= 50)); then
                printf "${EXEC} Setting fan speed to $OPTARG%%\n" >&2
                setCustomSpeed $OPTARG
                exit 0
            elif (($OPTARG > 30)); then
                printf "${WARNING} Setting fan speed to $OPTARG%%\n" >&2
                setCustomSpeed $OPTARG
                exit 0
            elif (($OPTARG > 0)); then
                printf "${WARNING} Setting fan speed to $OPTARG%% ${RED}Danger!${RESET}\n" >&2
                setCustomSpeed $OPTARG
                exit 0
            elif (($OPTARG <= 0)) ; then
                printf "${WARNING} ${RED}Turning off the fan. Not recommended!${RESET}\n" >&2
                setCustomSpeed $OPTARG
                exit 0
            fi
            ;;
        r)  killProcesses
            reset
            exit $?
            ;;
        \?) printf "${ERROR} Invalid option: -$OPTARG\n" >&2
            exit 1
            ;;
        :)  printf "${ERROR} Option -$OPTARG requires an argument.\n" >&2
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))

usage
exit 0