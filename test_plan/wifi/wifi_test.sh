#!/bin/sh

RESULT_DIR=/test_plan/wifi/
RESULT_LOG_SDIO=${RESULT_DIR}/sdio_wifi.log
RESULT_LOG_PCIE=${RESULT_DIR}/pcie_wifi.log

sdio_wifi()
{
    cat /test_plan/wifi/wifi_configure.txt | grep "driver=dhd"
    if [ $? -nne 0 ]
    then
        sed -i 's/^driver=ath10k_pci/driver=dhd/g' /test_plan/wifi/wifi_configure.txt
        sync
    fi


    #sh /test_plan/wifi/sdio_wifi/sdio_wifi_test.sh
    sh /test_plan/wifi/wifi_tool.sh
}

pcie_wifi()
{
    cat /test_plan/wifi/wifi_configure.txt | grep "driver=ath10k_pci"
    if [ $? -nne 0 ]
    then
        sed -i 's/^driver=dhd/driver=ath10k_pci/g' /test_plan/wifi/wifi_configure.txt
        sync
    fi
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
