#!/bin/sh

RESULT_DIR=/test_plan/wifi/
RESULT_LOG_SDIO=${RESULT_DIR}/sdio_wifi.log
RESULT_LOG_PCIE=${RESULT_DIR}/pcie_wifi.log


error_handle()
{
    echo "not fount your choice wifi mode: ${WIFI_MODE}"
}

change_config_data()
{
    cat /test_plan/wifi/wifi_configure.txt | grep "$1=$2"
    if [ $? -ne 0 ]
    then
        sed -i "s/$1=$3/$1=$2/g" /test_plan/wifi/wifi_configure.txt
        sync
    fi
}

change_wifi_mode()
{
    change_config_data $1 $2 $3 
}

wifi_mode()
{
    echo "*****************************"
    echo " select wifi mode."
    echo "station mode:         1"
    echo "ap mode:              2"
    echo "*****************************"
    read -t 30 WIFI_MODE_CHOICE

    case ${WIFI_MODE_CHOICE} in
        1)
            change_wifi_mode mode station ap
            ;;
        2)
            change_wifi_mode mode ap station
            ;;
        *)
            error_handle
            ;;
    esac
}


pcie_wifi()
{
    change_wifi_mode driver ath10k_pci dhd
    wifi_mode
    
    #sh /test_plan/wifi/pcie_wifi/pcie_wifi_test.sh
    sh /test_plan/wifi/wifi_tool.sh
}

sdio_wifi()
{
    change_wifi_mode  driver dhd  ath10k_pci
    wifi_mode
    
    #sh /test_plan/wifi/pcie_wifi/pcie_wifi_test.sh
    sh /test_plan/wifi/wifi_tool.sh
}

wifi_test()
{
    echo "*****************************"
    echo "**                         **"
    echo "**      WIFI TEST          **"
    echo "**                         **"
    echo "*****************************"

    echo "*****************************"
    echo "input sdio wifi or pcie wifi"
    echo "SDIO WIFI:                1"
    echo "PCIE WIFI:                2"

    read -t 30 WIFI_CHOICE
    case ${WIFI_CHOICE} in
        1)
            sdio_wifi
            ;;
        2)
            pcie_wifi
            ;;
        *)
            echo "not found wifi module."
            ;;
    esac
}

wifi_test
