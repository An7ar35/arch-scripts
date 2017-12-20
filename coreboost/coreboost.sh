#!/bin/bash
modprobe msr
cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
disabled_counter=0;
core_count=0;
for core in $cores; do
    ((core_count++))
    wrmsr -p${core} 0x1a0 0x4000850089
    state=$(rdmsr -p${core} 0x1a0 -f 38:38)
    if [[ $state -eq 1 ]]; then
        ((disabled_counter++))
    fi
done

echo "CPU Turbo boost disabled on ${disabled_counter}/${core_count} cores." | systemd-cat -t CoreBoost -p info
