#!/bin/sh

echo "--------- Running hook_pre_init.sh ---------------"
echo "     ----  initialize occupy.here  ----           "

PIRATEBOX_CONF=$1

. $PIRATEBOX_CONF

mkdir -p $SHARE_FOLDER/data
mkdir -p $SHARE_FOLDER/Shared/tmp
ln -s $SHARE_FOLDER/Shared $PIRATEBOX_FOLDER/occupy.here/public/uploads 


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
%pubring $SHARE_FOLDER/data/gpg.pub
%secring $SHARE_FOLDER/data/gpg.sec
%commit
EOF
        gpg --batch --gen-key $SHARE_FOLDER/data/gpg.conf
else
  echo "Skipping gpg config, because it already exists"
fi


echo "Exchanging www folder..."
mv    $WWW_FOLDER $PIRATEBOX_FOLDER/www_old
mkdir -p  $WWW_FOLDER
mv  $PIRATEBOX_FOLDER/www_old/library  $WWW_FOLDER 

chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/occupy.here -R


## Switch hostname and recreate redirect.html file
$PIRATEBOX_FOLDER/bin/install_piratebox.sh  $PIRATEBOX_CONF hostname occupy_here.lan

#Catch all redirect to switch to correct hostname
ln    $WWW_FOLDER/redirect.html $WWW_FOLDER/index.html
