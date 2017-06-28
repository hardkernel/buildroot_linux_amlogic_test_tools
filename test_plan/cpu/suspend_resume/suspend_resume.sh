#!/bin/sh

RESULT_DIR=/test_log/cpu
RESULT_LOG=${RESULT_DIR}/suspend_resume.log

mkdir -p ${RESULT_DIR}

echo mem >  /sys/power/state
if [  $? -ne 0 ]
then
    echo "suspend_resume=failure" >> ${RESULT_LOG}
else
    echo "suspend_resume=failure" >> ${RESULT_LOG}
fi
