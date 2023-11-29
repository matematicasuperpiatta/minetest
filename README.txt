-- INSTALL LIBRARIES --
LINUX
	sudo apt-get update
	sudo apt-get install lua5.1 luarocks -y
	sudo luarocks install luasocket
	sudo apt-get install git lsof python3-pip -y
	pip3 install jsonpickle sympy sockets requests tabulate openpyxl
	sudo apt-get install build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev
	libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev

WINDOWS
	follow instruction from
	https://github.com/minetest/minetest/blob/master/doc/compiling/windows.md

-- CREATE FOLDER --
CLIENT
	git clone https://github.com/matematicasuperpiatta/minetest.git ms_client
	cd ms_client
        git checkout feature-ticket
	cp minetest.conf.client minetest.conf
	cd lib/
	git clone https://github.com/minetest/irrlicht.git irrlichtmt
	cd irrlichtmt/
	git checkout 1.9.0mt8
	cd ../../
	python3 configure.py
SERVER
	git clone https://github.com/matematicasuperpiatta/minetest.git ms_server
	cd ms-server
	git checkout develop
	cp minetest.conf.ms minetest.conf
	cd lib/
	git clone https://github.com/minetest/irrlicht.git irrlichtmt/
	cd irrlichtmt/
	git checkout 1.9.0mt8
	cd ../../
	cd mods/
	git clone https://gitlab.com/leonardoguidoni/ms-shared.git ms/
	cd ms/raspberryjammod/
	git checkout develop
	git clone https://gitlab.com/stemblocks/ms-mcpipy.git ms_mcpipy/
	cd ms_mcpipy/
	git checkout develop
	mkdir ../../../../worlds
	cp -r MATEMATICA_SUPERPIATTA ../../../../worlds
	../../../../


-- COMPILING --
SERVER (only linux)
	-- from ms_server folder --
	cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE
	make -j 1
CLIENT
	LINUX
	-- from ms_client folder --
	cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=FALSE -DBUILD_CLIENT=TRUE
	make -j 1

	WINDOWS
	follow instruction from
	https://github.com/minetest/minetest/blob/master/doc/compiling/windows.md
	(You must choose the modality Debug / Release both from CMake and Visual Studio steps)

	ANDROID (from LINUX computer)
	download and install Android Studio
	-- from ms_client folder --
	extract content of
		https://drive.google.com/file/d/1D0xQlCgf9DXSiY64HLT2q6ReCVpZfC2c/view?usp=drive_link
	in ms-android/native/deps

	from Android Studio
	>File>Open and select ms_client/ms-android
	>Build/Build bundle(s) / APK(s)>Build APK(s)

	-- If you want make a release for App Store --
	in ms-android/build.gradle change raw
		project.ext.set("versionCode", 53)
	with a valid versionCode
	>Build>Generate signed boundle or APK
	choice Android App Boundle
	insert valid credentials*
	chose 'release'

	*Is a .jks file. When you obtain one, is common to save in .ssh folder
-- INSTALLING --
	LINUX - create an AppImage
	# From the same folder where ms_client has been created:
	mkdir ms_1.1.2_linux
	mkdir ms_1.1.2_linux/ms.AppDir
	cp ms_client -r ms_client_linux/ms.AppDir/ms
	cd ms_client_linux/ms.AppDir
	# Incolla i files presenti in https://drive.google.com/file/d/1dmMeoErokvFzyeqlfIFUj-ChvRW6aUoR/view?usp=sharing, https://drive.google.com/file/d/1dppAshkcpgApG1FrFzcVymcHDehzeIW1/view?usp=sharing, https://drive.google.com/file/d/1kOzQfFeadNg3B8XRycBNbIzezIA4oJhl/view?usp=sharing, https://drive.google.com/file/d/1uPiXlvpKFIQce4EiiNFpbm2ZxP657bj6/view?usp=sharing
	chmod +x AppRun
	chmod +x MatematicaSuperpiatta.desktop
	mkdir usr
	cd ms
	cp -rf bin builtin cache client clientmods doc fonts games locale misc mods po textures minetest.conf ../usr
	cd ..
	cp usr/misc/minetest-xorg-icon-128.png usr/icon.png
	echo "" > usr/debug.txt
	rm -rf ms
	cd ..
	ARCH=x86_64 appimagetool ms.AppDir




















