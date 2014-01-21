NAME = occupy.here
VERSION = r7
BUILD_VERSION=1.0.1

SRC_OCCUPY=./src_occupy.here
SRC_DL_FILE=src_occupy.here.zip
SRC_URL=https://github.com/occupyhere/occupy.here/archive/$(VERSION).zip
#SRC_MD5SUM=rrrrrrr

PIRATEBOX_IMG_URL="http://piratebox.aod-rpg.de/piratebox_ws_1.0_img.gz"
PIRATEBOX_IMG_GZ=piratebox_ws_1.0_img.gz
MOD_IMAGE=image_file.img
#--------
MOD_IMAGE_TGZ=occupyhere_1.0_img.tar.gz
#--------
IMAGE_BUILD_TGT=image_mnt
CUSTOMIZATION_FOLDER=customization
OCCUPY_TGT_FOLDER=$(CUSTOMIZATION_FOLDER)/occupy.here

PATCH_FOLDER=patches

MOD_VERSION_TAG=$(CUSTOMIZATION_FOLDER)/occupy.here_version


clean: 
	- rm -v $(MOD_VERSION_TAG)
	- rm -vr $(OCCUPY_TGT_FOLDER) 
	- rm $(MOD_IMAGE_TGZ)
	- rm $(MOD_IMAGE)

cleanall: clean
	- rm -rv $(SRC_OCCUPY)
	- rm -v $(SRC_DL_FILE)
	- rm -v piratebox_ws_1.0_img.gz
	- rm -rv $(IMAGE_BUILD_TGT) 

$(PIRATEBOX_IMG_GZ):
	wget -c $(PIRATEBOX_IMG_URL) -O $@

$(SRC_DL_FILE):
	wget -c $(SRC_URL) -O $@

$(SRC_OCCUPY): $(SRC_DL_FILE)
	unzip $(SRC_DL_FILE)
	mv occupy.here-$(VERSION) $@


$(IMAGE_BUILD_TGT):
	mkdir -p $@
	
$(MOD_IMAGE): $(PIRATEBOX_IMG_GZ)
	gunzip $(PIRATEBOX_IMG_GZ) -c > $@


$(MOD_IMAGE_TGZ): $(IMAGE_BUILD_TGT) customize_occupyhere  $(MOD_IMAGE) $(MOD_VERSION_TAG)
	echo "#### Mounting image-file"
	sudo  mount -o loop,rw,sync   $(MOD_IMAGE)   $(IMAGE_BUILD_TGT)
	echo "#### Copy Modifications to image file"
	sudo   cp -vr $(CUSTOMIZATION_FOLDER)/*   $(IMAGE_BUILD_TGT)
	sudo patch -t -i $(PATCH_FOLDER)/lighttpd.1.patch $(IMAGE_BUILD_TGT)/conf/lighttpd/lighttpd.conf
	sudo patch -t -i $(PATCH_FOLDER)/lighttpd.2.patch $(IMAGE_BUILD_TGT)/conf/lighttpd/lighttpd.conf
	sudo patch -t -i $(PATCH_FOLDER)/piratebox.conf.1.patch $(IMAGE_BUILD_TGT)/conf/piratebox.conf 
	sudo patch -t -i $(PATCH_FOLDER)/piratebox.conf.2.patch $(IMAGE_BUILD_TGT)/conf/piratebox.conf 
	sudo patch -t -i $(PATCH_FOLDER)/init.d_piratebox_alt.1.patch $(IMAGE_BUILD_TGT)/init.d/piratebox_alt
	##
	sudo umount  $(IMAGE_BUILD_TGT)
	tar czf  $(MOD_IMAGE_TGZ)  $(MOD_IMAGE)

$(MOD_VERSION_TAG): 
	echo  "$(NAME) - $(VERSION)"   > $@
	echo  "  modded with Version $(BUILD_VERSION)" >> $@


$(OCCUPY_TGT_FOLDER): $(SRC_OCCUPY)
	mkdir -p $@
	cp -rv $(SRC_OCCUPY)/app $@
	cp -rv $(SRC_OCCUPY)/config-example.php $@
	cp -rv $(SRC_OCCUPY)/init.php $@
	cp -rv $(SRC_OCCUPY)/bootstrap/step6/config.php $@
	cp -rv $(SRC_OCCUPY)/data $@
	cp -rv $(SRC_OCCUPY)/library $@
	cp -rv $(SRC_OCCUPY)/public $@
	cp -rv $(SRC_OCCUPY)/import $@
	find ./$@ -name .svn | xargs -I {} rm -rv {}

customize_occupyhere: $(OCCUPY_TGT_FOLDER)
	# This folder will be exchanged with a link to usb stick
	- rm -r $(OCCUPY_TGT_FOLDER)/public/uploads
	patch -t -i $(PATCH_FOLDER)/config.php.1.patch  $(OCCUPY_TGT_FOLDER)/config.php
	patch -t -i $(PATCH_FOLDER)/config.php.2.patch  $(OCCUPY_TGT_FOLDER)/config.php

shortimage: $(MOD_IMAGE_TGZ)


#.DEFAULT_GOAL: shortimage
#.PHONY: shortimage clean cleanall
