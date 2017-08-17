#!/bin/sh

function resource_ready()
{
	mkdir /sdcard
	cp /test_plan/ddr/ddr_window/S95ddrtest /etc/init.d/
	chmod 777 /etc/init.d/S95ddrtest
	sync
	reboot -f
}

function resource_copy()
{
	ls /dev/sda1
	if [ $? -eq 0 ]
	then
		mount /dev/sda1 /mnt
	else
		mount /dev/sda /mnt
	fi
	
	cd /mnt
	echo "Please input the No. of platform"
	read platform
	mkdir ddr_windows_results_$platform
	
	echo "CP start!!"
	cp /sdcard/ddr_window_* /mnt/ddr_windows_results_$platform/
	echo "CP sync!!"
	sync
	echo "sync stop!!"
}

echo "A113 DDR Windows Test,Please input the numbers:
			1,Start DDR_Windows
			2.CP the DDR_windows result"

read cast;

case ${cast} in
	1)
	resource_ready
	;;
	2)
	resource_copy
	;;
esac