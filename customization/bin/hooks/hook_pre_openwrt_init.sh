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

#Patching path names on the live system to not 
#   run into obosolete pathes
sqlite3_bin=$(find  /usr -follow  -name sqlite3 | grep bin)
zip_bin=$(find  /usr -follow  -name zip | grep bin)
unzip_bin=$(find  /usr -follow  -name unzip | grep bin)

sed "s,'/usr/bin/sqlite3','$sqlite3_bin',g" -i $PIRATEBOX_FOLDER/occupy.here/config.php
sed "s,'/usr/bin/zip','$zip_bin',g" -i  $PIRATEBOX_FOLDER/occupy.here/config.php
sed "s,'/usr/bin/unzip','$unzip_bin',g" -i $PIRATEBOX_FOLDER/occupy.here/config.php

