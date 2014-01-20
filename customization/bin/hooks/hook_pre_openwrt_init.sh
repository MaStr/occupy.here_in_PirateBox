#!/bin/sh

echo "------- Running hook_pre_openwrt_init.sh -------"
echo "    ---       initilize occupy.here      ---    "

PIRATEBOX_CONF=$1

. $PIRATEBOX_CONF


# Load configuration
. /etc/ext.config
. $ext_linktarget/etc/piratebox.config

# Load function libraries
. $ext_linktarget/usr/share/piratebox/piratebox.common

MAC_ADDRESS=$(/sbin/ifconfig | grep 'eth0' | tr -s ' ' | cut -d ' ' -f5 | sed "s/://g")


echo "${initscript}: Fixing timezone in php config..."
sed 's|;date.timezone =|date.timezone = UTC|' -i  $ext_linktarget/etc/php.ini


pb_setSSID "$pb_wireless_ssid  $MAC_ADDRESS"
uci commit

