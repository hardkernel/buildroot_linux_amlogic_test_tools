#!/bin/sh

RESULT_DIR=/test_log/cpu
RESULT_LOG=${RESULT_DIR}/cpu_hotplut.log

#cpu info check
CPU_COUNT=0
echo "**************************************"
echo "the current cpu status:"
while [ ${CPU_COUNT} -lt 4  ]
do
    on_off_check=`cat /sys/devices/system/cpu/cpu${CPU_COUNT}/online`
    echo "cpu${CPU_COUNT}: ${on_off_check}"
    let CPU_COUNT+=1
done
echo "**************************************"


mkdir -p ${RESULT_DIR}


echo "######## cpu hotplug #######"
echo "you want operation which cpu"
echo "cpu0  cpu1  cpu2  cpu3"
echo "###########################"

echo "please input which cpu: eg : 1"

read -t 30 CPU_NUMBER

cpu_value_all_handle()
{
	cpu_t1=`cat /sys/devices/system/cpu/cpu$1/online`
	cpu_t2=`cat /sys/devices/system/cpu/cpu$2/online`
	cpu_t3=`cat /sys/devices/system/cpu/cpu$3/online`
	
	let cpu_t1+=cpu_t2
	let cpu_t1+=cpu_t3
	if [ ${cpu_t1} -eq 0 ]
	then
		echo "cpu$1:0 cpu$2:0 cpu$3:0" >> ${RESULT_LOG}
		echo "you can't set cpu$4:0"   >> ${RESULT_LOG}
		sync
		cat ${RESULT_LOG}
		exit 0
	fi
}

case ${CPU_NUMBER} in
	0)
		cpu_value_all_handle 1 2 3 0
		;;
	1)
		cpu_value_all_handle 0 2 3 1
		;;
	2)
		cpu_value_all_handle 0 1 3 2
		;;
	3)
		cpu_value_all_handle 0 1 2 3
		;;
	*)
		;;
esac

echo "**********************"
echo "off   :   0"
echo "on    :   1"
echo "**********************"
echo "please input off or on: eg : 0"
read -t 30  CPU_ON_OFF

check_value()
{
    local_value=`cat /sys/devices/system/cpu/cpu$1`
	
}

#error check
on_off_value=`cat /sys/devices/system/cpu/cpu${CPU_NUMBER}/online`
echo "on value: ${on_off_value}"
if [ ${on_off_value} -eq  ${CPU_ON_OFF} ]
then
	echo "reset cpu${CPU_NUMBER} failure."
	echo "cpu${CPU_NUMBER} is ${on_off_value}, please reset your value."
    echo  "cpu_hotplug=failure" > ${RESULT_LOG}
else
	echo ${CPU_ON_OFF} > /sys/devices/system/cpu/cpu${CPU_NUMBER}/online
	if [ $? -ne 0 ]
	then
    	echo "cpu_hotplug=failure" >> ${RESULT_LOG}
	else
    	echo "cpu_hotplug=success" >> ${RESULT_LOG}
	fi
fi
cat ${RESULT_LOG}
