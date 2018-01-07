#!/bin/bash
#-------------------------------------------# Methods #--------------------------------------------#
############################
# Displays coreboost usage #
############################
printUsage () {
    echo "|========================== CoreBoost v1.1 =========================|"
    echo "|······· Made by An7ar35, 2018 · https://an7ar35.bitbucket.io ······|"
    echo "|===================================================================|"
    echo ""
    echo "  Description:"
    echo "    Script to enable/disable Turbo Boost in Intel CPUs."
    echo "  Usage:"
    echo "    coreboost [-e] [-d]"
    echo "  Options:"
    echo "    -e  Enable Turbo Boost"
    echo "    -d  Disable Turbo Boost"
    echo "    -h  Usage help."
    echo "    -s  Prints the TurboBoost status of all the cores."
}

##############################################
# Prints the TurboBoost status for all cores #
##############################################
printCoreStatus() {
    cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
    echo "TurboBoost status:"
    for core in ${cores}; do
        state=$(sudo rdmsr -p${core} 0x1a0 -f 38:38)
        if [[ $state -eq 1 ]]; then
            echo "Core $1: disabled."
        else
            echo "Core $1: enabled."
        fi
    done
}

#############################
# Turns on/off turbo boost  #
# @param $1 1=on;           #
#           0=off           #
#############################
switchTurboBoost() {
    cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')

    enabled_count=0;
    disabled_count=0;
    core_count=0;

    for core in ${cores}; do
        ((core_count++))

        if [ $1 -eq 0 ]; then
            sudo wrmsr -p${core} 0x1a0 0x4000850089
        else
            sudo wrmsr -p${core} 0x1a0 0x850089
        fi

        state=$(sudo rdmsr -p${core} 0x1a0 -f 38:38)
        if [[ $state -eq 1 ]]; then
            ((enabled_count++))
        else
            ((disabled_count++))
        fi
    done

    if [ $1 -eq 0 ]; then
        echo "CPU turbo boost disabled on ${disabled_count}/${core_count} cores." | systemd-cat -t coreboost -p info
    else
        echo "CPU turbo boost enabled on ${enabled_count}/${core_count} cores." | systemd-cat -t coreboost -p info
    fi
}



#---------------------------------------------# Main # --------------------------------------------#
sudo modprobe msr
if [[ -z $(which rdmsr) ]]; then
    echo "Cannot run. 'msr-tools' is missing." | systemd-cat -t coreboost -p info
    echo "'msr-tools' is missing."
    exit 1
fi

while getopts "dehs" opt; do
    case $opt in
        d)  switchTurboBoost 0
            exit 0
            ;;
        e)  switchTurboBoost 1
            exit 0
            ;;
        h)  printUsage
            exit 0
            ;;
        s)  printCoreStatus
            exit 0
            ;;
        \?) printMsg 1 "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)  printMsg 1 "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))

printUsage
exit 0