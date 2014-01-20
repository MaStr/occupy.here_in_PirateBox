#!/bin/sh

echo "--------- Running hook_pre_init.sh ---------------"
echo "     ----  initialize occupy.here  ----           "

PIRATEBOX_CONF=$1

. $PIRATEBOX_CONF

mkdir -p $SHARE_FOLDER/data
mkdir -p $SHARE_FOLDER/Shared/tmp
ln -s $PIRATEBOX_FOLDER/Shared $PIRATEBOX_FOLDER/occupy.here/public/uploads 


MAC_ADDRESS=$(/sbin/ifconfig | grep 'eth0' | tr -s ' ' | cut -d ' ' -f5 | sed "s/://g")

if [ ! -e $SHARE_FOLDER/data/gpg.conf ] ; then
        echo
        echo "Generating GnuPG keys"
        echo "---------------------"
        cat >$SHARE_FOLDER/data/gpg.conf <<EOF
Key-Type: rsa
Key-Length: 2048
Name-Real: occupy.here
Name-Comment: $MAC_ADDRESS 
Name-Email: $MAC_ADDRESS@occupyhere.org
Expire-Date: 0
%pubring /usb/occupy.here/data/gpg.pub
%secring /usb/occupy.here/data/gpg.sec
%commit
EOF
        gpg --batch --gen-key $SHARE_FOLDER/data/gpg.conf
else
  echo "Skipping gpg config, because it already exists"
fi


echo "Exchanging www folder..."
mv    $WWW_FOLDER $PIRATEBOX_FOLDER/www_old
mkdir -p  $WWW_FOLDER
mv -v   $PIRATEBOX_FOLDER/www_old/library  $WWW_FOLDER 


## Switch hostname and recreate redirect.html file
$PIRATEBOX_FOLDER/bin/install_piratebox.sh  $PIRATEBOX_CONF hostname occupy.here

#Catch all redirect to switch to correct hostname
ln    $WWW_FOLDER/redirect.html $WWW_FOLDER/index.html