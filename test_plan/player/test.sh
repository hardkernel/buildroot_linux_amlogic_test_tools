#!/bin/sh

#Run cpu a53
/test_plan/player/cpuburn-a53 &

#Change cpu freq
/test_plan/player/cpu_freq_v1_0.sh & 

mount /dev/sda1 /mnt

info()
{
	if [ $? -neq 0 ]; then
		echo "play $3 wrong"
	else
		echo "play $3 OK"
	fi
}

while :
do
	aplay -D plug:2to8 /mnt/Hello.wav
	info

	aplay -D hw:0,2 /mnt/8ch_full.wav
	info	

	alsaplayer -d plug:2to8 /mnt/Hello.wav
	info

	alsaplayer -d plug:2to8 /mnt/Hello.mp3
	info

	alsaplayer -d plug:2to8 /mnt/Hello.flac
	info

	alsaplayer -d plug:2to8 /mnt/Hello.ogg
	info
done
