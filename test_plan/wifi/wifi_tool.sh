#!/bin/sh
ssid="appolo"
password="Amluser88!!"
driver="dhd"
mode="station"
config_file="/test_plan/wifi/wifi_configure.txt"
driver_list="dhd ath10k_pci"
router_ip="192.168.168.1"
ping_period="4"
retry="1"
onoff_test="0"
s400_arg="firmware_path=/etc/wifi/fw_bcm43455c0_ag_apsta.bin nvram_path=/etc/wifi/nvram.txt"
s420_arg="firmware_path=/etc/wifi/fw_bcm4356a2_ag_apsta.bin nvram_path=/etc/wifi/nvram.txt"

NAME1=wpa_supplicant
DAEMON1=/usr/sbin/$NAME1
PIDFILE1=/var/run/$NAME1.pid

NAME2=hostapd
DAEMON2=/usr/sbin/$NAME2
PIDFILE2=/var/run/$NAME2.pid

NAME3=dnsmasq
DAEMON3=/usr/sbin/$NAME3
PIDFILE3=/var/run/$NAME3.pid

NAME4=dhcpcd
DAEMON4=/usr/sbin/$NAME4
PIDFILE4=/var/run/${NAME4}-wlan0.pid



############################################################################################
###############Function Zone################################################################
############################################################################################

function main() {

###########show usage first#####################
usage
###########initialize ssid passwd etc###########
initial_configure $1 $2 $3 $4 $5

#########stop wifi first#################
stop_wifi

########if want to disable wifi,should exit here#
if [ "$1" = "stop" ];then
echo "wifi function stopped!"
end_script
fi

if [ $onoff_test -eq 1 ]; then
##############wifi on/off loop begin#############
	wifi_onoff_loop
else
########start station or ap #####################
	start_wifi
    end_script
fi
}




function initial_configure() {
if [ -f $config_file ];then
########load from txt##################
echo "reading from txt...."
	while read line ; do
	key=`echo $line | awk -F "=" '{print $1}'`
	val=`echo $line | awk -F "=" '{print $2}'`
    case "$key" in
		ssid)
		ssid=$val
		;;
		password)
		password=$val
		;;
		driver)
		driver=$val
		;;
		mode)
		mode=$val
		;;
		debug)
		debug=$val
		;;
		ping_period)
		ping_period=$val
		;;
		retry)
		retry=$val
		;;
        onoff_test)
		onoff_test=$val
		;;
	esac
	done < $config_file
else
########load from input################
    echo "reading from input...."
	if [ $1 ]; then
	    ssid=$1
	fi
	if [ $2 ]; then
	    password=$2
	fi
	if [ $3 ]; then
	    driver=$3
	fi
	if [ $4 ]; then
	    mode=$4
	fi
	if [ "${5}" = "debug" ]; then
    	debug="1"
	fi
fi
echo "user set:
ssid=$ssid, key=$password, driver=$driver mode=$mode debug=$debug
4s to check your configure
"
if [ "`echo $password |wc -L`" -lt "8" ];then
echo "waring: password lentgh is less than 8, it is not fit for WPA-PSK"
fi

##########disable kernel printk##################
if [ ! $debug -eq 1 ]; then
	enable_printk 0
fi
}

function load_driver() {
if [ $1 = "0" ];then
	echo "removing driver if loaded"
	local cnt=1
	driver_num=`echo $driver_list | awk -F " " '{print NF+1}'`
	while [ $cnt -lt $driver_num ]; do
		loaded_driver=`echo $driver_list | awk -F " " '{print $'$cnt'}'`
		lsmod | grep $loaded_driver
		if [ $? -eq 0 ];then
			echo "loaded_driver=$loaded_driver"
			rmmod $loaded_driver
		fi
		cnt=$((cnt + 1))
	done
else
	echo "start driver loading..."
	if [ "$mode" == "ap" -o "$driver" == "dhd" ];then
		#sure s400 
		cat /proc/device-tree/amlogic-dt-id | grep "s400"
		if [ $? -eq 0 ]
		then
			modprobe $driver $s400_arg
		fi
		# sure s420
		cat /proc/device-tree/amlogic-dt-id | grep "s420"
		if [ $? -eq 0 ]
		then
			modprobe $driver $s420_arg
		fi
	else
		modprobe $driver
	fi
		
	if [ $? -eq 0 ]; then
		echo "dirver loaded"
	else
		echo "fail to load driver"
		end_script
	fi

	##########check wlan0############################
	echo "checking wlan0..."
	check_in_loop 10 check_wlan
	echo "wlan0 shows up
	"
fi
}

function stop_wifi_app() {
echo "Stopp prv wpa_supplicant first"
start-stop-daemon -K -o -p $PIDFILE1 2> /dev/null
sleep 1
echo "Stopp prv hostapd first"
start-stop-daemon -K -o -p $PIDFILE2 2> /dev/null
sleep 1
echo "Stopp prv dnsmasq first"
start-stop-daemon -K -o -p $PIDFILE3 2> /dev/null
sleep 1
echo "Stopp prv dhcpcd first"
start-stop-daemon -K -o -p $PIDFILE4 2> /dev/null
sleep 1
}

function usage() {
echo "
##################################################################
#usage:                                                          
#first choice:
#   write configure in /etc/wifi_configure.txt
#second choice:
#   $0  \"ssid\" \"key\" \"driver\" \"mode\"                             
#   example:$0 $ssid $password $driver $mode                               
#   dirver choice: dhd; ath10k. default to dhd     
#   version:1.4
##################################################################
"
} 


