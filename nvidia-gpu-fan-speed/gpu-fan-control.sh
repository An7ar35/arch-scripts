#! /bin/bash
    
#----------------------------------------------------------------------
# Description: adaptive fan speed management for NVIDIA GPUs on Linux
# Author:  Artem S. Tashkinov
# Created at: Fri Jul 10 07:47:43 GMT 2015
# Edited by: An7ar35
# Edited at: Sat Sep 10 18:38 GMT 2016
# Computer: localhost.localdomain
#
# Copyright (c) 2015 Artem S. Tashkinov  All rights reserved.
#
#----------------------------------------------------------------------
    
polltime=2 # in seconds
    
range[0]="0 29"
dtemp[0]=0
range[1]="30 40"
dtemp[1]=50
range[2]="41 50"
dtemp[2]=70
range[3]="51 58"
dtemp[3]=85
range[4]="59 200"
dtemp[4]=100
    
trap ctrl_c INT
    
ctrl_c() {
        echo
        echo -n "Resetting GPU fan management: "
        nvidia-settings -a [gpu:0]/GPUFanControlState=0 &>/dev/null && echo "OK" || echo "Failed!"
        exit 0
}
    
result=`nvidia-settings -a [gpu:0]/GPUFanControlState=1 | grep "assigned value 1"`
test -z "$result" && echo "Fan speed management is not supported on this GPU. Exiting" && exit 1
    
while :; do
        temp=`nvidia-settings -q GPUCoreTemp -t | head -1`
    
        i=0
        while [ "x${range[i]}" != "x" ]; do
                read lo hi <<<$(echo ${range[$i]})
    
                if [ $temp -ge $lo -a $temp -le $hi ]; then
                        echo "GPU Temperature: ${temp}. Setting GPU fan speed to ${dtemp[$i]}%"
                        nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=${dtemp[$i]}" &> /dev/null
                fi
    
                i=$((i+1))
        done
    
        sleep $polltime
done
