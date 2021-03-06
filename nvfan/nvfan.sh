#!/bin/bash
#--------------------------------------# Default Settings #----------------------------------------#
#---- DO NOT CHANGE THOSE SETTINGS. CUSTOM SETTINGS SHOULD BE CHANGED IN THE 'nvfan.conf' FILE ----#
#--------------------------------------------------------------------------------------------------#
readonly DEFAULT_LOG=0          # Logger flag. When 1, every call is logged to journalctl
readonly DEFAULT_REFRESH=2      # Number of seconds between updates
declare -a DEFAULT_RANGE        # DEFAULT_RANGE[i]: Temperature range 'i'
declare -a DEFAULT_SPEED        # DEFAULT_SPEED[i]: Speed of fans (%) on DEFAULT_RANGE 'i'
DEFAULT_RANGE=([0]="0 29" [1]="30 40" [2]="41 50" [3]="51 58" [4]="59 200")
DEFAULT_SPEED=([0]=0 [1]=50 [2]=70 [3]=85 [4]=100)
readonly -a DEFAULT_RANGE
readonly -a DEFAULT_SPEED

#------------------------------------------# Constants #-------------------------------------------#
readonly CONFIG_DIRECTORY="/home/$USER/.config/nvfan"
readonly CONFIG_FILE="nvfan.conf"

#----------------------------------------# Settings Vars #-----------------------------------------#
declare -i log
declare -i refresh
declare -a range
declare -a speed

#-------------------------------------------# Methods #--------------------------------------------#
########################
# Displays nvfan usage #
########################
usage () {
    echo "|================= NVIDIA GPU Fan Controller v1.0 ==================|"
    echo "|······· Made by An7ar35, 2017 · https://an7ar35.bitbucket.io ······|"
    echo "|===================================================================|"
    echo ""
    echo "  Description:"
    echo "    Script controlling the fan speed of an NVIDIA card based on"
    echo "    temperatures. Adapted from Artem S. Tashkinov's adaptive fan"
    echo "    speed management script."
    echo "  Usage:"
    echo "    nvfan [-a] [-h] [-k] [-s <% fan speed>]"
    echo "  Options:"
    echo "    -a  Start the automatic fan speed controller process based on "
    echo "        the presets (will kill old processes and reloads 'nvfan.conf'"
    echo "        if it was running previously)."
    echo "    -h  Usage help."
    echo "    -s  Manually set speed of fan <% fan speed>. Kills the auto fan"
    echo "        speed process."
    echo "    -t  Prints the current GPU temperature."
    echo "    -r  Kills the fan controller process and resets to NVIDIA's own"
    echo "        fan management.";
}


#########################################################
# Prints a message to console                           #
# @param $1 log level                                   #
#           - 0 = critical,                             #
#           - 1 = error,                                #
#           - 2 = warning,                              #
#           - 3 = info-exec,                            #
#           - 4 = info-ok,                              #
#           - 5 = info-kill                             #
# @param $2 message                                     #
#########################################################
printMsg() {
	case $1 in
        0) printf "\\033[0;31m[CRITICAL]\\033[0m %s\\n" "$2" >&2;;
		1) printf "\\033[0;31m[ERROR]\\033[0m %s\\n" "$2" >&2;;
		2) printf "\\033[1;33m[WARNING]\\033[0m %s\\n" "$2" >&2;;
		3) printf "\\033[0;32m(!)\\033[0m %s\\n" "$2";;
		4) printf "\\033[1;34m(!)\\033[0m %s\\n" "$2" >&2;;
		5) printf "\\033[1;33m(!)\\033[0m %s\\n" "$2" >&2;;
		*) printf "%s\\n" "$2" >&2;;
	esac
}

#########################################################
# Sends a message to journalctl                         #
# @param $1 log level                                   #
#           (0=critical, 1=error, 2=warning, 3+=info)   #
# @param $2 message                                     #
#########################################################
sendToLog() {
    case $1 in
        0) echo "$2" | systemd-cat -t nvfan -p crit;;
		1) echo "$2" | systemd-cat -t nvfan -p err;;
		2) echo "$2" | systemd-cat -t nvfan -p warning;;
		*) echo "$2" | systemd-cat -t nvfan -p info;;
	esac
}

#########################################################
# Logs a message                                        #
# @param $1 log level                                   #
#           (0=critical, 1=error, 2=warning, 3=info)    #
# @param $2 message                                     #
#########################################################
logMsg() {
    if [ "${log}" = 1 ]; then
        sendToLog "${@:1:2}"
    else
        printMsg "${@:1:2}"
    fi
}

