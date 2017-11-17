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

ddr_window_test_lede()
{
        ###############################
        echo "ddr window test start..."
        ###############################
        DDR_WINDOW_DIR=/test_plan/ddr/ddr_window
        kernel_version=$(uname -a | awk '{print $3}')
        ddr_window_path=/lib/modules/${kernel_version}/ddr_window.ko
        echo "kernel: ${kernel_version}"
        echo "ddr window path: ${ddr_window_path}"
        insmod ${ddr_window_path}
        if [ $? -ne 0 ]
        then
                echo "insmod ddr_window.ko failure"
                exit 1
        fi
        ${DDR_WINDOW_DIR}/memcpy_test -f &
        if [ $? -ne 0 ]
        then
                echo "FAILURE: memcpy_test aplication start error."
                exit 1
        fi
        ${DDR_WINDOW_DIR}/ddr_window -f &
        if [ $? -ne 0 ]
        then
                echo "FAILURE: ddr window aplication start error."
                exit 1
        fi

}

platform_handle()
{
	build_env=$(uname -a | awk '{print $2}')
	case ${build_env} in
	  "LEDE")
		ddr_window_test_lede
		;;
	  "buildroot")
		resource_ready
		;;
	esac
}

case ${cast} in
	1)
	platform_handle
	;;
	2)
	resource_copy
	;;
esac