function enable_printk() {
if [ "${1}" = "1" ];then
	echo 7 > /proc/sys/kernel/printk
elif [ "${1}" = "0" ];then
	echo 1 > /proc/sys/kernel/printk
fi
}                                                               
        
function end_script() {
if [ ! $debug -eq 1 ];then
	enable_printk 1
fi
exit
}		
alias check_wlan="ifconfig wlan0 2> /dev/null"
alias check_wpa="wpa_cli ping 2> /dev/null | grep PONG"
alias check_ap_connect="wpa_cli status 2> /dev/null | grep state=COMPLETED"
alias check_hostapd="hostapd_cli status 2> /dev/null | grep state=ENABLED"
alias check_dnsmasq="ps | grep -v grep | grep dnsmasq > /dev/null"

function check_in_loop() {
local cnt=1
while [ $cnt -lt $1 ]; do
    echo "check_in_loop processing..."
    case "$2" in
        check_wlan)
        check_wlan
        ;;
        check_hostapd)
        check_hostapd
        ;;
        check_dnsmasq)
        check_dnsmasq
        ;;
        check_wpa)
        check_wpa
        ;;
        check_ap_connect)
        check_ap_connect
        ;;
    esac
    if [ $? -eq 0 ];then
        return
    else
        cnt=$((cnt + 1))
        sleep 1
        continue
    fi   
done
echo "fail!!"
end_script
}

function wifi_onoff_loop() {
echo "
#####################################################
#####begin to turn on/off wifi for $retry times
#####################################################
"
sleep 1
local cnt=0
while [ $cnt -lt $retry ]; do
	start_wifi
	sleep 2
	stop_wifi
	sleep 5
	cnt=$((cnt + 1))
	echo "wifi has been tuned on/off for $cnt times...
    "
done
echo "wifi on/off test passed!!"
end_script
}

function stop_wifi() {

echo "#########stoping wifi#####################"
#####stop wpa_supplicant hostapd dhcpcd dnsamas##
stop_wifi_app
#########remove all loaded wifi driver###########
load_driver 0
}

function start_wifi() {

echo "########starting wifi#####################"
###############load wifi driver##################
load_driver 1
#####stop wpa_supplicant hostapd dhcpcd dnsamas##

if [ "${mode}" = "station" ]; then
	start_sta
elif [ "${mode}" = "ap" ]; then
	start_ap
else
	echo "bad mode!"
	end_script
fi

}


#########start hostapd###################
function start_ap() {

#create hostapd configure
echo "starting hostapd..."
echo "interface=wlan0
driver=nl80211
ctrl_interface=/var/run/hostapd
ssid=${ssid}
channel=6
ieee80211n=1
hw_mode=g
ignore_broadcast_ssid=0"  > /etc/hostapd_temp.conf

if [ ! "${password}" = "NONE" ];then
    echo "
wpa=3
wpa_passphrase=${password}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP" >> /etc/hostapd_temp.conf
fi
if [ $debug -eq 1 ];then
    start-stop-daemon -S  -m -p $PIDFILE2  -x $DAEMON2 -- /etc/hostapd_temp.conf -B -P /var/run/hostapd.pid
else
    start-stop-daemon -S -b -m -p $PIDFILE2  -x $DAEMON2 -- /etc/hostapd_temp.conf
fi

check_in_loop 6 check_hostapd
echo "start hostpad successfully!!
"
##remove temp conf if debug is off##########
if [ ! $debug -eq 1 ];then
	rm /etc/hostapd_temp.conf
fi
###############start dnsmasq#################
echo "starting dnsmasq..."
ifconfig wlan0 192.168.2.1

start-stop-daemon -S -m -p $PIDFILE3 -b -x $DAEMON3  -- -iwlan0  --dhcp-option=3,192.168.2.1 --dhcp-range=192.168.2.50,192.168.2.200,12h -p100

check_in_loop 6 check_dnsmasq
echo "start dnsmasq successfully!!"
echo "ap is started!!"
end_script
}

############start wpa_supplicant##########
function start_sta() {
echo "starting wpa_supplicant..."
ifconfig wlan0 0.0.0.0

if [ $debug -eq 1 ];then
start-stop-daemon -S -m -p $PIDFILE1 -x $DAEMON1 -- -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf -d -B -P $PIDFILE1
else
start-stop-daemon -S -m -p $PIDFILE1 -b -x $DAEMON1 -- -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf 
fi
check_in_loop 10 check_wpa
echo "connecting ap ...."
id=`wpa_cli add_network | grep -v "interface"`
wpa_cli set_network $id ssid \"${ssid}\" > /dev/null
if [ "$password" = "NONE" ]; then
    wpa_cli set_network $id key_mgmt NONE
else
    wpa_cli set_network $id psk \"${password}\" > /dev/null
fi
wpa_cli select_network $id  > /dev/null
wpa_cli enable_network $id  > /dev/null

check_in_loop 10 check_ap_connect
echo "start wpa_supplicant successfully!!"

############start dhcp#######################
echo "starting dhcp..."
if [ $debug -eq 1 ];then
dhcpcd wlan0
else
dhcpcd wlan0 > /dev/null
fi
echo "ap connected!!"
ping_test
}

function ping_test() {
router_ip=`dhcpcd -U wlan0 2> /dev/null | grep routers | awk -F "=" '{print $2}' | sed "s/'//g"`
echo "
now going to ping router's ip: $router_ip for $ping_period seconds"
ping $router_ip -w $ping_period
if [ $? -eq 1 ];then
echo "ping fail!! please check"
else
echo "ping successfully"
fi
}
main $1 $2 $3 $4 $5