#########################################################################
# Creates the default configuration file if 'nvfan.conf does not exist' #
#########################################################################
createDefaultConfigFile() {
    if [ ! -d "$CONFIG_DIRECTORY" ]; then
        mkdir -p "$CONFIG_DIRECTORY"
    fi

    if [ ! -d "$CONFIG_DIRECTORY/$CONFIG_FILE" ]; then
        config="${CONFIG_DIRECTORY}/${CONFIG_FILE}"
        printMsg 3 "Creating config file '${config}' with default values..."

        printf "Log=%s\\n" "$DEFAULT_LOG" >> "${config}"
        printf "Refresh=%s\\n" "$DEFAULT_REFRESH" >> "${config}"
        i=0
        while [ "${DEFAULT_RANGE[i]}" != "" ]; do
            read -r l h <<< "${DEFAULT_RANGE[$i]}"
            printf "Speed=%s [%s-%s]\\n" "${DEFAULT_SPEED[$i]}" "${l}" "${h}" >> "${config}"
            i=$((i+1))
        done
    fi
}

#####################################################
# Gets value of a key/value pair in the config text #
# @param $1 Key to find                             #
# @param $2 Key-Value pair text to search           #
# @return Value of key                              #
#####################################################
getValue() {
    line=$(grep "$1" <<< "$2")
    value=$(echo "${line}" | awk -F' ' '{print $2}')
    echo "${value}"
}

#################################
# Checks if var is number       #
# @param $1 Variable to check   #
# @return "true"/"false"        #
#################################
isNumber() {
    if echo "$1" | grep -E -q '^[0-9]+$'; then
        echo "true"
    else
        echo "false"
    fi
}

################################
# Loads the configuration file #
################################
loadConfigFile() {
    printMsg 3 "Loading '$CONFIG_DIRECTORY/$CONFIG_FILE'..."
    # Load config file + strip '[',']','"' and replace with nothing, strip '-' and replace with a space
    file_contents=$(awk -F= '{gsub(/"|\[|\]/,"",$2);gsub(/\-/," ",$2);print $1 " " $2}' "$CONFIG_DIRECTORY/$CONFIG_FILE")

    log_value=$( getValue "Log" "$file_contents")
    refresh_value=$( getValue "Refresh" "$file_contents")
    speed_values=$(grep "Speed" <<< "${file_contents}" | sed 's|Speed ||')

    # Check 'Log' value and assign
    if [ "$(isNumber "${log_value}")" = "true" ] && [ "${log_value}" -lt 2 ]; then
        log=${log_value}
    else
        log=${DEFAULT_LOG}
        logMsg 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): 'Log=${log_value}' - bad value, using default."
    fi

    #Check 'Refresh' value and assign
    if [ "$(isNumber "${refresh_value}")" = "true" ] && [ "${refresh_value}" -gt 0 ]; then
        refresh=${refresh_value}
    else
        refresh=${DEFAULT_REFRESH}
        logMsg 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): 'Refresh=${refresh_value}' - bad value, using default."
    fi

    error_flag=false
    #Check 'Speed' values and their associated temperature range and assign to local arrays
    while read -r line; do
        read -r s l h <<< "${line}"
        if [ "$(isNumber "${s}")" = "true" ] && [ "$(isNumber "${l}")" = "true" ] && [ "$(isNumber "${h}")" = "true" ]; then
            if [ "${l}" -lt "${h}" ]; then
                speed+=("$s")
                range+=("$l $h")
            else
                error_flag=true
                logMsg 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): [BAD] $s : $l to $h -> low temp is >= to high temp."
            fi
        else
            error_flag=true
            logMsg 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): [BAD] $s : $l to $h -> invalid value(s)."
        fi
    done <<< "${speed_values}"

    #Check error flag and load up default values for speed/range
    if [ "$error_flag" = true ]; then
        speed=()
        range=()
        sendToLog 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): Found problem(s) with Speed-Temp value(s) in config file. Fallen back on defaults."
        printMsg 1 "Config file ($CONFIG_DIRECTORY/$CONFIG_FILE): Found problem(s) with Speed-Temp value(s) in config file. Fallen back on defaults."
        i=0
        while [ "${DEFAULT_RANGE[i]}" != "" ]; do
            read -r s <<< "${DEFAULT_SPEED[$i]}"
            read -r l h <<< "${DEFAULT_RANGE[$i]}"
            speed+=("$s")
            range+=("$l $h")
            i=$((i+1))
        done
    else
        logMsg 4 "Speed-Temp.Range values successfully loaded from 'nvfan.conf'"
    fi
}

#####################################
# Checks config file exists         #
# @return 0 (not found), 1 (exists) #
#####################################
checkConfigFile() {
    if [ -d "$CONFIG_DIRECTORY" ] && [ -e "$CONFIG_DIRECTORY/$CONFIG_FILE" ]; then
        echo "true"
    else
        echo "false"
    fi
}

