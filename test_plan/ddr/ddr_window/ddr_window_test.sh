#!/bin/sh

###############################
echo "ddr window test start..."

###############################
DDR_WINDOW_DIR=/test_plan/ddr/ddr_window

insmod ${DDR_WINDOW_DIR}/ddr_window.ko
if [ $? -ne 0 ]
then
	echo "insmod ddr_window.ko failure"
	exit 1
fi

${DDR_WINDOW_DIR}/ddr_window -f &
if [ $? -ne 0 ]
then
	echo "FAILURE: ddr window aplication start error."
	exit 1
fi
