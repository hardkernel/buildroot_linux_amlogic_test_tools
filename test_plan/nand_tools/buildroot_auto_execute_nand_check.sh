#!/bin/sh
#chkconfig:2345 80 90
#description:auto reboot check nand test

#sleep 8 sec waiting for system ready
sleep 8
FLAG_FILE=/nand_tools/auto_execute_nand_test_tools
if [ -f ${FLAG_FILE} ]
then
    sh /nand_tools/Nand_test_tools.sh
fi
