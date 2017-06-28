#!/bin/sh

PROCESS="aplay"
DELAYS=3
TEST_CASE=8

taskkill()
{
	if [ $# -ne 2 ]; then
	  PID=`ps ax | grep $1 | awk '{if ($0 !~/grep/) {print $1}}'`
		#echo "PID=$PID"
		if [ -n "$PID" ]; then 
			kill -9 $PID >/dev/null 2>&1
                        return 0
		else
			return 1
		fi
	fi
	return 1
}

delay()
{
	local index=$1
	if [ $# -ne 2 ]; then
		while [ $index -gt 0 ]
		do
		   sleep 1
	           #index=$[ $index -1 ]
	           let index-=1
		   echo -n "."
		done
		echo "stop"
                echo ""
		return 0 			
	fi	
	return 1
}

pdm_in()
{
	local channel=8
	if [ $# -ne 1 ]; then
	#mount -t vfat  /dev/sda1 /mnt
	rm /mnt/pdm_in_dir -rf
	mkdir -p /mnt/pdm_in_dir
	echo "******************start PDM_IN test**************************"
	#set 8000 16000 44100 48000	
	ratelist="8000 16000 44100 48000"
	bitlist="S16_LE S24_LE S32_LE"
	
	while [ $channel -ge 2 ]
	do		
		for i in $ratelist
        	do	
			for j in $bitlist
			do
				echo "channel="$channel",rate="$i",bit=$j"	
				aplay -C -Dhw:0,3 -r $i -f $j -t wav -c $channel /mnt/pdm_in_dir/pdm_in_ch${channel}_r${i}_$j.wav &
				delay $DELAYS
				kill_task		
			done
		done
		let channel=channel/2	
	done			
	#umount /mnt
	echo "*********************stop PDM_IN test*************************"
	fi
}

tdm_in()
{
	local channel=8
	if [ $# -ne 1 ]; then
	#mount -t vfat  /dev/sda1 /mnt
	rm /mnt/tdm_in_dir -rf
	mkdir -p /mnt/tdm_in_dir
	echo ""
	echo ""
	echo ""
	echo "******************start TDM_IN test**************************"
	#set 8000 16000 44100 48000
    ratelist="8000 16000 44100 48000"                                                                                  
    bitlist="S16_LE S24_LE S32_LE"	
	while [ $channel -ge 2 ]
	do		
		for i in $ratelist
        	do	
			for j in $bitlist
			do	
				echo "channel="$channel",rate="$i",bit=$j"	
				aplay -C -Dhw:0,2 -r $i -f $j -t wav -c $channel /mnt/tdm_in_dir/tdm_in_ch${channel}_r${i}_$j.wav &
				delay $DELAYS
				kill_task
			done		
		done
		let channel=channel/2	
	done			
	#umount /mnt
	echo "*********************stop TDM_IN test*************************"
	fi
}

tdm_out()
{
	local channel=8
	if [ $# -ne 3 ]; then
	#mount -t vfat  /dev/sda1 /mnt
#	echo ""
#	echo ""
#	echo ""
#	echo "******************start TDM_OUT test**************************"
	#set 8000 16000 44100 48000 96000 192000 384000 
	#set S16_LE S24_LE S32_LE	
	ratelist="8000 16000 44100 48000"
	bitlist="S16_LE S24_LE S32_LE"
	
	while [ $channel -ge 2 ]
	do		
		for i in $ratelist
        	do	
			for j in $bitlist
			do
				echo "channel="$channel",rate="$i",bit=$j"	
				aplay -Dhw:0,2 /mnt/$1/$2_ch${channel}_r${i}_$j.wav &
				delay $DELAYS
				kill_task		
			done
		done
		let channel=channel/2	
	done			
	#umount /mnt
#	echo "*********************stop TDM_OUT test*************************"
	fi
}

tdm_in_tdm_out()
{
    echo ""                                                                
    echo ""                                                                
    echo ""                                                                
    echo "******************start TDM_IN_TDM_OUT test**************************" 
	tdm_out tdm_in_dir  tdm_in                                                                   
    echo "*********************stop TDM_IN_TDM_OUT test*************************"	
}

pdm_in_tdm_out()
{
    echo ""                                                                
	echo ""                                                                
	echo ""                                                                
	echo "******************start PDM_IN_TDM_OUT test**************************"
	tdm_out pdm_in_dir pdm_in                                                                          
	echo "*********************stop PDM_IN_TDM_OUT test*************************"	
}

line_in_line_out()
{
	local channel=2
	if [ $# -ne 2 ]; then
	#mount -t vfat  /dev/sda1 /mnt
	echo ""
	echo ""
	echo ""
	echo "******************start LINE_IN and LINE_OUT  test**************************"
	#set 8000 16000 44100 48000 96000 
	#set S16_LE S24_LE S32_LE	
	ratelist="8000 16000 44100 48000 96000"
	bitlist="S16_LE S24_LE S32_LE"
	
	while [ $channel -ge 2 ]
	do		
		for i in $ratelist
        	do	
			for j in $bitlist
			do
				echo "channel="$channel",rate="$i",bit=$j"	
				aplay -C -Dhw:0,2 -r $i -f $j -c 2 | aplay  -Dhw:0,2 &
				delay 10
				kill_task				
			done
		done
		let channel=channel/2	
	done			
	#umount /mnt
	echo "*********************stop LINE_IN and LINE_OUT test*************************"
	fi
}

spdif_in_spdif_out()
{
    echo ""                                                                      
    echo ""                                                                      
    echo ""                                                                      
    echo "******************start SPDIF_IN_SPDIF_OUT test**************************" 
	echo ""
	echo "(^_^)"
	echo ""
    echo "*********************stop SPDIF_IN_SPDIF_OUT test*************************"	
}


kill_task()
{
	while true
	do
		taskkill $PROCESS
		ret=$?
		if [ $ret -eq 1 ]; then
		break
		fi
	done
}

echo 0 > /proc/sys/kernel/printk
echo ""
echo "****************************************************"
echo "*     Amlogic A113 Platform Audio Case Test        *"
echo "****************************************************"
echo "*   tdm in test:                    [0]            *"
echo "*   pdm in test:                    [1]            *"
echo "*   tdm out test:                   [2]            *"
echo "*   tdm in and tdm out test:        [3]            *"
echo "*   pdm in and tdm out test:        [4]            *"
echo "*   line in and line out test:      [5]            *"
echo "*   spdif in and spdif out test:    [6]            *"
echo "****************************************************"

echo ""
echo -n  "choice your case:"
read TEST_CASE


case $TEST_CASE in
    "0")
        tdm_in
    ;;
    "1")
		pdm_in
    ;;
    "2")
	echo ""
	echo ""
	echo ""
        echo "******************start TDM_OUT test**************************" 
        tdm_out pcm_dir tdm_out
        echo "******************stop TDM_OUT test**************************" 
    ;;
    "3")
        tdm_in_tdm_out tdm_in_dir
    ;;
    "4")
        pdm_in_tdm_out pdm_in_dir
    ;;
    "5")
        line_in_line_out
    ;;
    "6")
        spdif_in_spdif_out
    ;;	
    *) echo "can't recognition this case" 
    ;;
esac

echo 7 > /proc/sys/kernel/printk
exit
