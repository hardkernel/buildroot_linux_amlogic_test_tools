#!/bin/sh

echo "*****************************************"
echo "***                                   ***"
echo "***         IR TEST                   ***"
echo "***                                   ***"
echo "*****************************************"

/test_plan/ir/irsend -lc 0xe21dfb04 -t 800000
if [ $? -ne 0 ]
then
    echo "ir test error."
fi
