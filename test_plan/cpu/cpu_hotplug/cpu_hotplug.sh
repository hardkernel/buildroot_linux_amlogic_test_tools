#!/bin/sh

RESULT_DIR=/test_log/cpu
RESULT_LOG=${RESULT_DIR}/cpu_hotplut.log

mkdir -p ${RESULT_DIR}

echo "######## cpu hotplug #######"
echo "you want operation which cpu"
echo "cpu0  cpu1  cpu2  cpu3"
echo "###########################"

echo "please input which cpu: eg : 1"

read -t 30 CPU_NUMBER

echo "**********************"
echo "off   :   0"
echo "on    :   1"
echo "**********************"
echo "please input off or on: eg : 0"
read -t 30  CPU_ON_OFF

echo ${CPU_ON_OFF} /sys/devices/system/cpu/cpu${CPU_NUMBER}/online
if [ $? -ne 0 ]
then
    echo "cpu_hotplug=failure" >> ${RESULT_LOG}
else
    echo "cpu_hotplug=success" >> ${RESULT_LOG}
fi

cat ${RESULT_LOG}