############################################################
# Checks that fan speed management is supported on the GPU #
# @return 0 (not supported), 1 (supported)
############################################################
checkGPU() {
    result='nvidia-settings -a [gpu:0]/GPUFanControlState=1 | grep "assigned value 1"'
    test -z "$result" && logMsg 1 "NVIDIA Fan speed management is not supported on this GPU." && return 0
    return 1
}

##################################################################
# Kills all 'nvfan' running processes that are not this instance #
##################################################################
killProcesses() {
    pids=$(/bin/ps -fu "${USER}" | awk '/nvfan/ && /-a/ && !/awk/ && !/grep/ {print $2 " " $3}')

    if [ "${#pids}" -gt 0 ]; then #Proceses to kill?
        printMsg 3 "Terminating running fan management processes..."

        while read -r pid ppid; do
            if [ "${pid}" -ne "$$" ] && [ "${ppid}" -ne "$$" ]; then #if not this instance (pid) or spawned by it (ppid)
                printMsg 5 "Killing nvfan process [PID: ${pid}, PPID: ${ppid}]."
                kill "${pid}"
            fi
        done <<< "${pids}"
    fi
}

#############################################
# Resets to NVIDIA's own GPU fan management #
#############################################
reset() {
    if (nvidia-settings -a [gpu:0]/GPUFanControlState=0 &>/dev/null); then
        logMsg 4 "Resetting GPU fan management: Success."
        return 0
    else
        logMsg 1 "Resetting GPU fan management: Failed."
        return 1
    fi
}

#####################################
# Sets fan speed                    #
# @param $1 Fan speed value in %    #
#####################################
setCustomSpeed() {
    temp=$(nvidia-settings -q GPUCoreTemp -t | head -1)
    logMsg 3 "[GPU: ${temp}°C] Setting GPU fan speed to $1%%."
    nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$1" &> /dev/null
}

#########################################
# Sets fan speed based on preset values #
#########################################
startPresetController() {
    while :; do
        temp=$(nvidia-settings -q GPUCoreTemp -t | head -1)

        i=0
        while [ "${range[i]}" != "" ]; do
            read -r l h <<< "${range[$i]}"

            if [ "$temp" -ge "$l" ] && [ "$temp" -le "$h" ]; then

                if (("${log}" == 1)); then
                    sendToLog 3 "[GPU: ${temp}°C] Setting Fan speed to ${speed[$i]}% using preset values."
                fi

                nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=${speed[$i]}" &> /dev/null
            fi

            i=$((i+1))
        done

        sleep ${refresh}
    done
}

###################################################
# Prints the current GPU temperature in degrees C #
###################################################
printCurrentTemperature() {
    printf "(-) GPU: %s°C\\n" "$(nvidia-settings -q GPUCoreTemp -t | head -1)"
}

#---------------------------------------------# Main # --------------------------------------------#
if checkGPU; then
    printMsg 1 "NVIDIA Fan speed management is not supported on this GPU."
    exit 1
fi

#echo "Current nvfan PID: $$"

while getopts "ahs:tr" opt; do
    case $opt in
        a)  killProcesses
            if [ "$(checkConfigFile)" = "false" ]; then
                createDefaultConfigFile
            fi
            loadConfigFile
            printMsg 3 "Starting auto fan speed based on presets..."
            startPresetController &
            exit 0
            ;;
        h)  usage
            exit 0
            ;;
        s)  killProcesses
            if ((OPTARG > 100)); then
                printMsg 1 "Speed must be between 0-100%%"
                exit 1
            elif ((OPTARG >= 50)); then
                printMsg 3 "Setting fan speed to $OPTARG%%"
                setCustomSpeed "$OPTARG"
                exit 0
            elif ((OPTARG > 30)); then
                printMsg 2 "Setting fan speed to $OPTARG%%"
                setCustomSpeed "$OPTARG"
                exit 0
            elif ((OPTARG > 0)); then
                printMsg 2 "Setting fan speed to $OPTARG%% ${RED}Danger!${RESET}"
                setCustomSpeed "$OPTARG"
                exit 0
            elif ((OPTARG <= 0)) ; then
                printMsg 2 "${RED}Turning off the fan. Not recommended!${RESET}"
                setCustomSpeed "$OPTARG"
                exit 0
            fi
            ;;
        t)  printCurrentTemperature
            exit 0
            ;;
        r)  killProcesses
            reset
            exit $?
            ;;
        \?) printMsg 1 "Invalid option: $OPTARG"
            exit 1
            ;;
        :)  printMsg 1 "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

usage
exit 0
